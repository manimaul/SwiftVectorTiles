//
//  MADGeometry.hh
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/17/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MADCoordinate.hh"

@interface MADGeometry : NSObject

+(MADGeometry*) create:(NSString *)wkt;
+(MADGeometry*) createFromData:(NSData *)wkb;

-(BOOL) covers:(MADGeometry*)other;
-(BOOL) intersects:(MADGeometry*)other;
-(BOOL) empty;
-(MADGeometry *)intersection:(MADGeometry *)other;
-(NSArray<MADCoordinate*>*)coordinates;

@property NSString* WKT;

@end
