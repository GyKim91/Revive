//
//  main.h
//  
//
//
//
//

#import <Cocoa/Cocoa.h>


@interface ViewController : NSViewController

@end

@interface UserSession : NSObject
{
    NSString *usrname;
    NSString *password;
    NSString *token;
    NSString *sessionID;
    BOOL option_save_token;
}

- (void)login_sequence;
- (void)save_token;
- (void)web_register;
- (void)retrieve_sessionid;
- (void)launch_game;
- (void)reset_config;
- (void)log_out;
- (void)invalid_login;


@end
