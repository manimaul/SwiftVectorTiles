//
// Created by William Kamp on 1/29/17.
// Copyright (c) 2017 William Kamp. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftVectorTiles

class MadGeometryTypeTests: XCTestCase {

    func testPoint() {
        let wkt = "POINT(6 10)"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadPoint else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.point, geom.geometryType())
    }

    func testMultiPoint() {
        let wkt = "MULTIPOINT(3.5 5.6, 4.8 10.5)"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadMultiPoint else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.multiPoint, geom.geometryType())
    }

    func testPolygon() {
        let wkt = "POLYGON((1 1,5 1,5 5,1 5,1 1),(2 2, 3 2, 3 3, 2 3,2 2))"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadPolygon else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.polygon, geom.geometryType())
    }

    func testMultiPolygon() {
        let wkt = "MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2, 3 2, 3 3, 2 3,2 2)),((3 3,6 2,6 4,3 3)))"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadMultiPolygon else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.multiPolygon, geom.geometryType())
    }

    func testLineString() {
        let wkt = "LINESTRING (3 4,10 50,20 25)"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadLineString else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.lineString, geom.geometryType())
    }

    func testMultiLineString() {
        let wkt = "MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadMultiLineString else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.multiLineString, geom.geometryType())
    }

    func testLinearRing() {
        let wkt = "LINEARRING (3 4,10 50,20 25,3 4)"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadLinearRing else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.linearRing, geom.geometryType())
    }

    func testGeometryCollection() {
        let wkt = "GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))"
        guard let geom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadMultiGeometry else {
            XCTFail("invalid wkt")
            return
        }
        XCTAssertEqual(MadGeometryType.geometryCollection, geom.geometryType())
    }
}



