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
        guard let ptr = GEOSGeom_createLinearRing_r(GeosContext, coordinateSequence.sequencePtr) else {
            fatalError("coordinates did not form a ring")
        }
        self.init(GeosGeometryPointer(ptr: ptr, owner: nil))
    }

    convenience init(_ coordinates: [MadCoordinate]) {
        let coordinateSequence = MadCoordinateSequence(coordinates)
        self.init(coordinateSequence)
    }

    convenience init(_ coordinates: (Double, Double)...) {
        let coordinateSequence = MadCoordinateSequence(coordinates)
        self.init(coordinateSequence)
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
        _ = GEOSGeomGetLength_r(GeosContext, geometryPtr.ptr, &value)
        return value
    }
}
