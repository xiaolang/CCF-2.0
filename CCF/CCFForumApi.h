//
//  CCFApi.h
//  CCF
//
//  Created by 迪远 王 on 16/2/28.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <vBulletinForumEngine/vBulletinForumEngine.h>


@interface CCFForumApi : NSObject <ForumEngine>

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler;

@end
