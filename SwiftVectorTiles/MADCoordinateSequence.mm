//
//  MADCoordinateSequence.m
//  SwiftVectorTiles
//
//  Created by William Kamp on 1/21/17.
//  Copyright © 2017 William Kamp. All rights reserved.
//

#include <vector>
#import "MADCoordinateSequence.hh"
#import "MADCoordinate.hh"

@implementation MADCoordinateSequence {
    std::vector<MADCoordinate*> _list;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])stackbuf
                                    count:(NSUInteger)stackbufLength {
    NSUInteger count = 0;
    unsigned long countOfItemsAlreadyEnumerated = state->state;
    if(countOfItemsAlreadyEnumerated == 0) {
        state->mutationsPtr = &state->extra[0];
    }
    if (countOfItemsAlreadyEnumerated < _list.size()) {
        __unsafe_unretained const id * const_array = _list.data();
        state->itemsPtr = (__typeof__(state->itemsPtr))const_array;
        count = _list.size();
        countOfItemsAlreadyEnumerated = _list.size();
    } else {
        count = 0;
    }
    state->state = countOfItemsAlreadyEnumerated;
    return count;
}

@end
