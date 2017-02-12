//
//  MadGeometry.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/22/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadGeometry {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var wkt: String? = { [unowned self] in
        return MadGeometry.geosGeometryWellKnownText(self.geos.ownedPtr)
    }()

    public private(set) lazy var wkb: Data? = { [unowned self] in
        return MadGeometry.geosGeometryWellKnownBinary(self.geos.ownedPtr)
    }()

    public private(set) lazy var coordinates: [GeoCoordinate] = { [unowned self] in
        guard let coordGeos = MadGeometry.geosGeometryCoordinateSequence(self.geos.ownedPtr) else {
            return [GeoCoordinate]()
        }
        return MadCoordinateSequence.geosCoordinateSequenceCoordinates(coordGeos)
    }()

    public private(set) lazy var geometryType: MadGeometryType = { [unowned self] in
        return MadGeometryType.typeFromPtr(self.geos.ownedPtr)
    }()

    public private(set) lazy var isEmpty: Bool = { [unowned self] in
        return MadGeometry.geosGeometryEmpty(self.geos.ownedPtr)
    }()

    public private(set) lazy var coordinateSequence: MadCoordinateSequence? = { [unowned self] in
        guard let seq = MadGeometry.geosGeometryCoordinateSequenceClone(self.geos.ownedPtr) else {
            return nil
        }
        return MadCoordinateSequence(seq)
    }()

    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal var geos: GPtrOwner

    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal init(_ ptrOwner: GPtrOwner) {
        self.geos = ptrOwner
    }

    deinit {
        geos.destroy()
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public func covers(other: MadGeometry) -> Bool {
        return MadGeometry.geosGeometryCovers(geos.ownedPtr, other: other.geos.ownedPtr)
    }

    public func intersection(other: MadGeometry) -> MadGeometry? {
        guard let geos = MadGeometry.geosGeometryIntersection(geos.ownedPtr, other: other.geos.ownedPtr) else {
            return nil
        }
        return MadGeometryFactory.madGeometry(geos)
    }

    public func intersects(other: MadGeometry) -> Bool {
        return MadGeometry.geosGeometryIntersects(geos.ownedPtr, other: other.geos.ownedPtr)
    }

    public func empty() -> Bool {
        return MadGeometry.geosGeometryEmpty(geos.ownedPtr)
    }

    public func transform(_ trans: GeoCoordinateTransform) -> MadGeometry? {
        fatalError("unimplemented abstract function")
    }

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosGeometryFromWellKnownText(_ wkt: String) -> GPtrOwner? {
        let wktReaderPtr = GEOSWKTReader_create_r(GeosContext)
        guard let geomPtr = GEOSWKTReader_read_r(GeosContext, wktReaderPtr, wkt) else {
            return nil
        }
        GEOSWKTReader_destroy_r(GeosContext, wktReaderPtr)
        return GPtrOwnerCreate(geomPtr)
    }

    internal static func geosGeometryFromWellKnownBinary(_ wkb: Data) -> GPtrOwner? {
        let wkbReaderPtr = GEOSWKBReader_create_r(GeosContext)
        guard let geomPtr = GEOSWKBReader_read_r(GeosContext, wkbReaderPtr, [UInt8](wkb), wkb.count) else {
            return nil
        }
        GEOSWKBReader_destroy_r(GeosContext, wkbReaderPtr)
        return GPtrOwnerCreate(geomPtr)
    }

    internal static func geosGeometryClone(_ geosPtr: GeosGeometryPtr) -> GPtrOwner {
        guard let ptr = GEOSGeom_clone_r(GeosContext, geosPtr.ptr) else {
            fatalError("fatal error cloning coordinate sequence")
        }
        return GPtrOwnerCreate(ptr)
    }

    internal static func geosGeometryCovers(_ geosPtr: GeosGeometryPtr, other: GeosGeometryPtr) -> Bool {
        return GEOSCovers(geosPtr.ptr, other.ptr) == CChar("1")
    }

    internal static func geosGeometryIntersection(_ geosPtr: GeosGeometryPtr, other: GeosGeometryPtr) -> GPtrOwner? {
        guard let ptr = GEOSIntersection_r(GeosContext, geosPtr.ptr, other.ptr) else {
            return nil
        }
        return GPtrOwnerCreate(ptr)
    }

    internal static func geosGeometryIntersects(_ geosPtr: GeosGeometryPtr, other: GeosGeometryPtr) -> Bool {
        return GEOSIntersects(geosPtr.ptr, other.ptr) == CChar("1")
    }

    internal static func geosGeometryEmpty(_ geosPtr: GeosGeometryPtr) -> Bool {
        return GEOSisEmpty_r(GeosContext, geosPtr.ptr) == CChar("1")
    }

    internal static func geosGeometryCoordinateSequence(_ geosPtr: GeosGeometryPtr) -> GeosCoordinateSequencePtr? {
        guard let ptr = GEOSGeom_getCoordSeq_r(GeosContext, geosPtr.ptr) else {
            return nil
        }
        return GeosCoordinateSequencePtr(ptr: ptr)
    }

    internal static func geosGeometryCoordinateSequenceClone(_ geosPtr: GeosGeometryPtr) -> CSPtrOwner? {
        guard let seq = geosGeometryCoordinateSequence(geosPtr),
              let seqClone = GEOSCoordSeq_clone_r(GeosContext, seq.ptr) else {
            return nil
        }
        return CSPtrOwnerCreate(seqClone)
    }

    internal static func geosGeometryWellKnownText(_ geosPtr: GeosGeometryPtr) -> String? {
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

    internal static func geosGeometryWellKnownBinary(_ geosPtr: GeosGeometryPtr) -> Data? {
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

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion
    
}
