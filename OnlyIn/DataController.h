
#import <Foundation/Foundation.h>

//singleton class
@interface DataController : NSObject {
    
	NSString *baseURL;
    UIManagedDocument *database;
}

@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) UIManagedDocument *database;

// SINGLETON BUSINESS
+ (DataController *) dc;
+ (id) allocWithZone : (NSZone *)zone;
- (id) copyWithZone : (NSZone *)zone;

@end
