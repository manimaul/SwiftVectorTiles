//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol MultiPolygon : MultiGeometry {

}

internal class GeosMultiPolygon: GeosMultiGeometry, MultiPolygon {

}
