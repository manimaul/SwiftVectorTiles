//
// Created by Willard Kamp on 2/1/17.
// Copyright (c) 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadGeometryFactory {

    internal static func madGeometry(_ geos: GPtrOwner?) -> MadGeometry? {
        if let geos = geos {
            switch MadGeometryType.typeFromPtr(geos.ownedPtr) {
            case .point:
                return MadPoint(geos)
            case .lineString:
                return MadLineString(geos)
            case .linearRing:
                return MadLinearRing(geos)
            case .polygon:
                return MadPolygon(geos)
            case .multiPoint:
                return MadMultiPoint(geos)
            case .multiLineString:
                return MadMultiLineString(geos)
            case .multiPolygon:
                return MadMultiPolygon(geos)
            case .geometryCollection:
                return MadGeometryCollection(geos)
            default:
                geos.destroy()
                return nil
            }
        }
        return nil
    }

    public static func geometryFromWellKnownText(_ wkt: String) -> MadGeometry? {
        guard let owner = MadGeometry.geosGeometryFromWellKnownText(wkt) else {
            return nil
        }
        return madGeometry(owner)
    }

    public static func geometryFromWellKnownBinary(_ wkb: Data) -> MadGeometry? {
        guard let owner = MadGeometry.geosGeometryFromWellKnownBinary(wkb) else {
            return nil
        }
        return madGeometry(owner)
    }
}
