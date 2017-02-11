//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol LineString: Geometry {
    var length: Double { get }
    var isCounterClockWise: Bool { get }
    func reverse() -> LineString?
}

func geosLineStringLength(_ geosPtr: GeosGeometryPtr) -> Double {
    var value: Double = 0
    _ = GEOSGeomGetLength_r(GeosContext, geosPtr.ptr, &value)
    return value
}

func geosLineStringCreate(_ coordinates: CSPtrOwner) -> GPtrOwner {
    guard let ptr = GEOSGeom_createLineString_r(GeosContext, coordinates.ptr) else {
        fatalError("coordinates did not form a ring")
    }
    return GPtrOwnerCreate(ptr)
}

internal final class GeosLineString: GeosLineString, LineString {

    public lazy var length: Double = { [unowned self] in
        return geosLineStringLength(self.geos.ownedPtr)
    }()

    public lazy var isCounterClockWise: Bool = { [unowned self] in
        return self.coordinateSequence!.isCounterClockWise
    }()

    convenience init(_ coordinateSequence: GeosCoordinateSequence) {
        let sOwner = geosCoordinateSequenceClone(coordinateSequence.geos.ownedPtr)
        let gOwner = geosLineStringCreate(sOwner)
        self.init(gOwner)
    }

    convenience init(_ coordinates: [GeoCoordinate]) {
        let sOwner = geosCoordinateSequenceCreate(coordinates)
        let gOwner = geosLineStringCreate(sOwner)
        self.init(gOwner)
    }

    convenience init(_ coordinates: GeoCoordinate...) {
        let sOwner = geosCoordinateSequenceCreate(coordinates)
        let gOwner = geosLineStringCreate(sOwner)
        self.init(gOwner)
    }

    public func reverse() -> GeosLineString? {
        guard let ownedCoordinateSequence = geosGeometryCoordinateSequence(self.geos.ownedPtr) else {
            return nil
        }
        let sOwner = geosCoordinateSequenceReversed(ownedCoordinateSequence)
        let gOwner = geosLineStringCreate(sOwner)
        return GeosLineString(gOwner)
    }

    override public func transform(_ trans: GeoCoordinateTransform) -> GeosLineString? {
        guard let sPtr = geosGeometryCoordinateSequence(self.geos.ownedPtr) else {
            return nil
        }
        let sOwner = geosCoordinateSequenceTransform(sPtr, trans: trans)
        let gOwner = geosLineStringCreate(sOwner)
        return GeosLineString(gOwner)
    }
}
