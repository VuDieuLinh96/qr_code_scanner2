#import "QrCodeScanner2Plugin.h"
#import "QrReaderViewController.h"

@implementation QrCodeScanner2Plugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    QrReaderViewFactory *viewFactory = [[QrReaderViewFactory alloc] initWithRegistrar:registrar];
    [registrar registerViewFactory:viewFactory withId:@"com.lynkmyu.qr_code_scanner2.reader_view"];
    
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.lynkmyu.qr_code_scanner2"
                                     binaryMessenger:[registrar messenger]];
    QrCodeScanner2Plugin* instance = [[QrCodeScanner2Plugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"imgQrCode" isEqualToString:call.method]) {
        [self scanQRCode:call result:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)scanQRCode:(FlutterMethodCall*)call result:(FlutterResult)result{
    NSString *path = call.arguments[@"file"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count > 0) {
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *qrData = feature.messageString;
        result(qrData);
    } else {
        result(NULL);
    }
}

@end

