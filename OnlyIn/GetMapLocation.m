//
//  GetMapLocation.m
//  OnlyIn
//
//  Created by Jennifer Clark on 3/25/13.
//  Copyright (c) 2013 Jennifer Clark. All rights reserved.
//

#import "GetMapLocation.h"

@interface GetMapLocation()

{
    CLLocationManager *locationManager;
    CLGeocoder *geoCoder;
}

@end

@implementation GetMapLocation

-(void)startLocationManagerUpdates
{
    locationManager = [[CLLocationManager alloc] init];
    geoCoder = [[CLGeocoder alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; //this updates the location whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [locationManager startUpdatingLocation];
}

-(void)stopLocationManagerUpdates
{
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [geoCoder reverseGeocodeLocation: locationManager.location completionHandler:
     
     ^(NSArray *placemarks, NSError *error) {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             //handle errors & connectivity issues
             return;
         }
         
         if(placemarks && placemarks.count > 0)
         {
             CLPlacemark *currentLocation = [placemarks lastObject];
             //NSString *completeAddress = [[currentLocation.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSArray *resultComponents = [[[currentLocation.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "] componentsSeparatedByString:@", "];
            
             NSString *townGeneral = [NSString stringWithFormat:@"%@", [currentLocation locality]]; //always yields town name, not borough specific
             NSString *townSpecific = [resultComponents objectAtIndex:1]; //is borough specific but sometimes yields a building number
             NSString *state = [NSString stringWithFormat:@"%@", [currentLocation administrativeArea]];
             NSString *townAndState = [NSString stringWithFormat:@"%@, %@",townSpecific, state]; //use the more specific town at first
             
             int i;
             for (i = 0; i < townSpecific.length; i++) { //check to make sure the specific town does not contain a numeric address
                 NSString *characterString = [NSString stringWithFormat:@"%c",[townSpecific characterAtIndex:i]];
                 int intValue = [characterString intValue];
                 if (intValue) { //if it contains a number, use the more general town name
                     townAndState = [NSString stringWithFormat:@"%@, %@",townGeneral, state];
                     break;
                 }
             }
            
             [self.delegate updateLocationLabel:self currentLocation:townAndState];
             [self stopLocationManagerUpdates]; //once we get our data, stop the updates
         }
                  
     }];
}



@end
