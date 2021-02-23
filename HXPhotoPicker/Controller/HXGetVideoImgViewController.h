//
//  HXGetVideoImgViewController.h
//  HXPhotoPickerExample
//
//  Created by 刘耀宗 on 2021/1/8.
//  Copyright © 2021 洪欣. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HXVideoEditViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface HXGetVideoImgViewController : UIViewController
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, copy) void (^clickNext)(UIImage *img);
- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
@end

NS_ASSUME_NONNULL_END
