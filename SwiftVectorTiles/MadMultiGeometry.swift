//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadMultiGeometry: MadGeometry, Sequence {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var geometries: [MadGeometry] = { [unowned self] in
        var geoms = [MadGeometry]()
        for i in 0 ... (self.count - 1) {
            let gPtr = MadMultiGeometry.geosMultiGeometryAt(self.geos.ownedPtr, index: i)
            let gOwner = MadGeometry.geosGeometryClone(gPtr)
            guard let geom = MadGeometryFactory.madGeometry(gOwner) else {
                fatalError("could not create geometry from clone")
            }
            geoms.append(geom)
        }
        return geoms
    }()

    public private(set) lazy var count: Int = { [unowned self] in
        return MadMultiGeometry.geosMultiGeometryCount(self.geos.ownedPtr)
    }()

    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    override public func transform(_ trans: GeoCoordinateTransform) -> MadMultiGeometry? {
        let gOwner = MadMultiGeometry.geosMultiGeometryTransform(self.geos, trans: trans)
        return MadGeometryFactory.madGeometry(gOwner) as? MadMultiGeometry
    }

    //endregion

    //region CONFORMS Sequence ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public subscript(index: Int) -> MadGeometry {
        assert(geometries.count > index, "Index out of bounds")
        assert(index >= 0, "index less than zero")
        return geometries[index]
    }

    public func makeIterator() -> AnyIterator<MadGeometry> {
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

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosMultiGeometryTransform(_ geosPtr: GPtrOwner, trans: GeoCoordinateTransform) -> GPtrOwner {
        let count = MadMultiGeometry.geosMultiGeometryCount(geosPtr.ownedPtr)
        let type = MadGeometryType.typeFromPtr(geosPtr.ownedPtr).cType()
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: count)
            for i in 0 ... (count - 1) {
                let gPtr = geosMultiGeometryAt(geosPtr.ownedPtr, index: i)
                // creating a geometry from an internal (managed) ptr that will not destroy it's ptr
                // when it falls out of scope
                let mGPtr = GPtrOwnerManagedCreate(gPtr.ptr)
                guard let temp = MadGeometryFactory.madGeometry(mGPtr) else {
                    fatalError("error creating temporary geometry")
                }

                // don't allow the transformed geometry to destroy it's ptr when it falls out of scope
                // since we will be moving it into a new multi-geometry
                guard let unManaged = temp.transform(trans) else {
                    fatalError("error transforming geometry")
                }
                let unManagedPtr = GPtrOwnerMakeManaged(unManaged.geos)
                unManaged.geos = unManagedPtr

                cPtrPtr?[i] = unManagedPtr.ptr
            }
        }
        guard let ptr = GEOSGeom_createCollection_r(GeosContext, type, cPtrPtr, UInt32(count)) else {
            fatalError("could not create geometry collection")
        }
        cPtrPtr?.deallocate(capacity: count)
        return GPtrOwnerCreate(ptr)
    }

    internal static func geosMultiGeometryCreate(_ geosPtrs: [GPtrOwner], geometryType: MadGeometryType) -> GPtrOwner {
        var geomPtr: OpaquePointer
        let type = geometryType.cType()
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if geosPtrs.count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geosPtrs.count)
            for (i, geom) in geosPtrs.enumerated() {
                cPtrPtr?[i] = geom.ptr
            }
            let count = UInt32(geosPtrs.count)
            geomPtr = GEOSGeom_createCollection_r(GeosContext, type, cPtrPtr, count)
            cPtrPtr?.deallocate(capacity: geosPtrs.count)
        } else {
            geomPtr = GEOSGeom_createCollection_r(GeosContext, type, nil, 0)
        }
        return GPtrOwnerCreate(geomPtr)
    }

    internal static func geosMultiGeometryCount(_ geosPtr: GeosGeometryPtr) -> Int {
        return Int(GEOSGetNumGeometries_r(GeosContext, geosPtr.ptr))
    }

    internal static func geosMultiGeometryAt(_ geosPtr: GeosGeometryPtr, index: Int) -> GeosGeometryPtr {
        guard let ptr = GEOSGetGeometryN_r(GeosContext, geosPtr.ptr, Int32(index)) else {
            fatalError("index out of bounds")
        }
        return GeosGeometryPtr(ptr: ptr)
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

}
