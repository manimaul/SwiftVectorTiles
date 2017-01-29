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
        guard let ptr = GEOSGeom_createPoint_r(GeosContext, coordinateSequence.sequencePtr) else {
            fatalError("could not create point from coordinate sequence")
        }
        let ggp = GeosGeometryPointer(ptr: ptr, owner: nil)
        self.init(ggp)
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
        if let tCoordinates = coordinateSequence()?.transform(t: t) {
            if (tCoordinates.count == 1) {
                return MadPoint(tCoordinates[0])
            }
        }
        return nil
    }
    
}
