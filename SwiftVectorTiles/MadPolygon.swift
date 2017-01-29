//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadPolygon: MadGeometry {

    public func getExteriorRing() -> MadLinearRing? {
        guard let ptr = GEOSGetExteriorRing_r(GeosContext, geometryPtr.ptr) else {
            return nil
        }
        return MadLinearRing(GeosGeometryPointer(ptr: ptr, owner: self))
    }

    public func getInteriorRings() -> [MadLinearRing] {
        var retVal = [MadLinearRing]()
        let count = GEOSGetNumInteriorRings_r(GeosContext, geometryPtr.ptr)
        if count > 0 {
            for i in 0...(count - 1) {
                let ptr = GEOSGetInteriorRingN_r(GeosContext, geometryPtr.ptr, i)!
                let ring = MadLinearRing(GeosGeometryPointer(ptr: ptr, owner: self))
                retVal.append(ring)
            }
        }
        return retVal
    }
    
    override public func transform(_ t: MadCoordinateTransform) -> MadPolygon? {

        var iRings = [MadLinearRing]()
        for ring in getInteriorRings() {
            guard let tRing = ring.transform(t) else {
                return nil
            }
            iRings.append(tRing)
        }
        guard let eRing = getExteriorRing()?.transform(t) else {
            return nil
        }

        var iRingCArrayPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if iRings.count > 0 {
            iRingCArrayPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: iRings.count)
            for (i, ring) in iRings.enumerated() {
                iRingCArrayPtr?[i] = ring.geometryPtr.ptr
            }
            defer {
                iRingCArrayPtr?.deallocate(capacity: iRings.count)
            }
        }

        let nHoles = UInt32(iRings.count)
        guard let tPolyPtr = GEOSGeom_createPolygon_r(GeosContext, eRing.geometryPtr.ptr, iRingCArrayPtr, nHoles) else {
            return nil
        }
        return MadPolygon(GeosGeometryPointer(ptr: tPolyPtr, owner: nil))
    }
    
    public func area() -> Double {
        var a :Double = 0
        GEOSArea_r(GeosContext, self.geometryPtr.ptr, &a)
        return a
    }
    
}
