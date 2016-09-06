//
//  ViewController.h
//  WPCodeScaning
//
//  Created by 吴鹏 on 16/9/5.
//  Copyright © 2016年 wupeng. All rights reserved.
//

#import "WPZBarViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

#define frameLine 20

@interface WPZBarViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,ZBarReaderDelegate,AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL isShow;
}

@property (nonatomic , strong) UIView * contentView;
@property (nonatomic , strong) CAShapeLayer * contentShapeLayer;
@property (nonatomic , strong) UIView * frameShapeLayer1;
@property (nonatomic , strong) UIView * backView;
@property (nonatomic , strong) UIImageView * scanImageView;

@property (nonatomic , strong) AVCaptureSession * captureSession;
@property (nonatomic , strong) AVCaptureDevice * inputDevice;
@property (nonatomic , strong) AVCaptureDeviceInput * captureInput;
@property (nonatomic , strong) AVCaptureMetadataOutput * output;
@property (nonatomic , strong) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;
@property (nonatomic , strong) AVCaptureConnection * connection;
@property (nonatomic , strong) AVCaptureOutput * captureOutput;

@end
@implementation WPZBarViewController



- (void)viewDidLoad
{
    
    BOOL Custom= [UIImagePickerController
                  isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];//判断摄像头是否能用
    if (Custom)
    {
        [self openCapture];
    }
    [super viewDidLoad];
    [self.view addSubview:self.contentView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self animation];
}

#pragma mark - property

- (UIView *)contentView
{
    if(!_contentView)
    {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT )];
        [_contentView.layer addSublayer:self.contentShapeLayer];
        [_contentView addSubview:self.frameShapeLayer1];
        [_contentView addSubview:self.backView];
        
    }
    return _contentView;
}

- (CAShapeLayer *)contentShapeLayer
{
    if(!_contentShapeLayer)
    {
        _contentShapeLayer = [CAShapeLayer layer];
        
         UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, WIDTH, HEIGHT) cornerRadius:0];
        UIBezierPath * path1 = [UIBezierPath bezierPathWithRect:CGRectMake(50, (HEIGHT - WIDTH + 100)/2, WIDTH-100, WIDTH-100)];
        path.usesEvenOddFillRule = YES;
        
        [path appendPath:path1];
        
        _contentShapeLayer.path = path.CGPath;
        _contentShapeLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
        _contentShapeLayer.fillRule = kCAFillRuleEvenOdd;
    }
    return _contentShapeLayer;
}

- (UIView *)frameShapeLayer1
{
    if(!_frameShapeLayer1)
    {
        _frameShapeLayer1 = [[UIView alloc] initWithFrame:CGRectMake(50, (HEIGHT - WIDTH + 100)/2, WIDTH-100, WIDTH-100)];
        _frameShapeLayer1.backgroundColor = [UIColor clearColor];
        _frameShapeLayer1.layer.cornerRadius =0 ;
        _frameShapeLayer1.layer.borderWidth = 5;
        _frameShapeLayer1.layer.borderColor = [UIColor redColor].CGColor;
        _frameShapeLayer1.clipsToBounds = YES;
        [_frameShapeLayer1 addSubview:self.scanImageView];
    }
    
    return _frameShapeLayer1;
}

- (UIView *)backView
{
    if(!_backView)
    {
        _backView = [[UIView alloc]initWithFrame:CGRectMake(50,(HEIGHT - WIDTH + 100)/2 +WIDTH -100 , WIDTH - 100, 0)];
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }
    return _backView;
}

- (UIImageView *)scanImageView
{
    if(!_scanImageView)
    {
        _scanImageView = [[UIImageView alloc]init];
        _scanImageView.image = [UIImage imageNamed:@"scan_net"];
        _scanImageView.clipsToBounds = YES;
    }
    return _scanImageView;
}

- (AVCaptureSession *)captureSession
{
    if(!_captureSession)
    {
        _captureSession = [[AVCaptureSession alloc]init];
    }
    return _captureSession;
}

- (AVCaptureDevice *)inputDevice
{
    if(!_inputDevice)
    {
        _inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _inputDevice;
}

- (AVCaptureDeviceInput *)captureInput
{
    if(!_captureInput)
    {
        _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:nil];
    }
    return _captureInput;
}

- (AVCaptureMetadataOutput *)output
{
    if(!_output)
    {
        _output=[[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
    }
    return _output;
}

- (AVCaptureVideoPreviewLayer *)captureVideoPreviewLayer
{
    if(!_captureVideoPreviewLayer)
    {
        _captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        _captureVideoPreviewLayer.frame = self.view.bounds;
    //    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResize;
    }
    return _captureVideoPreviewLayer;
}

#pragma mark - private

- (void)openCapture
{
    
    if(self.captureInput == nil)
    {
        NSLog(@"权限没有打开");
    }else
    {
        [self createView];
    }
    
    [self.captureSession addInput:self.captureInput];
    
        
    [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [self.captureSession addOutput:self.output];
    
    CGRect viewRect = self.view.frame;
    
    CGRect containerRect = CGRectMake(50, (HEIGHT - WIDTH + 100)/2, WIDTH-100, WIDTH-100);
    
    
    self.output.rectOfInterest = [self getViewRect:containerRect scanView:viewRect];
    
    self.output.metadataObjectTypes =@[AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeQRCode];
    
    self.captureOutput = (AVCaptureStillImageOutput*)[self.captureSession.outputs objectAtIndex:0];
    self.connection =[self.captureOutput connectionWithMediaType:AVMediaTypeVideo];
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    [self.captureSession startRunning];

}

-(void)createView
{
    NSArray * titleStr=@[@"相册",@"开灯",@"条形码"];
    
    for (int i=0; i<titleStr.count; i++) {
        UIButton*button=[UIButton buttonWithType:UIButtonTypeCustom];

        [button setTitle:titleStr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.cornerRadius = 65/2;
        button.titleLabel.font = [UIFont systemFontOfSize:15];

        button.frame=CGRectMake((WIDTH - 65 *3)/4*(i + 1) + i * 65, HEIGHT-100, 65, 65);
        button.tag = i;
        [self.contentView addSubview:button];
        if (i==0) {
            [button addTarget:self action:@selector(pressPhotoLibraryButton) forControlEvents:UIControlEventTouchUpInside];
        }
        if (i==1) {
            [button addTarget:self action:@selector(flashLightClick) forControlEvents:UIControlEventTouchUpInside];
        }else
        {
            [button addTarget:self action:@selector(changeClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
}

- (void)pressPhotoLibraryButton
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = YES;
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:^{
        [self.captureSession stopRunning];
    }];
}


-(void)flashLightClick{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if (device.torchMode==AVCaptureTorchModeOff)
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:AVCaptureTorchModeOn];
        
    }else
    {
        [device setTorchMode:AVCaptureTorchModeOff];
    }
    
}

- (void)changeClick:(UIButton *)sender
{
    if(sender.tag != 2)
        return;
    CGRect toRect;
    CGRect fram;
    CGFloat focun;
    if(!isShow)
    {
        [sender setTitle:@"二维码" forState:UIControlStateNormal];
        toRect = CGRectMake(50, (HEIGHT - WIDTH + 100)/2, WIDTH-100, 100);
        fram = CGRectMake(50, (HEIGHT - WIDTH + 100)/2 +100, WIDTH - 100,WIDTH - 100 -100);
        focun = 1.5;

    }else
    {
        [sender setTitle:@"条形码" forState:UIControlStateNormal];
        toRect = CGRectMake(50, (HEIGHT - WIDTH + 100)/2, WIDTH-100,WIDTH - 100);
        fram = CGRectMake(50, (HEIGHT - WIDTH + 100)/2 +WIDTH - 100, WIDTH - 100, 0);
        focun = 1;

    }
    
    CGRect viewRect = self.view.frame;
    
    CGRect containerRect = toRect;
    
    
    self.output.rectOfInterest = [self getViewRect:containerRect scanView:viewRect];
    

    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.frameShapeLayer1.frame = toRect;
                         self.backView.frame = fram;
    
    } completion:^(BOOL finished) {
        [self animation];
    }];
    
    
    isShow = !isShow;
}

#pragma mark decode image
- (void)decodeImage:(UIImage *)image
{
    
    ZBarSymbol *symbol = nil;
    
    ZBarReaderController* read = [ZBarReaderController new];
    
    read.readerDelegate = self;
    
    CGImageRef cgImageRef = image.CGImage;
    
    for(symbol in [read scanImage:cgImageRef])break;
    
    if (symbol!=nil)
    {
        [self dismissViewControllerAnimated:YES completion:^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(wp_scanningResultStr:)])
            {
                [self.delegate wp_scanningResultStr:symbol.data];
            }
        }];
        [self.captureSession stopRunning];
        
    }else{
        [self.captureSession startRunning];

    }

}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
    
    [self decodeImage:image];
}
#pragma mark AVCaptureMetadataOutputObjectsDelegate//IOS7下触发
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    

    if (metadataObjects.count>0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        
//       AVMetadataMachineReadableCodeObject *obj = (AVMetadataMachineReadableCodeObject *)[self.captureVideoPreviewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        [self dismissViewControllerAnimated:YES completion:^{
            if(self.delegate && [self.delegate respondsToSelector:@selector(wp_scanningResultStr:)])
            {
                [self.delegate wp_scanningResultStr:metadataObject.stringValue];
            }
        }];
        
        
    }
    
    [self.captureSession stopRunning];
    
   
    
    
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self dismissViewControllerAnimated:YES completion:^{[self decodeImage:image];}];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [self.captureSession startRunning];
    }];
}

#pragma mark - image to CMSampleBufferRef

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace)
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
    
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
                                                              NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage =
    CGImageCreate(width,
                  height,
                  8,
                  32,
                  bytesPerRow,
                  colorSpace,
                  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  provider,
                  NULL,
                  true,
                  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    return image;
}

- (void)animation
{
   
    [self.scanImageView.layer removeAllAnimations];
        self.scanImageView.frame = CGRectMake(0, -CGRectGetHeight(self.frameShapeLayer1.frame), CGRectGetWidth(self.frameShapeLayer1.frame), CGRectGetHeight(self.frameShapeLayer1.frame));
        CABasicAnimation * opacitylayer1 = [CABasicAnimation animation];
        opacitylayer1.keyPath = @"opacity";
        opacitylayer1.fromValue = @(0);
        opacitylayer1.toValue = @(1);
        CABasicAnimation *scanNetAnimation = [CABasicAnimation animation];
        scanNetAnimation.keyPath = @"transform.translation.y";
        scanNetAnimation.byValue = @(CGRectGetHeight(self.frameShapeLayer1.frame));
        
        CAAnimationGroup * group = [CAAnimationGroup animation];
        group.animations = @[opacitylayer1 , scanNetAnimation ];
        group.duration = 3.5;
        group.beginTime = 0;
       
        
        CABasicAnimation * opacitylayer = [CABasicAnimation animation];
        opacitylayer.keyPath = @"opacity";
        opacitylayer.fromValue = @(1);
        opacitylayer.toValue = @(0);
        opacitylayer.duration = 3.5;
        opacitylayer.beginTime = 2.5;
        
        CAAnimationGroup * group1 = [CAAnimationGroup animation];
        group1.animations = @[group , opacitylayer];
        group1.duration = 3.5;
        group1.repeatCount = MAXFLOAT;
        group1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        
        [self.scanImageView.layer addAnimation:group1 forKey:@"translationAnimation"];

}



-(CGRect)getViewRect:(CGRect)rect scanView:(CGRect)readerViewBounds
{
    
    
    CGFloat x,y,width,height;
    
    x = (CGRectGetHeight(readerViewBounds)-rect.size.height)/2/CGRectGetHeight(readerViewBounds);
    y = 50/CGRectGetWidth(readerViewBounds);
    width = rect.size.height/CGRectGetHeight(readerViewBounds);
    height = rect.size.width/CGRectGetWidth(readerViewBounds);

    
    return CGRectMake(x, y, width, height);
    
}

@end
