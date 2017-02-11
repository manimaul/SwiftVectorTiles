//
//  MadGeometry.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/22/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol Geometry {
    var wkt: String? { get }
    var wkb: Data? { get }
    var coordinates: [GeoCoordinate] { get }
    var geometryType: MadGeometryType { get }
    var isEmpty: Bool { get }
    func covers(other: Geometry) -> Bool
    func intersection(other: Geometry) -> Geometry?
    func intersects(other: Geometry) -> Bool
    func transform(_ trans: GeoCoordinateTransform) -> Self?
}

//region geosGeometry

internal func geosGeometryFromWellKnownText(_ wkt: String) -> GPtrOwner? {
    let wktReaderPtr = GEOSWKTReader_create_r(GeosContext)
    guard let geomPtr = GEOSWKTReader_read_r(GeosContext, wktReaderPtr, wkt) else {
        return nil
    }
    GEOSWKTReader_destroy_r(GeosContext, wktReaderPtr)
    return GPtrOwnerCreate(geomPtr)
}

internal func geosGeometryFromWellKnownBinary(_ wkb: Data) -> GPtrOwner? {
    let wkbReaderPtr = GEOSWKBReader_create_r(GeosContext)
    guard let geomPtr = GEOSWKBReader_read_r(GeosContext, wkbReaderPtr, [UInt8](wkb), wkb.count) else {
        return nil
    }
    GEOSWKBReader_destroy_r(GeosContext, wkbReaderPtr)
    return GPtrOwnerCreate(geomPtr)
}

func geosGeometryClone(_ geosPtr: GeosGeometryPtr) -> GPtrOwner {
    guard let ptr = GEOSGeom_clone_r(GeosContext, geosPtr.ptr) else {
        fatalError("fatal error cloning coordinate sequence")
    }
    return GPtrOwnerCreate(ptr)
}

func geosGeometryCovers(_ geosPtr: GeosGeometryPtr, other: GeosGeometryPtr) -> Bool {
    return GEOSCovers(geosPtr.ptr, other.ptr) == CChar("1")
}

func geosGeometryIntersection(_ geosPtr: GeosGeometryPtr, other: GeosGeometryPtr) -> GPtrOwner? {
    guard let ptr = GEOSIntersection_r(GeosContext, geosPtr.ptr, other.ptr) else {
        return nil
    }
    return GPtrOwnerCreate(ptr)
}

func geosGeometryIntersects(_ geosPtr: GeosGeometryPtr, other: GeosGeometryPtr) -> Bool {
    return GEOSIntersects(geosPtr.ptr, other.ptr) == CChar("1")
}

func geosGeometryEmpty(_ geosPtr: GeosGeometryPtr) -> Bool {
    return GEOSisEmpty_r(GeosContext, geosPtr.ptr) == CChar("1")
}

func geosGeometryCoordinateSequence(_ geosPtr: GeosGeometryPtr) -> GeosCoordinateSequencePtr? {
    guard let ptr = GEOSGeom_getCoordSeq_r(GeosContext, geosPtr.ptr) else {
        return nil
    }
    return GeosCoordinateSequencePtr(ptr: ptr)
}

func geosGeometryCoordinateSequenceClone(_ geosPtr: GeosGeometryPtr) -> CSPtrOwner? {
    guard let seq = geosGeometryCoordinateSequence(geosPtr),
          let seqClone = GEOSCoordSeq_clone_r(GeosContext, seq.ptr) else {
        return nil
    }
    return CSPtrOwnerCreate(seqClone)
}

func geosGeometryWellKnownText(_ geosPtr: GeosGeometryPtr) -> String? {
    let wktWriter = GEOSWKTWriter_create_r(GeosContext)
    let wktData = GEOSWKTWriter_write_r(GeosContext, wktWriter, geosPtr.ptr)
    GEOSWKTWriter_destroy_r(GeosContext, wktWriter)
    if let wktData = wktData {
        let wkt = String(cString: wktData)
        GEOSFree_r(GeosContext, wktData)
        return wkt
    }
    return nil
}

func geosGeometryWellKnownBinary(_ geosPtr: GeosGeometryPtr) -> Data? {
    let wkbWriter = GEOSWKBWriter_create_r(GeosContext)
    var size :Int = 0
    let wkbData = GEOSWKBWriter_write_r(GeosContext, wkbWriter, geosPtr.ptr, &size)
    GEOSWKBWriter_destroy_r(GeosContext, wkbWriter)
    if let wkbData = wkbData {
        let wkb = Data(bytes: wkbData, count: size)
        GEOSFree_r(GeosContext, wkbData)
        return wkb
    }
    return nil
}

//endregion

internal class GeosGeometry : Geometry {

    internal var geos: GPtrOwner

    lazy var wkt: String? = { [unowned self] in
        return geosGeometryWellKnownText(self.geos.ownedPtr)
    }()

    lazy var wkb: Data? = { [unowned self] in
        return geosGeometryWellKnownBinary(self.geos.ownedPtr)
    }()

    lazy var coordinates: [GeoCoordinate] = { [unowned self] in
        guard let coordGeos = geosGeometryCoordinateSequence(self.geos.ownedPtr) else {
            return [GeoCoordinate]()
        }
        return geosCoordinateSequenceCoordinates(coordGeos)
    }()

    lazy var geometryType: MadGeometryType = { [unowned self] in
        return MadGeometryType.typeFromPtr(self.geos.ownedPtr)
    }()

    lazy var isEmpty: Bool = { [unowned self] in
        return geosGeometryEmpty(self.geos.ownedPtr)
    }()

    lazy var coordinateSequence: GeosCoordinateSequence? = { [unowned self] in
        guard let seq = geosGeometryCoordinateSequenceClone(self.geos.ownedPtr) else {
            return nil
        }
        return GeosCoordinateSequence(seq)
    }()

    internal init(_ ptrOwner: GPtrOwner) {
        self.geos = ptrOwner
    }

    deinit {
        geos.destroy()
    }
    
    func covers(other: Geometry) -> Bool {
        let other = other as! GeosGeometry
        return geosGeometryCovers(geos.ownedPtr, other: other.geos.ownedPtr)
    }

    func intersection(other: Geometry) -> Geometry? {
        let other = other as! GeosGeometry
        guard let geos = geosGeometryIntersection(geos.ownedPtr, other: other.geos.ownedPtr) else {
            return nil
        }
        return MadGeometryFactory.madGeometry(geos)
    }
    
    func intersects(other: Geometry) -> Bool {
        let other = other as! GeosGeometry
        return geosGeometryIntersects(geos.ownedPtr, other: other.geos.ownedPtr)
    }
    
    func empty() -> Bool {
        return geosGeometryEmpty(geos.ownedPtr)
    }
    
    func transform(_ trans: GeoCoordinateTransform) -> Self? {
        fatalError("unimplemented abstract function")
    }
    
}
