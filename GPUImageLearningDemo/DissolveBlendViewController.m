//
//  DissolveBlendViewController.m
//  GPUImageLearningDemo
//
//  Created by donglingxiao on 2018/11/30.
//  Copyright © 2018 donglingxiao. All rights reserved.
//

#import "DissolveBlendViewController.h"

@interface DissolveBlendViewController ()
{
    GPUImageMovie *movieFile;
    GPUImageMovie *movieFile2;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
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
    
    NSURL *sampleURL2 = [[NSBundle mainBundle] URLForResource:@"qwe" withExtension:@"mp4"];
    movieFile2 = [[GPUImageMovie alloc] initWithURL:sampleURL2];
    movieFile2.runBenchmark = YES;
    movieFile2.playAtActualSpeed = YES;
    //
    NSArray *thMovies = @[movieFile, movieFile2];
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640, 480) ];
    
    
    // 响应链
    [movieFile addTarget:filter];
    [movieFile2 addTarget:filter];
    
    // 显示到界面
    [filter addTarget:filterView];
    [filter addTarget:movieWriter];
    
    [movieFile2 startProcessing];
    [movieFile startProcessing];
    [movieWriter startRecording];
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
