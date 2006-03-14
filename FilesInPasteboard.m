#import "FilesInPasteboard.h"

@implementation FilesInPasteboard

+(id) getContents
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSString *availableType = [pasteboard availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]];
	
	if (availableType == nil) {
		//NSLog(@"no abailable");
		return nil;
	}
	
	NSData *theData = [pasteboard dataForType:NSFilenamesPboardType];
	if (theData == nil) {
		//NSLog(@"no data");
		return nil;
	}
	
	NSString *error = nil;
	NSPropertyListFormat format;
	id plist = [NSPropertyListSerialization propertyListFromData:theData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&error];
	//NSLog([plist description]);
	return plist;
}

@end
