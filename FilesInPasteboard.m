#import "FilesInPasteboard.h"

@implementation FilesInPasteboard

+(id) getContents
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSString *availableType = [pasteboard availableTypeFromArray:
		[NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil]];
	NSLog(availableType);
	if (availableType == nil) {
		//NSLog(@"no abailable");
		return nil;
	}
	
	id result = nil;
	if (availableType == NSFilenamesPboardType) {
		NSData *theData = [pasteboard dataForType:availableType];
		if (theData == nil) {
			//NSLog(@"no data");
			return nil;
		}

		NSString *error = nil;
		NSPropertyListFormat format;
		result = [NSPropertyListSerialization propertyListFromData:theData
												 mutabilityOption:NSPropertyListImmutable
														   format:&format
												 errorDescription:&error];
		 if (error) NSLog(error);
	
	} else {
		NSString *a_path = [pasteboard stringForType:NSStringPboardType];
		if (!a_path || (![a_path hasPrefix:@"/"]))  return nil;
		result = [NSArray arrayWithObject:a_path];
	}
	
	//NSLog([result description]);
	return result;
}

@end
