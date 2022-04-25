//
//  ControlView.m
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import "ControlView.h"

@implementation ControlView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

static int (^minimum)(int, int) = ^ int (int x, int y) {
    return y ^ ((x ^ y) & -(x < y));
};

static int (^maximum)(int, int) = ^ int (int x, int y) {
    return x ^ ((x ^ y) & -(x < y));
};

static int (^validate_range)(int, int, int) = ^ int (int min, int max, int val) {
    return maximum(min, minimum(val, max));
};

static CGPoint (^button_center_point)(const unsigned long) = ^ CGPoint (const unsigned long button_tag) {
    return ^ (float * angle_t, float * radius_t) {
        ((active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (^ long {
            *angle_t = rescale(button_tag, 0.0, 4.0, 180.0, 270.0);
            return TRUE_BIT;
        }()));
        float radians = ((*angle_t) * kRadians_f);
        return CGPointMake(center_point.x - (*radius_t) * -cos(radians), center_point.y - (*radius_t) * -sin(radians));
    }(&angle, &radius);
};

static float (^radius_from_point)(CGPoint) = ^ (CGPoint point) {
    return ^ (float * radius_t) {
        *radius_t = (atan2(point.y - center_point.y, point.x - center_point.x)) * (radius_range[0] / M_PI);
        (*radius_t < 0.0) && (*radius_t = *radius_t + 360.0);
        *radius_t = maximum(radius_range[0], minimum(radius_range[1], *radius_t));
        //    a = fmaxf(radius_range[0], fminf(a, radius_range[1]));
        return *radius_t;
    }(&radius);
};

static float (^angle_from_point)(CGPoint) = ^ (CGPoint point) {
    return ^ (float * angle_t) {
        *angle_t = sqrt(pow(point.x - center_point.x, 2.0) + pow(point.y - center_point.y, 2.0));
        *angle_t = maximum(radius_range[0], minimum(radius_range[1], *angle_t));
        //    r = fmaxf(radius_range[0], fminf(r, radius_range[1]));
        return *angle_t;
    }(&angle);
};


static unsigned long (^(^_Nonnull touch_handler)(__strong UITouch * _Nullable))(const unsigned long (^ const (* _Nullable restrict))(void));
static unsigned long (^ _Nonnull  handle_touch)(const unsigned long (^ const (* _Nullable restrict))(void));
static unsigned long (^(^(^touch_handler_init)(const ControlView * __strong))(__strong UITouch * _Nullable))(const unsigned long (^ const (* _Nullable restrict))(void)) = ^ (const ControlView * __strong view) {
    __block unsigned long touch_property;
    
    return ^ (__strong UITouch * _Nullable touch) {
        
        return ^ (const unsigned long (^ const (* _Nullable restrict state_setter_t))(void)) {
            ^ (CGPoint touch_point) {
                touch_point.x = validate_range(CGRectGetMinX(view.bounds), center_point.x, touch_point.x);
                touch_point.y = validate_range(CGRectGetMaxY(view.bounds) - CGRectGetWidth(view.bounds), center_point.y, touch_point.y);
                radius_from_point(touch_point);
                angle_from_point(touch_point);
                printf("%lu\n", (touch_property = (unsigned int)round(rescale(angle, arc_range[0], arc_range[1], CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor))));
                (active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (highlighted_property_bit_vector = (1UL << touch_property));
                
                iterate(&buttons, 5)(^ (id button) {
                    [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                    [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                    [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                    [(UIButton *)button setCenter:button_center_point(((UIButton *)button).tag)];
                    printf("%s\n", [NSStringFromCGPoint([(UIButton *)button center]) UTF8String]);
                    (((active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (^ unsigned long {
                        return TRUE_BIT;
                    }())));
                    ((selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL) && printf("%lu == %s\n", ((UIButton *)button).tag, [NSStringFromCGPoint([(UIButton *)button center]) UTF8String]);
                });
                [view setNeedsDisplay];
            }([touch preciseLocationInView:(ControlView *)view]);
            
            return (unsigned long)(((unsigned long)0 | (unsigned long)state_setter_t) && (*state_setter_t)() || FALSE_BIT);
        };
    };
};

- (void)awakeFromNib {
    [super awakeFromNib];
    
    center_point= CGPointMake(CGRectGetMaxX(((ControlView *)self).bounds) - (((UIButton *)buttons[0]).intrinsicContentSize.width + ((UIButton *)buttons[0]).intrinsicContentSize.height), CGRectGetMaxY(((ControlView *)self).bounds) - (((UIButton *)buttons[0]).intrinsicContentSize.width + ((UIButton *)buttons[0]).intrinsicContentSize.height));
    radius = CGRectGetMidX(((ControlView *)self).bounds) * 1.5;
    radius_range[0] = CGRectGetMidX(((ControlView *)self).bounds);
    radius_range[1] = center_point.x;
    
    map(&buttons, 5)(^ const void * (const unsigned long index) {
        __block UIButton * button;
        [button = [UIButton new] setTag:index];
        [button setImage:[UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertyImageValues[0][index] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateDeselected)] forState:UIControlStateNormal];
        [button setImage:[UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertyImageValues[1][index] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateSelected)] forState:UIControlStateSelected];
        [button setImage:[UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertyImageValues[1][index] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateHighlighted)] forState:UIControlStateHighlighted];
        NSMutableParagraphStyle *centerAlignedParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        centerAlignedParagraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *centerAlignedTextAttributes = @{NSForegroundColorAttributeName:[UIColor systemYellowColor],
                                                      NSFontAttributeName:[UIFont systemFontOfSize:14.0],
                                                      NSParagraphStyleAttributeName:centerAlignedParagraphStyle};
        
        NSString *valueString = [NSString stringWithFormat:@"%.2f", 0.00];
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:valueString attributes:centerAlignedTextAttributes];
        [button setAttributedTitle:attributedString forState:UIControlStateNormal];
        [button.titleLabel setFrame:UIScreen.mainScreen.bounds];
        [button sizeToFit];
        
        float angle = rescale(index, 0.0, 4.0, 180.0, 270.0);
        NSNumber * button_angle = [NSNumber numberWithFloat:angle];
        objc_setAssociatedObject (button,
                                  (void *)index,
                                  button_angle,
                                  OBJC_ASSOCIATION_RETAIN);
        
        [button setUserInteractionEnabled:FALSE];
        void (^eventHandlerBlockTouchUpInside)(void) = ^{
            NSNumber * associatedObject = (NSNumber *)objc_getAssociatedObject (button, (void *)index);
            //            printf("%s\n", [[associatedObject stringValue] UTF8String]);
        };
        objc_setAssociatedObject(button, @selector(invoke), eventHandlerBlockTouchUpInside, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [button addTarget:eventHandlerBlockTouchUpInside action:@selector(invoke) forControlEvents:UIControlEventTouchUpInside];
        
        CGPoint target_center = button_center_point(index);
        [button setCenter:target_center];
        [self addSubview:button];
        
        return (const id *)CFBridgingRetain(button);
    });
    
    printf("START\t\t%s\n", [NSStringFromCGPoint([(UIButton *)buttons[0] center]) UTF8String]);
    
    touch_handler = touch_handler_init((ControlView *)self);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    (handle_touch = touch_handler(touches.anyObject))(nil);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    handle_touch(nil);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    handle_touch(state_setter_ptr);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    handle_touch(nil);
}

@end
