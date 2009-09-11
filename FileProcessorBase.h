#import <Cocoa/Cocoa.h>

@interface FileProcessorBase : NSObject {
	IBOutlet id owner;
	NSArray *locations;
	NSString *currentLocation;
	NSArray *sourceItems;
	NSString* currentSource;
	NSString* newName;
	NSLock* lock;
	NSString* loginShell;
	NSEnumerator *enumerator;
	BOOL isCanceled;
}
@property (retain) NSArray* locations;
@property (retain) NSString* currentLocation;
@property (retain) NSArray* sourceItems;
@property (assign) id owner;
@property (assign) NSString* currentSource;
@property (retain) NSString* newName;
@property (retain) NSString* loginShell;
@property (retain) NSEnumerator *enumerator;
@property (assign) BOOL isCanceled;

- (id)initWithSourceItems:(NSArray *)array toLocations:(NSArray *)pathes owner:(id)ownerObject;
- (void)startThreadTask:(id)sender;
- (void)displayErrorLog:(NSString *)aText;
- (void)lock;
- (void)unlock;

// private
- (BOOL)resolveNewName:(NSString *)source;
- (BOOL)trySVN:(NSString *)command withSource:(NSString *)source;
- (void)doTask:(id)sender;

@end
