//
//  MadMultiPoing.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/25/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadMultiLineString : MadMultiGeometry {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public convenience init(_ coordinates: [MadCoordinateSequence]) {
        var geosPtrs = [CSPtrOwner]()
        for cs in coordinates {
            geosPtrs.append(MadCoordinateSequence.geosCoordinateSequenceClone(cs.geos.ownedPtr))
        }
        let gOwner = MadMultiLineString.geosMultiLineStringCreate(geosPtrs)
        self.init(gOwner)
    }

    public convenience init(_ coordinates: MadCoordinateSequence...) {
        self.init(coordinates)
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosMultiLineStringCreate(_ geosPtrs: [CSPtrOwner]) -> GPtrOwner {
        var cArrayArray: UnsafeMutablePointer<OpaquePointer?>? = nil
        if geosPtrs.count > 0 {
            cArrayArray = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geosPtrs.count)
            for (i, geosPtr) in geosPtrs.enumerated() {
                let gOwner = MadLineString.geosLineStringCreate(geosPtr)
                cArrayArray?[i] = gOwner.ptr
            }
        }
        let type = MadGeometryType.multiLineString.cType()
        guard let ptr = GEOSGeom_createCollection_r(GeosContext, type, cArrayArray, UInt32(geosPtrs.count)) else {
            fatalError("could not create multi line string")
        }
        cArrayArray?.deallocate(capacity: geosPtrs.count)
        return GPtrOwnerCreate(ptr)
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion
    
}
