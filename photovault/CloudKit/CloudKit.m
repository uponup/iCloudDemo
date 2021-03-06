//
//  CloudKit.m
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import "CloudKit.h"
#import "PVDocument.h"

#define kContainerIdentifier @"iCloud.com.tm.photovault"

@implementation CloudKit

+ (BOOL)cloudEnable {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [manager URLForUbiquityContainerIdentifier:kContainerIdentifier];
    return url != nil;
}

+ (void)uploadWithKey:(NSString *)imgKey withCompletion:(completionBlock)block {
    if ([self cloudEnable]) {
        NSLog(@"cloud 可用");
    }else {
        NSLog(@"cloud 不可用");
    }
    
    NSURL *url = [self cloudUrlWithKey:imgKey];
    NSLog(@"%@", url);
    PVDocument *cloudDoc = [[PVDocument alloc] initWithFileURL:url];
    cloudDoc.data = [self dataWithImgKey:imgKey];
    
    NSDate *date1 = [NSDate date];
    [cloudDoc saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            
            NSDate *date2 = [NSDate date];
            NSLog(@"upload---->: %.f", [date2 timeIntervalSinceDate:date1]);

            block(YES, cloudDoc.data);
        }else {
            block(NO, nil);
        }
    }];
}

+ (void)downloadWithKey:(NSString *)imgKey withCompletion:(completionBlock)block {
    NSURL *url = [self cloudUrlWithKey:imgKey];
    NSURL *localUrl = [self localUrlWithKey:imgKey];
    PVDocument *cloudDoc = [[PVDocument alloc] initWithFileURL:url];
    PVDocument *localDoc = [[PVDocument alloc] initWithFileURL:localUrl];
    NSDate *date1 = [NSDate date];
    [cloudDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            localDoc.data = [cloudDoc.data copy];
            if (success) {
                NSDate *date2 = [NSDate date];
                NSLog(@"download---->: %.f", [date2 timeIntervalSinceDate:date1]);
                block(YES, localDoc.data);
            }else {
                block(NO, nil);
            }
        }else {
            block(NO, nil);
        }
        [cloudDoc closeWithCompletionHandler:^(BOOL success) {
            NSLog(@"%@ download close：%@", imgKey, @(success));
        }];
    }];
}

+ (void)changeWithKey:(NSString *)imgKey withCompletion:(completionBlock)block {
    NSURL *cloudUrl = [self cloudUrlWithKey:imgKey];
    PVDocument *cloudDoc = [[PVDocument alloc] initWithFileURL:cloudUrl];
    [cloudDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            UIImage *image = [UIImage imageNamed:@"change.png"];
            cloudDoc.data = UIImagePNGRepresentation(image);
            [cloudDoc saveToURL:cloudUrl forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if (success) {
                    block(YES, cloudDoc.data);
                }else {
                    block(NO, nil);
                }
            }];
        }else {
            block(NO, nil);
        }
        [cloudDoc closeWithCompletionHandler:^(BOOL success) {
            NSLog(@"%@ change close: %@", imgKey, @(success));
        }];
    }];
}

+ (void)deleteWithKey:(NSString *)imgKey withCompletion:(completionBlock)block {
    NSURL *cloudUrl = [self cloudUrlWithKey:imgKey];
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:cloudUrl error:&error];
    if (error) {
        block(NO, nil);
    }else {
        block(YES, nil);
    }
}

#pragma mark -

+ (NSURL *)localUrlWithKey:(NSString *)key {
    NSURL *fileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *url = [fileUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@", key]];
    return url;
}

+ (NSURL *)cloudUrlWithKey:(NSString *)key {
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)，需要一个容器标示
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *url = [manager URLForUbiquityContainerIdentifier:kContainerIdentifier];
    //取得Documents目录
    url = [url URLByAppendingPathComponent:@"Documents/images"];
    
    if ([[NSFileManager defaultManager] isUbiquitousItemAtURL:url]) {
        
    }else {
        NSLog(@"不存在");
        [[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //取得最终地址
    url = [url URLByAppendingPathComponent:key];
    return url;
}

+ (NSData *)dataWithImgKey:(NSString *)imgKey {
    UIImage *image = [UIImage imageNamed:imgKey];
    return UIImagePNGRepresentation(image);
}

@end
