//
//  MadPoint.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/24/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadPoint : MadGeometry {

    public convenience init(_ coordinateSequence: MadCoordinateSequence) {
        if coordinateSequence.weakOwner != nil {
            fatalError("supplied coordinate sequence is owned by another geometry")
        }
        guard let ptr = GEOSGeom_createPoint_r(GeosContext, coordinateSequence.sequencePtr) else {
            fatalError("could not create point from coordinate sequence")
        }
        self.init(ptr)
        coordinateSequence.weakOwner = self
        self.coordinateSequence = coordinateSequence
    }

    public convenience init(_ coordinate: (Double, Double)) {
        let coordSeq = MadCoordinateSequence(coordinate)
        self.init(coordSeq)
    }
    
    public convenience init(_ coordinate: MadCoordinate) {
        let coordSeq = MadCoordinateSequence(coordinate)
        self.init(coordSeq)
    }
    
    override public func transform(_ t: MadCoordinateTransform) -> MadPoint? {
        if let tCoordinates = coordinateSequence?.transform(t: t) {
            if (tCoordinates.count == 1) {
                let point = MadPoint(tCoordinates)
                return point
            }
        }
        return nil
    }
    
}
