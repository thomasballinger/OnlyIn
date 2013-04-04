//
//  GetMapLocation.h
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class GetMapLocation;
@protocol setCurrentLocation <NSObject>

- (void)updateLocationLabel:(GetMapLocation *)sender currentLocation:(NSString *)locationInfo;

@end

@interface GetMapLocation : NSObject <CLLocationManagerDelegate>

-(void)startLocationManagerUpdates;
-(void)stopLocationManagerUpdates;

@property (weak, nonatomic) id <setCurrentLocation> delegate;

@end
