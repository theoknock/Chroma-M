//
//  ViewController.m
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    Renderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mtkView.backgroundColor = UIColor.blackColor;
    [self.mtkView setDevice:self.mtkView.preferredDevice];
    [self.mtkView setFramebufferOnly:FALSE];
    self.mtkView.preferredFramesPerSecond = 60;
    
    _renderer = [[Renderer alloc] initWithMetalKitView:self.mtkView];
    
    [_renderer mtkView:self.mtkView drawableSizeWillChange:self.mtkView.drawableSize];
    printf("%s\n   ", [NSStringFromCGSize(self.mtkView.drawableSize) UTF8String]);
    printf("%f\n", self.mtkView.layer.contentsScale);
    printf("%f\n", self.mtkView.drawableSize.width / self.mtkView.drawableSize.height);
    printf("%f\n", self.mtkView.drawableSize.height / self.mtkView.drawableSize.width);
    self.mtkView.delegate = _renderer;
    
    [VideoCamera setAVCaptureVideoDataOutputSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)_renderer];
}

@end
