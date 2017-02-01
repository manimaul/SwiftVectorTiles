//
//  SwiftVectorTilesTests.swift
//  SwiftVectorTilesTests
//
//  Created by William Kamp on 12/27/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import XCTest
@testable import SwiftVectorTiles

class SwiftVectorTilesTests: XCTestCase {

    func testEncodeMultiPolygon() {
        let wkt = "MULTIPOLYGON (((0 0, 4096 0, 4096 4096, 0 4096, 0 0)), ((0 0, 2048 0, 2048 2048, 0 2048, 0 0)))"
        guard let multiGeom = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadMultiPolygon else {
            XCTFail("failed to create multi-polygon")
            return
        }

        let encoder = VectorTileEncoder()
        encoder.addFeature(layerName: "land", attributes: nil, geometry: multiGeom)
        let data = encoder.encode()

        XCTAssertNotNil(data)
    }

    func testEncodePolygon() {
        let encoder = VectorTileEncoder()
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"
        let geometry = MadGeometryFactory.geometryFromWellKnownText(wkt) as! MadPolygon
        var atts = [String: Attribute]()
        atts["some_key"] = Attribute.attString("some_value")
        encoder.addFeature(layerName: "land", attributes: atts, geometry: geometry)
        let data = encoder.encode()
        XCTAssertNotNil(data)
        let expected :[UInt8] = [26, 60, 10, 4, 108, 97, 110, 100, 18, 23, 18, 2, 0, 0, 24, 3, 34, 15, 9, 0, 128, 66,
                                 26, 0, 255, 65, 128, 66, 0, 0, 128, 66, 15, 26, 8, 115, 111, 109, 101, 95, 107, 101,
                                 121, 34, 12, 10, 10, 115, 111, 109, 101, 95, 118, 97, 108, 117, 101, 40, 128, 32, 120, 2]
        XCTAssertEqual(expected, [UInt8](data))
    }

}
