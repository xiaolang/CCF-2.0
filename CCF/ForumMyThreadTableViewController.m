//
//  ForumMyThreadTableViewController.m
//  CCF
//
//  Created by 迪远 王 on 16/3/6.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ForumMyThreadTableViewController.h"
#import "CCFSearchResultCell.h"
#import "ForumWebViewController.h"

@interface ForumMyThreadTableViewController ()

@end

@implementation ForumMyThreadTableViewController

- (void)onPullRefresh {
    [self.ccfApi listMyAllThreadsWithPage:1 handler:^(BOOL isSuccess, ForumDisplayPage *message) {
        [self.tableView.mj_header endRefreshing];

        if (isSuccess) {
            [self.tableView.mj_footer endRefreshing];

            self.currentPage = 1;
            [self.dataList removeAllObjects];

            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];

        }

    }];
}

- (void)onLoadMore {
    [self.ccfApi listMyAllThreadsWithPage:self.currentPage + 1 handler:^(BOOL isSuccess, ForumDisplayPage *message) {
        [self.tableView.mj_footer endRefreshing];

        if (isSuccess) {
            self.currentPage++;
            if (self.currentPage >= message.totalPageCount) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataList addObjectsFromArray:message.dataList];
            [self.tableView reloadData];

        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CCFSearchResultCell";
    CCFSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];

    ThreadInSearch *thread = self.dataList[indexPath.row];
    [cell setData:thread];

    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"CCFSearchResultCell" configuration:^(CCFSearchResultCell *cell) {
        [self configureCell:cell atIndexPath:indexPath];
    }];
}


- (void)configureCell:(CCFSearchResultCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.fd_enforceFrameLayout = NO; // Enable to use "-sizeThatFits:"

    [cell setData:self.dataList[(NSUInteger) indexPath.row]];
}

#pragma mark Controller跳转

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowThreadPosts"]) {

        ForumWebViewController *controller = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        ThreadInSearch *thread = self.dataList[(NSUInteger) indexPath.row];

        TransBundle *transBundle = [[TransBundle alloc] init];
        [transBundle putIntValue:[thread.threadID intValue] forKey:@"threadID"];
        [transBundle putStringValue:thread.threadAuthorName forKey:@"threadAuthorName"];

        [self transBundle:transBundle forController:controller];
    }
}


- (IBAction)showLeftDrawer:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
