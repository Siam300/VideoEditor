//
//  ViewController.m
//  VideoEditor
//
//  Created by Auto on 5/2/24.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)btnPlay:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Video" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayer *player = [AVPlayer playerWithURL:url];
    AVPlayerViewController *controller = [[AVPlayerViewController alloc]init];
    
    controller.player = player;
    
    //show video on fullscreen
    controller.view.frame = self.view.bounds;
    [[self view] addSubview: controller.view];
    
    [player play];
}
@end
