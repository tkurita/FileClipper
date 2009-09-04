#import <Cocoa/Cocoa.h>

@interface FileProcessorBase : NSObject {
	IBOutlet id owner;
	NSString *location;
	NSArray *sourceItems;
	NSString* currentSource;
	NSString* newName;
	NSLock* lock;
}
@property (retain) NSString* location;
@property (retain) NSArray* sourceItems;
@property (assign) id owner;
@property (assign) NSString* currentSource;
@property (retain) NSString* newName;

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path owner:(id)ownerObject;
- (void)startTask:(id)sender;
- (void)displayErrorLog:(NSString *)aText;
- (void)lock;
- (void)unlock;
- (BOOL)resolveNewName:(NSString *)source;

@end
