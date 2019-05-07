//
//  JKLoadingView.m
//  Wallet
//
//  Created by BQJR on 2018/8/21.
//

#import "JKLoadingView.h"
#import "FLAnimatedImage.h"

@implementation JKLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)show {
    self.hidden = NO;
}

- (void)dissmiss {
    self.hidden = YES;
}

- (void)setupUI {
    NSData *gifData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"qz_loading" withExtension:@"gif"]];
    FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:gifData];
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.animatedImage = image;
    
    [self insertSubview:imageView atIndex:0];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(94/2.0);
        make.height.mas_equalTo(70/2.0);
    }];
}

@end
