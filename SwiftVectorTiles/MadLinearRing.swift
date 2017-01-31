//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadLinearRing: MadLineString {

    convenience init(_ coordinateSequence: MadCoordinateSequence) {
        guard let ptr = GEOSGeom_createLinearRing_r(GeosContext, coordinateSequence.sequencePtr) else {
            fatalError("coordinates did not form a ring")
        }
        self.init(GeosGeometryPointer(ptr: ptr, owner: nil))
    }

    override public func reverse() -> MadLinearRing? {
        guard let coordinateSequence = coordinateSequence() else {
            return nil
        }
        var coords = [MadCoordinate](coordinateSequence)
        coords.reverse()
        return MadLinearRing(coords)
    }

    override public func transform(_ t: MadCoordinateTransform) -> MadLinearRing? {
        guard let tCoords = coordinateSequence()?.transform(t: t) else {
            fatalError()
        }
        return MadLinearRing(tCoords)
    }
    
}
