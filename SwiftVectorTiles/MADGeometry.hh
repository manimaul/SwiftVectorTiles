//
//  MADGeometry.hh
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MADCoordinate.hh"
#import "MADGeometryType.h"

@interface MADGeometry : NSObject

-(BOOL) covers:(MADGeometry*)other;
-(BOOL) intersects:(MADGeometry*)other;
-(BOOL) empty;
-(NSArray<MADCoordinate*>*)coordinates;
-(MADGeometryType)getGeometryType;
-(NSString*)getWellKnownText;
-(MADGeometry*)transform:(MADCoordinateTransform)transform;
-(MADGeometry*)intersection:(MADGeometry*)other;

@end
