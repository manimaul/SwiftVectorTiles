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
    
    fileprivate static func madGeometry(_ ptr: OpaquePointer?) -> MadGeometry? {
        if let ptr = ptr {
            switch typeFromPtr(ptr: ptr) {
            case .point:
                return MadPoint(ptr)
            case .lineString:
                return MadLineString(ptr)
            case .linearRing:
                return MadLinearRing(ptr)
            case .polygon:
                return MadPolygon(ptr)
            case .multiPoint:
                return MadMultiPoint(ptr)
            case .multiLineString:
                return MadMultiLineString(ptr)
            case .multiPolygon:
                return MadMultiPolygon(ptr)
            case .geometryCollection:
                return MadMultiGeometry(ptr)
            default:
                GEOSGeom_destroy_r(GeosContext, ptr)
                return nil
            }
        }
        return nil
    }
    
    public static func geometryFromWellKnownText(_ wkt: String) -> MadGeometry? {
        let wktReaderPtr = GEOSWKTReader_create_r(GeosContext)
        let geomPtr = GEOSWKTReader_read_r(GeosContext, wktReaderPtr, wkt)
        GEOSWKTReader_destroy_r(GeosContext, wktReaderPtr)
        return madGeometry(geomPtr)
    }
    
    public static func geometryFromWellKnownBinary(_ wkb: Data) -> MadGeometry? {
        let wkbReaderPtr = GEOSWKBReader_create_r(GeosContext)
        let geomPtr = GEOSWKBReader_read_r(GeosContext, wkbReaderPtr, [UInt8](wkb), 0)
        GEOSWKBReader_destroy_r(GeosContext, wkbReaderPtr)
        return madGeometry(geomPtr)
    }
}

public class MadGeometry {

    weak var owner: MadGeometry?
    let ptr: OpaquePointer
    fileprivate var wkt: String?
    fileprivate var wkb: Data?

    internal init(_ ptr: OpaquePointer, owner: MadGeometry? = nil) {
        self.ptr = ptr
        self.owner = owner
    }
    
    public func covers(other: MadGeometry) -> Bool {
        return GEOSCovers(ptr, other.ptr) == CChar("1")
    }

    public func intersection(other: MadGeometry) -> MadGeometry? {
        guard let ptr = GEOSIntersection_r(GeosContext, ptr, other.ptr) else {
            return nil
        }
        return MadGeometryFactory.madGeometry(ptr)
    }
    
    public func intersects(other: MadGeometry) -> Bool {
        return GEOSIntersects(ptr, other.ptr) == CChar("1")
    }
    
    public func empty() -> Bool {
        return GEOSisEmpty_r(GeosContext, ptr) == CChar("1")
    }
    
    public func wellKnownText() -> String? {
        if let text = wkt {
            return text
        }
        let wktWriter = GEOSWKTWriter_create_r(GeosContext)
        let wktData = GEOSWKTWriter_write_r(GeosContext, wktWriter, ptr)
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
        let wkbData = GEOSWKBWriter_write_r(GeosContext, wkbWriter, ptr, &size)
        GEOSWKBWriter_destroy_r(GeosContext, wkbWriter)
        if let wkbData = wkbData {
            wkb = Data(bytes: wkbData, count: size)
            GEOSFree_r(GeosContext, wkbData)
        }
        return wkb
    }
    
    public func geometryType() -> MadGeometryType {
        return MadGeometryFactory.typeFromPtr(ptr: ptr)
    }
    
    public func coordinateSequence() -> MadCoordinateSequence? {
        guard let seq = GEOSGeom_getCoordSeq_r(GeosContext, ptr) else {
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
        if owner != nil {
            GEOSGeom_destroy_r(GeosContext, ptr)
        }
    }
    
}
