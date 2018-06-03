//
//  main.m
//
//
//
//  
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "main.h"


@implementation ViewController

- (IBAction)field_username:(NSTextField *)sender {
}
- (IBAction)field_password:(NSSecureTextField *)sender {
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
- (IBAction)button_login:(NSButton *)sender {
}
- (IBAction)button_register:(NSButton *)sender {
}
- (IBAction)checkbox_savelogin:(NSButton *)sender {
}


@end

@implementation UserSession

- (void)login_sequence {
    usrname = @"";
    password = @"";
    NSString *login_url = [[NSString alloc]initWithFormat:@"https://heroesawaken.com/api/token?username=%@&password=%@", usrname, password];
    NSURL *login_API = [NSURL URLWithString:login_url];
    NSURLRequest *login_request = [NSURLRequest requestWithURL:login_API];
    NSData *login_response = [NSURLConnection sendSynchronousRequest:login_request returningResponse:nil error:nil];
    NSString *login_response_decode = [[NSString alloc] initWithData:login_response encoding:NSASCIIStringEncoding];
    NSCharacterSet *removed_characters = [NSCharacterSet characterSetWithCharactersInString:@"{}\""];
    token = [[login_response_decode componentsSeparatedByCharactersInSet: removed_characters] componentsJoinedByString: @""];
    token = [token stringByReplacingOccurrencesOfString:@"token:"
                                         withString:@""];
    NSLog(@"%@", token);
} // WORKS, NEED IF STATEMENT IN CASE OF INVALID CREDENTIALS

- (void)save_token {

    // Create auth.conf file if user selected remember login
}

-(void)launcher_init {
    NSError * error;
    NSString * stringFromFile;
    NSString * stringFilepath = @"loadfile.txt";
    stringFromFile = [[NSString alloc] initWithContentsOfFile:stringFilepath
                                                     encoding:NSWindowsCP1250StringEncoding
                                                        error:&error];
} // Check for auth.conf and if exists skip login screen

- (void)web_register {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://heroesawaken.com/register"]];
} // WORKS

- (void)retrieve_sessionid {
    NSString *session_url = [[NSString alloc]initWithFormat:@"https://heroesawaken.com/api/user?token=%@", token];
    NSURL *session_API = [NSURL URLWithString:session_url];
    NSURLRequest *session_request = [NSURLRequest requestWithURL:session_API];
    NSData *session_response = [NSURLConnection sendSynchronousRequest:session_request returningResponse:nil error:nil];
    NSString *session_response_decode = [[NSString alloc] initWithData:session_response encoding:NSASCIIStringEncoding];
//    Trim response to only have sessionID
    NSString *trimmedsessionresponse=[session_response_decode substringFromIndex:MAX((int)[session_response_decode length]-34, 0)];
    NSCharacterSet *removed_characters_sid = [NSCharacterSet characterSetWithCharactersInString:@"}\""];
    sessionID = [[trimmedsessionresponse componentsSeparatedByCharactersInSet: removed_characters_sid] componentsJoinedByString: @""];
    NSLog(@"%@", sessionID);
// Write the sessionID to Info.plist
//    NSString *sessionID_insert = [[NSString alloc]initWithFormat:@"+sessionId %@ +magma 0", sessionID];
    NSString *plistpath = @"/Applications/Heroes Awaken ALPHA.app/Contents/Info.plist";
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
        // String holds "+sessionId current_sessionid +magma"
        
        // Break it down into arrays using whitespace
        NSArray *sessionID_arr = [sessionID_cur componentsSeparatedByString:@" "];

        // Call array 1 to retrieve the current sessionid in the file for replacement
        NSLog(@"MyString %@",sessionID_arr[1]);
        NSString *plistmod = [plistcontent stringByReplacingOccurrencesOfString:sessionID_arr[1]
                                                                     withString:sessionID];
        NSError *plistwriteerror;
        [plistmod writeToFile:plistpath atomically:YES encoding:NSUTF8StringEncoding error:&plistwriteerror];
    }

} // NEED TO CHECK IF TOKEN WAS ALREADY SAVED AND USE IT

- (void)launch_game {
    [[NSWorkspace sharedWorkspace] launchApplication:@"Heroes Awaken ALPHA"];
} // WORKS

- (void)reset_config {
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSError *reset_error = nil;
    [file_manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Battlefield Heroes"] error:&reset_error];
} // WORKS

- (void)log_out {
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSError *reset_error = nil;
    [file_manager removeItemAtPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Battlefield Heroes"] error:&reset_error];
    // Delete auth.conf file which only exists if user selected remember login
}

- (void)invalid_login {
    
}
@end

//———————— Main Program ————————

int main (int argc, const char * argv[]) {
    
    // Create an instance of UserSession
    UserSession *LiveUserSession;
    
    LiveUserSession = [[UserSession alloc] init];
    
    // Initialize launcher
//    [LiveUserSession launcher_init];
    
    // Summon window
    
    

    
    // Reset config
//    [LiveUserSession reset_config];
    
    // Login
//    [LiveUserSession login_sequence];
    
    // Register
//    [LiveUserSession web_register];
    
    // Get sessionID
//    [LiveUserSession retrieve_sessionid];
    
    // Launch game
//    [LiveUserSession launch_game];

    return 0;
}
