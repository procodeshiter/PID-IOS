#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <libproc.h>

@interface ProcessInfoFetcher : NSObject
@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSTextField *pidTextField;
@property (strong) IBOutlet NSTextField *resultLabel;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (IBAction)getProcessInfo:(id)sender;
- (NSString *)getProcessInfoForPID:(pid_t)pid;
@end

@implementation ProcessInfoFetcher

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self.pidTextField setPlaceholderString:@"Input PID"];
}

- (IBAction)getProcessInfo:(id)sender {
    NSString *pidString = [self.pidTextField stringValue];
    pid_t pid = (pid_t)[pidString intValue];

    NSLog(@"Getting process info for PID from UI: %d", pid);
    NSString *result = [self getProcessInfoForPID:pid];
    self.resultLabel.stringValue = result;
}

- (NSString *)getProcessInfoForPID:(pid_t)pid {
    struct proc_bsdinfo info;

    NSLog(@"Fetching process info for PID: %d", pid);
    if (proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &info, sizeof(info)) <= 0) {
        NSLog(@"Failed to get process info for PID %d", pid);
        return [NSString stringWithFormat:@"Failed to get process info for PID %d", pid];
    }

    NSLog(@"Successfully retrieved process info for PID: %d", pid);
    return [NSString stringWithFormat:@"Process ID: %d\nProcess Name: %s\nParent Process ID: %d\nUser ID: %d\nGroup ID: %d",
            info.pbi_pid, info.pbi_name, info.pbi_ppid, info.pbi_uid, info.pbi_gid];
}

@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc == 2) {
            pid_t pid = atoi(argv[1]);
            NSLog(@"Fetching process info for PID from command line: %d", pid);
            ProcessInfoFetcher *fetcher = [[ProcessInfoFetcher alloc] init];
            NSString *result = [fetcher getProcessInfoForPID:pid];
            NSLog(@"%@", result);
            return 0;
        }
        return NSApplicationMain(argc, argv);
    }
}