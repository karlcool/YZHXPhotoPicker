//
//  HXGetVideoImgViewController.m
//  HXPhotoPickerExample
//
//  Created by 刘耀宗 on 2021/1/8.
//  Copyright © 2021 洪欣. All rights reserved.
//

#import "HXGetVideoImgViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "HXPhotoModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HXPhotoDefine.h"
#import "HXPhotoManager.h"
#import "HX_PhotoEditViewController.h"
#import "UIViewController+HXExtension.h"

//#import "Witty-Swift.h"
@interface HXGetVideoImgViewController ()
@property (weak, nonatomic) IBOutlet UILabel *currectTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (nonatomic,strong) UIImageView *selectImgView;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) HXPhotoModel *videoModel;
@property (weak, nonatomic) IBOutlet UIView *bottomImgView;
@property (nonatomic, strong) NSMutableArray *imgList;
@property (weak, nonatomic) IBOutlet UIImageView *centerImgView;
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (strong, nonatomic) HXPhotoEdit *photoEdit;
@property (strong, nonatomic) HXPhotoManager *manager;
@end

@implementation HXGetVideoImgViewController

-(NSMutableArray *)imgList
{
    if (_imgList == nil) {
        _imgList = [[NSMutableArray alloc] init];
    }
    return _imgList;
}


- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.type = HXConfigurationTypeWXChat;
        _manager.configuration.singleSelected = YES;
        _manager.configuration.lookGifPhoto = NO;
        _manager.configuration.albumListTableView = ^(UITableView *tableView) {
        };
        _manager.configuration.videoMaximumSelectDuration = 15.f;
        _manager.configuration.selectVideoBeyondTheLimitTimeAutoEdit = YES;
        _manager.configuration.singleJumpEdit = YES;
        _manager.configuration.photoEditConfigur.onlyCliping = YES;

    }
    return _manager;
}

-(UIImageView *)selectImgView
{
    if (_selectImgView == nil) {
        _selectImgView = [[UIImageView alloc] init];
        _selectImgView.image = [UIImage imageNamed:@"video_select"];
        _selectImgView.contentMode = UIViewContentModeScaleAspectFit;
        _selectImgView.userInteractionEnabled = YES;
        _selectImgView.clipsToBounds = NO;
        
    }
    return _selectImgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.url = self.videoUrl;
    HXPhotoModel *videoModel = [HXPhotoModel photoModelWithVideoURL:self.url];
    self.videoModel = videoModel;
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%.2fs",videoModel.videoDuration];
    [self.selectImgView sizeToFit];
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.selectImgView.frame = CGRectMake(16, self.view.bounds.size.height - self.selectImgView.frame.size.height - 16 - hxBottomMargin, self.selectImgView.frame.size.width, self.selectImgView.frame.size.height);
    });
    [self.view addSubview:self.selectImgView];
    [self getVideoImgList];
    
    self.centerImgView.layer.cornerRadius = 6;
    self.centerImgView.layer.masksToBounds = YES;
    self.tipView.layer.cornerRadius = 6;
    self.tipView.layer.masksToBounds = YES;
    self.tipView.layer.maskedCorners = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    
    UIPanGestureRecognizer *ges = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pangesture:)];
    [self.selectImgView addGestureRecognizer:ges];
    
}
//点击关闭
- (IBAction)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
//点击下一步
- (IBAction)onNext:(id)sender {
    if (self.centerImgView.image) {
        if (self.clickNext) {
            self.clickNext(self.centerImgView.image);
        }
    }
    
    
}


//选择图片
- (IBAction)onChooseMedia:(id)sender {
    
    [self hx_presentSelectPhotoControllerWithManager:self.manager didDone:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL isOriginal, UIViewController *viewController, HXPhotoManager *manager) {
        NSLog(@"当前的数据是%@",photoList);
        if (photoList.count != 0) {
            self.centerImgView.image = photoList[0].previewPhoto;
        }
    } cancel:^(UIViewController *viewController, HXPhotoManager *manager) {
    }];
    //编辑图片
    
//    HXPhotoModel *photoModel = [HXPhotoModel photoModelWithImage:self.centerImgView.image];
//    photoModel.photoEdit = self.photoEdit;
//    HXWeakSelf
//    [self hx_presentWxPhotoEditViewControllerWithConfiguration:self.manager.configuration.photoEditConfigur photoModel:photoModel delegate:nil finish:^(HXPhotoEdit * _Nonnull photoEdit, HXPhotoModel * _Nonnull photoModel, HX_PhotoEditViewController * _Nonnull viewController) {
//        if (photoEdit) {
//            // 有编辑过
////            weakSelf.imageView.image = photoEdit.editPreviewImage;
//        }else {
//            // 为空则未进行编辑
////            weakSelf.imageView.image = photoModel.thumbPhoto;
//        }
//        // 记录下当前编辑的记录，再次编辑可在上一次基础上进行编辑
//        weakSelf.photoEdit = photoEdit;
//        NSSLog(@"%@", photoModel);
//    } cancel:^(HX_PhotoEditViewController * _Nonnull viewController) {
//        NSSLog(@"取消：%@", viewController);
//    }];
}

-(void)pangesture:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
            CGPoint point = [panGestureRecognizer translationInView:self.selectImgView];
      
        self.selectImgView.center = CGPointMake(self.selectImgView.center.x + point.x, self.selectImgView.center.y);
        
        [self showImg];
        if (self.selectImgView.center.x <= 16  ) {
            self.selectImgView.center = CGPointMake(16, self.selectImgView.center.y);
            self.currectTimeLabel.text = [NSString stringWithFormat:@"0s"];
        
        }else if(self.selectImgView.center.x > ([UIScreen mainScreen].bounds.size.width - 16) ) {
            self.selectImgView.center = CGPointMake(([UIScreen mainScreen].bounds.size.width - 16), self.selectImgView.center.y);
            self.currectTimeLabel.text = [NSString stringWithFormat:@"%.2lfs",self.videoModel.videoDuration];
        }
        NSLog(@"当前的数据是%@",NSStringFromCGPoint(self.selectImgView.center));
 
        
          [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:self.view];            //关键，不设为零会不断递增，视图会突然不见
        }
}

//显示照片
-(void)showImg {
    [self.bottomImgView.subviews enumerateObjectsUsingBlock:^(UIImageView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat minx = CGRectGetMinX(obj.frame);
        CGFloat maxX = CGRectGetMaxX(obj.frame);
        if ((self.selectImgView.center.x - 16 )>= minx && (self.selectImgView.center.x - 16)  <= maxX) {
            self.centerImgView.image = self.imgList[idx];
            NSLog(@"当前选中的是第%ld 张图片",idx);
            
            self.currectTimeLabel.text = [NSString stringWithFormat:@"%.2lfs",self.videoModel.videoDuration / self.imgList.count * idx];
        }
            
    }];
}

//获取所有的图片数组
-(void)getVideoImgList {
    //每 0.5 秒
    NSTimeInterval index = 0.0;
    NSMutableArray *imgList = [NSMutableArray array];
    while (index < self.videoModel.videoDuration) {
        UIImage *img = [self thumbnailImageForVideo:self.url atTime:index];
        [imgList addObject:img];
        index += 1;
    }
    self.imgList = imgList;
    [imgList enumerateObjectsUsingBlock:^(UIImage *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:obj];
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 32) / imgList.count ;
        imgView.frame = CGRectMake(width * idx, 0, width, 40);
        [self.bottomImgView addSubview:imgView];
        
    }];
    
    NSLog(@"当前的数据是%@",imgList);
    
    [self showImg];
    
}

- (UIImage *)thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
     AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
     NSParameterAssert(asset);
     AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
     assetImageGenerator.appliesPreferredTrackTransform = YES;
     assetImageGenerator.apertureMode =AVAssetImageGeneratorApertureModeEncodedPixels;

     CGImageRef thumbnailImageRef = NULL;
     CFTimeInterval thumbnailImageTime = time;
     NSError *thumbnailImageGenerationError = nil;

        CMTime n_time = CMTimeMake(time * asset.duration.timescale , asset.duration.timescale );
    
     thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:n_time actualTime:NULL error:&thumbnailImageGenerationError];

     if(!thumbnailImageRef)
     NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);

     UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage:thumbnailImageRef] : nil;
     return thumbnailImage;
 }



-(void)setVideoUrl:(NSURL *)videoUrl
{
    _videoUrl = videoUrl;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
