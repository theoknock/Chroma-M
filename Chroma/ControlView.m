//
//  ControlView.m
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import "ControlView.h"
#include <stdio.h>   /* for printf */
#include <stdarg.h>  /* for va_arg, va_start,
va_list, va_end */

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

CGPoint (^button_center_point_va)(const char *fmt, ...) = ^ CGPoint (const char *fmt, ...) {
    __block va_list ap;
    va_start(ap, fmt);
    return ^ (float * angle_t, float * radius_t) {
        const char * fmt_block = fmt;
        while (*fmt_block)
        {
            switch (*fmt_block)
            {
                case '%':
                    fmt_block++;
                    if (*fmt_block == 'd')
                    {
                        int button_tag = va_arg(ap, int);
                        ((active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (^ long {
                            *angle_t = rescale(button_tag, CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor, arc_range[1], arc_range[0]);
                            return TRUE_BIT;
                        }()));
                    }
                    else if (*fmt_block == 'f')
                    {
                        *angle_t = va_arg(ap, double);
                    }
                    else {
                        printf("%%%c is an unknown format\n",
                               *fmt_block);
                    }
                    fmt_block++;
                    break;
                default:
                    printf("%c is unknown\n", *fmt_block);
                    fmt_block++;
                    break;
            } }
        va_end(ap);
        float radians = ((*angle_t) * kRadians_f);
        return CGPointMake(center_point.x - (*radius_t) * -cos(radians), center_point.y - (*radius_t) * -sin(radians));
    }(&angle, &radius);
};

//static CGPoint (^button_center_point)(const unsigned long) = ^ CGPoint (const unsigned long button_tag) {
//    return ^ (float * angle_t, float * radius_t) {
//        ((active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (^ long {
//            *angle_t = rescale(button_tag, CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor, arc_range[1], arc_range[0]);
//            return TRUE_BIT;
//        }()));
//        float radians = ((*angle_t) * kRadians_f);
//        return CGPointMake(center_point.x - (*radius_t) * -cos(radians), center_point.y - (*radius_t) * -sin(radians));
//    }(&angle, &radius);
//};
//
//static CGPoint (^point_from_angle)(const float) = ^ CGPoint (const float button_angle) {
//    return ^ (float * angle_t, float * radius_t) {
//        float radians = ((*angle_t) * kRadians_f);
//        return CGPointMake(center_point.x - (*radius_t) * -cos(radians), center_point.y - (*radius_t) * -sin(radians));
//    }(&button_angle, &radius);
//};

static float (^angle_from_point)(CGPoint) = ^ (CGPoint point) {
    return ^ (float * angle_t) {
        *angle_t = (atan2(point.y - center_point.y, point.x - center_point.x)) * (arc_range[1] / M_PI);
        (*angle_t < 0.0) && (*angle_t = *angle_t + 360.0);
        *angle_t = validate_range(arc_range[1], arc_range[0], *angle_t);
        return *angle_t;
    }(&angle);
};

static float (^radius_from_point)(CGPoint) = ^ (CGPoint point) {
    return ^ (float * radius_t) {
        *radius_t = sqrt(pow(point.x - center_point.x, 2.0) + pow(point.y - center_point.y, 2.0));
        *radius_t = validate_range(radius_range[1], radius_range[0], *radius_t);
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
                        
                        //                        (a & b) | (~a & c)
                        float tick_height = (t == arc_range[1] || t == arc_range[0]) ? 9.0 : (t % (unsigned int)round((arc_range[1] - arc_range[0]) / 9.0) == 0) ? 6.0 : 3.0;
                        {
                            CGPoint xy_outer = CGPointMake(((*radius_t + tick_height) * cosf(radians)),
                                                           ((*radius_t + tick_height) * sinf(radians)));
                            CGPoint xy_inner = CGPointMake(((*radius_t - tick_height) * cosf(radians)),
                                                           ((*radius_t - tick_height) * sinf(radians)));
                            CGContextSetStrokeColorWithColor(ctx, (t < (unsigned long)(*angle_t)) ? [[UIColor systemGreenColor] CGColor] : [[UIColor systemRedColor] CGColor]);
                            CGContextSetLineWidth(ctx, (t == arc_range[1] || t == arc_range[0]) ? 2.0 : (t % 9 == 0) ? 1.0 : 0.625);
                            CGContextMoveToPoint(ctx, xy_outer.x + CGRectGetMaxX(rect), xy_outer.y + CGRectGetMaxY(rect));
                            CGContextAddLineToPoint(ctx, xy_inner.x + CGRectGetMaxX(rect), xy_inner.y + CGRectGetMaxY(rect));
                            CGContextStrokePath(ctx);
                        };
                        
                        UIGraphicsEndImageContext();
                        t++;
                        return (unsigned long)(t ^ (unsigned long)arc_range[0]) && (unsigned long)(recursive_block)(t);
                    })(arc_range[1]);
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
//            ^ unsigned long (unsigned long state) {
//                    return (unsigned long)(((unsigned long)0 | (unsigned long)state_setter_t)) && (*state_setter_t)(^ unsigned long {
//                        const int frame_count = 30;
//                        __block int angle_offset = 360.0 / frame_count;
//                        return integrate((unsigned long)frame_count)(^ unsigned long (unsigned long frame, BOOL * STOP) {
//                            int degrees = (int)round((angle_offset * frame) % 360);
//                            return iterate(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ (UIButton * button) {
//                                [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                                [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                                [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                                [(UIButton *)button setCenter:button_center_point_va("%f", (rescale(((UIButton *)button).tag, CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor, arc_range[0], arc_range[1])) + degrees)];
//                            });
//                        });
//                    }());
//            }(^ unsigned long (unsigned long state) {
//
//                return state && iterate(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ (UIButton * button) {
//                    [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                    [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                    [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                    [(UIButton *)button setCenter:button_center_point_va("%d", (((UIButton *)button).tag))];
//                    [(ControlView *)view setNeedsDisplay];
//                });
//            }(^ unsigned long (unsigned long state) {
//                return state && ^ unsigned long (CGPoint touch_point) {
//                    touch_point.x = validate_range(CGRectGetMinX(view.bounds), center_point.x, touch_point.x);
//                    touch_point.y = validate_range(CGRectGetMaxY(view.bounds) - CGRectGetWidth(view.bounds), center_point.y, touch_point.y);
//                    radius_from_point(touch_point);
//                    angle_from_point(touch_point);
//                    return (active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (highlighted_property_bit_vector = (1UL << (touch_property = (unsigned int)round(rescale(angle, arc_range[0], arc_range[1], CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor)))));
//                }([touch preciseLocationInView:(ControlView *)view]);
//            }(^ unsigned long (unsigned long state) {
//                    return (unsigned long)(((unsigned long)0 | (unsigned long)state_setter_t)) && (*state_setter_t)(^ unsigned long {
//                        const int frame_count = 30;
//                        __block int angle_offset = 360.0 / frame_count;
//                        return integrate((unsigned long)frame_count)(^ unsigned long (unsigned long frame, BOOL * STOP) {
//                            int degrees = (int)round((angle_offset * frame) % 360);
//                            return iterate(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ (UIButton * button) {
//                                [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                                [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                                [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                                [(UIButton *)button setCenter:button_center_point_va("%f", (rescale(((UIButton *)button).tag, CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor, arc_range[0], arc_range[1])) + degrees)];
//                            });
//                        });
//                    }());
//                }(1UL))));
            
//            (^ unsigned long (unsigned long state) {
//                return (active_component_bit_vector & BUTTON_ARC_COMPONENT_BIT_MASK) && (highlighted_property_bit_vector = (1UL << (touch_property = (unsigned int)round(rescale(angle, arc_range[0], arc_range[1], CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor)))));
//            }(^ unsigned long (unsigned long state) {
//                iterate(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ (UIButton * button) {
//                    [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                    [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                    [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
//                    [(UIButton *)button setCenter:button_center_point_va("%d", (((UIButton *)button).tag))];
//                    [(ControlView *)view setNeedsDisplay];
//                });
//            }(TRUE_BIT))));
//
            
           
            
            
            
//            return TRUE_BIT;
            
            
//
            
            ^ unsigned long (unsigned long block_3) {
                printf("block_3_i\n");
                return ^ unsigned long { return printf("block_3_r\n"); }();
            }(^ unsigned long (unsigned long block_2) {
                printf("block_2_i\n");
                return ^ unsigned long (unsigned long block_2a) { // within scope of block_2
                    printf("block_2a_i\n");
                    return ^ unsigned long (unsigned long block_2b) {  // within scope of block_2
                        printf("block_2b_i\n");
                        return ^ unsigned long { return printf("block_2b_r\n"); }();
                    }(^ unsigned long { return printf("block_2a_r\n"); }());
                }(^ unsigned long { return printf("block_2_r\n"); }());
            }(^ unsigned long (unsigned long block_1) {
                printf("block_1_i\n");
                return ^ unsigned long { return printf("block_1_r\n"); }();
            }(^ unsigned long { return printf("block\n"); }())));
            
            
            return ^ unsigned long (unsigned long state) {
                iterate(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ (id button) {
                    [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                    [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                    [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                    [(UIButton *)button setCenter:button_center_point_va("%d", (((UIButton *)button).tag))];
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
                const int frame_count = 30;
                __block int angle_offset = 360.0 / frame_count;
                return (integrate((unsigned long)frame_count)(^ (unsigned long frame, BOOL * STOP) {
                    int degrees = (int)round((angle_offset * frame) % 360);
                    return iterate(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ (UIButton * button) {
                        [(UIButton *)button setHighlighted:(highlighted_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                        [(UIButton *)button setSelected:(selected_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                        [(UIButton *)button setHidden:(hidden_property_bit_vector >> ((UIButton *)button).tag) & 1UL];
                        [(UIButton *)button setCenter:button_center_point_va("%f", (rescale(((UIButton *)button).tag, CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor, arc_range[0], arc_range[1])) + degrees)];
                    });
                }));
//                return TRUE_BIT;
            }())))));
        };
    };
    
};


- (void)awakeFromNib {
    [super awakeFromNib];
    
    center_point = CGPointMake(CGRectGetMaxX(((ControlView *)self).bounds) - 40.5, CGRectGetMaxY(((ControlView *)self).bounds) - 40.5);
    radius = (center_point.x / 2);
    radius_range[1] = radius;
    radius_range[0] = center_point.x;
    
    
    map(&buttons_ptr, CaptureDeviceConfigurationControlPropertyAll)(^ const void * (const unsigned long index) {
        __block UIButton * button;
        [button = [UIButton new] setTag:index];
        [button setImage:[UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertyImageValues[1][index] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateDeselected)] forState:UIControlStateNormal];
        [button setImage:[UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertyImageValues[0][index] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateSelected)] forState:UIControlStateSelected];
        [button setImage:[UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertyImageValues[0][index] withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(CaptureDeviceConfigurationControlStateHighlighted)] forState:UIControlStateHighlighted];
        [button sizeToFit];
        
        float angle = rescale(index, CaptureDeviceConfigurationControlPropertyTorchLevel, CaptureDeviceConfigurationControlPropertyVideoZoomFactor, arc_range[1], arc_range[0]);
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
        
        [button setCenter:button_center_point_va("%d", index)];
        [self addSubview:button];
        
        return (const id *)CFBridgingRetain(button);
    });
    
    
    
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
    handle_touch(state_setter_ptr);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    handle_touch(nil);
}

@end
