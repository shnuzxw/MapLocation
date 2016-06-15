//
//  RootViewController.m
//  MapLocation
//
//  Created by smile.zhang on 16/6/14.
//  Copyright © 2016年 smile.zhang. All rights reserved.
//

#import "RootViewController.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>//引入云检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapView.h>//只引入所需的单个头文件

#import <AMapLocationKit/AMapLocationKit.h>

#import <CoreLocation/CLLocationManager.h>

#import "HPLocationConverter.h"

@interface RootViewController () <BMKLocationServiceDelegate, AMapLocationManagerDelegate, CLLocationManagerDelegate> {
    AMapLocationManager *_localtionManager;
    CLLocationManager *_iosLocManager;
    BMKLocationService *_bdlocService;
}

@property (nonatomic, strong) UILabel *bdLabel;
@property (nonatomic, strong) UILabel *amapLabel;
@property (nonatomic, strong) UILabel *iosLabel;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor cyanColor];
    self.title = @"地图";
    BMKMapView* mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    mapView.showsUserLocation = YES;//显示定位图层
    [self.view addSubview:mapView];

    //初始化BMKLocationService
    _bdlocService = [[BMKLocationService alloc]init];
    _bdlocService.delegate = self;
    //启动LocationService
    [_bdlocService startUserLocationService];


    [AMapLocationServices sharedServices].apiKey = @"c3faac0a3d2cad911a6ae2b377c0573b";
    _localtionManager = [[AMapLocationManager alloc] init];
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [_localtionManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //   定位超时时间，可修改，最小2s
    _localtionManager.locationTimeout = 3;
    //   逆地理请求超时时间，可修改，最小2s
    _localtionManager.reGeocodeTimeout = 3;

    _localtionManager.delegate = self;
    [_localtionManager startUpdatingLocation];

    _iosLocManager = [[CLLocationManager alloc] init];
    _iosLocManager.delegate = self;
    [_iosLocManager startUpdatingLocation];
}

#pragma mark - BMKLocationServiceDelegate
//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    //    NSLog(@"百度定位：heading is %@",userLocation.heading);
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    CLLocationCoordinate2D coord = [HPLocationConverter bd09ToGcj02:userLocation.location.coordinate];
    NSString *string = [NSString stringWithFormat:@"百度-GCJ02// lat:%.6f,lng:%.6f",coord.latitude, coord.longitude];
    NSLog(@"%@",string);
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.bdLabel.text = string;
    });
}

#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location {
    CLLocationCoordinate2D coord = [HPLocationConverter gcj02ToWgs84:location.coordinate];
    coord = location.coordinate;
    NSString *string = [NSString stringWithFormat:@"高德-WGS84// lat:%.6f,lng:%.6f",coord.latitude, coord.longitude];
    NSLog(@"%@",string);
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.amapLabel.text = string;
    });
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations firstObject];
    NSString *string = [NSString stringWithFormat:@"GPS(WGS84)// lat:%.6f,lng:%.6f", location.coordinate.latitude, location.coordinate.longitude];
    NSLog(@"%@",string);
    __weak typeof(self) ws = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        ws.iosLabel.text = string;
    });
}

#pragma mark - Getter
- (UILabel *)bdLabel{
    if (!_bdLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 320, 30)];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        _bdLabel = label;
    }
    return _bdLabel;
}

- (UILabel *)amapLabel {
    if (!_amapLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, 320, 30)];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        _amapLabel = label;
    }
    return _amapLabel;
}

- (UILabel *)iosLabel {
    if (!_iosLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 160, 320, 30)];
        label.backgroundColor = [UIColor whiteColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        _iosLabel = label;
    }
    return _iosLabel;
}

@end
