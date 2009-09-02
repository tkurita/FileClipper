#import <Cocoa/Cocoa.h>

@interface FileProcessorBase : NSObject {
	NSString *location;
	NSArray *sourceItems;
	id owner;
}
@property (retain) NSString* location;
@property (retain) NSArray* sourceItems;
@property (retain) id owner;

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path owner:(id)ownerObject;
- (void) startTask:(id)sender;
- (void) displayErrorLog:(NSString *)aText;

@end
