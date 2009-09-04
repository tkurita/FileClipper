#import <Cocoa/Cocoa.h>

@interface FileProcessorBase : NSObject {
	IBOutlet id owner;
	NSString *location;
	NSArray *sourceItems;
	NSString* currentSource;
	NSString* newName;
	NSLock* lock;
	NSString* loginShell;
}
@property (retain) NSString* location;
@property (retain) NSArray* sourceItems;
@property (assign) id owner;
@property (assign) NSString* currentSource;
@property (retain) NSString* newName;
@property (retain) NSString* loginShell;

- (id)initWithSourceItems:(NSArray *)array toLocation:(NSString *)path owner:(id)ownerObject;
- (void)startThreadTask:(id)sender;
- (void)displayErrorLog:(NSString *)aText;
- (void)lock;
- (void)unlock;
- (BOOL)resolveNewName:(NSString *)source;
- (BOOL)trySVN:(NSString *)command withSource:(NSString *)source;

@end
