//
//  MadCoordinateSequence.swift
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/24/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

import Foundation

typealias MadCoordinateTransform = (MadCoordinate) -> MadCoordinate

public class MadCoordinateSequence: Sequence, Equatable {
    internal weak var weakOwner: MadGeometry?
    internal let sequencePtr: OpaquePointer
    public let count: Int
    public lazy var isCounterClockWise: Bool = { [unowned self] in
        return self.getIsCCW()
    }()

    init(_ coordinates: [MadCoordinate]) {
        count = coordinates.count
        sequencePtr = GEOSCoordSeq_create_r(GeosContext, UInt32(count), 2)
        for (i, coord) in coordinates.enumerated() {
            let index = UInt32(i)
            GEOSCoordSeq_setX_r(GeosContext, sequencePtr, index, coord.x)
            GEOSCoordSeq_setY_r(GeosContext, sequencePtr, index, coord.y)
        }
    }

    convenience init(_ coordinates: MadCoordinate...) {
        self.init(coordinates)
    }

    init(_ coordinates: [(Double, Double)]) {
        count = coordinates.count
        sequencePtr = GEOSCoordSeq_create_r(GeosContext, UInt32(count), 2)
        for (i, coord) in coordinates.enumerated() {
            let index = UInt32(i)
            GEOSCoordSeq_setX_r(GeosContext, sequencePtr, index, coord.0)
            GEOSCoordSeq_setY_r(GeosContext, sequencePtr, index, coord.1)
        }
    }

    convenience init(_ coordinates: (Double, Double)...) {
        self.init(coordinates)
    }

    init(_ sequence: OpaquePointer, owner: MadGeometry? = nil) {
        self.sequencePtr = sequence
        self.weakOwner = owner
        var num: UInt32 = 0
        GEOSCoordSeq_getSize_r(GeosContext, sequencePtr, &num)
        count = Int(num)
    }

    public func clone() -> MadCoordinateSequence? {
        guard let ptr = GEOSCoordSeq_clone_r(GeosContext, sequencePtr) else {
            return nil
        }
        return MadCoordinateSequence(ptr)
    }

    public func transform(t: MadCoordinateTransform) -> MadCoordinateSequence? {
        guard let ptr = GEOSCoordSeq_create_r(GeosContext, UInt32(count), 2) else {
            return nil
        }
        for (i, coord) in enumerated() {
            let index = UInt32(i)
            let tCoord = t(coord)
            let rX = GEOSCoordSeq_setX_r(GeosContext, ptr, index, tCoord.x)
            let rY = GEOSCoordSeq_setY_r(GeosContext, ptr, index, tCoord.y)
            if (rX + rY) == 0 {
                GEOSCoordSeq_destroy_r(GeosContext, ptr)
                return nil
            }
        }
        return MadCoordinateSequence(ptr)
    }

    private func getIsCCW() -> Bool {
        let ring = [MadCoordinate](self)

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
            if p.y > hiPt.y {
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
        let disc = GEOSOrientationIndex_r(GeosContext, prev.x, prev.y, hiPt.x, hiPt.y, next.x, next.y)

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
            isCCW = (prev.x > next.x);
        } else {
            // if area is positive, points are ordered CCW
            isCCW = (disc > 0);
        }
        return isCCW;
    }

    // pragma: Sequence

    public subscript(index: Int) -> MadCoordinate {
        var x: Double = 0
        var y: Double = 0
        assert(self.count > index, "Index out of bounds")
        assert(index >= 0, "index less than zero")
        let i = UInt32(index)
        GEOSCoordSeq_getX_r(GeosContext, sequencePtr, i, &x);
        GEOSCoordSeq_getY_r(GeosContext, sequencePtr, i, &y);
        return MadCoordinate(x: x, y: y)
    }

    public func makeIterator() -> AnyIterator<MadCoordinate> {
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

    public static func ==(lhs: MadCoordinateSequence, rhs: MadCoordinateSequence) -> Bool {
        if lhs.count == rhs.count {
            for (lhsCoord, rhsCoord) in zip(lhs, rhs) {
                if lhsCoord.x != rhsCoord.x && lhsCoord.y != rhsCoord.y {
                    return false
                }
            }
            return true
        }
        return false
    }

    deinit {
        if weakOwner != nil {
            GEOSCoordSeq_destroy_r(GeosContext, sequencePtr)
        }
    }

}
