//
//  ViewController.m
//  YingShi
//
//  Created by sherwin.chen on 2019/5/7.
//  Copyright © 2019 sherwin.chen. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "MJRefresh.h"
#import "Masonry.h"
#import "JKLoadingView.h"

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define STATUS_BAR_HEIGHT (iPhoneX ? 44.f : 20.f)

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) WKWebView *myWebView;
@property (nonatomic, strong) NSURLRequest *request;

@property(nonatomic, strong) NSString *srcURL;

@property(nonatomic, strong) JKLoadingView *mLoadingView;
@property (nonatomic, strong) UIView * statusView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //self.srcURL = @"http://www.pz5918.com/wap";
    self.srcURL = @"https://m.tianxiaxinyong.com/cooperation/crp-op/index.html?channel=NCtQdE8za3lrUDczdXdoTCtSYytydz09&appId=305801010&bizContent=OWmLxk9FkOtqRbOumoubjfCLsKTMOLlPmuEFcumPjr8%3D&charset=utf-8&format=json&randomKey=U7FSMXbGuk3N%2BZ6DjpHw%2BsXkQWMwvcBpvGNf0DLgFOxg%2BGI%2Bgbz%2FuqmT%2BvJtE1lfluMN0yLg4Kc7bMBmY45IwqYwAHtjk2ZT22%2B714Rd%2FdKg88tO5wAwSAOuvgLwQ%2F8IMXjTmdB65ClJKrzCicdKORwbeg%2Bc%2Bf4OZU3RMNlOMYQ%3D&sign=XDzTYwd5Y%2BHd7EiGeM1vChsqrj0Njcgb0wzHFUwOOeNC4Ziw2d3EfJozeloKRw6oZmBpfuTY%2BIrVmcab7t4TylV8C28p8mV3YhHf1NCMXbCCxRrSiOSdN8O4n%2BCqzVOwPItcTP446BycxkmYaNP%2FYp3iWBc%2FhOVhXnmuc2RmOV0%3D&signType=RSA&timestamp=1560417461969&version=3.0";
    //self.srcURL = @"https://static.maimaiti.cn/wallet/cash/index/index.html";

    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = YES;

    //
    MJRefreshNormalHeader *mjHead =  [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self reload];
        [self.myWebView.scrollView.mj_header  endRefreshing];
    }];

    self.myWebView.scrollView.mj_header = mjHead;
    // 隐藏时间
    mjHead.lastUpdatedTimeLabel.hidden = YES;
    // 隐藏状态
    //mjHead.stateLabel.hidden = YES;


    [self.statusView setBackgroundColor:[UIColor whiteColor]];

    self.mLoadingView = [[JKLoadingView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.mLoadingView];

    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.srcURL]];
    [self loadRequestURL:self.request];

    return;
}


- (void)reload {

    //如果因无网络导致url未设置，无启启用reload, 需要重新loadRequest.==> find bug with LT
    if (self.myWebView.URL == NULL) {
        [self loadRequestURL:self.request];
    }
    else {
        [self.myWebView reload];
    }
}

/**
 *  请求网络资源
 *  @param  request 请求的具体地址和设置
 */
- (void)loadRequestURL:(NSURLRequest *)request {

    [self.mLoadingView show];

    self.request = request.mutableCopy;

    //request web with head setting.
    [self.myWebView loadRequest:self.request];

    return;
}

- (WKWebView *)myWebView
{
    if(!_myWebView)
    {
        _myWebView = [[WKWebView alloc] initWithFrame:self.view.frame];
        _myWebView.opaque = NO;
        _myWebView.backgroundColor = [UIColor clearColor];
        _myWebView.UIDelegate = self;
        _myWebView.navigationDelegate = self;

        [self.view addSubview:_myWebView];

    }
    return _myWebView;
}

- (UIView *) statusView {
    if(!_statusView)
    {
        _statusView = [[UIView alloc] init];
        _statusView.backgroundColor = [UIColor whiteColor];

        [self.view addSubview:_statusView];
        [_statusView mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.bottom.equalTo(self.view.mas_top);
            make.left.right.top.equalTo(self.view);
            make.height.mas_equalTo(STATUS_BAR_HEIGHT);
        }];
    }
    return _statusView;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self.mLoadingView show];
}


- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

    [self.mLoadingView dissmiss];
    return;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [self.mLoadingView dissmiss];

}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    [self.mLoadingView dissmiss];
    if (error.code == NSURLErrorCancelled) {
        return;
    }

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    [self.mLoadingView dissmiss];

    [self showAlert:@"加载失败，请检测您的网络或尝试下拉刷新."];
}

/// 处理页面白屏
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [self reload];
}

#pragma mark - WKUIDelegate
// 一定是iOS8以上才会运行到此，使用UIAlertController
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:(webView.title ? webView.title:@"") message:(message?:@"提示") preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:NULL];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"确定"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(YES);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(NO);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {

    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:prompt
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];

    [ac addAction:[UIAlertAction actionWithTitle: @"确定"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSString *input = ((UITextField *)ac.textFields.firstObject).text;
                                             completionHandler(input);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle: @"取消"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action) {
                                             completionHandler(nil);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

-(void) showAlert:(NSString*) info {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:info preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        [self reload];
    }]];

    [self presentViewController:alertController animated:YES completion:nil];
}

@end
