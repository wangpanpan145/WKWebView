//
//  ViewController.m
//  WKWebView-OC
//
//  Created by mac on 2021/2/21.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WebViewJavascriptBridge.h"
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"------ %s ------ %d 行 ------ %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>
@property(nonatomic,strong)WKWebView *webView;
@property(nonatomic,strong)WebViewJavascriptBridge *bridge;
@end

@implementation ViewController
- (void)dealloc
{
    NSLog(@"ViewController ---dealloc");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isNet = YES;
    isNet = NO;
    if (isNet) {
        NSString *url = @"https://www.baidu.com";
        //url = @"https://hqhhtest.hqhh520.cn/h5/#/carRental";
        //url = @"https://hqhhtest.hqhh520.cn/h5/#/carRental?classId=9&cityId=7994414457790201856&longitude=117.406417&latitude=37.785834";
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    } else {
        //NSString *filePath = [[NSBundle mainBundle]pathForResource:@"index" ofType:@"html"];
        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"index_bridge" ofType:@"html"];
        NSURL *baseUrl = [[NSBundle mainBundle]bundleURL];
        NSString *sourceString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:sourceString baseURL:baseUrl];
    }
    
    //self.webView.navigationDelegate = self;
    [self createUI];
    [self addObserver];
    [self addRegisterHandler];
    
    self.webView.UIDelegate = self;
}
- (void)createUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backMethod:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"上一个网页" style:UIBarButtonItemStylePlain target:self action:@selector(forwardMethod:)];
    self.title = @"xxx";
}
#pragma mark - click
- (void)backMethod:sender
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
    
    [self.bridge callHandler:@"testJSFunction" data:@"一个字符串" responseCallback:^(id responseData) {
        NSLog(@"%@",responseData);
    }];
    
}
- (void)forwardMethod:sender
{
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    //NSLog(@"URL:%@",navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"decidePolicyForNavigationResponse");
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didStartProvisionalNavigation");
}
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"didCommitNavigation");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"didFinishNavigation");
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"didFailNavigation");
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    //当Response响应后 不允许则会加载失败
    NSLog(@"didFailProvisionalNavigation");
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation");
}
//- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
//{
//    NSLog(@"didReceiveAuthenticationChallenge");
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
//        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
//        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
//    }
//}
#pragma mark - Observer
- (void)addObserver
{
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]) {
        self.title = self.webView.title;
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        //NSLog(@"%f",self.webView.estimatedProgress);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
#pragma mark - UIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - MessageHandler
- (WKWebViewConfiguration *)addMessageHandler
{
    //设置偏好设置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    // 默认是0 其实不建议在此设置的
    config.preferences.minimumFontSize = 40;
    return config;
}
#pragma mark - registerHandler
- (void)addRegisterHandler
{
    //配置
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    //监听
    [self.bridge registerHandler:@"scanClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"扫一扫 %@",data);
        responseCallback(@"回调");
    }];
    [self.bridge registerHandler:@"locationClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"地址 %@",data);
        responseCallback(@"回调");
    }];
    [self.bridge registerHandler:@"colorClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"改变颜色 %@",data);
        responseCallback(@"回调");
    }];
    [self.bridge registerHandler:@"shareClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"分享%@",data);
        responseCallback(@"回调");
    }];
    [self.bridge registerHandler:@"payClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"支付 %@",data);
        responseCallback(@"回调");
    }];
    [self.bridge registerHandler:@"shakeClick" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"摇一摇 %@",data);
        responseCallback(@"回调");
    }];
    [self.bridge registerHandler:@"goback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"返回 %@",data);
        responseCallback(@"回调");
    }];
}
#pragma mark - lazy懒加载
- (WKWebView *)webView
{
    if (!_webView) {
        WKWebView *view = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:[self addMessageHandler]];
        [self.view addSubview:view];
        _webView = view;
    }
    return _webView;
}
@end

