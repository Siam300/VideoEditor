//
//  ViewController.m
//  VideoEditor
//
//  Created by Auto on 5/2/24.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>

@interface ViewController () <UITabBarDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;



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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    // Changed to check mediaType
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Changed media type comparison
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        self.videoURL = info[UIImagePickerControllerMediaURL];
        [self playVideo];
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)pickVideo:(id)sender {
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    // Set mediaTypes to pick videos only
    videoPicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    videoPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [self presentViewController:videoPicker animated:YES completion:nil];
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
