//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

internal final class MadLinearRing: MadGeometry {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public lazy var length: Double = { [unowned self] in
        return MadLineString.geosLineStringLength(self.geos.ownedPtr)
    }()

    public lazy var isCounterClockWise: Bool = { [unowned self] in
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
        let gOwner = MadLinearRing.geosLinearRingCreate(sOwner)
        self.init(gOwner)
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public func reverse() -> MadLinearRing? {
        guard let sOwned = MadGeometry.geosGeometryCoordinateSequence(geos.ownedPtr) else {
            return nil
        }
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceReversed(sOwned)
        return MadLinearRing(MadLinearRing.geosLinearRingCreate(sOwner))
    }

    override public func transform(_ trans: GeoCoordinateTransform) -> MadLinearRing? {
        guard let sOwned = MadGeometry.geosGeometryCoordinateSequence(geos.ownedPtr) else {
            return nil
        }
        let sOwner = MadCoordinateSequence.geosCoordinateSequenceTransform(sOwned, trans: trans)
        let sOwnerReversed = MadCoordinateSequence.geosCoordinateSequenceReversed(sOwned)
        sOwner.destroy()
        return MadLinearRing(MadLinearRing.geosLinearRingCreate(sOwnerReversed))
    }

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosLinearRingCreate(_ coordinates: CSPtrOwner) -> GPtrOwner {
        guard let ptr = GEOSGeom_createLinearRing_r(GeosContext, coordinates.ptr) else {
            fatalError("coordinates did not form a ring")
        }
        return GPtrOwnerCreate(ptr)
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

}
