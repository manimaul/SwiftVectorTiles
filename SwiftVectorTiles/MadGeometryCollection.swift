//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

internal final class MadGeometryCollection: MadGeometry, Sequence {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var geometries: [MadGeometry] = { [unowned self] in
        var geoms = [MadGeometry]()
        let count = MadGeometryCollection.geosGeometryCollectionCount(self.geos.ownedPtr)
        if count > 0 {
            for i in 0 ... (count - 1) {
                let ownedPtr = MadGeometryCollection.geosGeometryCollectionGeometryAt(self.geos.ownedPtr, index: i)
                let unownedPtr = MadGeometry.geosGeometryClone(ownedPtr)
                guard let geom = MadGeometryFactory.madGeometry(unownedPtr) else {
                    fatalError("unable to create geometry collection")
                }
                geoms.append(geom)
            }
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

    convenience init(_ geometries: [MadGeometry]) {
        var geomPtr: OpaquePointer
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if geometries.count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geometries.count)
            for (i, geom) in geometries.enumerated() {
                let mg = geom as! MadGeometry
                let geosPtr = MadGeometry.geosGeometryClone(mg.geos.ownedPtr)
                cPtrPtr?[i] = geosPtr.ptr
            }
            let count = UInt32(geometries.count)
            geomPtr = GEOSGeom_createCollection_r(GeosContext, MadGeometryType.geometryCollection.cType(), cPtrPtr, count)
            cPtrPtr?.deallocate(capacity: geometries.count)
        } else {
            geomPtr = GEOSGeom_createEmptyCollection_r(GeosContext, MadGeometryType.geometryCollection.cType())
        }
        self.init(GPtrOwnerCreate(geomPtr))
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//    todo: look at this
    override public func transform(_ t: GeoCoordinateTransform) -> MadGeometryCollection? {
        return nil
//        var tGeometries = [MadGeometry]()
//        for geometry in geometries {
//            guard let tGeom = geometry.transform(t) else {
//                return nil
//            }
//            tGeometries.append(tGeom)
//        }
//        return MadGeometryCollection(tGeometries)
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

    internal static func geosGeometryCollectionCount(_ geosPtr: GeosGeometryPtr) -> Int {
        return Int(GEOSGetNumGeometries_r(GeosContext, geosPtr.ptr))
    }

    internal static func geosGeometryCollectionGeometryAt(_ geosPtr: GeosGeometryPtr, index: Int) -> GeosGeometryPtr {
        guard let ownedPtr = GEOSGetGeometryN_r(GeosContext, geosPtr.ptr, Int32(index)) else {
            fatalError("index out of bounds")
        }
        return GeosGeometryPtr(ptr: ownedPtr)
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

}
