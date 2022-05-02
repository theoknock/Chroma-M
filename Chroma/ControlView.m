//
//  ControlView.m
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import "ControlView.h"

@implementation ControlView


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

static CGPoint (^point_from_angle)(const float) = ^ CGPoint (const float button_angle) {
    return ^ (float * angle_t, float * radius_t) {
        float radians = ((*angle_t) * kRadians_f);
        return CGPointMake(center_point.x - (*radius_t) * -cos(radians), center_point.y - (*radius_t) * -sin(radians));
    }(&button_angle, &radius);
};

static float (^angle_from_point)(CGPoint) = ^ (CGPoint point) {
    return ^ (float * angle_t) {
        *angle_t = (atan2(point.y - center_point.y, point.x - center_point.x)) * (arc_range[0] / M_PI);
        (*angle_t < 0.0) && (*angle_t = *angle_t + 360.0);
        *angle_t = validate_range(arc_range[0], arc_range[1], *angle_t);
        return *angle_t;
    }(&angle);
};

static float (^radius_from_point)(CGPoint) = ^ (CGPoint point) {
    return ^ (float * radius_t) {
        *radius_t = sqrt(pow(point.x - center_point.x, 2.0) + pow(point.y - center_point.y, 2.0));
        *radius_t = validate_range(radius_range[0], radius_range[1], *radius_t);
        return *radius_t;
    }(&radius);
};

static const void (^(^tick_wheel_renderer)(void))(CGContextRef, CGRect) = ^{
    __block unsigned long (^recursive_block)(unsigned long);
    return ^ (float * angle_t, float * radius_t) {
        return ^ (CGContextRef ctx, CGRect rect) {
            dispatch_barrier_sync(enumerator_queue(), ^{
                ((active_component_bit_vector ^ BUTTON_ARC_COMPONENT_BIT_MASK) && ^ unsigned long (void) {
                    UIGraphicsBeginImageContextWithOptions(rect.size, FALSE, 1.0);
                    CGContextTranslateCTM(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
                    (recursive_block = ^ unsigned long (unsigned long t) {
                        float radians = t * kRadians_f;
                        float tick_height = (t == arc_range[0] || t == arc_range[1]) ? 9.0 : (t % (unsigned int)round((arc_range[1] - arc_range[0]) / 9.0) == 0) ? 6.0 : 3.0;
                        {
                            CGPoint xy_outer = CGPointMake(((*radius_t + tick_height) * cosf(radians)),
                                                           ((*radius_t + tick_height) * sinf(radians)));
                            CGPoint xy_inner = CGPointMake(((*radius_t - tick_height) * cosf(radians)),
                                                           ((*radius_t - tick_height) * sinf(radians)));
                            CGContextSetStrokeColorWithColor(ctx, (t < (unsigned long)(*angle_t)) ? [[UIColor systemGreenColor] CGColor] : [[UIColor systemRedColor] CGColor]);
                            CGContextSetLineWidth(ctx, (t == arc_range[0] || t == arc_range[1]) ? 2.0 : (t % 9 == 0) ? 1.0 : 0.625);
                            CGContextMoveToPoint(ctx, xy_outer.x + CGRectGetMaxX(rect), xy_outer.y + CGRectGetMaxY(rect));
                            CGContextAddLineToPoint(ctx, xy_inner.x + CGRectGetMaxX(rect), xy_inner.y + CGRectGetMaxY(rect));
                        };
                        CGContextStrokePath(ctx);
                        UIGraphicsEndImageContext();
                        t++;
                        return (unsigned long)(t ^ (unsigned long)arc_range[1]) && (unsigned long)(recursive_block)(t);
                    })(arc_range[0]);
                    return TRUE_BIT;
                }()) || ((active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && ^ unsigned long (void) {
                    CGContextClearRect(ctx, rect);
                    return TRUE_BIT;
                }());
            });
        };
    }(&angle, &radius);
};

static const void (^draw_tick_wheel)(CGContextRef, CGRect);
static const void (^ const (* restrict draw_tick_wheel_t))(CGContextRef, CGRect) = &draw_tick_wheel;

static unsigned long (^(^_Nonnull touch_handler)(__strong UITouch * _Nullable))(const unsigned long (^ const (* _Nullable restrict))(unsigned long));
static unsigned long (^ _Nonnull  handle_touch)(const unsigned long (^ const (* _Nullable restrict))(unsigned long));
static unsigned long (^(^(^touch_handler_init)(const ControlView * __strong))(__strong UITouch * _Nullable))(const unsigned long (^ const (* _Nullable restrict))(unsigned long)) = ^ (const ControlView * __strong view) {
    __block unsigned long touch_property;

    draw_tick_wheel = tick_wheel_renderer();
    
    return ^ (__strong UITouch * _Nullable touch) {
        
        return ^ (const unsigned long (^ const (* _Nullable restrict state_setter_t))(unsigned long)) {
            
            return ^ unsigned long (unsigned long state) {
                
                ^ unsigned long (unsigned long state) {
                    iterate(&buttons, 5)(^ (id button) {
                        [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                        [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                        [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                        [(UIButton *)button setCenter:button_center_point(((UIButton *)button).tag)];
                    });
                    [view setNeedsDisplay];
                    return state;
                }(^ unsigned long (unsigned long state) {
                    return (active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (highlighted_property_bit_vector = (1UL << (touch_property = (unsigned int)round(rescale(angle, arc_range[0], arc_range[1], CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor)))));
                }(^ unsigned long (unsigned long state) {
                    return ^ unsigned long (CGPoint touch_point) {
                        touch_point.x = validate_range(CGRectGetMinX(view.bounds), center_point.x, touch_point.x);
                        touch_point.y = validate_range(CGRectGetMaxY(view.bounds) - CGRectGetWidth(view.bounds), center_point.y, touch_point.y);
                        radius_from_point(touch_point);
                        angle_from_point(touch_point);
                        return state;
                    }([touch preciseLocationInView:(ControlView *)view]);
                }((unsigned long)(((unsigned long)0 | (unsigned long)state_setter_t) && (*state_setter_t)(^ unsigned long {
                    const int frame_count = 60;
                    __block int angle_offset = 360.0 / frame_count;
                    (integrate((unsigned long)frame_count)(^ (unsigned long frame, BOOL * STOP) {
                        int degrees = (int)round((angle_offset * frame) % 360);
                        iterate(&buttons, 5)(^ (UIButton * button) {
                            [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                            [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                            [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                            [(UIButton *)button setCenter:point_from_angle(((int)angle_from_point(button_center_point(((UIButton *)button).tag)) + degrees))];
                        });
                        return frame;
                    }));
                    return TRUE_BIT;
                }())))));
            
                return state;
                
            }(TRUE_BIT);
        };
    };
};

- (void)awakeFromNib {
    [super awakeFromNib];
    typeof(^{}) predicate = ^{
        printf("predicate\n");
    };
    typeof(^{}) function = ^{
        printf("function\n");
    };
    typeof(^{}) block = ^{
        printf("block\n");
    };
    test_predicate_functions(predicate, function, block);
    
    center_point = CGPointMake(CGRectGetMaxX(((ControlView *)self).bounds) - (((UIButton *)buttons[0]).intrinsicContentSize.width + ((UIButton *)buttons[0]).intrinsicContentSize.height), CGRectGetMaxY(((ControlView *)self).bounds) - (((UIButton *)buttons[0]).intrinsicContentSize.width + ((UIButton *)buttons[0]).intrinsicContentSize.height));
    radius = CGRectGetMidX(((ControlView *)self).bounds);
    radius_range[0] = CGRectGetMidX(((ControlView *)self).bounds);
    radius_range[1] = center_point.x;
    
    printf("map == %lu\n", map(&buttons, 5)(^ const void * (const unsigned long index) {
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
    }));

    touch_handler = touch_handler_init((ControlView *)self);
}

- (void)drawRect:(CGRect)rect {
    (*draw_tick_wheel_t)(UIGraphicsGetCurrentContext(), rect);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    (handle_touch = touch_handler(touches.anyObject))(nil);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    handle_touch(nil);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    const int frame_count = 60;
//    __block int angle_offset = 360.0 / frame_count;
//    (integrate((unsigned long)frame_count)(^ (unsigned long frame, BOOL * STOP) {
//        int degrees = (int)round((angle_offset * frame) % 360);
//        iterate(&buttons, 5)(^ (UIButton * button) {
//            [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//            [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//            [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//            [(UIButton *)button setCenter:point_from_angle(((int)angle_from_point(button_center_point(((UIButton *)button).tag)) + degrees))];
//        });
//        return frame;
//    }));
    handle_touch(state_setter_ptr);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    handle_touch(nil);
}

@end
