//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadMultiGeometry: MadGeometry, Sequence {

    internal var geometries = [MadGeometry]()

    override internal init(_ ptr: OpaquePointer, owner: MadGeometry? = nil) {
        super.init(ptr, owner: owner)
        let count = Int(GEOSGetNumGeometries_r(GeosContext, ptr))
        for i in 0...Int32(count - 1) {
            guard let geomPtr = GEOSGetGeometryN_r(GeosContext, ptr, i),
                  let geometry = MadGeometryFactory.madGeometry(geomPtr, owner: self) else {
                fatalError("the supplied geometry was not a collection")
            }
            geometries.append(geometry)
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

    override public func transform(_ t: MadCoordinateTransform) -> MadMultiGeometry? {
        var tGeometries = [MadGeometry]()
        for geometry in geometries {
            guard let tGeom = geometry.transform(t) else {
                return nil
            }
            tGeometries.append(tGeom)
        }

        var geomPtr: OpaquePointer
        let type = geometryType().cType()
        var cPtrPtr: UnsafeMutablePointer<OpaquePointer?>? = nil
        if tGeometries.count > 0 {
            cPtrPtr = UnsafeMutablePointer<OpaquePointer?>.allocate(capacity: geometries.count)
            for (i, geom) in tGeometries.enumerated() {
                cPtrPtr?[i] = geom.ptr
            }
            let count = UInt32(tGeometries.count)
            geomPtr = GEOSGeom_createCollection_r(GeosContext, type, cPtrPtr, count)
        } else {
            geomPtr = GEOSGeom_createCollection_r(GeosContext, type, nil, 0)
        }
        guard let retVal = MadGeometryFactory.madGeometry(geomPtr) as? MadMultiGeometry else {
            return nil
        }
        return retVal
    }

}
