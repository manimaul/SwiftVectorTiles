//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadGeometryCollection : MadGeometry, Sequence {

    internal var geometries = [MadGeometry]()

    public convenience init(_ geometries: [MadGeometry]) {
        var geomPtr: OpaquePointer
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if geometries.count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geometries.count)
            for (i, geom) in geometries.enumerated() {
                cPtrPtr?[i] = geom.ptr
            }
            let count = UInt32(geometries.count)
            geomPtr = GEOSGeom_createCollection_r(GeosContext, MadGeometryType.geometryCollection.cType(), cPtrPtr, count)
            cPtrPtr?.deallocate(capacity: geometries.count)
        } else {
            geomPtr = GEOSGeom_createEmptyCollection_r(GeosContext, MadGeometryType.geometryCollection.cType())
        }
        self.init(geomPtr)
    }

    override internal init(_ ptr: OpaquePointer, owner: MadGeometry? = nil) {
        super.init(ptr, owner: owner)
        if MadGeometryType.typeFromPtr(ptr: ptr) != MadGeometryType.geometryCollection {
            fatalError("the supplied geometry was not a geometry collection")
        }
        let count = Int(GEOSGetNumGeometries_r(GeosContext, ptr))
        if count > 0 {
            for i in 0 ... Int32(count - 1) {
                guard let geomPtr = GEOSGetGeometryN_r(GeosContext, ptr, i),
                      let tGeom = MadGeometryFactory.madGeometry(geomPtr, owner: self) else {
                    fatalError("the supplied geometry was not a collection")
                }
                geometries.append(tGeom)
            }
        }
    }

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

    override public func transform(_ t: MadCoordinateTransform) -> MadGeometryCollection? {
        var tGeometries = [MadGeometry]()
        for geometry in geometries {
            guard let tGeom = geometry.transform(t) else {
                return nil
            }
            tGeometries.append(tGeom)
        }
        return MadGeometryCollection(tGeometries)
    }

}
