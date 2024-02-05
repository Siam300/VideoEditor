//
//  ViewController.m
//  VideoEditor
//
//  Created by Auto on 5/2/24.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>

@interface ViewController ()

@property (strong, nonatomic) NSURL *videoURL;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)playVideo {
    // Dismiss the existing video
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    AVPlayer *player = [AVPlayer playerWithURL:self.videoURL];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    
    controller.player = player;
    
    [self presentViewController:controller animated:YES completion:^{
        [player play];
    }];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    // Handle the picked documents (in this case, a video)
    NSURL *pickedURL = [urls firstObject];
    if (pickedURL) {
        self.videoURL = pickedURL;
        [self playVideo];
    }
}

- (IBAction)pickVideo:(id)sender {
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeMovie] inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (IBAction)btnPlay:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Video2" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    
    controller.player = player;
    
    [self presentViewController:controller animated:YES completion:nil];
    
    [player play];
    
}
@end
