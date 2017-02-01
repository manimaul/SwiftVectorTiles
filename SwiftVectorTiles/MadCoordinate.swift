//
//  MadCoordinate.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/24/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public struct MadCoordinate {
    public let x :Double
    public let y :Double 
    
    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    static func == (lhs: MadCoordinate, rhs: MadCoordinate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}
