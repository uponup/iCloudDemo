//
//  PVDocument.m
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import "PVDocument.h"

@implementation PVDocument

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    if (self.data) {
        return [self.data copy];
    }
    return [NSData data];
}

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    self.data = [contents copy];
    return YES;
}

@end
