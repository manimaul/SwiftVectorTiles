//
//  MadMultiPoing.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/25/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol MultiLineString : MultiGeometry {

}

internal func geosMultiLineStringCreate(_ geosPtrs: [CSPtrOwner]) -> GPtrOwner {
    var cArrayArray: UnsafeMutablePointer<OpaquePointer?>? = nil
    if geosPtrs.count > 0 {
        cArrayArray = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geosPtrs.count)
        for (i, geosPtr) in geosPtrs.enumerated() {
            let gOwner = geosLineStringCreate(geosPtr)
            cArrayArray?[i] = gOwner.ptr
        }
    }
    let type = MadGeometryType.multiLineString.cType()
    guard let ptr = GEOSGeom_createCollection_r(GeosContext, type, cArrayArray, UInt32(geoms.count)) else {
        fatalError("could not create multi line string")
    }
    cArrayArray?.deallocate(capacity: geoms.count)
    return GPtrOwner(ptr)
}

public class GeosMultiLineString : GeosMultiGeometry, MultiLineString {

    public convenience init(_ coordinates: [GeosCoordinateSequence]) {
        var geosPtrs = [CSPtrOwner]()
        for cs in coordinates {
            geosPtrs.append(geosCoordinateSequenceClone(cs.geos))
        }
        let gOwner = geosMultiLineStringCreate(geosPtrs)
        self.init(gOwner)
    }

    public convenience init(_ coordinates: GeosCoordinateSequence...) {
        self.init(coordinates)
    }
    
}
