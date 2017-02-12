//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

internal final class MadPolygon: MadGeometry {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var exteriorRing: MadLinearRing? = { [unowned self] in
        let ring = MadPolygon.goesPolygonExteriorRing(self.geos.ownedPtr)
        let ringClone = MadGeometry.geosGeometryClone(ring);
        return MadLinearRing(ringClone)
    }()

    public private(set) lazy var interiorRings: [MadLinearRing] = { [unowned self] in
        var rings = [MadLinearRing]()
        if self.interiorRingsCount > 0 {
            for i in 0 ... (self.interiorRingsCount - 1) {
                let ring = MadPolygon.goesPolygonInteriorRingAt(self.geos.ownedPtr, index: i)
                let ringClone = MadGeometry.geosGeometryClone(ring)
                rings.append(MadLinearRing(ringClone))
            }
        }
        return rings
    }()

    public private(set) lazy var interiorRingsCount: Int = { [unowned self] in
        return MadPolygon.goesPolygonInteriorRingCount(self.geos.ownedPtr)
    }()

    public private(set) lazy var area: Double = { [unowned self] in
        return MadPolygon.geosPolyGoneArea(self.geos.ownedPtr)
    }()

    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    override public func transform(_ trans: GeoCoordinateTransform) -> MadPolygon? {
        let eRing = MadPolygon.goesPolygonExteriorRing(self.geos.ownedPtr)
        let eRingCs = MadPolygon.geosGeometryCoordinateSequence(eRing)!
        let eRingCsTrans = MadCoordinateSequence.geosCoordinateSequenceTransform(eRingCs, trans: trans)
        let eRingTrans = MadLinearRing.geosLinearRingCreate(eRingCsTrans)
        var holesTrans: [GPtrOwner]?
        if interiorRingsCount > 0 {
            holesTrans = [GPtrOwner]()
            for i in 0 ... (interiorRingsCount - 1) {
                let ring = MadPolygon.goesPolygonInteriorRingAt(self.geos.ownedPtr, index: i)
                guard let ringCs = MadGeometry.geosGeometryCoordinateSequence(ring) else {
                    fatalError("error determining coordinate sequence of interior ring")
                }
                let ringCsTrans = MadCoordinateSequence.geosCoordinateSequenceTransform(ringCs, trans: trans)
                let ringTrans = MadLinearRing.geosLinearRingCreate(ringCsTrans)
                holesTrans?.append(ringTrans)
            }
        }
        let polyTrans = MadPolygon.geosPolygonCreate(eRingTrans, interiorLinearRings: holesTrans)
        return MadPolygon(polyTrans)
    }

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosPolygonCreate(_ exteriorLinearRing: GPtrOwner, interiorLinearRings: [GPtrOwner]?) -> GPtrOwner {
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if let interiorLinearRings = interiorLinearRings {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: interiorLinearRings.count)
            for (i, owner) in interiorLinearRings.enumerated() {
                cPtrPtr?[i] = owner.ptr
            }
        }
        let count = UInt32(interiorLinearRings?.count ?? 0)
        guard let ptr = GEOSGeom_createPolygon_r(GeosContext, exteriorLinearRing.ptr, cPtrPtr, count) else {
            fatalError("error creating polygon")
        }
        return GPtrOwnerCreate(ptr)
    }

    internal static func goesPolygonExteriorRing(_ geosPtr: GeosGeometryPtr) -> GeosGeometryPtr {
        guard let ptr = GEOSGetExteriorRing_r(GeosContext, geosPtr.ptr) else {
            fatalError("could not create exterior ring")
        }
        return GeosGeometryPtr(ptr: ptr)
    }

    internal static func goesPolygonInteriorRingCount(_ geosPtr: GeosGeometryPtr) -> Int {
        let count = GEOSGetNumInteriorRings_r(GeosContext, geosPtr.ptr)
        return Int(count)
    }

    internal static func goesPolygonInteriorRingAt(_ geosPtr: GeosGeometryPtr, index: Int) -> GeosGeometryPtr {
        guard let ptr = GEOSGetInteriorRingN_r(GeosContext, geosPtr.ptr, Int32(index)) else {
            fatalError("could not get interior ring")
        }
        return GeosGeometryPtr(ptr: ptr)
    }

    internal static func geosPolyGoneArea(_ geosPtr: GeosGeometryPtr) -> Double {
        var a: Double = 0
        GEOSArea_r(GeosContext, geosPtr.ptr, &a)
        return a
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

}
