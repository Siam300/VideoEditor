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
@property (strong, nonatomic) UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textField = [[UITextField alloc] init];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.placeholder = @"Enter Text";
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.textField];
}


- (void)playVideo:(NSURL *)videoURL {
    // Dismiss the existing video
    if (self.presentedViewController) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.player = player;
    
    // Create custom overlay view for text field
    UIView *textOverlayView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 200, 30)];
    textOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    // Add the text field to the text overlay view
    [self addTextFieldToOverlay:textOverlayView];
    
    // Add pan gesture recognizer for dragging the text overlay view
    UIPanGestureRecognizer *textOverlayPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTextOverlayPan:)];
    [textOverlayView addGestureRecognizer:textOverlayPanGestureRecognizer];
    
    // Create custom overlay view for text field overlay
    UIView *textFieldOverlayView = [[UIView alloc] initWithFrame:CGRectMake(10, 250, 60, 30)];
    textFieldOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    // Add the text field overlay to the text field overlay view
    [self addSaveButtonToOverlay:textFieldOverlayView];
    
    controller.contentOverlayView.subviews.firstObject.hidden = YES;
    
    // Add the custom overlay views to the AVPlayerViewController
    [controller.contentOverlayView addSubview:textOverlayView];
    [controller.contentOverlayView addSubview:textFieldOverlayView];
    
    // Present the AVPlayerViewController
    [self presentViewController:controller animated:YES completion:^{
        [player play];
    }];
}

- (void)handleTextOverlayPan:(UIPanGestureRecognizer *)gestureRecognizer {
    UIView *view = gestureRecognizer.view;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [gestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
}

- (void)addTextFieldToOverlay:(UIView *)overlayView {
    [overlayView addSubview:self.textField];
    
    // Enable user interaction for the overlay view
    overlayView.userInteractionEnabled = YES;
    
    // Center the text field in the overlay view
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.textField.centerXAnchor constraintEqualToAnchor:overlayView.centerXAnchor],
        [self.textField.centerYAnchor constraintEqualToAnchor:overlayView.centerYAnchor],
        [self.textField.widthAnchor constraintEqualToConstant:200],
        [self.textField.heightAnchor constraintEqualToConstant:30]
    ]];
}

- (void)addSaveButtonToOverlay:(UIView *)overlayView {
    // Create a custom button
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [customButton setTitle:@"Save" forState:UIControlStateNormal];
    [customButton setBackgroundColor:[UIColor whiteColor]];
    [customButton addTarget:self action:@selector(customButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    customButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add the button to the overlay view
    [overlayView addSubview:customButton];
    
    // Position the save button at the top leading of the overlay view
    [NSLayoutConstraint activateConstraints:@[
        [customButton.leadingAnchor constraintEqualToAnchor:overlayView.leadingAnchor constant:10],
        [customButton.topAnchor constraintEqualToAnchor:overlayView.topAnchor constant:10],
        [customButton.widthAnchor constraintEqualToConstant:60],
        [customButton.heightAnchor constraintEqualToConstant:30]
    ]];
}

- (void)customButtonTapped {
    NSLog(@"Save Button Tapped!");
    // Add your custom button functionality here
}

- (void)addTextOverlayToVideo:(AVAsset *)composition withFileName:(NSString *)outputFileName {
    CGSize size = [[[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
    
    // Create text layer
    CATextLayer *titleLayer = [CATextLayer layer];
    titleLayer.backgroundColor = [UIColor whiteColor].CGColor;
    titleLayer.string = @"Dummy text";
    titleLayer.font = (__bridge CFTypeRef)[UIFont fontWithName:@"Helvetica" size:28];
    titleLayer.shadowOpacity = 0.5;
    titleLayer.alignmentMode = kCAAlignmentCenter;
    titleLayer.frame = CGRectMake(0, 50, size.width, size.height / 6);
    
    CALayer *videoLayer = [CALayer layer];
    videoLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    CALayer *parentLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:titleLayer];
    
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize = size;
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                      inLayer:parentLayer];
    
    // Instruction for watermark
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, composition.duration);
    AVAssetTrack *videoTrack = [[composition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = @[layerInstruction];
    videoComposition.instructions = @[instruction];
    
    // Get documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Generate a unique file name
    NSString *uniqueFileName = outputFileName;
    NSInteger count = 1;
    
    while ([[NSFileManager defaultManager] fileExistsAtPath:[docsDir stringByAppendingPathComponent:uniqueFileName]]) {
        uniqueFileName = [NSString stringWithFormat:@"%@_%ld.%@", [outputFileName stringByDeletingPathExtension], (long)count++, [outputFileName pathExtension]];
    }
    
    // Create the full path for the movie file
    NSString *movieFilePath = [docsDir stringByAppendingPathComponent:uniqueFileName];
    NSURL *movieDestinationUrl = [NSURL fileURLWithPath:movieFilePath];
    
    // Use AVAssetExportSession to export video
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = movieDestinationUrl;
    
    // Export video asynchronously
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        switch (assetExport.status) {
            case AVAssetExportSessionStatusFailed:
                NSLog(@"Failed %@", assetExport.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Cancelled %@", assetExport.error);
                break;
            default:
                NSLog(@"Movie complete");
                
                // Play the exported video
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self playVideo:movieDestinationUrl];
                }];
                break;
        }
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    // Changed to check mediaType
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    // Changed media type comparison
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        self.videoURL = info[UIImagePickerControllerMediaURL];
        
        // Do something with the entered text
        NSString *enteredText = self.textField.text;
        NSLog(@"Entered Text: %@", enteredText);
        
        // Define the desired output file name (you can customize this)
        NSString *outputFileName = @"result.mov";
        
        // Add text overlay to the video with the specified output file name
        AVAsset *videoAsset = [AVAsset assetWithURL:self.videoURL];
        [self addTextOverlayToVideo:videoAsset withFileName:outputFileName];
        
        // Add Save button
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButtonTapped)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)saveButtonTapped {
    // Save the video with text
    NSString *outputFileName = @"result.mov";
    AVAsset *videoAsset = [AVAsset assetWithURL:self.videoURL];
    [self addTextOverlayToVideo:videoAsset withFileName:outputFileName];
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
