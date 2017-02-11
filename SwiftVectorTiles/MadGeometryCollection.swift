//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol GeometryCollection: Geometry, Sequence {
    var geometries: [Geometry] { get }
    subscript(index: Int) -> Geometry {
        get
    }

    func makeIterator() -> AnyIterator<Geometry>
}

//region geosGeometryCollection

internal func geosGeometryCollectionCount(_ geosPtr: GeosGeometryPtr) -> Int {
    return Int(GEOSGetNumGeometries_r(GeosContext, geosPtr.ptr))
}

internal func geosGeometryCollectionGeometryAt(_ geosPtr: GeosGeometryPtr, index: Int) -> GeosGeometryPtr {
    guard let ownedPtr = GEOSGetGeometryN_r(GeosContext, geosPtr.ptr, Int32(index)) else {
        fatalError("index out of bounds")
    }
    return GeosGeometryPtr(ptr: ownedPtr)
}

//endregion


internal final class GeosGeometryCollection: GeosGeometry, GeometryCollection {

    lazy var geometries: [Geometry] = { [unowned self] in
        var geoms = [Geometry]()
        let count = geosGeometryCollectionCount(self.geos.ownedPtr)
        if count > 0 {
            for i in 0 ... (count - 1) {
                let ownedPtr = geosGeometryCollectionGeometryAt(self.geos.ownedPtr, index: i)
                let unownedPtr = geosGeometryClone(ownedPtr)
                guard let geom = MadGeometryFactory.madGeometry(unownedPtr) else {
                    fatalError("unable to create geometry collection")
                }
                geoms.append(geom)
            }
        }
        return geoms
    }()

    convenience init(_ geometries: [Geometry]) {
        var geomPtr: OpaquePointer
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if geometries.count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geometries.count)
            for (i, geom) in geometries.enumerated() {
                let mg = geom as! GeosGeometry
                let geosPtr = geosGeometryClone(mg.geos.ownedPtr)
                cPtrPtr?[i] = geosPtr.ptr
            }
            let count = UInt32(geometries.count)
            geomPtr = GEOSGeom_createCollection_r(GeosContext, MadGeometryType.geometryCollection.cType(), cPtrPtr, count)
            cPtrPtr?.deallocate(capacity: geometries.count)
        } else {
            geomPtr = GEOSGeom_createEmptyCollection_r(GeosContext, MadGeometryType.geometryCollection.cType())
        }
        self.init(GeosGeometryPtr(ptr: geomPtr))
    }

    subscript(index: Int) -> Geometry {
        assert(geometries.count > index, "Index out of bounds")
        assert(index >= 0, "index less than zero")
        return geometries[index]
    }

    func makeIterator() -> AnyIterator<Geometry> {
        var index = 0
        return AnyIterator {
            guard index < self.geometries.count else {
                return nil
            }
            let item = self[index]
            index += 1
            return item
        }
    }

    override func transform(_ t: GeoCoordinateTransform) -> GeosGeometryCollection? {
        var tGeometries = [Geometry]()
        for geometry in geometries {
            guard let tGeom = geometry.transform(t) else {
                return nil
            }
            tGeometries.append(tGeom)
        }
        return GeosGeometryCollection(tGeometries)
    }

}
