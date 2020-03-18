#import <Cocoa/Cocoa.h>
@class AppController;

@interface FileProcessorBase : NSObject

@property NSLock* lockobj;
@property NSArray* locations;
@property NSString* currentLocation;
@property NSArray* sourceItems;
@property (assign) IBOutlet id owner;
@property (assign) NSString* currentSource;
@property NSString* nuName;
@property NSString* loginShell;
@property NSEnumerator *enumerator;
@property BOOL isCanceled;
@property AppController *appController;

- (id)initWithSourceItems:(NSArray *)array toLocations:(NSArray *)pathes owner:(id)ownerObject;
- (void)startThreadTask:(id)sender;
- (void)displayErrorLog:(NSString *)format, ...;
- (void)lock;
- (void)unlock;

// private
- (BOOL)resolveNewName:(NSString *)source;
- (void)doTask:(id)sender;

@end
