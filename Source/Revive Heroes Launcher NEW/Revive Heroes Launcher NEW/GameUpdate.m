//
//  GameUpdate.m
//  Revive Heroes Launcher
//
//  Created by Gyula Kimpan on 13/10/2017.
//  Copyright © 2017 Gyucika91. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "md5gen.h"

@implementation GameUpdate

-(void)generateMD5 {
    NSString *bfhPath = @"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/BFH";
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bfhPath error:nil];
    
    BOOL isDir;
    
    [[NSFileManager defaultManager] fileExistsAtPath:sPath isDirectory:&isDir];
    
    if(isDir)
    {
        NSArray *contentOfDirectory=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:sPath error:NULL];
        
        int contentcount = [contentOfDirectory count];
        int i;
        for(i=0;i<contentcount;i++)
        {
            NSString *fileName = [contentOfDirectory objectAtIndex:i];
            NSString *path = [sPath stringByAppendingFormat:@"%@%@",@"/",fileName];
            
            
            if([[NSFileManager defaultManager] isDeletableFileAtPath:path])
            {
                NSLog(path);
                [self scanPath:path];
            }
        }
        
    }
    else
    {
        NSString *msg=[NSString stringWithFormat:@"%@",sPath];
        NSLog(msg);
    }
    
    NSString *result = [FileHash md5HashOfFileAtPath:bfhPath];
    NSLog(@"%@", result);
    [self updateSequence];
}

-(void)updateSequence {
    
}

- (void)forceupdate {
    
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
                
            };
            
        };
        NSString *bfh_path = @"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/BFH";
        NSString *temp_path = @"/Applications/Battlefield Heroes.app/Contents/Resources/drive_c/temp/";
        [file_manager removeItemAtPath:bfh_path error:nil];
        [file_manager moveItemAtPath:temp_path toPath:bfh_path error:nil];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Battlefield Heroes update complete!";
            notification.informativeText = @"The game has been updated. Return to the launcher to play.";
            notification.soundName = NSUserNotificationDefaultSoundName;
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }];
        
    }];
    
}

@end
