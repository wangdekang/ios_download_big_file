//
//  ViewController.m
//  测试小文件下载
//
//  Created by 王德康 on 15/6/15.
//  Copyright (c) 2015年 王德康. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLConnectionDataDelegate>

// 开始下载按钮
@property (weak, nonatomic) IBOutlet UIButton *btn;

- (IBAction)startDownload:(id)sender;
// 进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;


// 已经下载文件的大小
@property(nonatomic, assign) long long fileCurrentLength;
// 当前文件的总小大
@property(nonatomic, assign) long long fileMaxLength;
// 要生成的文件路径
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, copy) NSString *fileName;
// 文件句柄
@property(nonatomic, strong) NSFileHandle *fileHandle;
// 请求连接
@property(nonatomic, strong) NSURLConnection *conn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// 写入沙盒的文件路径
- (NSString *)filePath {
    if (_filePath == nil) {
        
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath  = [cachePath stringByAppendingPathComponent:self.fileName];
        _filePath = filePath;
    }
    
    return _filePath;
}

// 开始下载
- (void)downloadfile3 {
    
    // 百度网站的地址，不稳定，随时可能下载失败
    NSURL *url = [NSURL URLWithString:@"http://124.167.222.33/ws.cdn.baidupcs.com/file/ce7ca01edbd64ec39d1d80e5e0b6b123?bkt=p-175f9b6bacaa31b095a2beb38cc023e5&xcode=89b099a05d15c478dff07ad57ada660b4f4ab0ea65aa64e3ed03e924080ece4b&fid=2232202584-250528-190329993132603&time=1434361009&sign=FDTAXERLBH-DCb740ccc5511e5e8fedcff06b081203-aKn2hitISHLPpAqI%2BaYML4xZreU%3D&to=hc&fm=Nan,B,U,nc&sta_dx=8&sta_cs=386&sta_ft=rar&sta_ct=7&newver=1&newfm=1&flow_ver=3&sl=70910031&expires=8h&rt=pr&r=940313902&mlogid=819397827&vuk=2232202584&vbdid=834121574&fin=%E5%BE%AE%E4%BF%A1%E5%85%AC%E4%BC%97%E8%B4%A6%E5%8F%B7%E8%87%AA%E5%AE%9A%E4%B9%89%E8%8F%9C%E5%8D%95%E5%86%85%E6%B5%8B%E7%94%B3%E8%AF%B7.rar&fn=%E5%BE%AE%E4%BF%A1%E5%85%AC%E4%BC%97%E8%B4%A6%E5%8F%B7%E8%87%AA%E5%AE%9A%E4%B9%89%E8%8F%9C%E5%8D%95%E5%86%85%E6%B5%8B%E7%94%B3%E8%AF%B7.rar&slt=pm&uta=0&rtype=1&iv=0&wshc_tag=0&wsts_tag=557e9cb1&wsid_tag=7b79a28d&wsiphost=ipdbm"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置请求头,获取数据的区间
    NSString *range = [NSString stringWithFormat:@"Bytes=%lld-", self.fileCurrentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 直接发起一个异步请求
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    // 直接发起一个异步请求
    // NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    
    // 初始化等待发起一个异步请求
    // NSURLConnection *con = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    // [con start];
}

#pragma mark NSURLConnectiondelegate

// 数据返回
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
}

// 下载数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    // 追加写入
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    
    // 进度条设置 注意类型转换 int / int = int
    self.fileCurrentLength += data.length;
    self.progressView.progress = (double)self.fileCurrentLength / self.fileMaxLength;
}

// Http 响应返回
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (self.fileCurrentLength) return;
    
    // 获取文件大小
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    self.fileMaxLength = [resp.allHeaderFields[@"Content-Length"] longLongValue];
    
    // 获取文件名
    self.fileName      = response.suggestedFilename;
    
    // 初始化长度
    self.fileCurrentLength = 0;
    
    // 创建文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:self.filePath contents:nil attributes:nil];
    
    // 打开文件，单线程建议使用
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
}

// 文件下载完成
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // 关闭沙盒文件
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    
    // 下载完成，改变按钮状态
    self.btn.selected = NO;
    
    // Document 目录是备份目录，不适合存放大的文件
    // Library/Cache 适合存放缓存数据
}

- (IBAction)startDownload:(UIButton *)btn {
    btn.selected = !btn.isSelected;
    NSLog(@"%@", self.filePath);
    if (btn.selected) {
        // 开始下载
        [self downloadfile3];
    } else {
        // 取消下载
        [self.conn cancel];
        self.conn = nil;
    }
}
@end
