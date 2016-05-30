//
//  HU_ScanView.m
//  二维码扫描
//
//  Created by huhang on 15/11/27.
//  Copyright (c) 2015年 huhang. All rights reserved.
//

#import "HU_ScanView.h"
#import "UIView+BSExtension.h"
#import <AVFoundation/AVFoundation.h>

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface HU_ScanView()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) UIImageView *lineScanView;
@property (nonatomic,strong) UIImageView *scanImageView;
@property (strong, nonatomic) CIDetector *detector;

@end

@implementation HU_ScanView

+ (instancetype)showScanView{
    HU_ScanView *scanView = [[HU_ScanView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    return scanView;
}

- (instancetype)initWithFrame:(CGRect)frame{
 
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{

    //创建扫描框
    UIImageView *scanImageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth - 200) / 2, (ScreenHeight  - 200) / 2, 200, 200)];
    scanImageView.backgroundColor = [UIColor clearColor];
    scanImageView.image = [UIImage imageNamed:@"scanscanBg"];
    [self addSubview:scanImageView];
    self.scanImageView = scanImageView;
    
    //方法调用
    [self methodCall];
}

- (void)methodCall{
  
    //设置扫描前基本操作
    [self setScanDeviceStartOpertion];
    //添加模糊效果
    [self getTheScanViewOutsideAddBlearView];
    //使线条上下滑动
    [self getTheLineScanViewSlide];
}

#pragma mark - 设置扫描前基本操作
- (void)setScanDeviceStartOpertion{

    //1.初始化捕捉会话对象(AVCaptureSession 管理输入(AVCaptureInput)和输出(AVCaptureOutput)流，包含开启和停止会话方法。)
    _captureSession = [[AVCaptureSession alloc]init];
    //1.1 设置采集率
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //2.初始化捕捉设备(AVCaptureDevice 代表了物理捕获设备如:摄像机。用于配置等底层硬件设置相机的自动对焦模式。)
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //3.用捕捉设备实例创建输入流(AVCaptureDeviceInput 是AVCaptureInput的子类,可以作为输入捕获会话，用AVCaptureDevice实例初始化。)
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (!input) {
        UIAlertView *altertView = [[UIAlertView alloc]initWithTitle:@"系统提示" message:@"该设备无摄像头" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [altertView show];
        return;
    }
    //3.1将输入流添加到捕捉会话中
    [_captureSession addInput:input];
   
    //4.创建媒体数据输出流(AVCaptureMetadataOutput 是AVCaptureOutput的子类，处理输出捕获会话。捕获的对象传递给一个委托实现AVCaptureMetadataOutputObjectsDelegate协议。协议方法在指定的派发队列（dispatch queue）上执行。)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //4.1将媒体数据输出流添加到主队列中
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //4.2设置扫描范围(作用:指定rectOfInterest可能改善检测性能对于某些类型的元数据)
    CGFloat rectX = (ScreenHeight - CGRectGetHeight(_scanImageView.frame)) / 2 / ScreenHeight;
    CGFloat rectY = (ScreenWidth - CGRectGetWidth(_scanImageView.frame)) / 2 / ScreenWidth ;
    CGFloat rectW = CGRectGetHeight(_scanImageView.frame) / ScreenHeight;
    CGFloat rectH = CGRectGetWidth(_scanImageView.frame) / ScreenWidth;
    output.rectOfInterest = CGRectMake(rectX,rectY,rectW,rectH);
    if (output) {
        //4.3将媒体输出流添加到捕捉会话中
        [_captureSession addOutput:output];
        //4.4设置扫码支持的编码格式
        NSMutableArray *array = [[NSMutableArray alloc]initWithObjects:AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code, nil];
        output.metadataObjectTypes = array;
    }
    
    //5.初始化预览图层(AVCaptureVideoPreviewLayer是CALayer的一个子类，显示捕获到的相机输出流。)
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
    //5.1设置预览图层填充方式
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //5.2设置图层的frame
    previewLayer.frame = self.bounds;
    //5.3将图层添加到预览的view图层上
    [self.layer insertSublayer:previewLayer above:0];

    //6.把扫描框放到视图最上层
    [self bringSubviewToFront:_scanImageView];
    
    //让其开始扫描
    [_captureSession startRunning];
}

#pragma mark - 添加模糊效果
- (void)getTheScanViewOutsideAddBlearView{

    //使上半部分变模糊
    [self creatBlearView:CGRectMake(0, 0, ScreenWidth, CGRectGetMinY(_scanImageView.frame))];
    //使左半部分变模糊
    [self creatBlearView:CGRectMake(0, CGRectGetMinY(_scanImageView.frame), CGRectGetMinX(_scanImageView.frame), CGRectGetHeight(_scanImageView.frame))];
    //使右半部分变模糊
    [self creatBlearView:CGRectMake(CGRectGetMaxX(_scanImageView.frame), CGRectGetMinY(_scanImageView.frame), ScreenWidth - CGRectGetMaxX(_scanImageView.frame), CGRectGetHeight(_scanImageView.frame))];
    //使下半部分变模糊
    [self creatBlearView:CGRectMake(0, CGRectGetMaxY(_scanImageView.frame), ScreenWidth, ScreenHeight - CGRectGetMaxY(_scanImageView.frame))];
}

#pragma mark 创建模糊视图
- (void)creatBlearView:(CGRect)rect{
 
    UIView *blearView = [[UIView alloc]initWithFrame:rect];
    blearView.backgroundColor = [UIColor blackColor];
    blearView.alpha = 0.6;
    [self addSubview:blearView];
    
    //设置提示词
    if (rect.origin.x == 0 && rect.origin.y == 0 && rect.size.width == CGRectGetWidth(self.frame) && rect.size.height == CGRectGetMinY(_scanImageView.frame)) {
        UILabel *reminderLb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(_scanImageView.frame) + 10, CGRectGetMinY(_scanImageView.frame) - 100, CGRectGetWidth(_scanImageView.frame) - 20, 100)];
        reminderLb.text = [NSString stringWithFormat:@"将取景框对准二维码,\n即可自动扫描。"];
        reminderLb.numberOfLines = 0;
        reminderLb.textAlignment = NSTextAlignmentCenter;
        reminderLb.textColor = [UIColor whiteColor];
        reminderLb.font = [UIFont systemFontOfSize:15];
        [blearView addSubview:reminderLb];
    }
   
    if (rect.origin.x == 0 && rect.origin.y == CGRectGetMaxY(_scanImageView.frame) && rect.size.width == ScreenWidth && rect.size.height == ScreenHeight - CGRectGetMaxY(_scanImageView.frame)) {
        
        NSArray *array = @[@"相册",@"闪光灯",@"二微码"];
        for (int i = 0; i < 3; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake((ScreenWidth - 80 * 3 ) / 4 + i * (80 + (ScreenWidth - 80 * 3 ) / 4),(ScreenHeight - CGRectGetMaxY(_scanImageView.frame)) / 2 - 40, 80 , 80);
            button.backgroundColor = [UIColor clearColor];
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 10 + i;
            button.layer.borderWidth = 1;
            button.layer.borderColor = [UIColor whiteColor].CGColor;
            button.layer.cornerRadius = 40;
            button.layer.masksToBounds = YES;
            [blearView addSubview:button];
        }
    }
}

- (void)buttonAction:(UIButton *)sender{
   
    switch (sender.tag) {
        case 10:{
            [self photoLibraryButton];
        }
            break;
        case 11:{
        
        }
            break;
        case 12:{
        
        }
            break;
        default:
            break;
    }
}

#pragma mark - 线条上下滑动
- (void)getTheLineScanViewSlide{

   //开始是线条frame
    CGRect startRect = CGRectMake(CGRectGetMinX(_scanImageView.frame), CGRectGetMinY(_scanImageView.frame), _scanImageView.width, 5);
    if (!_lineScanView) {
        UIImageView *lineScanView = [[UIImageView alloc]initWithFrame:startRect];
        lineScanView.image = [UIImage imageNamed:@"scanLine"];
        [self addSubview:lineScanView];
        self.lineScanView = lineScanView;
    }else{
        _lineScanView.frame = startRect;
    }

    //结束时线条的frame
    CGRect endRect = CGRectMake(_scanImageView.x, CGRectGetMaxY(_scanImageView.frame) - 5, _scanImageView.width, 5);
    [UIView animateWithDuration:2 animations:^{
        _lineScanView.frame = endRect;
    } completion:^(BOOL finished) {
        //使其循环滑动
        [self getTheLineScanViewSlide];
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
 
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
        self.returnScanResult (self,metadataObj.stringValue);
    }
}

#pragma mark - 开始扫描
- (void)startScan{
    [_captureSession startRunning];
}

#pragma mark - 结束扫描
- (void)stopScan{
    //停止会话
    [_captureSession stopRunning];
    _captureSession = nil;
}


#pragma mark - 进入相册
- (void)photoLibraryButton {
    self.detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - 选择二维码照片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *superImage = [CIImage imageWithCGImage:image.CGImage];
    CIFilter *lighten = [CIFilter filterWithName:@"CIColorControls"];
    [lighten setValue:superImage forKey:kCIInputImageKey];
    float i = 0;
    while (i <= 4) {
        //修改照片对比度参数 0---4
        [lighten setValue:@(i) forKey:@"inputContrast"];
        CIImage *result = [lighten valueForKey:kCIOutputImageKey];
        CGImageRef cgImage = [context createCGImage:result fromRect:[superImage extent]];
        //修改后的照片
        NSArray *features = [self.detector featuresInImage:[CIImage imageWithCGImage:cgImage]];
        CGImageRelease(cgImage);
        if (features.count >= 1) {
            CIQRCodeFeature *feature = [features firstObject];
            NSString *scannedResult = feature.messageString;
            self.returnScanResult (self,scannedResult);
            return;
        }
        //变化区间可以自行设置
        i = i+0.5;
    }
}

@end
