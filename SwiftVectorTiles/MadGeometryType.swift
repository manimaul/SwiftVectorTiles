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
}
