//
//  MadPoint.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/24/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public class MadPoint: MadGeometry {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var x: Double = { [unowned self] in
        return MadPoint.geosPointX(self.geos.ownedPtr)
    }()

    public private(set) lazy var y: Double = { [unowned self] in
        return MadPoint.geosPointY(self.geos.ownedPtr)
    }()

    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public convenience init(_ coordinateSequence: MadCoordinateSequence) {
        // cloning the supplied sequence so that we do not take ownership of a
        // sequence that may be deleted in another scope
        let geos = MadCoordinateSequence.geosCoordinateSequenceClone(coordinateSequence.geos.ownedPtr)
        self.init(MadPoint.geosPointCreate(geos))
    }

    public convenience init(_ coordinate: GeoCoordinate) {
        // this pointer will be owned by the created point
        let geos = MadCoordinateSequence.geosCoordinateSequenceCreate(coordinate)
        self.init(MadPoint.geosPointCreate(geos))
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    override public func transform(_ trans: GeoCoordinateTransform) -> MadPoint? {
        if let sequencePtr = coordinateSequence?.geos {
            let tSequencePtr = MadCoordinateSequence.geosCoordinateSequenceTransform(sequencePtr.ownedPtr, trans: trans)
            if (MadCoordinateSequence.geosCoordinateSequenceCount(tSequencePtr.ownedPtr) == 1) {
                let pointPtr = MadPoint.geosPointCreate(tSequencePtr)
                return MadGeometryFactory.madGeometry(pointPtr) as? MadPoint
            } else {
                tSequencePtr.destroy()
            }
        }
        return nil
    }

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosPointCreate(_ coordinates: CSPtrOwner) -> GPtrOwner {
        guard let ptr = GEOSGeom_createPoint_r(GeosContext, coordinates.ptr) else {
            fatalError("could not create point from coordinate sequence")
        }
        return GPtrOwnerCreate(ptr)
    }

    internal static func geosPointX(_ geosPtr: GeosGeometryPtr) -> Double {
        guard let seqPtr = geosGeometryCoordinateSequence(geosPtr) else {
            fatalError("could not read point coordinate sequence")
        }
        var x: Double = 0.0
        _ = GEOSCoordSeq_getX_r(GeosContext, seqPtr.ptr, 0, &x)
        return x
    }

    internal static func geosPointY(_ geosPtr: GeosGeometryPtr) -> Double {
        guard let seqPtr = geosGeometryCoordinateSequence(geosPtr) else {
            fatalError("could not read point coordinate sequence")
        }
        var y: Double = 0.0
        _ = GEOSCoordSeq_getY_r(GeosContext, seqPtr.ptr, 0, &y)
        return y
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

}
