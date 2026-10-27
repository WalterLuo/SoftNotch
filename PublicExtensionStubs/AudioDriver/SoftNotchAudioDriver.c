// Public build placeholder for the premium virtual microphone driver.

#include <CoreFoundation/CoreFoundation.h>

void *SoftNotchAudioDriverFactory(CFAllocatorRef allocator, CFUUIDRef requestedType)
{
    (void)allocator;
    (void)requestedType;
    return NULL;
}
