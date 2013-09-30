#import <mach-o/dyld.h>

#ifdef USE_ASSTUDIO
extern void ASKInitialize();
#endif

extern int NSApplicationMain(int argc, const char *argv[]);

int main(int argc, const char *argv[])
{
#ifdef USE_ASSTUDIO
	ASKInitialize();
#endif	
	return NSApplicationMain(argc, argv);
}