//
// Created by Willard Kamp on 2/1/17.
// Copyright (c) 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadGeometryFactory {

    internal static func madGeometry(_ geos: GPtrOwner?) -> Geometry? {
        if let geos = geos {
            switch MadGeometryType.typeFromPtr(geos.ownedPtr) {
            case .point:
                return GeosPoint(geos)
            case .lineString:
                return GeosLineString(geos)
            case .linearRing:
                return GeosLinearRing(geos)
            case .polygon:
                return GeosPolygon(geos)
            case .multiPoint:
                return GeosMultiPoint(geos)
            case .multiLineString:
                return GeosMultiLineString(geos)
            case .multiPolygon:
                return GeosMultiPolygon(geos)
            case .geometryCollection:
                return GeosGeometryCollection(geos)
            default:
                geos.destroy()
                return nil
            }
        }
        return nil
    }

    public static func geometryFromWellKnownText(_ wkt: String) -> Geometry? {
        guard let owner = geosGeometryFromWellKnownText(wkt) else {
            return nil
        }
        return madGeometry(owner)
    }

    public static func geometryFromWellKnownBinary(_ wkb: Data) -> Geometry? {
        guard let owner = geosGeometryFromWellKnownBinary(wkb) else {
            return nil
        }
        return madGeometry(owner)
    }
}