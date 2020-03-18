#import "FilesInPasteboard.h"

@implementation FilesInPasteboard

+(NSArray *) getContents
{
	NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
	NSString *availableType = [pasteboard availableTypeFromArray:
		@[NSFilenamesPboardType, (NSString *)kUTTypeFileURL, NSStringPboardType]];
	//NSLog(availableType);
	if (availableType == nil) {
		//NSLog(@"no abailable");
		return nil;
	}
	
	NSArray *result = nil;
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
		 if (error) NSLog(@"Error : %@", error);
    } else if (availableType == (NSString *)kUTTypeFileURL) {
        NSArray *classArray = [NSArray arrayWithObject:[NSURL class]]; // types of objects you are looking for
        NSArray *arrayOfURLs = [pasteboard readObjectsForClasses:classArray options:nil]; // read objects of those classes

        NSMutableArray *pathlist = [NSMutableArray arrayWithCapacity:[arrayOfURLs count]];
        [arrayOfURLs enumerateObjectsUsingBlock:^(NSURL *url, NSUInteger idx, BOOL *stop) {
            [pathlist addObject:[url path]];
        }];
        result = pathlist;
        
	} else {
		NSString *a_path = [pasteboard stringForType:NSStringPboardType];
		if (!a_path || (![a_path hasPrefix:@"/"]))  return nil;
		if ([[NSFileManager defaultManager] fileExistsAtPath:a_path]) {
			result = @[a_path];
		} else {
			result = nil;
		}
	}
	
	//NSLog([result description]);
	return result;
}

@end
