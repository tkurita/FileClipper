#import <mach-o/dyld.h>

extern int NSApplicationMain(int argc, const char *argv[]);

int main(int argc, const char *argv[])
{
	return NSApplicationMain(argc, argv);
}