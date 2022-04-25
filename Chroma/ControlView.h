//
//  ControlView.h
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import <UIKit/UIKit.h>
#include <stdio.h>
#import <stdlib.h>
#include <Block.h>
#include <math.h>

#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

#define BUTTON_ARC_COMPONENT_BIT_MASK ( 1UL << 0 |   1UL << 1 |   1UL << 2 |   1UL << 3 |   1UL << 4 )
#define TICK_WHEEL_COMPONENT_BIT_MASK ( 0UL << 0 |   0UL << 1 |   0UL << 2 |   0UL << 3 |   0UL << 4 )
#define TRUE_BIT ( 1UL << 0 )
#define FALSE_BIT (TRUE_BIT ^ TRUE_BIT)

unsigned long active_component_bit_vector     = ( 1UL << 0 |   1UL << 1 |   1UL << 2 |   1UL << 3 |   1UL << 4 );
unsigned long highlighted_property_bit_vector = ( 0UL << 0 |   0UL << 1 |   0UL << 2 |   0UL << 3 |   0UL << 4 );
unsigned long selected_property_bit_vector    = ( 0UL << 0 |   0UL << 1 |   0UL << 2 |   0UL << 3 |   0UL << 4 );
unsigned long hidden_property_bit_vector      = ( 0UL << 0 |   0UL << 1 |   0UL << 2 |   0UL << 3 |   0UL << 4 );

static CGPoint center_point;
static float radius;
static float radius_range[2];
static const float arc_range[2] = {180.0, 270.0};
static float angle;

static const float kPi_f      = (float)(M_PI);
static const float k1Div180_f = 1.0f / 180.0f;
static const float kRadians_f = k1Div180_f * kPi_f;

static float (^ _Nonnull degreesToRadians)(float) = ^ float (float degrees) {
    return (degrees * M_PI / 180.0);
};

static float (^ _Nonnull rescale)(float, float, float, float, float) = ^ float (float old_value, float old_min, float old_max, float new_min, float new_max) {
    float scaled_value = (new_max - new_min) * (old_value - old_min) / (old_max - old_min) + new_min;
    return scaled_value;
};

typedef enum : unsigned long {
    CaptureDeviceConfigurationControlPropertyTorchLevel,
    CaptureDeviceConfigurationControlPropertyLensPosition,
    CaptureDeviceConfigurationControlPropertyExposureDuration,
    CaptureDeviceConfigurationControlPropertyISO,
    CaptureDeviceConfigurationControlPropertyVideoZoomFactor,
    CaptureDeviceConfigurationControlPropertyAll
} CaptureDeviceConfigurationControlProperty;

static dispatch_queue_t _Nonnull enumerator_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("enumerator_queue()", NULL);
    });
    
    return queue;
};

static dispatch_queue_t _Nonnull animator_queue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
    });
    
    return queue;
};

static NSArray<NSString *> * const CaptureDeviceConfigurationControlPropertyImageKeys = @[@"CaptureDeviceConfigurationControlPropertyTorchLevel",
                                                                                          @"CaptureDeviceConfigurationControlPropertyLensPosition",
                                                                                          @"CaptureDeviceConfigurationControlPropertyExposureDuration",
                                                                                          @"CaptureDeviceConfigurationControlPropertyISO",
                                                                                          @"CaptureDeviceConfigurationControlPropertyZoomFactor"];


static NSArray<NSArray<NSString *> *> * const CaptureDeviceConfigurationControlPropertyImageValues = @[@[@"bolt.circle",
                                                                                                         @"viewfinder.circle",
                                                                                                         @"timer",
                                                                                                         @"camera.aperture",
                                                                                                         @"magnifyingglass.circle"],@[@"bolt.circle.fill",
                                                                                                                                      @"viewfinder.circle.fill",
                                                                                                                                      @"timer",
                                                                                                                                      @"camera.aperture",
                                                                                                                                      @"magnifyingglass.circle.fill"]];

typedef enum : NSUInteger {
    CaptureDeviceConfigurationControlStateDeselected,
    CaptureDeviceConfigurationControlStateSelected,
    CaptureDeviceConfigurationControlStateHighlighted
} CaptureDeviceConfigurationControlState;

static UIImageSymbolConfiguration * (^CaptureDeviceConfigurationControlPropertySymbolImageConfiguration)(CaptureDeviceConfigurationControlState) = ^ UIImageSymbolConfiguration * (CaptureDeviceConfigurationControlState state) {
    UIImageSymbolConfiguration * symbol_point_size_weight = [UIImageSymbolConfiguration configurationWithPointSize:42.0 weight:UIImageSymbolWeightLight];
    switch (state) {
        case CaptureDeviceConfigurationControlStateDeselected: {
            UIImageSymbolConfiguration * symbol_color             = [UIImageSymbolConfiguration configurationWithHierarchicalColor:[UIColor systemBlueColor]];
            return [symbol_color configurationByApplyingConfiguration:symbol_point_size_weight];
        }
            break;
        case CaptureDeviceConfigurationControlStateSelected: {
            UIImageSymbolConfiguration * symbol_color             = [UIImageSymbolConfiguration configurationWithHierarchicalColor:[UIColor systemYellowColor]];
            return [symbol_color configurationByApplyingConfiguration:symbol_point_size_weight];
        }
            break;
        case CaptureDeviceConfigurationControlStateHighlighted: {
            UIImageSymbolConfiguration * symbol_color             = [UIImageSymbolConfiguration configurationWithHierarchicalColor:[UIColor systemRedColor]];
            return [symbol_color configurationByApplyingConfiguration:symbol_point_size_weight];
        }
            break;
        default: {
            UIImageSymbolConfiguration * symbol_color             = [UIImageSymbolConfiguration configurationWithHierarchicalColor:[UIColor systemYellowColor]];
            return [symbol_color configurationByApplyingConfiguration:symbol_point_size_weight];
        }
            break;
    }
};

static NSString * (^CaptureDeviceConfigurationControlPropertySymbol)(CaptureDeviceConfigurationControlProperty, CaptureDeviceConfigurationControlState) = ^ NSString * (CaptureDeviceConfigurationControlProperty property, CaptureDeviceConfigurationControlState state) {
    return CaptureDeviceConfigurationControlPropertyImageValues[state][property];
};

static NSString * (^CaptureDeviceConfigurationControlPropertyString)(CaptureDeviceConfigurationControlProperty) = ^ NSString * (CaptureDeviceConfigurationControlProperty property) {
    return CaptureDeviceConfigurationControlPropertyImageKeys[property];
};

static UIImage * (^CaptureDeviceConfigurationControlPropertySymbolImage)(CaptureDeviceConfigurationControlProperty, CaptureDeviceConfigurationControlState) = ^ UIImage * (CaptureDeviceConfigurationControlProperty property, CaptureDeviceConfigurationControlState state) {
    return [UIImage systemImageNamed:CaptureDeviceConfigurationControlPropertySymbol(property, state) withConfiguration:CaptureDeviceConfigurationControlPropertySymbolImageConfiguration(state)];
};

static __strong id _Nonnull buttons[5];
static void (^(^map)(id _Nonnull * _Nonnull, const unsigned long))(const void *(^__strong)(const unsigned long)) = ^ (id * _Nonnull obj_collection, const unsigned long index_count) {
    __block unsigned long (^recursive_block)(unsigned long);
    return ^ (const void * (^enumeration)(const unsigned long)) {
        (recursive_block = ^ unsigned long (unsigned long counter) {
            obj_collection[counter] = (__bridge id)((__bridge const void * _Nonnull)CFBridgingRelease(enumeration(counter)));
            return (unsigned long)((counter += 1) ^ index_count) && (unsigned long)(recursive_block)(counter);
        })(0ul);
    };
};

static void (^(^iterate)(id _Nonnull * _Nonnull, const unsigned long))(void(^__strong)(id)) = ^ (id * _Nonnull obj_collection, const unsigned long index_count) {
    __block unsigned long (^recursive_block)(unsigned long);
    return ^ (void(^enumeration)(id)) {
        (recursive_block = ^ unsigned long (unsigned long counter) {
            enumeration(obj_collection[counter]);
            return (unsigned long)((counter += 1) ^ index_count) && (unsigned long)(recursive_block)(counter);
        })(0ul);
    };
};


static const unsigned long (^state_setter)(void) = ^{
    selected_property_bit_vector = highlighted_property_bit_vector & active_component_bit_vector;
    hidden_property_bit_vector = (~selected_property_bit_vector & active_component_bit_vector);
    highlighted_property_bit_vector = active_component_bit_vector ^ active_component_bit_vector;
    active_component_bit_vector = ~active_component_bit_vector;
    
    return active_component_bit_vector;
};
static const unsigned long (^ _Nullable const (* _Nullable restrict state_setter_ptr))(void) = &state_setter;


@interface ControlView : UIView

@end

NS_ASSUME_NONNULL_END
