//
//  GeosSwiftVectorTilesTests.swift
//  GeosSwiftVectorTilesTests
//
//  Created by William Kamp on 12/27/16.
//  Copyright © 2016 William Kamp. All rights reserved.
//

import XCTest
@testable import GeosSwiftVectorTiles

class GeosSwiftVectorTilesTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPolygon() {
        let encoder = VectorTileEncoder()
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"
        let geometry = Geometry.create(wkt)
        var atts = [String: Attribute]()
        atts["some_key"] = Attribute.attString("some_value")
        encoder.addFeature(layerName: "land", attributes: nil, geometry: geometry)
        let data = encoder.encode()
        XCTAssertNotNil(data)
        XCTAssertEqual(35, data.count)
    }

    func testWKTPolygon() {
        // initialize an encoder
        let encoder = VectorTileEncoder()

        // create some attributes
        var atts = [String: Attribute]()
        atts["some_key"] = Attribute.attString("some_value")

        // polygon geometry "well known text"
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"

        // add the geometry and it's attributes as a "feature"
        encoder.addFeature(layerName: "land", attributes: atts, geometry: wkt)

        // encode to Mapbox vector tile
        let data :Data = encoder.encode()

        XCTAssertNotNil(data)
        XCTAssertEqual(63, data.count)
    }
    
}
