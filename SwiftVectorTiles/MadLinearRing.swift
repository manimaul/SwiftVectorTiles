//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol LinearRing: Geometry {
    var length: Double { get }
    var isCounterClockWise: Bool { get }
    func reverse() -> Self?
}


internal func geosLinearRingCreate(_ coordinates: CSPtrOwner) -> GPtrOwner {
    guard let ptr = GEOSGeom_createLinearRing_r(GeosContext, coordinates.ptr) else {
        fatalError("coordinates did not form a ring")
    }
    return GPtrOwnerCreate(ptr)
}

internal final class GeosLinearRing: GeosGeometry, LinearRing {

    public lazy var length: Double = { [unowned self] in
        return geosLineStringLength(self.geos.ownedPtr)
    }()

    public lazy var isCounterClockWise: Bool = { [unowned self] in
        return self.coordinateSequence!.isCounterClockWise
    }()

    convenience init(_ coordinateSequence: GeosCoordinateSequence) {
        let sOwner = geosCoordinateSequenceClone(coordinateSequence.geos.ownedPtr)
        let gOwner = geosLinearRingCreate(sOwner)
        self.init(gOwner)
    }

    public func reverse() -> GeosLinearRing? {
        guard let sOwned = geosGeometryCoordinateSequence(geos.ownedPtr) else {
            return nil
        }
        let sOwner = geosCoordinateSequenceReversed(sOwned)
        return GeosLinearRing(geosLinearRingCreate(sOwner))
    }

    override public func transform(_ trans: GeoCoordinateTransform) -> GeosLinearRing? {
        guard let sOwned = geosGeometryCoordinateSequence(geos.ownedPtr) else {
            return nil
        }
        let sOwner = geosCoordinateSequenceTransform(sOwned, trans: trans)
        let sOwnerReversed = geosCoordinateSequenceReversed(sOwned)
        sOwner.destroy()
        return GeosLinearRing(geosLinearRingCreate(sOwnerReversed))
    }

}
