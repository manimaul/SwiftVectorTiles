//
// Created by Willard Kamp on 2/1/17.
// Copyright (c) 2017 William Kamp. All rights reserved.
//

import Foundation

internal var GeosContext: OpaquePointer = {
    return GEOS_init_r()
}()

public class MadGeometryFactory {

    internal static func madGeometry(_ ptr: OpaquePointer?, owner: MadGeometry? = nil) -> MadGeometry? {
        if let ptr = ptr {
            switch MadGeometryType.typeFromPtr(ptr: ptr) {
            case .point:
                return MadPoint(ptr, owner: owner)
            case .lineString:
                return MadLineString(ptr, owner: owner)
            case .linearRing:
                return MadLinearRing(ptr, owner: owner)
            case .polygon:
                return MadPolygon(ptr, owner: owner)
            case .multiPoint:
                return MadMultiPoint(ptr, owner: owner)
            case .multiLineString:
                return MadMultiLineString(ptr, owner: owner)
            case .multiPolygon:
                return MadMultiPolygon(ptr, owner: owner)
            case .geometryCollection:
                return MadGeometryCollection(ptr, owner: owner)
            default:
                GEOSGeom_destroy_r(GeosContext, ptr)
                return nil
            }
        }
        return nil
    }

    public static func geometryFromWellKnownText(_ wkt: String) -> MadGeometry? {
        let wktReaderPtr = GEOSWKTReader_create_r(GeosContext)
        let geomPtr = GEOSWKTReader_read_r(GeosContext, wktReaderPtr, wkt)
        GEOSWKTReader_destroy_r(GeosContext, wktReaderPtr)
        return madGeometry(geomPtr)
    }

    public static func geometryFromWellKnownBinary(_ wkb: Data) -> MadGeometry? {
        let wkbReaderPtr = GEOSWKBReader_create_r(GeosContext)
        let geomPtr = GEOSWKBReader_read_r(GeosContext, wkbReaderPtr, [UInt8](wkb), wkb.count)
        GEOSWKBReader_destroy_r(GeosContext, wkbReaderPtr)
        return madGeometry(geomPtr)
    }
}