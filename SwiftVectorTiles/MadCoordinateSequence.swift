//
//  MadCoordinateSequence.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/24/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

public typealias GeoCoordinate = (Double, Double)
public typealias GeoCoordinateTransform = (GeoCoordinate) -> GeoCoordinate

private let DIMENSIONS = UInt32(2)

public final class MadCoordinateSequence: Sequence, Equatable {

    //region PUBLIC PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public private(set) lazy var count: Int = { [unowned self] in
        return MadCoordinateSequence.geosCoordinateSequenceCount(self.geos.ownedPtr)
    }()

    public private(set) lazy var isCounterClockWise: Bool = { [unowned self] in
        return self.getIsCCW()
    }()

    //endregion

    //region INTERNAL PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal let geos: CSPtrOwner

    //endregion

    //region PRIVATE PROPERTIES ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //endregion

    //region INITIALIZERS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public convenience init(_ coordinates: [GeoCoordinate]) {
        self.init(MadCoordinateSequence.geosCoordinateSequenceCreate(coordinates))
    }

    public convenience init(_ coordinates: GeoCoordinate...) {
        self.init(coordinates)
    }

    internal init(_ geos: CSPtrOwner) {
        self.geos = geos
    }

    deinit {
        self.geos.destroy()
    }

    //endregion

    //region PUBLIC FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public func clone() -> MadCoordinateSequence? {
        return MadCoordinateSequence(MadCoordinateSequence.geosCoordinateSequenceClone(geos.ownedPtr))
    }

    public func transform(trans: GeoCoordinateTransform) -> MadCoordinateSequence? {
        return MadCoordinateSequence(MadCoordinateSequence.geosCoordinateSequenceTransform(geos.ownedPtr, trans: trans))
    }

    //endregion

    //region CONFORMS Sequence ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public subscript(index: Int) -> GeoCoordinate {
        return MadCoordinateSequence.geosCoordinateSequenceCoordinateAt(geos.ownedPtr, index: index)
    }

    public func makeIterator() -> AnyIterator<GeoCoordinate> {
        var index = 0
        return AnyIterator {
            guard index < self.count else {
                return nil
            }
            let item = self[index]
            index += 1
            return item
        }
    }

    //endregion

    //region CONFORMS Equatable ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    public static func ==(lhs: MadCoordinateSequence, rhs: MadCoordinateSequence) -> Bool {
        if lhs.count == rhs.count {
            for (lhsCoord, rhsCoord) in zip(lhs, rhs) {
                if lhsCoord.0 != rhsCoord.0 && lhsCoord.1 != rhsCoord.1 {
                    return false
                }
            }
            return true
        }
        return false
    }

    //endregion

    //region INTERNAL FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    internal static func geosCoordinateSequenceCreate(_ coordinates: GeoCoordinate...) -> CSPtrOwner {
        return geosCoordinateSequenceCreate(coordinates)
    }

    internal static func geosCoordinateSequenceCreate(_ coordinates: [GeoCoordinate]) -> CSPtrOwner {
        let count = UInt32(coordinates.count)
        guard let ptr = GEOSCoordSeq_create_r(GeosContext, count, 2) else {
            fatalError("fatal error creating coordinate sequence")
        }
        for (i, coord) in coordinates.enumerated() {
            let index = UInt32(i)
            GEOSCoordSeq_setX_r(GeosContext, ptr, index, coord.0)
            GEOSCoordSeq_setY_r(GeosContext, ptr, index, coord.1)
        }
        return CSPtrOwnerCreate(ptr)
    }

    internal static func geosCoordinateSequenceClone(_  geosPtr: GeosCoordinateSequencePtr) -> CSPtrOwner {
        guard let ptr = GEOSCoordSeq_clone_r(GeosContext, geosPtr.ptr) else {
            fatalError("fatal error cloning coordinate sequence")
        }
        return CSPtrOwnerCreate(ptr)
    }

    internal static func geosCoordinateSequenceTransform(_  geosPtr: GeosCoordinateSequencePtr, trans: GeoCoordinateTransform) -> CSPtrOwner {
        let count = UInt32(geosCoordinateSequenceCount(geosPtr))
        guard let ptr = GEOSCoordSeq_create_r(GeosContext, count, DIMENSIONS) else {
            fatalError("error transforming coordinate sequence")
        }
        if (count > 0) {
            var coord = (0.0, 0.0)
            for i in 0 ... (count - 1) {
                _ = GEOSCoordSeq_getX_r(GeosContext, geosPtr.ptr, i, &coord.0)
                _ = GEOSCoordSeq_getY_r(GeosContext, geosPtr.ptr, i, &coord.1)
                coord = trans(coord)
                _ = GEOSCoordSeq_setX_r(GeosContext, ptr, i, coord.0)
                _ = GEOSCoordSeq_setY_r(GeosContext, ptr, i, coord.1)
            }
        }
        return CSPtrOwnerCreate(ptr)
    }

    internal static func geosCoordinateSequenceReversed(_  geosPtr: GeosCoordinateSequencePtr) -> CSPtrOwner {
        let count = UInt32(geosCoordinateSequenceCount(geosPtr))
        guard let ptr = GEOSCoordSeq_create_r(GeosContext, count, DIMENSIONS) else {
            fatalError("error transforming coordinate sequence")
        }
        if (count > 0) {
            var coord = (0.0, 0.0)
            let r = count - 1
            for i in 0 ... r {
                _ = GEOSCoordSeq_getX_r(GeosContext, geosPtr.ptr, r - i, &coord.0)
                _ = GEOSCoordSeq_getY_r(GeosContext, geosPtr.ptr, r - i, &coord.1)
                _ = GEOSCoordSeq_setX_r(GeosContext, ptr, i, coord.0)
                _ = GEOSCoordSeq_setY_r(GeosContext, ptr, i, coord.1)
            }
        }
        return CSPtrOwnerCreate(ptr)
    }

    internal static func geosCoordinateSequenceCount(_  geosPtr: GeosCoordinateSequencePtr) -> Int {
        var num: UInt32 = 0
        GEOSCoordSeq_getSize_r(GeosContext, geosPtr.ptr, &num)
        return Int(num)
    }

    internal static func geosCoordinateSequenceCoordinateAt(_  geosPtr: GeosCoordinateSequencePtr, index: Int) -> GeoCoordinate {
        var x: Double = 0
        var y: Double = 0
        assert(geosCoordinateSequenceCount(geosPtr) > index, "Index out of bounds")
        assert(index >= 0, "index less than zero")
        let i = UInt32(index)
        GEOSCoordSeq_getX_r(GeosContext, geosPtr.ptr, i, &x);
        GEOSCoordSeq_getY_r(GeosContext, geosPtr.ptr, i, &y);
        return (x, y)
    }

    internal static func geosCoordinateSequenceCoordinates(_ geosPtr: GeosCoordinateSequencePtr) -> [GeoCoordinate] {
        let count = geosCoordinateSequenceCount(geosPtr)
        var coordinates = [GeoCoordinate]()
        if count > 0 {
            for i in 0...(count - 1) {
                coordinates.append(geosCoordinateSequenceCoordinateAt(geosPtr, index: i))
            }
        }
        return coordinates
    }

    //endregion

    //region PRIVATE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    private func getIsCCW() -> Bool {
        let ring = [GeoCoordinate](self)

        // # of points without closing endpoint
        let nPts = ring.count - 1

        // sanity check
        if nPts < 3 {
            fatalError("Ring has fewer than 3 points, so orientation cannot be determined")
        }

        // find highest point
        var hiPt = ring[0]
        var hiIndex = 0

        for i in 0 ... ring.count - 1 {
            let p = ring[i]
            if p.1 > hiPt.1 {
                hiPt = p
                hiIndex = i
            }
        }

        // find distinct point before highest point
        var iPrev = hiIndex
        repeat {
            iPrev = iPrev - 1
            if iPrev < 0 {
                iPrev = nPts
            }
        } while ring[iPrev] == hiPt && iPrev != hiIndex

        // find distinct point after highest point
        var iNext = hiIndex
        repeat {
            iNext = (iNext + 1) % nPts
        } while ring[iNext] == hiPt && iNext != hiIndex

        let prev = ring[iPrev]
        let next = ring[iNext]

        /**
         * This check catches cases where the ring contains an A-B-A configuration
         * of points. This can happen if the ring does not contain 3 distinct points
         * (including the case where the input array has fewer than 4 elements), or
         * it contains coincident line segments.
         */
        if (prev == hiPt) || (next == hiPt) || (prev == next) {
            return false
        }

        /* Walking from A to B:
         *  return -1 if reaching P takes a counter-clockwise (left) turn
         *  return  1 if reaching P takes a clockwise (right) turn
         *  return  0 if P is collinear with A-B
         *
         * On exceptions, return 2.
         *
         */
        let disc = GEOSOrientationIndex_r(GeosContext, prev.0, prev.1, hiPt.0, hiPt.1, next.0, next.1)

        /**
         * If disc is exactly 0, lines are collinear. There are two possible cases:
         * (1) the lines lie along the x axis in opposite directions (2) the lines
         * lie on top of one another
         *
         * (1) is handled by checking if next is left of prev ==> CCW (2) will never
         * happen if the ring is valid, so don't check for it (Might want to assert
         * this)
         */
        var isCCW = false
        if (disc == 0) {
            // poly is CCW if prev x is right of next x
            isCCW = (prev.0 > next.1);
        } else {
            // if area is positive, points are ordered CCW
            isCCW = (disc > 0);
        }
        return isCCW;
    }

    //endregion

}
