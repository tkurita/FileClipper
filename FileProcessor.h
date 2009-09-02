#import <Cocoa/Cocoa.h>


@interface FileProcessor : NSObject {
	NSString *location;
	NSArray *sourceItems;
}

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path;
- (void) startTask:(id)sender;

@end
