//
//  MADCoordinateSequence+Sequence.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/21/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

extension MADCoordinateSequence : Sequence {
    public func makeIterator() -> NSFastEnumerationIterator {
        return NSFastEnumerationIterator(self)
    }
}
