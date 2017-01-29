//
//  MadGeometry.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/22/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

internal var GeosContext: OpaquePointer = {
    return GEOS_init_r()
}()

internal struct GeosGeometryPointer {
    let ptr: OpaquePointer
    weak var owner: MadGeometry?
}

public class MadGeometryFactory {

    fileprivate static func typeFromPtr(ptr: OpaquePointer?) -> MadGeometryType {
        if let ptr = ptr {
            let geometryType = GEOSGeomTypeId_r(GeosContext, ptr)
            if let type = MadGeometryType(rawValue: Int(geometryType)) {
                return type
            }
        }
        return .unknown
    }
    
    fileprivate static func madGeometry(geometryPtr: OpaquePointer?) -> MadGeometry? {
        if let geometryPtr = geometryPtr {
            let ggp = GeosGeometryPointer(ptr: geometryPtr, owner: nil)
            switch typeFromPtr(ptr: geometryPtr) {
            case .point:
                return MadPoint(ggp)
            case .lineString:
                return MadLineString(ggp)
            case .linearRing:
                return MadLinearRing(ggp)
            case .polygon:
                return MadPolygon(ggp)
            case .multiPoint:
                return MadMultiPoint(ggp)
            case .multiLineString:
                return MadMultiLineString(ggp)
            case .multiPolygon:
                return MadMultiPolygon(ggp)
            case .geometryCollection:
                return MadMultiGeometry(ggp)
            default:
                GEOSGeom_destroy_r(GeosContext, geometryPtr)
                return nil
            }
        }
        return nil
    }
    
    public static func geometryFromWellKnownText(_ wkt: String) -> MadGeometry? {
        let wktReaderPtr = GEOSWKTReader_create_r(GeosContext)
        let geomPtr = GEOSWKTReader_read_r(GeosContext, wktReaderPtr, wkt)
        GEOSWKTReader_destroy_r(GeosContext, wktReaderPtr)
        return madGeometry(geometryPtr: geomPtr)
    }
    
    public static func geometryFromWellKnownBinary(_ wkb: Data) -> MadGeometry? {
        let wkbReaderPtr = GEOSWKBReader_create_r(GeosContext)
        let geomPtr = GEOSWKBReader_read_r(GeosContext, wkbReaderPtr, [UInt8](wkb), 0)
        GEOSWKBReader_destroy_r(GeosContext, wkbReaderPtr)
        return madGeometry(geometryPtr: geomPtr)
    }
}

public class MadGeometry {
    
    internal let geometryPtr: GeosGeometryPointer
    fileprivate var wkt: String?
    fileprivate var wkb: Data?
    
    internal init(_ ptr: GeosGeometryPointer) {
        geometryPtr = ptr
    }
    
    public func covers(other: MadGeometry) -> Bool {
        return GEOSCovers(geometryPtr.ptr, other.geometryPtr.ptr) == CChar("1")
    }

    public func intersection(other: MadGeometry) -> MadGeometry? {
        guard let ptr = GEOSIntersection_r(GeosContext, geometryPtr.ptr, other.geometryPtr.ptr) else {
            return nil
        }
        return MadGeometryFactory.madGeometry(geometryPtr: ptr)
    }
    
    public func intersects(other: MadGeometry) -> Bool {
        return GEOSIntersects(geometryPtr.ptr, other.geometryPtr.ptr) == CChar("1")
    }
    
    public func empty() -> Bool {
        return GEOSisEmpty_r(GeosContext, geometryPtr.ptr) == CChar("1")
    }
    
    public func wellKnownText() -> String? {
        if let text = wkt {
            return text
        }
        let wktWriter = GEOSWKTWriter_create_r(GeosContext)
        let wktData = GEOSWKTWriter_write_r(GeosContext, wktWriter, geometryPtr.ptr)
        GEOSWKTWriter_destroy_r(GeosContext, wktWriter)
        if let wktData = wktData {
            wkt = String(cString: wktData)
            GEOSFree_r(GeosContext, wktData)
        }
        return wkt
    }
    
    public func wellKnownBinary() -> Data? {
        if let bin = wkb {
            return bin
        }
        let wkbWriter = GEOSWKBWriter_create_r(GeosContext)
        var size :Int = 0
        let wkbData = GEOSWKBWriter_write_r(GeosContext, wkbWriter, geometryPtr.ptr, &size)
        GEOSWKBWriter_destroy_r(GeosContext, wkbWriter)
        if let wkbData = wkbData {
            wkb = Data(bytes: wkbData, count: size)
            GEOSFree_r(GeosContext, wkbData)
        }
        return wkb
    }
    
    public func geometryType() -> MadGeometryType {
        return MadGeometryFactory.typeFromPtr(ptr: geometryPtr.ptr)
    }
    
    public func coordinateSequence() -> MadCoordinateSequence? {
        guard let seq = GEOSGeom_getCoordSeq_r(GeosContext, geometryPtr.ptr) else {
            return nil
        }
        return MadCoordinateSequence(seq)
    }

    public func coordinates() -> [MadCoordinate] {
        guard let seq = coordinateSequence() else {
            return [MadCoordinate]()
        }

        return [MadCoordinate](seq)
    }
    
    public func transform(_ t: MadCoordinateTransform) -> Self? {
        fatalError("abstract")
    }
    
    deinit {
        if geometryPtr.owner != nil {
            GEOSGeom_destroy_r(GeosContext, geometryPtr.ptr)
        }
    }
    
}
