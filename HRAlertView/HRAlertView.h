//
//  HRAlertView.h
//  HRAlertView
//
//  Created by T-bag on 2018/7/18.
//  Copyright © 2018年 T-bag. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

#pragma mark - HHRAlertAction

typedef NS_ENUM(NSInteger, HRAlertActionStyle) {
    HHRAlertActionStyleDefault = 0,
    HHRAlertActionStyleCancel,
};

@interface HRAlertAction : NSObject

typedef void (^HRAlertActionHandler)(void);

+ (instancetype _Nullable )actionWithTitle:(nullable NSString *)title
                                     style:(HRAlertActionStyle)style
                                   handler:(nullable HRAlertActionHandler)handler;

@property (nullable, nonatomic, readonly) NSString *title;
@property (nullable, nonatomic, copy) HRAlertActionHandler handler;
@property (nonatomic, assign) HRAlertActionStyle actionStyle;
@end

@class HRAlertView;

@protocol HRAlertViewDelegate<NSObject>

@optional

- (void)hrAlertView:(HRAlertView *_Nonnull)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface HRAlertView : UIView

@property (nonatomic, weak, nullable) id <HRAlertViewDelegate> delegate;
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *message;

- (instancetype _Nullable)initWithTitle:(nullable NSString *)title
                                message:(nullable NSString *)message
                               delegate:(nullable id /**<HRAlertViewDelegate>*/)delegate
                      cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                      otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.");

- (instancetype _Nullable)initWithTitle:(nullable NSString *)title
                                message:(nullable NSString *)message;

- (void)addAction:(HRAlertAction *_Nullable)action;

- (void)show;

- (void)dismiss;

@end
