//
//  ImageListTableViewController.m
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import "ImageListTableViewController.h"
#import "ImageCell.h"

@interface ImageListTableViewController ()
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation ImageListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([ImageCell class])];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ImageCell class]) forIndexPath:indexPath];
    NSString *imgName = self.dataArr[indexPath.row];
    cell.name = imgName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *imgName = self.dataArr[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_SelectImage object:@{@"img": imgName}];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Method
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i=0; i<7; i++) {
            [_dataArr addObject:[NSString stringWithFormat:@"%@.png", @(i+1)]];
        }
    }
    return _dataArr;
}

@end
