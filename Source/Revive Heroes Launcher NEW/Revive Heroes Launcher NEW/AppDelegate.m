//
//  AppDelegate.m
//  Revive Heroes Launcher NEW
//
//  Created by Gyucika91 on 05/10/2017.
//  Copyright © 2017 Gyucika91. All rights reserved.
//

#import "AppDelegate.h"
#import "SSZipArchive.h"

@interface AppDelegate ()

@property NSWindowController *mainWindowctl;
@property (weak) IBOutlet NSMenu *mainMenu;
@property (weak) IBOutlet NSWindow *mainwindow;
@property (weak) IBOutlet NSWindow *firstrunwindow;
@property (weak) IBOutlet NSWindow *errorwindow;
@property (weak) IBOutlet NSWindow *updatingwindow;
@property (weak) IBOutlet NSWindow *knownissues;

@end

@implementation AppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    // Listen for protocol handler and respond with getURL:withReplyEvent: below
}

- (void)getURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)reply
{
    NSString *launch_url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSArray *url_components = [launch_url componentsSeparatedByString: @"/"];
    NSString *sessionID = url_components[3]; // Here is set which part of the protocol URL is registered as SessionID
    NSString *plistpath = @"/Applications/Battlefield Heroes.app/Contents/Info.plist";
    NSError *plistreaderror;
    NSString *plistcontent = [NSString stringWithContentsOfFile:plistpath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&plistreaderror];
    // Define Program Flag boundaries that confine sessionId in Info.plist
    long idx1 = [plistcontent rangeOfString:@"+sessionId"].location;
    long idx2 = [plistcontent rangeOfString:@"+magma"].location;
    long len2 = [@"+magma" length];
    if ((idx1>=0)&&(idx2>=0)) {
        NSString *sessionID_cur= [plistcontent substringWithRange:NSMakeRange(idx1, idx2+len2-idx1)];
        //  String holds "+sessionId current_sessionid +magma"
        
        // Break it down into arrays using whitespace
        NSArray *sessionID_arr = [sessionID_cur componentsSeparatedByString:@" "];
        
        // Call array 1 to retrieve the current sessionid in the file for replacement
        NSString *plistmod = [plistcontent stringByReplacingOccurrencesOfString:sessionID_arr[1]
                                                                     withString:sessionID];
        NSError *plistwriteerror;
        [plistmod writeToFile:plistpath atomically:YES encoding:NSUTF8StringEncoding error:&plistwriteerror];
    };
    protocolDidRun = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    NSString *plistpath = @"/Applications/Revive Heroes Launcher.app/Contents/Info.plist";
    NSMutableDictionary *plistcontent = [[NSMutableDictionary alloc] initWithContentsOfFile:plistpath];
    NSString *firstrun = (NSString*)[plistcontent valueForKey: @"First run"];
    
    if ([firstrun intValue] == 1) {
        [plistcontent setValue:@"NO" forKey:@"First run"];
        [plistcontent writeToFile:plistpath atomically:YES];        // Change first run string to NO
        _mainWindowctl = [[NSWindowController alloc] initWithWindowNibName:@"FirstRunView"];
        [_mainWindowctl showWindow:self]; // Open First Run view
    } else {
        if (protocolDidRun == YES) {
            _mainWindowctl = [[NSWindowController alloc] initWithWindowNibName:@"MainWindow"];
            [_mainWindowctl showWindow:self];
            // Open Main view
        } else {
            _mainWindowctl = [[NSWindowController alloc] initWithWindowNibName:@"MainWindow"];
            [_mainWindowctl showWindow:self];
            // Open Error view
        }
    };
    
    NSString *local_version_str = (NSString*)[plistcontent valueForKey: @"CFBundleVersion"];
    int local_version = [local_version_str intValue];
    NSURL *version_url = [NSURL URLWithString: @"https://raw.githubusercontent.com/GyKim91/Revive/master/mac_bfh_version"];
    NSString *version_info = [NSString stringWithContentsOfURL:version_url encoding:NSUTF8StringEncoding error:nil];
    NSArray *version_array = [version_info componentsSeparatedByString:@"\n"];
    NSString *remote_version_str = version_array[0];
    int remote_version = [remote_version_str intValue];
    NSString *remote_download = version_array[1];
    NSURL *download_link = [NSURL URLWithString:remote_download];    
    
    /// IF section to download new version
    if (local_version < remote_version) {
        [[NSOperationQueue new] addOperationWithBlock:^{
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"rvh_launcher_latest.zip"];
        NSMutableData *filedata = [NSMutableData dataWithContentsOfURL:download_link];
        [filedata writeToFile:filePath atomically:YES];
        NSString *unzipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@""];
        [SSZipArchive unzipFileAtPath:filePath toDestination:unzipPath];
        NSFileManager *file_manager = [NSFileManager defaultManager];
        NSArray *applications_paths = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask, YES);
        NSString *app_path = [applications_paths[0] stringByAppendingPathComponent:@"Revive Heroes Launcher.app"];
        [file_manager removeItemAtPath:app_path error:nil];
        [file_manager moveItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"Revive Heroes Launcher.app"] toPath:app_path error:nil];  }];
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Revive Heroes Launcher updated!";
            notification.informativeText = @"The launcher has been updated. Restart it to use the latest version. Battlefield Heroes now works on 10.13!";
            notification.soundName = NSUserNotificationDefaultSoundName;
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    NSLog(@"%d", local_version);
    NSLog(@"%d", remote_version);
        NSLog(@"%@", download_link);
    }
    [self BFH_fix_for_high_sierra]; // Fix for game crash on launch for High Sierra
    NSString *bfhPath = @"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/BFH";
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bfhPath error:nil];
    NSLog(@"%@", dirFiles);
}

-(void)BFH_fix_for_high_sierra {
    NSString *plistpath_2 = @"/Applications/Battlefield Heroes.app/Contents/Info.plist";
    NSMutableDictionary *plistcontent_2 = [[NSMutableDictionary alloc] initWithContentsOfFile:plistpath_2];
    [plistcontent_2 setValue:@"false" forKey:@"Try To Use GPU Info"];
    [plistcontent_2 writeToFile:plistpath_2 atomically:YES];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

- (IBAction)button_knownissues:(id)sender {
    _mainWindowctl = [[NSWindowController alloc] initWithWindowNibName:@"KnownIssues"];
    [_mainWindowctl showWindow:self];
}

- (IBAction)button_closeknownissues:(id)sender {
    [_knownissues close];
}

- (IBAction)button_resetconfig:(id)sender {
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSError *reset_error = nil;
    [file_manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Battlefield Heroes"] error:&reset_error];
}

- (IBAction)button_forceupdate:(id)sender {
    [_mainwindow close];    
    _mainWindowctl = [[NSWindowController alloc] initWithWindowNibName:@"Updating"];
    [_mainWindowctl showWindow:self];
}

- (IBAction)button_startupdate:(id)sender {
    [self forceupdate];
}

- (void)forceupdate {
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    start_update_button.hidden = YES;
    [downloading startAnimation:nil];
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSURL *index_URL = [NSURL URLWithString:@"http://cdn-metadata.revive.systems/reviveheroes/depot/index"]; // Change this URL if BFH game files location changes!
    NSString *latest_filelist = [NSString stringWithContentsOfURL:index_URL encoding:NSUTF8StringEncoding error:nil];
    NSArray *rows = [latest_filelist componentsSeparatedByString:@"\n"];
    NSMutableArray *rows_clean = [NSMutableArray arrayWithArray:rows];
    [rows_clean removeLastObject];
    NSMutableArray *filenamecolumn = [NSMutableArray array];    // Store file names for downloading
    NSMutableArray *filesizecolumn = [NSMutableArray array];    // Store file sizes for progress tracking
    
    for (NSString *row in rows_clean){
        NSArray *columns = [row componentsSeparatedByString:@" "];
        [filenamecolumn addObject:columns[0]];
        [filesizecolumn addObject:columns[2]];
    };
    
    double sum = 0;
    for (NSNumber * n in filesizecolumn) {
        sum += [n doubleValue];
    }
    double total_download_size = sum / 1000000000;
    NSString *total_download_text = [NSString stringWithFormat:@"Total download size: %.2fGB", total_download_size];
    [download_size setStringValue:total_download_text];
    NSString *raw_filenamecolumn = [[filenamecolumn valueForKey:@"description"] componentsJoinedByString:@"\n"];
    NSString *clean_filenamecolums = [raw_filenamecolumn stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    NSArray *clean_filearray = [clean_filenamecolums componentsSeparatedByString:@"\n"];
    [[NSOperationQueue new] addOperationWithBlock:^{
        
        for (int i=0; i < [clean_filearray count]; i++)  { // Loop through the array that contains the game file names
            @autoreleasepool {
                NSString *bfh_file_url = [NSString stringWithFormat:@"http://cdn-metadata.revive.systems/reviveheroes/depot/dist/%@", [clean_filearray objectAtIndex:i]];
                NSURL *url = [NSURL URLWithString:bfh_file_url];
                NSString *raw_filePath = [NSString stringWithFormat:@"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/temp/%@", [clean_filearray objectAtIndex:i]];
                NSString *filePath = [raw_filePath stringByDeletingLastPathComponent];
                BOOL isDirectory;
                if (![file_manager fileExistsAtPath:filePath isDirectory:&isDirectory] || !isDirectory) {
                    [file_manager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
                };
                NSMutableData *filedata = [NSMutableData dataWithContentsOfURL:url];
                [filedata writeToFile:raw_filePath atomically:YES];
                NSString *progress = [NSString stringWithFormat:@"%d / %lu files downloaded.", i, (unsigned long)[clean_filearray count]];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [progress_text setStringValue:progress]  ;
                    }];
            };
            
        };
        NSString *bfh_path = @"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/BFH";
        NSString *temp_path = @"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/temp/";
        [file_manager removeItemAtPath:bfh_path error:nil];
        [file_manager moveItemAtPath:temp_path toPath:bfh_path error:nil];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [downloading stopAnimation:nil];
        progress_text.hidden = YES;
        [download_size setStringValue:@"Updating is complete"];
        close_update.hidden = NO;
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Battlefield Heroes update complete!";
            notification.informativeText = @"The game has been updated. Return to the launcher to play.";
            notification.soundName = NSUserNotificationDefaultSoundName;
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }];
        
    }];
}
- (IBAction)close_update_open_main:(id)sender {
    [_updatingwindow close];
    _mainWindowctl = [[NSWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [_mainWindowctl showWindow:self];
}


- (IBAction)button_soldiers:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://reviveheroes.com/create"]];
}

- (void)kill_launcher {
    [[NSApplication sharedApplication] terminate:nil];
    // Kills the launcher
}

- (IBAction)button_playnow:(id)sender {
    [[NSWorkspace sharedWorkspace] launchApplication:@"Battlefield Heroes"];
    [launch_indicator startAnimation:sender];
    [NSTimer scheduledTimerWithTimeInterval: 3
                                     target: self
                                   selector: @selector(kill_launcher)
                                   userInfo: nil
                                    repeats: NO];
    // Launches BFH, starts indicator animation and runs kill_launcher after 3 seconds
}

- (IBAction)button_openwebsite:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://reviveheroes.com"]];
    [[NSApplication sharedApplication] terminate:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
    return YES; // Ensure that when window is closed the application is terminated instead of hiding it
}
@end
