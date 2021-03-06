//
//  CCFSearchResultCell.m
//  CCF
//
//  Created by WDY on 16/1/11.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "CCFSearchResultCell.h"
#import <vBulletinForumEngine/vBulletinForumEngine.h>


@implementation CCFSearchResultCell {
    NSIndexPath *selectIndexPath;
}


- (void)setData:(ThreadInSearch *)data {


    NSString *title = [NSString stringWithFormat:@"[%@]%@", data.threadCategory, data.threadTitle];

    self.postTitle.text = title;
    self.postAuthor.text = data.threadAuthorName;
    self.postTime.text = data.lastPostTime;
    self.postBelongForm.text = data.fromFormName;
    self.postCategory.text = data.threadCategory;

    [self showAvatar:self.postAuthorAvatar userId:data.threadAuthorID];
}


- (void)setData:(id)data forIndexPath:(NSIndexPath *)indexPath {
    selectIndexPath = indexPath;
    [self setData:data];
}

- (IBAction)showUserProfile:(UIButton *)sender {
    [self.showUserProfileDelegate showUserProfile:selectIndexPath];
}

@end
