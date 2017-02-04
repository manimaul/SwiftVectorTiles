//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadPolygon: MadGeometry {

    public lazy var exteriorRing: MadLinearRing? = { [unowned self] in
       return self.getExteriorRing()
    }()

    public lazy var interiorRings: [MadLinearRing] = { [unowned self] in
        return self.getInteriorRings()
    }()

    public lazy var area: Double = { [unowned self] in
        return self.getArea()
    }()

    private func getExteriorRing() -> MadLinearRing? {
        guard let ptr = GEOSGetExteriorRing_r(GeosContext, ptr),
              let clonePtr = GEOSGeom_clone_r(GeosContext, ptr) else {
            return nil
        }
        return MadLinearRing(clonePtr)
    }

    private func getInteriorRings() -> [MadLinearRing] {
        var retVal = [MadLinearRing]()
        let count = GEOSGetNumInteriorRings_r(GeosContext, ptr)
        if count > 0 {
            for i in 0...(count - 1) {
                let iRingPtr = GEOSGetInteriorRingN_r(GeosContext, ptr, i)!
                let iRingClonePtr = GEOSGeom_clone_r(GeosContext, iRingPtr)!
                let ring = MadLinearRing(iRingClonePtr)
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
        guard let eRing = exteriorRing?.transform(t) else {
            return nil
        }
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if iRings.count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: iRings.count)
            for (i, ring) in iRings.enumerated() {
                cPtrPtr?[i] = ring.ptr
            }
        }
        let nHoles = UInt32(iRings.count)
        guard let tPolyPtr = GEOSGeom_createPolygon_r(GeosContext, eRing.ptr, cPtrPtr, nHoles) else {
            return nil
        }
        cPtrPtr?.deallocate(capacity: iRings.count)
        return MadPolygon(tPolyPtr)
    }
    
    private func getArea() -> Double {
        var a :Double = 0
        GEOSArea_r(GeosContext, ptr, &a)
        return a
    }
    
}
