#import "FileProcessor.h"
#import "PathExtra.h"
#import "ProgressWindowController.h"

#define useLog 0

@implementation FileProcessor

- (id)init
{
	if (self = [super init]) {
		processPathAsync = FSPathMoveObjectAsync;
		svnCpMvCommand = @"mv";
	}
	return self;
}

@end
