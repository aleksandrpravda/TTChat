//
// Copyright © 2019 Alexander Rogachev. All rights reserved.
//

#import "InteractableLabel.h"

@interface InteractableLabel()
@property(copy) void(^onTouchBeganCallback)(void);
@property(copy) void(^onTouchEndedCallback)(void);
@property(copy) void(^onTouchCanceledCallback)(void);
@property(strong) UIColor *normalColor;
@end

@implementation InteractableLabel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.onTouchBeganCallback) {
        self.onTouchBeganCallback();
    }
    self.normalColor = self.textColor;
    self.textColor = [UIColor lightGrayColor];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.onTouchEndedCallback) {
        self.onTouchEndedCallback();
    }
    self.textColor = self.normalColor;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.onTouchCanceledCallback) {
        self.onTouchCanceledCallback();
    }
    self.textColor = self.normalColor;
}

- (void)onTouchBegan:(void(^)(void))callback {
    self.onTouchBeganCallback = callback;
}

- (void)onTouchEnded:(void(^)(void))callback {
    self.onTouchEndedCallback = callback;
}

- (void)onTouchCanceled:(void(^)(void))callback {
    self.onTouchCanceledCallback = callback;
}
@end
