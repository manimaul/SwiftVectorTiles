//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol Polygon: Geometry {
    var exteriorRing: LinearRing? { get }
    var interiorRings: [LinearRing] { get }
    var interiorRingsCount: Int { get }
    var area: Double { get }
}

internal func geosPolygonCreate(_ exteriorLinearRing: GPtrOwner, interiorLinearRings: [GPtrOwner]?) -> GPtrOwner {
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

internal func goesPolygonExteriorRing(_ geosPtr: GeosGeometryPtr) -> GeosGeometryPtr {
    guard let ptr = GEOSGetExteriorRing_r(GeosContext, geosPtr.ptr) else {
        fatalError("could not create exterior ring")
    }
    return GeosGeometryPtr(ptr: ptr)
}

internal func goesPolygonInteriorRingCount(_ geosPtr: GeosGeometryPtr) -> Int {
    let count = GEOSGetNumInteriorRings_r(GeosContext, geosPtr.ptr)
    return Int(count)
}

internal func goesPolygonInteriorRingAt(_ geosPtr: GeosGeometryPtr, index: Int) -> GeosGeometryPtr {
    guard let ptr = GEOSGetInteriorRingN_r(GeosContext, geosPtr.ptr, Int32(index)) else {
        fatalError("could not get interior ring")
    }
    return GeosGeometryPtr(ptr: ptr)
}

internal func geosPolyGoneArea(_ geosPtr: GeosGeometryPtr) -> Double {
    var a: Double = 0
    GEOSArea_r(GeosContext, geosPtr.ptr, &a)
    return a
}


internal final class GeosPolygon: GeosGeometry, Polygon {

    lazy var exteriorRing: LinearRing? = { [unowned self] in
        let ring = goesPolygonExteriorRing(self.geos.ownedPtr)
        let ringClone = geosGeometryClone(ring);
        return GeosLinearRing(ringClone)
    }()

    lazy var interiorRings: [LinearRing] = { [unowned self] in
        var rings = [LinearRing]()
        if self.interiorRingsCount > 0 {
            for i in 0 ... (self.interiorRingsCount - 1) {
                let ring = goesPolygonInteriorRingAt(self.geos.ownedPtr, index: i)
                let ringClone = geosGeometryClone(ring)
                rings.append(GeosLinearRing(ringClone))
            }
        }
        return rings
    }()

    lazy var interiorRingsCount: Int = { [unowned self] in
        return goesPolygonInteriorRingCount(self.geos.ownedPtr)
    }()

    lazy var area: Double = { [unowned self] in
        return geosPolyGoneArea(self.geos.ownedPtr)
    }()

    override public func transform(_ trans: GeoCoordinateTransform) -> GeosPolygon? {
        let eRing = goesPolygonExteriorRing(self.geos.ownedPtr)
        let eRingCs = geosGeometryCoordinateSequence(eRing)!
        let eRingCsTrans = geosCoordinateSequenceTransform(eRingCs, trans: trans)
        let eRingTrans = geosLinearRingCreate(eRingCsTrans)
        var holesTrans: [GPtrOwner]?
        if interiorRingsCount > 0 {
            holesTrans = [GPtrOwner]()
            for i in 0 ... (interiorRingsCount - 1) {
                let ring = goesPolygonInteriorRingAt(self.geos.ownedPtr, index: i)
                guard let ringCs = geosGeometryCoordinateSequence(ring) else {
                    fatalError("error determining coordinate sequence of interior ring")
                }
                let ringCsTrans = geosCoordinateSequenceTransform(ringCs, trans: trans)
                let ringTrans = geosLinearRingCreate(ringCsTrans)
                holesTrans?.append(ringTrans)
            }
        }
        let polyTrans = geosPolygonCreate(eRingTrans, interiorLinearRings: holesTrans)
        return GeosPolygon(polyTrans)
    }

}
