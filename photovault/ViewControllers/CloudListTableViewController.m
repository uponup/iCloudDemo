//
//  CloudListTableViewController.m
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import "CloudListTableViewController.h"

#define Safe_Str(str) str.length>0 ? str : @""

@interface CloudListTableViewController ()
@property (strong, nonatomic) NSMetadataQuery *query;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation CloudListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(metadataQueryFinish:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:self.query];//数据获取完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(metadataQueryFinish:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:self.query];//查询更新通知
    
    [self loadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Load Data
- (void)loadData {
    [self.query startQuery];
}

#pragma mark - Notification
- (void)metadataQueryFinish:(NSNotification *)noti {
    NSLog(@"数据获取成功！");
    [self.dataArr removeAllObjects];
    NSArray *items = self.query.results;//查询结果集
    for (NSMetadataItem *item in items) {
        NSString *fileName = [item valueForAttribute:NSMetadataItemFSNameKey];
        if ([fileName isEqualToString:@"4.png"]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];

            for (NSString *key in item.attributes) {
                [dic setValue:[item valueForAttribute:key] forKey:key];
            }
            NSLog(@"%@", dic);
        }
        NSDate *date = [item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSString *dateString = [self dateStringWithDate:date];
        
        NSDate *dateChange = [item valueForAttribute:NSMetadataItemFSCreationDateKey];
        NSString *dateChangeStr = [self dateStringWithDate:dateChange];
        [self.dataArr addObject:@{@"name": fileName, @"date": dateString, @"dateChange": dateChangeStr}];
    }
    [self.tableView reloadData];
}

- (NSString *)dateStringWithDate:(NSDate *)date {
    NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
    dateformate.dateFormat = @"MM-dd HH:mm:ss";
    return Safe_Str([dateformate stringFromDate:date]);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    NSDictionary *itemDic = self.dataArr[indexPath.row];
    cell.textLabel.text = itemDic[@"name"];
    cell.detailTextLabel.attributedText = [self attributeStrWithDic:itemDic];
    cell.detailTextLabel.numberOfLines = 0;
    return cell;
}

- (NSAttributedString *)attributeStrWithDic:(NSDictionary *)dic {
    NSString *str = [NSString stringWithFormat:@"%@,\n 修改时间：%@", dic[@"date"], dic[@"dateChange"]];
    NSMutableAttributedString *mutl = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: UIColor.lightGrayColor, NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    NSRange range = [str rangeOfString:dic[@"date"]];
    [mutl addAttributes:@{NSForegroundColorAttributeName: UIColor.blackColor, NSFontAttributeName: [UIFont systemFontOfSize:17]} range:range];
    return  mutl;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *itemDic = self.dataArr[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:Notification_selectCloudItem object:@{@"name": itemDic[@"name"]}];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Method
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

- (NSMetadataQuery *)query {
    if (!_query) {
        _query = [[NSMetadataQuery alloc] init];
        _query.searchScopes = @[NSMetadataQueryUbiquitousDocumentsScope];
        
    }
    return _query;
}
@end
