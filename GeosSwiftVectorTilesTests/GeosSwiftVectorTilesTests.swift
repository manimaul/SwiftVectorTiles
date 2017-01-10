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
    
    func testEncodePolygon() {
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

    func testTransformPolygon() {
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"
        let g = Geometry.create(wkt) as? Polygon
        let tg = g?.transform { c in
            Coordinate(x: c.x * 2, y: c.y * 2)
        }
        XCTAssertNotNil(tg)
        XCTAssertEqual("POLYGON ((0 0, 8192 0, 8192 8192, 0 8192, 0 0))", tg?.WKT)
    }
    
    func testTransformGeometryCollection() {
        let g1 = Geometry.create("POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))")
        let g2 = Geometry.create("POLYGON ((0 0, 2048 0, 2048 2048, 0 2048, 0 0))")
        XCTAssertNotNil(g1)
        XCTAssertNotNil(g2)
        let gc = GeometryCollection(geometries: [g1!, g2!])
        guard let gct = gc?.transform(transform: { coord in
            Coordinate(x: coord.x * 2, y: coord.y * 2)
        }) else {
            XCTFail()
            return
        }
        let gt1 = gct.geometries[0]
        let gt2 = gct.geometries[1]
        
        XCTAssertEqual("POLYGON ((0 0, 8192 0, 8192 8192, 0 8192, 0 0))", gt1.WKT)
        XCTAssertEqual("POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))", gt2.WKT)
    }
    
    func testEncodeMultiPolygon() {
        let p1 = Geometry.create("POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))") as! Polygon
        let p2 = Geometry.create("POLYGON ((0 0, 2048 0, 2048 2048, 0 2048, 0 0))") as! Polygon
        let mp = MultiPolygon(geometries: [p1, p2])!
        
        let encoder = VectorTileEncoder()
        encoder.addFeature(layerName: "land", attributes: nil, geometry: mp)
        let data = encoder.encode()
        
        XCTAssertNotNil(data)
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
