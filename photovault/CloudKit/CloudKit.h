//
//  CloudKit.h
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^completionBlock)(BOOL result, NSData *obj);

@interface CloudKit : NSObject

+ (void)uploadWithKey:(NSString *)imgKey withCompletion:(completionBlock)block;
+ (void)downloadWithKey:(NSString *)imgKey withCompletion:(completionBlock)block;
+ (void)changeWithKey:(NSString *)imgKey withCompletion:(completionBlock)block;
+ (void)deleteWithKey:(NSString *)imgKey withCompletion:(completionBlock)block;


@end
