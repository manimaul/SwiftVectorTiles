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

    internal static func typeFromPtr(ptr: OpaquePointer?) -> MadGeometryType {
        if let ptr = ptr {
            let geometryType = GEOSGeomTypeId_r(GeosContext, ptr)
            if let type = MadGeometryType(rawValue: Int(geometryType)) {
                return type
            }
        }
        return .unknown
    }
}
