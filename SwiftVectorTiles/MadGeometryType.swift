//
//  GeometryType.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/22/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public enum MadGeometryType : Int {
    case unknown = -1,
    point,
    lineString,
    linearRing,
    polygon,
    multiPoint,
    multiLineString,
    multiPolygon,
    geometryCollection

    internal func cType() -> Int32 {
        return Int32(rawValue)
    }

    internal static func typeFromPtr(_ geosPtr: GeosGeometryPtr?) -> MadGeometryType {
        if let geosPtr = geosPtr {
            let geometryType = GEOSGeomTypeId_r(GeosContext, geosPtr.ptr)
            if let type = MadGeometryType(rawValue: Int(geometryType)) {
                return type
            }
        }
        return .unknown
    }
}
