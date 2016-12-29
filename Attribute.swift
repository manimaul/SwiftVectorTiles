//
//  Attribute.swift
//  GeosSwiftVectorTiles
//
//  Created by William Kamp on 12/29/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import Foundation


public enum Attribute : Hashable {
    case attInt(Int64)
    case attFloat(Float)
    case attDouble(Double)
    case attString(String)
    
    public static func == (lhs: Attribute, rhs: Attribute) -> Bool {
        return lhs.toInt() == rhs.toInt()
    }
    
    public var hashValue: Int {
        return self.toInt()
    }
    
    private func toInt() -> Int {
        switch self {
        case let .attInt(aInt):
            return aInt.hashValue
        case let .attFloat(aFloat):
            return aFloat.hashValue
        case let .attDouble(aDouble):
            return aDouble.hashValue
        case let .attString(aString):
            return aString.hashValue
        }
    }
}
