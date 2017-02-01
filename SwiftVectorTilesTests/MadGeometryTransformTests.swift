//
//  SwiftVectorTilesTests.swift
//  SwiftVectorTilesTests
//
//  Created by William Kamp on 12/27/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import XCTest
@testable import SwiftVectorTiles

class MadGeometryTransformTests: XCTestCase {

    func testTransformPolygon() {
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"
        let g = MadGeometryFactory.geometryFromWellKnownText(wkt) as! MadPolygon
        let tg = g.transform { c in
            return MadCoordinate(x: c.x * 2, y: c.y * 2)
        }
        XCTAssertNotNil(tg)
        let expected = "POLYGON ((0.0000000000000000 0.0000000000000000, " +
                "8192.0000000000000000 0.0000000000000000, " +
                "8192.0000000000000000 8192.0000000000000000, " +
                "0.0000000000000000 8192.0000000000000000, " +
                "0.0000000000000000 0.0000000000000000))"
        XCTAssertEqual(expected, tg?.wellKnownText())
    }

    func testTransformGeometryCollection() {
        let wkt = "GEOMETRYCOLLECTION(POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0)), POINT(6 10))"
        guard let multiGeom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadGeometryCollection else {
            XCTFail("")
            return
        }
        guard let gct = multiGeom.transform({ coord in
            MadCoordinate(x: coord.x * 2, y: coord.y * 2)
        }) else {
            XCTFail()
            return
        }

        let gt1 = gct[0]
        let gt2 = gct[1]

        let expected1 = "POLYGON ((0.0000000000000000 0.0000000000000000, " +
                "8192.0000000000000000 0.0000000000000000, " +
                "8192.0000000000000000 8192.0000000000000000, " +
                "0.0000000000000000 8192.0000000000000000, " +
                "0.0000000000000000 0.0000000000000000))"
        XCTAssertEqual(expected1, gt1.wellKnownText())

        let expected2 = "POINT (12.0000000000000000 20.0000000000000000)"
        XCTAssertEqual(expected2, gt2.wellKnownText())
    }

    func testTransformMultiPolygon() {
        let wkt = "MULTIPOLYGON (((0 0, 4096 0, 4096 4096, 0 4096, 0 0)), ((0 0, 2048 0, 2048 2048, 0 2048, 0 0)))"
        guard let multiGeom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadMultiPolygon else {
            XCTFail("")
            return
        }
        guard let gct = multiGeom.transform({ coord in
            MadCoordinate(x: coord.x * 2, y: coord.y * 2)
        }) else {
            XCTFail()
            return
        }

        let gt1 = gct[0]
        let gt2 = gct[1]

        let expected1 = "POLYGON ((0.0000000000000000 0.0000000000000000, " +
                "8192.0000000000000000 0.0000000000000000, " +
                "8192.0000000000000000 8192.0000000000000000, " +
                "0.0000000000000000 8192.0000000000000000, " +
                "0.0000000000000000 0.0000000000000000))"
        XCTAssertEqual(expected1, gt1.wellKnownText())

        let expected2 = "POLYGON ((0.0000000000000000 0.0000000000000000, " +
                "4096.0000000000000000 0.0000000000000000, " +
                "4096.0000000000000000 4096.0000000000000000, " +
                "0.0000000000000000 4096.0000000000000000, " +
                "0.0000000000000000 0.0000000000000000))"
        XCTAssertEqual(expected2, gt2.wellKnownText())
    }

}
