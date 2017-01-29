//
//  MadPolygon.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/23/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


public class MadMultiGeometry: MadGeometry, Sequence {

    private var geometries = [MadGeometry]()

    override internal init(_ ptr: GeosGeometryPointer) {
        super.init(ptr)
        let count = Int(GEOSGetNumGeometries_r(GeosContext, ptr.ptr))
        for i in 0...Int32(count - 1) {
            guard let geomPtr = GEOSGetGeometryN_r(GeosContext, ptr.ptr, i) else {
                fatalError("the supplied geometry was not a collection")
            }
            let ggp = GeosGeometryPointer(ptr: geomPtr, owner: self)
            geometries.append(MadGeometry(ggp))
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

}
