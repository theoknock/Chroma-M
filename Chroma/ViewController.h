//
//  ViewController.h
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import "Renderer.h"
#import "VideoCamera.h"

NS_ASSUME_NONNULL_BEGIN

@class ControlView;

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet MTKView *mtkView;
@property (strong, nonatomic) IBOutlet UIView *ControlView;

@end

NS_ASSUME_NONNULL_END
