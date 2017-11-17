//
//  ViewController.m
//  EmotionKeyboard
//
//  Created by bjovov on 2017/11/14.
//  Copyright © 2017年 caoxueliang.cn. All rights reserved.
//

#import "ViewController.h"
#import "EmoticonHelper.h"
#import <YYModel/YYModel.h>
#import "EmoticonGroup.h"
#import "EmoticonInputView.h"
#import <YYCategories/YYCategories.h>
#import "CommentViewController.h"

@interface ViewController ()

@end

@implementation ViewController
#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.title = @"首页";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[EmoticonHelper imageNamed:@"toolbar_compose_highlighted"] style:UIBarButtonItemStylePlain target:self action:@selector(sendStatus)];
    rightItem.tintColor = UIColorHex(fd8224);
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - Event Response
- (void)sendStatus{
    CommentViewController *controller = [[CommentViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    @weakify(nav);
    controller.dissMiss = ^{
        @strongify(nav);
        [nav dismissViewControllerAnimated:YES completion:NULL];
    };
    [self presentViewController:nav animated:YES completion:NULL];
    
}

@end

