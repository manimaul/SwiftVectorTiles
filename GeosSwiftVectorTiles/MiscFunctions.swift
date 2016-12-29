//
//  MiscFunctions.swift
//
//  Created by Andrea Cremaschi on 03/02/16.
//  Copyright (c) 2016 andreacremaschi. All rights reserved.
//

import Foundation

/**
 Misc functions
 */

public extension Geometry {
    
    func empty() -> Bool {        
        let result = GEOSisEmpty(self.geometry)
        return result == 1
    }
    
    func area() -> Double {
        var ar: Double = 0
        
        let result = GEOSArea_r(GEOS_HANDLE, self.geometry, &ar)
        assert (result == 1)
        return ar
    }
    
    func length() -> Double {
        var ar: Double = 0
        
        let result = GEOSLength_r(GEOS_HANDLE, self.geometry, &ar)
        assert (result == 1)
        return ar
    }

    /// - returns: The distance between the two geometries, expressed in the SRID of the first
    func distance(geometry: Geometry) -> Double {
        var dist: Double = 0
        
        let result = GEOSDistance_r(GEOS_HANDLE, self.geometry, geometry.geometry, &dist)
        assert (result == 1)
        return dist
    }

    // TODO: implement other misc functions
//    public func GEOSArea_r(handle: GEOSContextHandle_t, _ g: COpaquePointer, _ area: UnsafeMutablePointer<Double>) -> Int32
//    public func GEOSLength_r(handle: GEOSContextHandle_t, _ g: COpaquePointer, _ length: UnsafeMutablePointer<Double>) -> Int32
//    public func GEOSHausdorffDistance_r(handle: GEOSContextHandle_t, _ g1: COpaquePointer, _ g2: COpaquePointer, _ dist: UnsafeMutablePointer<Double>) -> Int32
//    public func GEOSHausdorffDistanceDensify_r(handle: GEOSContextHandle_t, _ g1: COpaquePointer, _ g2: COpaquePointer, _ densifyFrac: Double, _ dist: UnsafeMutablePointer<Double>) -> Int32
//    public func GEOSGeomGetLength_r(handle: GEOSContextHandle_t, _ g: COpaquePointer, _ length: UnsafeMutablePointer<Double>) -> Int32

}
