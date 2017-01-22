//
//  MADPolygon.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import "MADLinearRing.hh"

@implementation MADLinearRing


//public func isCCW() -> Bool {
//    let ring = [Coordinate](self)
//    
//    // # of points without closing endpoint
//    let nPts = ring.count - 1
//    
//    // sanity check
//    if nPts < 3 {
//        fatalError("Ring has fewer than 3 points, so orientation cannot be determined")
//    }
//    
//    // find highest point
//    var hiPt = ring[0]
//    var hiIndex = 0
//    
//    for i in 0...ring.count - 1 {
//        let p = ring[i]
//        if p.y > hiPt.y {
//            hiPt = p
//            hiIndex = i
//        }
//    }
//    
//    // find distinct point before highest point
//    var iPrev = hiIndex
//    repeat {
//        iPrev = iPrev - 1
//        if iPrev < 0 {
//            iPrev = nPts
//        }
//    } while ring[iPrev] == hiPt && iPrev != hiIndex
//        
//        // find distinct point after highest point
//        var iNext = hiIndex
//        repeat {
//            iNext = (iNext + 1) % nPts
//        } while ring[iNext] == hiPt && iNext != hiIndex
//            
//            let prev = ring[iPrev]
//            let next = ring[iNext]
//            
//        /**
//         * This check catches cases where the ring contains an A-B-A configuration
//         * of points. This can happen if the ring does not contain 3 distinct points
//         * (including the case where the input array has fewer than 4 elements), or
//         * it contains coincident line segments.
//         */
//            if (prev == hiPt) || (next == hiPt) || (prev == next) {
//                return false
//            }
//    
//    /* Walking from A to B:
//     *  return -1 if reaching P takes a counter-clockwise (left) turn
//     *  return  1 if reaching P takes a clockwise (right) turn
//     *  return  0 if P is collinear with A-B
//     *
//     * On exceptions, return 2.
//     *
//     */
//    let disc = GEOSOrientationIndex_r(GEOS_HANDLE, prev.x, prev.y, hiPt.x, hiPt.y, next.x, next.y)
//    
//    /**
//     * If disc is exactly 0, lines are collinear. There are two possible cases:
//     * (1) the lines lie along the x axis in opposite directions (2) the lines
//     * lie on top of one another
//     *
//     * (1) is handled by checking if next is left of prev ==> CCW (2) will never
//     * happen if the ring is valid, so don't check for it (Might want to assert
//     * this)
//     */
//    var isCCW = false
//    if (disc == 0) {
//        // poly is CCW if prev x is right of next x
//        isCCW = (prev.x > next.x);
//    }
//    else {
//        // if area is positive, points are ordered CCW
//        isCCW = (disc > 0);
//    }
//    return isCCW;
//}

-(BOOL) isCCW {
    /*
     
     */
    return NO;
}

-(MADLinearRing *)reverse {
    return nil;
}

@end
