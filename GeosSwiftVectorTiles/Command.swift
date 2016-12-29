//
//  Command.swift
//  GeosSwiftVectorTiles
//
//  Created by William Kamp on 12/29/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import Foundation

internal enum Command : UInt32 {
    case moveTo = 1, lineTo
    case closePath = 7
    
}
