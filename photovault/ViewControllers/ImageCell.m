//
//  ImageCell.m
//  photovault
//
//  Created by upon on 2020/4/8.
//  Copyright © 2020 upon. All rights reserved.
//

#import "ImageCell.h"

@interface ImageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iv;
@property (weak, nonatomic) IBOutlet UILabel *labelName;

@end
@implementation ImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.iv.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setName:(NSString *)name {
    _name = name;
    self.labelName.text = name;
    self.iv.image = [UIImage imageNamed:name];
}

@end
