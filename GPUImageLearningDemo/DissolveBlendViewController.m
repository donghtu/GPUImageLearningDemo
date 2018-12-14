//
//  DissolveBlendViewController.m
//  GPUImageLearningDemo
//
//  Created by donglingxiao on 2018/11/30.
//  Copyright © 2018 donglingxiao. All rights reserved.
//

#import "DissolveBlendViewController.h"
#import <Photos/Photos.h>

#define WeakSelf __weak typeof(self) weakSelf = self
@interface DissolveBlendViewController ()
{
    GPUImageMovie *movieFile;
    GPUImageMovie *movieFile2;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    NSURL *movieURL;
}
@end

@implementation DissolveBlendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    filter = [[GPUImageDissolveBlendFilter alloc] init];
    [(GPUImageDissolveBlendFilter *)filter setMix:0.5];
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    filterView.backgroundColor = [UIColor whiteColor];
    [filter addTarget:filterView];
    [self.view addSubview:filterView];
    // 播放
    NSURL *sampleURL = [[NSBundle mainBundle] URLForResource:@"sample_iPod" withExtension:@"m4v"];
    movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
   
    NSURL *sampleURL2 = [[NSBundle mainBundle] URLForResource:@"A_Nice_Day" withExtension:@"mp4"];
    movieFile2 = [[GPUImageMovie alloc] initWithURL:sampleURL2];
    movieFile2.runBenchmark = YES;
    movieFile2.playAtActualSpeed = YES;

    //
//    NSArray *thMovies = @[movieFile, movieFile2];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640, 480)];

    // 响应链
    [movieFile addTarget:filter];
//     movieFile.audioEncodingTarget = movieWriter;
    [movieFile2 addTarget:filter];
//        movieFile2.audioEncodingTarget = movieWriter;
    // 显示到界面
    [filter addTarget:filterView];
    [filter addTarget:movieWriter];
    
    [movieFile2 startProcessing];
    [movieFile startProcessing];
    [movieWriter startRecording];
    
    __weak typeof(self) weakSelf = self;
    [movieWriter setCompletionBlock:^{
        NSLog(@"完成了");
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->filter removeTarget:strongSelf->movieWriter];
        [strongSelf->movieWriter finishRecording];
        [strongSelf->movieFile endProcessing];
        [strongSelf->movieFile2 endProcessing];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            // 请求通过一个图片创建一个资源。
            PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:strongSelf->movieURL];
            // 请求编辑这个相簿。
            PHAssetCollectionChangeRequest *albumChangeRequest = [strongSelf getCurrentPhotoCollectionWithAlbumName:@"今日视频"];
            // 得到一个新的资源的占位对象并添加它到相簿编辑请求中。
            PHObjectPlaceholder *assetPlaceholder = [createAssetRequest placeholderForCreatedAsset];
            [albumChangeRequest addAssets:@[assetPlaceholder]];
        } completionHandler:^(BOOL success, NSError *error) {
            NSLog(@"Finished adding asset. %@", (success ? @"Success" : error));
        }];
    }];
}
- (PHAssetCollectionChangeRequest *)getCurrentPhotoCollectionWithAlbumName:(NSString *)albumName {
    // 1. 创建搜索集合
    PHFetchResult *result = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    // 2. 遍历搜索集合并取出对应的相册，返回当前的相册changeRequest
    for (PHAssetCollection *assetCollection in result) {
        if ([assetCollection.localizedTitle containsString:albumName]) {
            PHAssetCollectionChangeRequest *collectionRuquest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            return collectionRuquest;
        }
    }
    
    // 3. 如果不存在，创建一个名字为albumName的相册changeRequest
    PHAssetCollectionChangeRequest *collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
    return collectionRequest;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"内存紧张");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
