//
//  HRAlertView.m
//  HRAlertView
//
//  Created by T-bag on 2018/7/18.
//  Copyright © 2018年 T-bag. All rights reserved.
//

#import "HRAlertView.h"

#define UIColorFromHexWithAlpha(hexValue,a)    [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]
#define UIColorFromHex(hexValue)               UIColorFromHexWithAlpha(hexValue,1.0)

static NSMutableArray *visibleHRAlertViews = nil;

NSString *removeBlankSpace(NSString *string) {
    return [[string stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"　" withString:@""];
}

BOOL isEmptyString(NSString *string) {
    if ([string isEqual:[NSNull null]]) {
        return YES;
    }
    
    if (string == nil) {
        return YES;
    }
    
    if (removeBlankSpace(string).length == 0) {
        return YES;
    }
    
    return NO;
}


@interface HRAlertView()

@property (nonatomic, strong) UIView *wrapView;
@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIView *buttonView;
@property (nonatomic, strong) NSMutableArray <HRAlertAction *> *alertActions;
@property (nonatomic, copy) NSArray *otherButtonTitles;
@property (nonatomic, copy) NSString *cancelButtonTitle;

@end
@implementation HRAlertView

- (void)dealloc {
    NSLog(@"HRAlertView dealloc");
}

- (instancetype _Nullable)initWithTitle:(nullable NSString *)title
                                message:(nullable NSString *)message
                               delegate:(nullable id /**<HRAlertViewDelegate>*/)delegate
                      cancelButtonTitle:(nullable NSString *)cancelButtonTitle
                      otherButtonTitles:(nullable NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION NS_EXTENSION_UNAVAILABLE_IOS("Use UIAlertController instead.") {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.delegate = delegate;
        self.cancelButtonTitle = cancelButtonTitle;
        
        va_list args;
        va_start(args, otherButtonTitles);
        NSMutableArray *allArray = [NSMutableArray array];
        for (NSString *str = otherButtonTitles; str != nil; str = va_arg(args,NSString*)) {
            [allArray addObject:str];
        }
        va_end(args);
        
        self.otherButtonTitles = allArray.copy;
        
        if (!visibleHRAlertViews) {
            visibleHRAlertViews = [NSMutableArray array];
        }
        
        [self setupMessageUI];
        [self setupButtonUI];
    }
    return self;
}

- (void)setupMessageUI {
    UIView *wrapView = [[UIView alloc] init];
    wrapView.backgroundColor = [UIColor blackColor];
    wrapView.alpha = 0.4;
    self.wrapView = wrapView;
    [self addSubview:wrapView];
    [wrapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *alertView = [[UIView alloc] init];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.layer.cornerRadius = 8.f;
    alertView.clipsToBounds = YES;
    self.alertView = alertView;
    [self addSubview:alertView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = UIColorFromHex(0x282828);
    titleLabel.numberOfLines = 0;
    titleLabel.text = self.title;
    self.titleLabel = titleLabel;
    [alertView addSubview:titleLabel];
    
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.font = [UIFont systemFontOfSize:13];
    messageLabel.textColor = UIColorFromHex(0x8C8C8C);
    messageLabel.text = self.message;
    messageLabel.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.message];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3.f];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.message length])];
    messageLabel.attributedText = attributedString;
    self.messageLabel = messageLabel;
    [alertView addSubview:messageLabel];
    
    CGFloat messageTopOffset = isEmptyString(self.title) ? 0 : 10.f;
    CGFloat messageHeight = [self.message boundingRectWithSize:CGSizeMake(224, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]}
                                                       context:nil].size.height;
    CGFloat messageLineHeight = self.messageLabel.font.lineHeight;
    NSInteger lineCount = messageHeight / messageLineHeight;
    if (lineCount == 1) {
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    //layout
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alertView).offset(24);
        make.centerX.equalTo(self.alertView);
        make.leading.equalTo(self.alertView).offset(28);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(messageTopOffset);
        make.leading.equalTo(self.alertView).offset(28);
        make.trailing.equalTo(self.alertView).offset(-28);
    }];
    [self.messageLabel setContentCompressionResistancePriority:999
                                                       forAxis:UILayoutConstraintAxisVertical];
}

- (void)setupButtonUI {
    
    CGFloat buttonHeight;
    
    if (isEmptyString(self.cancelButtonTitle)) {
        buttonHeight = self.otherButtonTitles.count < 3 ? 44.f : 44.f * self.otherButtonTitles.count;
    } else {
        buttonHeight = self.otherButtonTitles.count < 2 ? 44.f : 44.f * (self.otherButtonTitles.count + 1);
    }
    
    UIView *buttonView = [[UIView alloc] init];
    self.buttonView = buttonView;
    buttonView.backgroundColor = [UIColor whiteColor];
    [self.alertView addSubview:buttonView];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = UIColorFromHex(0xE6E6E6);
    [buttonView addSubview:topLine];
    
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.alertView);
        make.top.equalTo(self.messageLabel.mas_bottom).offset(24);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(buttonView);
        make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
    }];
    
    if (self.otherButtonTitles.count == 0) {
        UIButton *cancelButton = [self createButtonWithTitle:self.cancelButtonTitle];
        cancelButton.tag = 0x8888;
        [buttonView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(buttonView);
            make.top.equalTo(topLine.mas_bottom);
        }];
    } else if (self.otherButtonTitles.count == 1) {
        UIView *verLine = [[UIView alloc] init];
        verLine.backgroundColor = UIColorFromHex(0xE6E6E6);
        
        UIView *otherButton = [self createButtonWithTitle:[self.otherButtonTitles objectAtIndex:0]];
        [buttonView addSubview:otherButton];
        
        if (isEmptyString(self.cancelButtonTitle)) {
            otherButton.tag = 0x8888;
            [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
            }];
        } else {
            [buttonView addSubview:verLine];
            [verLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
                make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
            }];
            
            UIButton *cancelButton = [self createButtonWithTitle:self.cancelButtonTitle];
            cancelButton.tag = 0x8888;
            [buttonView addSubview:cancelButton];
            [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
                make.trailing.equalTo(verLine.mas_leading);
            }];
            
            [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
                make.leading.equalTo(verLine.mas_trailing);
            }];
            otherButton.tag = 0x8888 + 1;
        }
        
    } else {
        if (isEmptyString(self.cancelButtonTitle) && self.otherButtonTitles.count == 2) {
            UIView *verLine = [[UIView alloc] init];
            verLine.backgroundColor = UIColorFromHex(0xE6E6E6);
            [buttonView addSubview:verLine];
            [verLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
                make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
            }];
            
            UIButton *cancelButton = [self createButtonWithTitle:[self.otherButtonTitles objectAtIndex:0]];
            cancelButton.tag = 0x8888;
            [buttonView addSubview:cancelButton];
            [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
                make.trailing.equalTo(verLine.mas_leading);
            }];
            
            UIView *otherButton = [self createButtonWithTitle:[self.otherButtonTitles objectAtIndex:1]];
            [buttonView addSubview:otherButton];
            [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.bottom.equalTo(buttonView);
                make.top.equalTo(topLine.mas_bottom);
                make.leading.equalTo(verLine.mas_trailing);
            }];
            otherButton.tag = 0x8888 + 1;
        } else {
            [topLine removeFromSuperview];
            UIView *aboveButton = nil;
            for (int i = 0; i < self.otherButtonTitles.count; i++) {
                UIView *sepLine = [[UIView alloc] init];
                sepLine.backgroundColor = UIColorFromHex(0xE6E6E6);
                [buttonView addSubview:sepLine];
                if (i == 0) {
                    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.top.leading.trailing.equalTo(buttonView);
                        make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
                    }];
                } else {
                    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.equalTo(buttonView);
                        make.top.equalTo(aboveButton.mas_bottom);
                        make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
                    }];
                }
                
                UIView *otherButton = [self createButtonWithTitle:[self.otherButtonTitles objectAtIndex:i]];
                if (!isEmptyString(self.cancelButtonTitle)) {
                    otherButton.tag = 0x8889 + i;
                } else {
                    otherButton.tag = 0x8888 + i;
                }
                [buttonView addSubview:otherButton];
                [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(buttonView);
                    make.top.equalTo(sepLine.mas_bottom);
                    make.height.mas_equalTo(44 - 1 / [UIScreen mainScreen].scale);
                }];
                aboveButton = otherButton;
            }
            if (!isEmptyString(self.cancelButtonTitle)) {
                UIView *sepLine = [[UIView alloc] init];
                sepLine.backgroundColor = UIColorFromHex(0xE6E6E6);
                [buttonView addSubview:sepLine];
                [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(buttonView);
                    make.top.equalTo(aboveButton.mas_bottom);
                    make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
                }];
                
                UIButton *cancelButton = [self createButtonWithTitle:self.cancelButtonTitle];
                cancelButton.tag = 0x8888;
                [buttonView addSubview:cancelButton];
                [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(buttonView);
                    make.top.equalTo(sepLine.mas_bottom);
                    make.height.mas_equalTo(44 - 1 / [UIScreen mainScreen].scale);
                }];
            }
        }
    }
}

- (void)setupActionUI {
    
    CGFloat buttonHeight = self.alertActions.count <= 2 ? 44.f : 44.f * self.alertActions.count;
    
    UIView *buttonView = [[UIView alloc] init];
    self.buttonView = buttonView;
    buttonView.backgroundColor = [UIColor whiteColor];
    [self.alertView addSubview:buttonView];
    
    [buttonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.alertView);
        make.top.equalTo(self.messageLabel.mas_bottom).offset(24);
        make.height.mas_equalTo(buttonHeight);
    }];
    
    UIView *topLine = [[UIView alloc] init];
    topLine.backgroundColor = UIColorFromHex(0xE6E6E6);
    [self.buttonView addSubview:topLine];
    
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.buttonView);
        make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
    }];
    
    if (self.alertActions.count == 1) {
        HRAlertAction *ac = (HRAlertAction *)[self.alertActions objectAtIndex:0];
        UIButton *button = [self createButtonWithTitle:ac.title];
        button.tag = 0x8888;
        [self.buttonView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.equalTo(self.buttonView);
            make.top.equalTo(topLine.mas_bottom);
        }];
    } else if (self.alertActions.count == 2) {
        UIView *verLine = [[UIView alloc] init];
        verLine.backgroundColor = UIColorFromHex(0xE6E6E6);
        [self.buttonView addSubview:verLine];
        
        [verLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.bottom.equalTo(self.buttonView);
            make.top.equalTo(topLine.mas_bottom);
            make.width.mas_equalTo(1 / [UIScreen mainScreen].scale);
        }];
        
        HRAlertAction *ac_1 = (HRAlertAction *)[self.alertActions objectAtIndex:0];
        UIButton *cancelButton = [self createButtonWithTitle:ac_1.title];
        cancelButton.tag = 0x8888;
        [self.buttonView addSubview:cancelButton];
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.equalTo(self.buttonView);
            make.top.equalTo(topLine.mas_bottom);
            make.trailing.equalTo(verLine.mas_leading);
        }];
        
        HRAlertAction *ac_2 = (HRAlertAction *)[self.alertActions objectAtIndex:1];
        UIView *otherButton = [self createButtonWithTitle:ac_2.title];
        otherButton.tag = 0x8888 + 1;
        [self.buttonView addSubview:otherButton];
        [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.bottom.equalTo(self.buttonView);
            make.top.equalTo(topLine.mas_bottom);
            make.leading.equalTo(verLine.mas_trailing);
        }];
    } else {
        [topLine removeFromSuperview];
        UIView *aboveButton = nil;
        for (int i = 0; i < self.alertActions.count; i++) {
            UIView *sepLine = [[UIView alloc] init];
            sepLine.backgroundColor = UIColorFromHex(0xE6E6E6);
            [self.buttonView addSubview:sepLine];
            if (i == 0) {
                [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.leading.trailing.equalTo(self.buttonView);
                    make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
                }];
            } else {
                [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.trailing.equalTo(self.buttonView);
                    make.top.equalTo(aboveButton.mas_bottom);
                    make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
                }];
            }
            HRAlertAction *ac = (HRAlertAction *)[self.alertActions objectAtIndex:i];
            UIView *otherButton = [self createButtonWithTitle:ac.title];
            otherButton.tag = 0x8888 + i;
            [self.buttonView addSubview:otherButton];
            [otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.equalTo(self.buttonView);
                make.top.equalTo(sepLine.mas_bottom);
                make.height.mas_equalTo(44 - 1 / [UIScreen mainScreen].scale);
            }];
            aboveButton = otherButton;
        }
    }
}

- (instancetype _Nullable)initWithTitle:(nullable NSString *)title
                                message:(nullable NSString *)message {
    self = [super init];
    if (self) {
        self.title = title;
        self.message = message;
        self.alertActions = [NSMutableArray array];
        [self setupMessageUI];
        
        if (!visibleHRAlertViews) {
            visibleHRAlertViews = [NSMutableArray array];
        }
    }
    return self;
}

- (void)addAction:(HRAlertAction *_Nullable)action {
    if (action) {
        [self.alertActions addObject:action];
    }
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromHex(0xFF9800) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromHex(0xFF9800) forState:UIControlStateHighlighted];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)show {
    if (![visibleHRAlertViews containsObject:self]) {
        [visibleHRAlertViews addObject:self];
    }
    if ([visibleHRAlertViews objectAtIndex:0] != self) {
        return;
    }
    if (self.alertActions.count > 0) {
        [self setupActionUI];
    }
    [self.alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.wrapView);
        make.width.mas_equalTo(280);
        make.bottom.equalTo(self.buttonView);
    }];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    [self layoutIfNeeded];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superview);
    }];
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values = @[@(0.5), @(0.8),  @(1)];
    animation.keyTimes = @[@(0), @(0.15), @(0.3)];
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear], [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    animation.duration = 0.3;
    [self.alertView.layer addAnimation:animation forKey:@"bouce"];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(0.4, 0.4);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [visibleHRAlertViews removeObject:self];
        [self showNextAlert];
    }];
}

- (void)showNextAlert {
    if (visibleHRAlertViews.count > 0) {
        HRAlertView *alert = (HRAlertView *)[visibleHRAlertViews objectAtIndex:0];
        [alert show];
    }
}

- (void)clickButton:(UIButton *)button {
    if (self.alertActions.count > 0) {
        HRAlertAction *ac = (HRAlertAction *)[self.alertActions objectAtIndex:button.tag - 0x8888];
        if (ac.handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ac.handler();
            });
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(hrAlertView: clickedButtonAtIndex:)]) {
            [self.delegate hrAlertView:self clickedButtonAtIndex:button.tag - 0x8888];
        }
    }
    [self dismiss];
}

@end

@interface HRAlertAction()

@property (nonatomic, copy) NSString *title;

@end

@implementation HRAlertAction

+ (instancetype _Nullable )actionWithTitle:(nullable NSString *)title
                                     style:(HRAlertActionStyle)style
                                   handler:(HRAlertActionHandler) handler {
    return [[[self class] alloc] initActionWithTitle:title
                                               style:(HRAlertActionStyle)style
                                             handler:handler];
}

- (instancetype)initActionWithTitle:(nullable NSString *)title
                              style:(HRAlertActionStyle)style
                            handler:(HRAlertActionHandler)handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.handler = handler;
        self.actionStyle = style;
    }
    return self;
}

@end
