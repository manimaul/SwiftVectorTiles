//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public protocol MultiGeometry: Geometry, Sequence {
    var geometries: [Geometry] { get }
    var count: Int { get }
    subscript(index: Int) -> Geometry { get }
    func makeIterator() -> AnyIterator<Geometry>
}

//region geosGeometry

internal func geosMultiGeometryTransform(_ geosPtr: GPtrOwner, trans: GeosCoordinateTransform) -> GPtrOwner {
    let count = geosMultiGeometryCount(geosPtr)
    let type = MadGeometryType.typeFromPtr(geosPtr.ownedPtr).cType()
    var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
    if count > 0 {
        cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geometries.count)
        for i in 0 ... (count - 1) {
            let gPtr = geosMultiGeometryAt(geosPtr, index: i)
            // creating a geometry from an internal (managed) ptr that will not destroy it's ptr
            // when it falls out of scope
            let mGPtr = GPtrOwnerManagedCreate(gPtr.ptr)
            let temp = MadGeometryFactory.madGeometry(mGPtr)

            // don't allow the transformed geometry to destroy it's ptr when it falls out of scope
            // since we will be moving it into a new multi-geometry
            let unManaged = temp.transform(trans) as! GeosGeometry
            let unManagedPtr = GPtrOwnerMakeManaged(unManaged.geos)
            unManaged.geos = unManagedPtr

            cPtrPtr[i] = unManagedPtr.ptr
        }
    }
    let ptr = GEOSGeom_createCollection(type, cPtrPtr, UInt32(count))
    cPtrPtr?.deallocate(capacity: count)
    return GPtrOwnerCreate(ptr)
}

internal func geosMultiGeometryCreate(_ geosPtr: [GPtrOwner]) -> GPtrOwner {
    var geomPtr: OpaquePointer
    let type = geometryType().cType()
    var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
    if tGeometries.count > 0 {
        cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geometries.count)
        for (i, geom) in tGeometries.enumerated() {
            cPtrPtr?[i] = geom.geos
        }
        let count = UInt32(tGeometries.count)
        geomPtr = GEOSGeom_createCollection_r(GeosContext, type, cPtrPtr, count)
        cPtrPtr?.deallocate(capacity: geometries.count)
    } else {
        geomPtr = GEOSGeom_createCollection_r(GeosContext, type, nil, 0)
    }
    guard let retVal = MadGeometryFactory.madGeometry(geomPtr) as? MadMultiGeometry else {
        return nil
    }
    return retVal
}

internal func geosMultiGeometryCount(_ geosPtr: GeosGeometryPtr) -> Int {
    return Int(GEOSGetNumCoordinates_r(GeosContext, geosPtr.ptr))
}

internal func geosMultiGeometryAt(_ geosPtr: GeosGeometryPtr, index: Int) -> GeosGeometryPtr {
    guard let ptr = GEOSGetGeometryN_r(GeosContext, ptr, Int32(index)) else {
        fatalError("index out of bounds")
    }
    return GeosGeometryPtr(ptr: ptr)
}

//endregion

internal class GeosMultiGeometry: GeosGeometry, MultiGeometry {

    internal lazy var geometries: [Geometry] = { [unowned self] in
        var geoms = [Geometry]()
        for i in 0 ... (self.count - 1) {
            let gPtr = geosMultiGeometryAt(self.geos.ownedPtr, index: i)
            let gOwner = geosGeometryClone(gPtr)
            geoms.append(MadGeometryFactory.madGeometry(gOwner))
        }
        return geoms
    }

    internal lazy var count: Int = { [unowned self] in
        return geosMultiGeometryCount(self.geos.ownedPtr)
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

    override public func transform(_ trans: GeoCoordinateTransform) -> GeosMultiGeometry? {
        let gOwner = geosMultiGeometryTransform(self.geos, trans: trans)
        return MadGeometryFactory.madGeometry(gOwner) as? GeosMultiGeometry
    }

}
