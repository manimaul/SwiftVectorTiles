//
//  MadMultiPoing.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/25/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadMultiLineString : MadMultiGeometry {

    public convenience init(_ coordinates: [MadCoordinateSequence]) {
        var geoms = [MadGeometry]()
        var cArrayArray: UnsafeMutablePointer<OpaquePointer?>? = nil
        if coordinates.count > 0 {
            cArrayArray = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: coordinates.count)
            for (i, coordinateSequence) in coordinates.enumerated() {
                let lineString = MadLineString(coordinateSequence)
                geoms.append(lineString)
                cArrayArray?[i] = lineString.ptr

            }
            defer {
                cArrayArray?.deallocate(capacity: geoms.count)
            }
        }
        let type = Int32(MadGeometryType.multiLineString.rawValue)
        guard let ptr = GEOSGeom_createCollection_r(GeosContext, type, cArrayArray, UInt32(geoms.count)) else {
            fatalError()
        }
        self.init(ptr)
        geometries.append(contentsOf: geoms)
    }

    public convenience init(_ coordinates: MadCoordinateSequence...) {
        self.init(coordinates)
    }
    
}
