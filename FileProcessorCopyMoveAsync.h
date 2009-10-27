#import <Cocoa/Cocoa.h>
#import "FileProcessorBase.h"

@interface FileProcessorCopyMoveAsync : FileProcessorBase {
	//void *processPathAsync;
	OSStatus (*processPathAsync)(FSFileOperationRef fileOp, const char *sourcePath, const char *destDirPath,
								 CFStringRef destName, OptionBits flags, FSPathFileOperationStatusProcPtr callback,
								 CFTimeInterval statusChangeInterval, FSFileOperationClientContext *clientContext);
	NSString *svnCpMvCommand;
}

@end
