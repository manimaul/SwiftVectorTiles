//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadLineString: MadGeometry {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var length: Double = { [unowned self] in
        return MadLineString.geosLineStringLength(self.geos.ownedPtr)
    }()

    public private(set) lazy var isCounterClockWise: Bool = { [unowned self] in
        return self.coordinateSequence!.isCounterClockWise
    }()

    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public convenience init(_ coordinateSequence: MadCoordinateSequence) {
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceClone(coordinateSequence.geos.ownedPtr)
        let gOwner = MadLineString.geosLineStringCreate(sOwner)
        self.init(gOwner)
    }

    public convenience init(_ coordinates: [GeoCoordinate]) {
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceCreate(coordinates)
        let gOwner = MadLineString.geosLineStringCreate(sOwner)
        self.init(gOwner)
    }

    public convenience init(_ coordinates: GeoCoordinate...) {
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceCreate(coordinates)
        let gOwner = MadLineString.geosLineStringCreate(sOwner)
        self.init(gOwner)
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public func reverse() -> MadLineString? {
        guard let ownedCoordinateSequence = MadGeometry.geosGeometryCoordinateSequence(self.geos.ownedPtr) else {
            return nil
        }
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceReversed(ownedCoordinateSequence)
        let gOwner = MadLineString.geosLineStringCreate(sOwner)
        return MadLineString(gOwner)
    }

    override public func transform(_ trans: GeoCoordinateTransform) -> MadLineString? {
        guard let sPtr = MadGeometry.geosGeometryCoordinateSequence(self.geos.ownedPtr) else {
            return nil
        }
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceTransform(sPtr, trans: trans)
        let gOwner = MadLineString.geosLineStringCreate(sOwner)
        return MadLineString(gOwner)
    }

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosLineStringLength(_ geosPtr: GeosGeometryPtr) -> Double {
        var value: Double = 0
        _ = GEOSGeomGetLength_r(GeosContext, geosPtr.ptr, &value)
        return value
    }

    internal static func geosLineStringCreate(_ coordinates: CSPtrOwner) -> GPtrOwner {
        guard let ptr = GEOSGeom_createLineString_r(GeosContext, coordinates.ptr) else {
            fatalError("coordinates did not form a ring")
        }
        return GPtrOwnerCreate(ptr)
    }
    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

}
