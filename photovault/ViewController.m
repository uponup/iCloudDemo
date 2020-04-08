//
//  ViewController.m
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import "ViewController.h"
#import "ImageListTableViewController.h"
#import "CloudListTableViewController.h"

#import "CloudKit.h"

@interface ViewController () {
    NSString *_uploadName;
    NSString *_downloadName;
    NSString *_changeName;
    NSString *_deleteName;
    
    NSInteger _tag; // 删改查：0，1，2
}
@property (weak, nonatomic) IBOutlet UIImageView *ivCurrent;
@property (weak, nonatomic) IBOutlet UILabel *labelMesg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tag = 0;
    _uploadName = @"";
    _downloadName = @"";
    _changeName = @"";
    _deleteName = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectImageNotification:) name:Notification_SelectImage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectItemNotification:) name:Notification_selectCloudItem object:nil];
}


#pragma mark - 通知
// 选择本地照片
- (void)selectImageNotification:(NSNotification *)noti {
    [self hideMesg];
    
    NSString *name = noti.object[@"img"];
    self.ivCurrent.image = [UIImage imageNamed:name];
    
    _uploadName = name;
}

// 选择云端照片
- (void)selectItemNotification:(NSNotification *)noti {
    [self hideMesg];
    
    NSString *name = noti.object[@"name"];
        if (_tag==0) {
        _deleteName = name;
    }else if (_tag == 1) {
        _changeName = name;
    }else if (_tag == 2) {
        _downloadName = name;
    }
}


- (IBAction)selectImage:(id)sender {
    NSLog(@"废弃");
}

#pragma mark - 按钮Action：增删改查

// 上传
- (IBAction)uploadAction:(id)sender {
    if (_uploadName.length == 0) {
        ImageListTableViewController *vc = [ImageListTableViewController new];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    [CloudKit uploadWithKey:[self keyWithImageName:_uploadName] withCompletion:^(BOOL result, NSData *obj) {
        if (result) {
            self.ivCurrent.image = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ivCurrent.image = [UIImage imageWithData:obj];
                });
            });
        }else {
            NSLog(@"===》%@ 上传失败!", self->_uploadName);
            self->_uploadName = @"";
        }
        self->_uploadName = @"";
    }];
}

// 删除
- (IBAction)deleteAction:(id)sender {
    if (_deleteName.length == 0) {
        _tag = 0;
        CloudListTableViewController *vc = [[CloudListTableViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    
    [self showMesg:@"删除中..."];
    NSString *key = [self keyWithImageName:_deleteName];
    [CloudKit deleteWithKey:key withCompletion:^(BOOL result, NSData *obj) {
        if (result) {
            self.ivCurrent.image = nil;
        }else {
            [self showMesg:[NSString stringWithFormat:@"delete %@ 失败", self->_deleteName]];
        }
        self->_deleteName = @"";
        [self hideMesg];
    }];
}

// 修改
- (IBAction)changeAction:(id)sender {
    if (_changeName.length == 0) {
        _tag = 1;
        CloudListTableViewController *vc = [[CloudListTableViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    NSString *key = [self keyWithImageName:_changeName];
    [CloudKit changeWithKey:key withCompletion:^(BOOL result, NSData *obj) {
        if (result) {
            self.ivCurrent.image = [UIImage imageWithData:obj];
        }else {
            [self showMesg:[NSString stringWithFormat:@"change %@ 失败", self->_changeName]];
        }
        self->_changeName = @"";
    }];
}

// 下载
- (IBAction)downloadAction:(id)sender {
    if (_downloadName.length == 0) {
        _tag = 2;
        CloudListTableViewController *vc = [[CloudListTableViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
        return;
    }
    [CloudKit downloadWithKey:[self keyWithImageName:_downloadName] withCompletion:^(BOOL result, NSData *obj) {
        if (result) {
            self.ivCurrent.image = nil;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.ivCurrent.image = [UIImage imageWithData:obj];
                });
            });
        }else {
            NSLog(@"===》%@ 上传失败!", self->_downloadName);
        }
        self->_downloadName = @"";
    }];
}



#pragma mark - Utils

- (NSString *)keyWithImageName:(NSString *)imgName {
    return imgName;
}

- (void)showMesg:(NSString *)str {
    self.labelMesg.hidden = NO;
    self.labelMesg.text = str;
}

- (void)hideMesg {
    self.labelMesg.hidden = YES;
}

@end
