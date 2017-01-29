//
//  MadGeometryTests.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

import XCTest
@testable import SwiftVectorTiles

class MadGeometryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateMadPolygon() {
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"
        guard let polygon = MadGeometryFactory.geometryFromWellKnownText(wkt) as? MadPolygon else {
            XCTFail("failed to create MadPolygon")
            return
        }
        XCTAssertFalse(polygon.empty())
    }
    
    func testTransformPolygon() {
        let wkt = "POLYGON ((0 0, 4096 0, 4096 4096, 0 4096, 0 0))"
        let g = MadGeometryFactory.geometryFromWellKnownText(wkt) as! MadPolygon
        let tg = g.transform { c in
            let cd = c
            return MadCoordinate(x: cd.x * 2, y: cd.y * 2)
        }
        XCTAssertNotNil(tg)
        XCTAssertEqual("POLYGON ((0 0, 8192 0, 8192 8192, 0 8192, 0 0))", tg?.wellKnownText())
    }
}
