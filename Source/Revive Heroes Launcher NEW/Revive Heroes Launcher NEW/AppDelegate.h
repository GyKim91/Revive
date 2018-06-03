//
//  AppDelegate.h
//  Revive Heroes Launcher NEW
//
//  Created by Gyucika91 on 05/10/2017.
//  Copyright © 2017 Gyucika91. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

{
    BOOL protocolDidRun;
    IBOutlet NSProgressIndicator *launch_indicator;
    IBOutlet NSTextField *progress_text;
    IBOutlet NSTextField *download_size;
    IBOutlet NSProgressIndicator *downloading;
    IBOutlet NSButton *start_update_button;
    IBOutlet NSButton *close_update;
}

@end

@interface GameUpdate : NSObject
{
    NSMutableArray *local_md5;
    NSMutableArray *download_list;
}
@end
