//
//  VideoFileViewController.m
//  GPU
//
//  Created by donglingxiao on 2018/11/26.
//  Copyright © 2018 donglingxiao. All rights reserved.
//

#import "VideoFileViewController.h"

@interface VideoFileViewController ()
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}
@end

@implementation VideoFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self processMovie];
}
- (void)processMovie {
    NSString *pathStr = [[NSBundle mainBundle] pathForResource:@"sample_iPod.m4v" ofType:nil];
    movieFile = [[GPUImageMovie alloc] initWithURL:[NSURL fileURLWithPath:pathStr]];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = NO;
    filter = [[GPUImageUnsharpMaskFilter alloc] init];
    
    [movieFile addTarget:filter];
    
    // Only rotate the video for display, leave orientation the same for recording
    GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    filterView.backgroundColor = [UIColor whiteColor];
    [filter addTarget:filterView];
    [self.view addSubview:filterView];
    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    [filter addTarget:movieWriter];
    
    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
    
    [movieWriter startRecording];
    [movieFile startProcessing];
    
    __weak typeof(self) weakSelf = self;
    [movieWriter setCompletionBlock:^{
        //NSLog(@"完成");
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf->filter removeTarget:strongSelf->movieWriter];
        [strongSelf->movieWriter finishRecording];
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

