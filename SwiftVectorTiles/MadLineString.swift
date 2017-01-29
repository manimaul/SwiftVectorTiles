//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadLineString: MadGeometry {

    public func length() -> Double {
        var value: Double = 0
        _ = GEOSGeomGetLength_r(GeosContext, geometryPtr.ptr, &value)
        return value
    }
}
