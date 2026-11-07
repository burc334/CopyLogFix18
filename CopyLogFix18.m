#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <os/log.h>
#import <mach-o/dyld.h>
#import <dispatch/dispatch.h>

static os_log_t SSLog;
static dispatch_queue_t SSInstallQueue;
static BOOL SSInstalled;

static NSData *SSContinuityIdentifier(void) {
    static NSData *identifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /*
         * CopyLog compares this value with -isEqualToData:, so the shim must
         * return NSData. The bytes are deliberately not a valid endpoint
         * identifier, which makes CopyLog fall through to the system path.
         */
        static const char bytes[] = "CopyLogFix18-No!";
        identifier = [[NSData alloc] initWithBytes:bytes length:sizeof(bytes) - 1];
    });
    return identifier;
}

static NSData *SSPersistentIdentifier(id self, SEL _cmd) {
    (void)self;
    (void)_cmd;
    return SSContinuityIdentifier();
}

static void SSInstallContinuityEndpointMethod(void) {
    if (SSInstalled) {
        return;
    }

    Class endpointClass = (Class)objc_getClass("DRPasteAnnouncementContinuityEndpoint");
    if (!endpointClass) {
        return;
    }

    SEL selector = sel_registerName("persistentIdentifier");
    if (!class_respondsToSelector(endpointClass, selector)) {
        BOOL added = class_addMethod(endpointClass, selector,
                                     (IMP)SSPersistentIdentifier,
                                     "@16@0:8");
        if (SSLog) {
            if (added) {
                os_log_info(SSLog, "Added -persistentIdentifier to %{public}s",
                            class_getName(endpointClass));
            } else {
                os_log_error(SSLog, "Could not add -persistentIdentifier to %{public}s",
                             class_getName(endpointClass));
            }
        }
    } else if (SSLog) {
        os_log_info(SSLog, "%{public}s already implements -persistentIdentifier",
                    class_getName(endpointClass));
    }

    SSInstalled = YES;
}

static void SSEnqueueInstall(void) {
    if (!SSInstallQueue) {
        return;
    }

    dispatch_async(SSInstallQueue, ^{
        SSInstallContinuityEndpointMethod();
    });
}

static void SSImageAdded(const struct mach_header *header, intptr_t slide) {
    (void)header;
    (void)slide;
    SSEnqueueInstall();
}

__attribute__((constructor))
static void SSCopyLogFix18Initialize(void) {
    SSLog = os_log_create("com.burc334.copylogfix18", "install");
    SSInstallQueue = dispatch_queue_create("com.burc334.copylogfix18.install",
                                           DISPATCH_QUEUE_SERIAL);

    /*
     * All images are loaded and their Objective-C classes are registered by
     * the time tweak constructors run, so try synchronously first.
     */
    SSInstallContinuityEndpointMethod();

    /*
     * If the endpoint class lives in an image that is loaded later, dyld calls
     * us again. The asynchronous queue serializes those retries.
     */
    _dyld_register_func_for_add_image(SSImageAdded);
    SSEnqueueInstall();
}
