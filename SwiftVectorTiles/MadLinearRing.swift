//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadLinearRing: MadLineString {

    public func isCCW() -> Bool {
        guard let seq = coordinateSequence() else {
            fatalError("a linear ring should have a coordinate sequence")
        }
        return seq.isCCW()
    }

    override public func reverse() -> MadLinearRing? {
        return super.reverse() as? MadLinearRing
    }

    override public func transform(_ t: MadCoordinateTransform) -> MadLinearRing? {
        guard let tSeq = coordinateSequence()?.transform(t: t) else {
            return nil
        }
        guard let ptr = GEOSGeom_createLinearRing_r(GeosContext, tSeq.sequencePtr) else {
            return nil
        }
        return MadLinearRing(GeosGeometryPointer(ptr: ptr, owner: nil))
    }
    
}
