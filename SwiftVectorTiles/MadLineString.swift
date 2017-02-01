//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadLineString: MadGeometry {

    convenience init(_ coordinateSequence: MadCoordinateSequence) {
        guard let ptr = GEOSGeom_createLineString_r(GeosContext, coordinateSequence.sequencePtr) else {
            fatalError("coordinates did not form a ring")
        }
        self.init(ptr)
    }

    convenience init(_ coordinates: [MadCoordinate]) {
        let coordinateSequence = MadCoordinateSequence(coordinates)
        self.init(coordinateSequence)
    }

    convenience init(_ coordinates: (Double, Double)...) {
        let coordinateSequence = MadCoordinateSequence(coordinates)
        self.init(coordinateSequence)
    }

    public func isCCW() -> Bool {
        guard let seq = coordinateSequence() else {
            fatalError("a linear ring should have a coordinate sequence")
        }
        return seq.isCCW()
    }

    public func reverse() -> MadLineString? {
        guard let coordinateSequence = coordinateSequence() else {
            return nil
        }
        var coords = [MadCoordinate](coordinateSequence)
        coords.reverse()
        return MadLineString(coords)
    }

    public func length() -> Double {
        var value: Double = 0
        _ = GEOSGeomGetLength_r(GeosContext, ptr, &value)
        return value
    }

    override public func transform(_ t: MadCoordinateTransform) -> MadLineString? {
        guard let tCoords = coordinateSequence()?.transform(t: t) else {
            fatalError()
        }
        return MadLineString(tCoords)
    }
}
