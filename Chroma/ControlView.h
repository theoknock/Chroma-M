//
//  ControlView.h
//  Chroma
//
//  Created by Xcode Developer on 4/24/22.
//

#import <UIKit/UIKit.h>
#include <stdio.h>
#include <stdlib.h>
#include <Block.h>
#include <math.h>
#include <dispatch/dispatch.h>
#include <libkern/osatomic.h>
#include <sys/types.h>
#include <sys/mman.h>

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

static const unsigned long (^state_setter)(void) = ^{
    selected_property_bit_vector = highlighted_property_bit_vector & active_component_bit_vector;
    hidden_property_bit_vector = (~selected_property_bit_vector & active_component_bit_vector);
    highlighted_property_bit_vector = active_component_bit_vector ^ active_component_bit_vector;
    active_component_bit_vector = ~active_component_bit_vector;
    
    return active_component_bit_vector;
};
static const unsigned long (^ _Nullable const (* _Nullable restrict state_setter_ptr))(void) = &state_setter;


static CGPoint center_point;

static float radius;
static float * const radius_t = &radius;
static float radius_range[2];

static float angle;
static float * const angle_t = &angle;
static const float arc_range[2] = {180.0, 270.0};

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

static unsigned long (^(^map)(id _Nonnull * _Nonnull, const unsigned long))(const void *(^__strong)(const unsigned long)) = ^ (id * _Nonnull obj_collection, const unsigned long index_count) {
    __block unsigned long (^recursive_block)(unsigned long);
    return ^ (const void * (^enumeration)(const unsigned long)) {
        return (recursive_block = ^ unsigned long (unsigned long index) {
            --index;
            *(obj_collection + index) = (__bridge id)((__bridge const void * _Nonnull)CFBridgingRelease(enumeration(index)));
            return (unsigned long)(index ^ 0UL) && (unsigned long)(recursive_block)(index);
        })(index_count);
    };
};

static unsigned long (^(^iterate)(id _Nonnull * _Nonnull, const unsigned long))(void(^__strong)(id)) = ^ (id * _Nonnull obj_collection, const unsigned long index_count) {
    __block unsigned long (^recursive_block)(unsigned long);
    return ^ (void(^enumeration)(id)) {
        return (recursive_block = ^ unsigned long (unsigned long index) {
            --index;
            enumeration(*(obj_collection + index));
            return (unsigned long)(index ^ 0UL) && (unsigned long)(recursive_block)(index);
        })(index_count);
    };
};

static OSQueueHead PredFuncPtrQueue = OS_ATOMIC_QUEUE_INIT;

struct PredFuncPtrStruct
{
    typeof(void(^*)(void)) predicate_t;
    typeof(void(^*)(void)) function_t;
    typeof(void(^*)(void)) block_t;
};

static void (^test_predicate_functions)(typeof(void(^)(void)), typeof(void(^)(void)), typeof(void(^)(void))) = ^ (typeof(void(^)(void)) predicate, typeof(void(^)(void)) function, typeof(void(^)(void)) block) {
    (predicate)();
    (function)();
    (block)();
    struct PredFuncPtrStruct * predicate_function_enqueue = malloc(sizeof(struct PredFuncPtrStruct));
    predicate_function_enqueue->predicate_t = Block_copy((typeof(void(^*)(void)))CFBridgingRetain(predicate));
    predicate_function_enqueue->function_t  = Block_copy((typeof(void(^*)(void)))CFBridgingRetain(function));
    predicate_function_enqueue->block_t  = Block_copy((typeof(void(^*)(void)))CFBridgingRetain(block));
    OSAtomicEnqueue(&PredFuncPtrQueue, predicate_function_enqueue, sizeof(struct PredFuncPtrStruct));
    struct PredFuncPtrStruct * predicate_function_dequeue = OSAtomicDequeue(&PredFuncPtrQueue, sizeof(struct PredFuncPtrStruct));
    ((const void(^)(void))CFBridgingRelease(predicate_function_dequeue->predicate_t))();
    ((const void(^)(void))CFBridgingRelease(predicate_function_dequeue->function_t))();
    ((const void(^)(void))CFBridgingRelease(predicate_function_dequeue->block_t))();
};

static OSQueueHead IntegrandQueue = OS_ATOMIC_QUEUE_INIT;
struct IntegrandStruct {
    typeof(unsigned long(^*)(unsigned long)) _Nonnull integrand_t;
};
static unsigned long (^ __strong integrand)(unsigned long, BOOL *);
static unsigned long (^(^integrate)(unsigned long))(unsigned long (^ __strong )(unsigned long, BOOL *)) = ^ (unsigned long frame_count) {
    __block typeof(CADisplayLink *) display_link;
    __block unsigned long frames = ~(1 << (frame_count + 1));
    __block unsigned long frame;
    __block BOOL STOP = FALSE;
    
    /*
     
     const float (^(^blk)(float))(void) = ^ (float f) {
             return ^ (float f) {
                 return ^ float {
                     return f;
                 };
             }(f);
         };
     const float(^blk_param)(void) = blk(1.0);
     printf("blk_param() == %f\n", blk_param());
     
     */
    
    return ^ (unsigned long (^ __strong integrand)(unsigned long, BOOL *)) {
        unsigned long (^ _Nonnull __strong integrands[frame_count])(void);
        
        map(&integrands, frame_count)(^ const void * (const unsigned long index) {
            printf("map == %lu\n", index);
            return (const void *)CFBridgingRetain(^ (unsigned long frame, BOOL * STOP) {
                return ^{
                    printf("integrand == %lu\n", frame);
                    return integrand(frame, STOP);
                };
            }(index, &STOP));
        });
                iterate(&integrands, frame_count)(^ (id block) {
                    printf("block == %lu\n", ((typeof(unsigned long (^)(void)))CFBridgingRelease((__bridge CFTypeRef _Nullable)(block)))());
        
                });
        display_link = [CADisplayLink displayLinkWithTarget:^{
            frames >>= 1;
            frame = floor(log2(frames));
            printf("display_link == %lu\n", frame);
//            unsigned long (^integrand_t)(void) = CFBridgingRelease((__bridge CFTypeRef _Nullable)(integrands[frame]));
//            iterate(&integrands, 30)(^ (id block) {
//                printf("integrand_t == %lu\n", ((typeof(unsigned long (^)(void)))block)());
//    //            = CFBridgingRelease((__bridge CFTypeRef _Nullable)(integrands[frame]));
//
//            });
//            (((frames & 1) & (STOP == FALSE)) && integrand_t()) || ^ long {
//                printf("integrand_t == %lu\n", ((typeof(unsigned long (^)(void)))integrand_t)());
                [display_link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                [display_link invalidate];
                [display_link setPaused:TRUE];
                display_link = nil;
//                return active_component_bit_vector;
//                return active_component_bit_vector;
//            }();
        } selector:@selector(invoke)];
        [display_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        return TRUE_BIT;
    };
};

// Iterate an array of predicated-function blocks...
//
//typedef typeof(unsigned long(^)(unsigned long)) blk;
//typedef typeof(unsigned long(^*)(unsigned long)) blk_t;
//blk blk_a;
//__block blk_t blka_t = &blk_a;
//blk blk_b;
//__block blk_t blkb_t = &blk_b;
//blk blk_c;
//const blk_t blkc_t = &blk_c;
//
//__block unsigned long count = 5;
//count = ~(1 << (count + 1));
//
//blk_a = ^ unsigned long (unsigned long counter) {
//    printf("blk_a counter == %lu\n", counter);
//    return (*blkc_t)(counter); //(unsigned long)(*blkb_t)(((counter <<= 1) ^ (0 - counter)));
//};
//
//blk_b = ^ unsigned long (unsigned long counter) {
//    printf("blk_b counter == %lu\n", counter);
//    return (*blkc_t)(counter); //(unsigned long)(*blka_t)(((counter <<= 1) ^ (0 - counter)));
//};
//
//blk_c = ^ unsigned long (unsigned long counter) {
//    int c =
//    printf("blk_c counter == %lu\n", (unsigned long)(floor(log2(counter))));
//    
//    return ((counter >>= 1UL) & 1UL) && ((counter % (1UL << 1) ^ (1UL << 0)) & (*blka_t)(counter)) | (*blkb_t)(counter);
//};
//
//
//
//(*blka_t)((unsigned long)(count));
//
//
//typedef typeof(unsigned long(^)(unsigned long)) predicate_function;
//typedef typeof(unsigned long(^*)(unsigned long)) predicate_function_t;
//predicate_function blk_a;
//__block predicate_function_t blka_t = &blk_a;
//predicate_function blk_b;
//__block predicate_function_t blkb_t = &blk_b;
//
//blk_a = ^ unsigned long (unsigned long predicate) {
//    return predicate && (*blkb_t)(TRUE_BIT); //(unsigned long)(*blkb_t)(((counter <<= 1) ^ (0 - counter)));
//};
//
//blk_b = ^ unsigned long (unsigned long counter) {
//    printf("blk_b counter == %lu\n", counter);
//    return (*blkc_t)(counter); //(unsigned long)(*blka_t)(((counter <<= 1) ^ (0 - counter)));
//};
//static void (^test)(void) = ^{
//    pred a, b;
//    a(b(1));
//    
//    
//    
//};
//// Compose a combining them in pairs (combine 1 and 2; then, combine with 3; then combine with 4...)
//// invoke the composition when there are no more blocks to combine
//
//

@interface ControlView : UIView

@end

NS_ASSUME_NONNULL_END
