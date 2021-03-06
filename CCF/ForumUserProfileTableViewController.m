//
//  ForumUserProfileTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/20.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumUserProfileTableViewController.h"
#import "CCFProfileTableViewCell.h"
#import "ForumUserThreadTableViewController.h"

#import "ForumWritePMNavigationController.h"
#import <UIImageView+WebCache.h>
#import "UIStoryboard+CCF.h"

#import "ForumConfig.h"

@interface ForumUserProfileTableViewController () <TransBundleDelegate> {

    UserProfile *userProfile;
    int userId;
    UIImage *defaultAvatarImage;
    ForumCoreDataManager *coreDateManager;
    CCFForumApi *ccfapi;
    NSMutableDictionary *avatarCache;
    NSMutableArray<UserEntry *> *cacheUsers;

}

@end

@implementation ForumUserProfileTableViewController

- (void)transBundle:(TransBundle *)bundle {
    userId = [bundle getIntValue:@"UserId"];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    defaultAvatarImage = [UIImage imageNamed:@"logo.jpg"];

    ccfapi = [[CCFForumApi alloc] init];
    coreDateManager = [[ForumCoreDataManager alloc] initWithEntryType:EntryTypeUser];
    avatarCache = [NSMutableDictionary dictionary];

    if (cacheUsers == nil) {
        cacheUsers = [[coreDateManager selectData:^NSPredicate * {
            return [NSPredicate predicateWithFormat:@"userID > %d", 0];
        }] copy];
    }

    for (UserEntry *user in cacheUsers) {
        [avatarCache setValue:user.userAvatar forKey:user.userID];
    }

}

- (BOOL)setLoadMore:(BOOL)enable {
    return NO;
}

- (void)onPullRefresh {
    NSString *userIdString = [NSString stringWithFormat:@"%d", userId];
    [self.ccfApi showProfileWithUserId:userIdString handler:^(BOOL isSuccess, UserProfile *message) {
        userProfile = message;

        [self.tableView.mj_header endRefreshing];


        [self showAvatar:self.userAvatar userId:userProfile.profileUserId];
        self.userName.text = userProfile.profileName;
        self.userRankName.text = userProfile.profileRank;
        self.userSignDate.text = userProfile.profileRegisterDate;
        self.userCurrentLoginDate.text = userProfile.profileRecentLoginDate;
        self.userPostCount.text = userProfile.profileTotalPostCount;

        [self.tableView reloadData];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

//
//#pragma mark - Table view data source
//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return userProfile == nil ? 0 : 1;
    } else if (section == 1) {
        return 2;
    } else {
        return 3;
    }
}

#pragma mark 跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowCCFUserThreadTableViewController"]) {
        ForumUserThreadTableViewController *controller = segue.destinationViewController;

        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putObjectValue:userProfile forKey:@"UserProfile"];
        [self transBundle:bundle forController:controller];

    }

}

- (void)showAvatar:(UIImageView *)avatarImageView userId:(NSString *)profileUserId {


    NSString *avatarInArray = [avatarCache valueForKey:profileUserId];

    if (avatarInArray == nil) {

        [ccfapi getAvatarWithUserId:profileUserId handler:^(BOOL isSuccess, NSString *avatar) {
            // 存入数据库
            [coreDateManager insertOneData:^(id src) {
                UserEntry *user = (UserEntry *) src;
                user.userID = profileUserId;
                user.userAvatar = avatar;
            }];
            // 添加到Cache中
            [avatarCache setValue:avatar forKey:profileUserId];

            // 显示头像
            if (avatar == nil) {
                [avatarImageView setImage:defaultAvatarImage];
            } else {
                [avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:defaultAvatarImage];
            }
        }];
    } else {
        if ([avatarInArray isEqualToString:NO_AVATAR_URL]) {
            [avatarImageView setImage:defaultAvatarImage];
        } else {
            NSURL *url = [NSURL URLWithString:avatarInArray];
            [avatarImageView sd_setImageWithURL:url placeholderImage:defaultAvatarImage];
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    if (indexPath.section == 1 && indexPath.row == 1) {
        ForumWritePMNavigationController *controller = (id) [[UIStoryboard mainStoryboard] instantiateViewControllerWithIdentifier:@"CreatePM"];
        TransBundle *bundle = [[TransBundle alloc] init];
        [bundle putStringValue:userProfile.profileName forKey:@"PROFILE_NAME"];

        [self presentViewController:(id) controller withBundle:bundle forRootController:YES animated:YES completion:^{

        }];
    }
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
