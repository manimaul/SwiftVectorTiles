//
//  MadPoint.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/24/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation


func geosPointCreate(_ coordinates: CSPtrOwner) -> GPtrOwner {
    guard let ptr = GEOSGeom_createPoint_r(GeosContext, coordinates.ptr) else {
        fatalError("could not create point from coordinate sequence")
    }
    return GPtrOwnerCreate(ptr)
}

func geosPointX(_ geosPtr: GeosGeometryPtr) -> Double {
    guard let seqPtr = geosGeometryCoordinateSequence(geosPtr) else {
        fatalError("could not read point coordinate sequence")
    }
    var x: Double = 0.0
    _ = GEOSCoordSeq_getX_r(GeosContext, seqPtr.ptr, 0, &x)
    return x
}

func geosPointY(_ geosPtr: GeosGeometryPtr) -> Double {
    guard let seqPtr = geosGeometryCoordinateSequence(geosPtr) else {
        fatalError("could not read point coordinate sequence")
    }
    var y: Double = 0.0
    _ = GEOSCoordSeq_getY_r(GeosContext, seqPtr.ptr, 0, &y)
    return y
}


public protocol Point: Geometry {
    var x: Double { get }
    var y: Double { get }
}

internal class GeosPoint: GeosGeometry, Point {

    lazy var x: Double = { [unowned self] in
        return geosPointX(self.geos.ownedPtr)
    }()

    lazy var y: Double = { [unowned self] in
        return geosPointY(self.geos.ownedPtr)
    }()

    internal convenience init(_ coordinateSequence: GeosCoordinateSequence) {
        // cloning the supplied sequence so that we do not take ownership of a
        // sequence that may be deleted in another scope
        let geos = geosCoordinateSequenceClone(coordinateSequence.geos.ownedPtr)
        self.init(geosPointCreate(geos))
    }

    public convenience init(_ coordinate: GeoCoordinate) {
        // this pointer will be owned by the created point
        let geos = geosCoordinateSequenceCreate(coordinate)
        self.init(geosPointCreate(geos))
    }

    override func transform(_ trans: GeoCoordinateTransform) -> GeosPoint? {
        if let sequencePtr = coordinateSequence?.geos {
            let tSequencePtr = geosCoordinateSequenceTransform(sequencePtr.ownedPtr, trans: trans)
            if (geosCoordinateSequenceCount(tSequencePtr.ownedPtr) == 1) {
                let pointPtr = geosPointCreate(tSequencePtr)
                return MadGeometryFactory.madGeometry(pointPtr) as? GeosPoint
            } else {
                tSequencePtr.destroy()
            }
        }
        return nil
    }

}
