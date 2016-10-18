//
//  ViewController.m
//  TestFotAccountKit
//
//  Created by AndyChen on 2016/10/5.
//  Copyright © 2016年 AndyChen. All rights reserved.
//
#import <AccountKit/AccountKit.h>
#import "ViewController.h"

@interface ViewController ()<AKFViewControllerDelegate>
{
    AKFAccountKit *_accountKit;
    UIViewController<AKFViewController> *_pendingLoginViewController;
    NSString *_authorizationCode;
    UILabel *accountIDLabel;
    UILabel *titleLabel;
    UILabel *valueLabel;
    UIButton *logoutButtom;
    UIButton *phontLoginButtom;
    UIButton *emailLoginButtom;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // initialize Account Kit
    if (_accountKit == nil) {
        // may also specify AKFResponseTypeAccessToken
        _accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    }
    
    // view controller for resuming login
    _pendingLoginViewController = [_accountKit viewControllerForLoginResume];
    [self setUPView];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self isUserLoggedIn]) {
        // if the user is already logged in, go to the main screen
        [self proceedToMainScreen];
    } else if (_pendingLoginViewController != nil) {
        // resume pending login (if any)
        [self _prepareLoginViewController:_pendingLoginViewController];
        [self presentViewController:_pendingLoginViewController
                           animated:animated
                         completion:NULL];
        _pendingLoginViewController = nil;
    } else
    {
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}
- (void)loginWithPhone:(id)sender
{
    //另一種預先可輸入電話號碼的設定
    AKFPhoneNumber *preFillPhoneNumber = nil;
    NSString *inputState = [[NSUUID UUID] UUIDString];
    NSLog(@"pre UUID :%@",inputState);
    UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForPhoneLoginWithPhoneNumber:preFillPhoneNumber state:inputState];
    viewController.enableSendToFacebook = YES; // defaults to NO
    [self _prepareLoginViewController:viewController]; // see below
    [self presentViewController:viewController animated:YES completion:NULL];
}
- (void)loginWithEmail:(id)sender
{
    NSString *inputState = [[NSUUID UUID] UUIDString];
    NSLog(@"pre UUID :%@",inputState);
    UIViewController<AKFViewController> *viewController = [_accountKit viewControllerForEmailLoginWithEmail:nil state:inputState];
    [self _prepareLoginViewController:viewController]; // see below
    [self presentViewController:viewController animated:YES completion:NULL];
}

-(BOOL)isUserLoggedIn
{
    NSLog(@"accountID :%@",[[_accountKit currentAccessToken] accountID]);
    return [[_accountKit currentAccessToken] accountID];
}
-(void)proceedToMainScreen
{
    NSLog(@"您已登入");
//    AKFAccountKit *accountKit = [[AKFAccountKit alloc] initWithResponseType:AKFResponseTypeAccessToken];
    [_accountKit requestAccount:^(id<AKFAccount> account, NSError *error) {
        // account ID
        accountIDLabel.text = [NSString stringWithFormat:@"%@",account.accountID];
        if ([account.emailAddress length] > 0) {
            titleLabel.text = @"Email Address";
            valueLabel.text = account.emailAddress;
        }
        else if ([account phoneNumber] != nil) {
            titleLabel.text = @"Phone Number";
            valueLabel.text = [[account phoneNumber] stringRepresentation];
        }else
        {
            NSLog(@"error :%@",[error localizedDescription]);
        }
    }];
}
-(void)setUPView
{
    float accountIDLabelX = [[UIScreen mainScreen] bounds].size.width/2-150;
    float accountIDLabelY = [[UIScreen mainScreen] bounds].size.height/6+30+100;
    UITextView *accountTextView = [[UITextView alloc] initWithFrame:CGRectMake(accountIDLabelX, accountIDLabelY-50, 300, 50)];
    [accountTextView setText:@"Account ID"];
    accountIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(accountIDLabelX, accountIDLabelY, 300, 50)];
    
    float titleLabelX = [[UIScreen mainScreen] bounds].size.width/2-150;
    float titleLabelY = 10+CGRectGetMaxY(accountIDLabel.frame)+50;
    UITextView *titleTextView = [[UITextView alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY-50, 300, 50)];
    [titleTextView setText:@"Title"];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, 200, 50)];

    
    float valueLabelX = [[UIScreen mainScreen] bounds].size.width/2-150;
    float valueLabelY = 10+CGRectGetMaxY(titleLabel.frame)+50;
    UITextView *valueTextView = [[UITextView alloc] initWithFrame:CGRectMake(valueLabelX, valueLabelY-50, 300, 50)];
    [valueTextView setText:@"Value"];
    valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(valueLabelX, valueLabelY, 200, 50)];
    
    //設定橘色背景與棕色邊框
    [accountTextView setBackgroundColor:[UIColor orangeColor]];
    [[accountTextView layer] setBorderColor:[[UIColor brownColor] CGColor]];
    [titleTextView setBackgroundColor:[UIColor orangeColor]];
    [[titleTextView layer] setBorderColor:[[UIColor brownColor] CGColor]];
    [valueTextView setBackgroundColor:[UIColor orangeColor]];
    [[valueTextView layer] setBorderColor:[[UIColor brownColor] CGColor]];
    
    //邊框粗細
    [[accountTextView layer] setBorderWidth:4.5];
    [[titleTextView layer] setBorderWidth:4.5];
    [[valueTextView layer] setBorderWidth:4.5];
    
    //設定圓角程度
    [[accountTextView layer] setCornerRadius:90];
    [[titleTextView layer] setCornerRadius:90];
    [[valueTextView layer] setCornerRadius:90];
    
    //指定內文字體大小並置中
    [accountTextView setFont:[UIFont boldSystemFontOfSize:25.0]];
    [accountTextView setTextAlignment:NSTextAlignmentCenter];
    [titleTextView setFont:[UIFont boldSystemFontOfSize:25.0]];
    [titleTextView setTextAlignment:NSTextAlignmentCenter];
    [valueTextView setFont:[UIFont boldSystemFontOfSize:25.0]];
    [valueTextView setTextAlignment:NSTextAlignmentCenter];
    
    //設定無法再被編輯
    [accountTextView setEditable:NO];
    [titleTextView setEditable:NO];
    [valueTextView setEditable:NO];
    
    //使內文保持在UITextView邊框之內
    [accountTextView setClipsToBounds: YES];
    [titleTextView setClipsToBounds: YES];
    [valueTextView setClipsToBounds: YES];
    
    [self.view addSubview:accountTextView];
    [self.view addSubview:titleTextView];
    [self.view addSubview:valueTextView];
    [self.view addSubview:accountIDLabel];
    [self.view addSubview:titleLabel];
    [self.view addSubview:valueLabel];
    
    logoutButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutButtom setBackgroundImage:[UIImage imageNamed:@"buttonBackground.png"] forState:UIControlStateNormal];
    [logoutButtom setFrame:CGRectMake(15, 25, [[UIScreen mainScreen] bounds].size.width-30, 40)];
    [logoutButtom setTitle:@"登出" forState:UIControlStateNormal];
    [logoutButtom setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [logoutButtom setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [[logoutButtom layer] setCornerRadius:10];
    [[logoutButtom layer] setMasksToBounds:YES];
    [logoutButtom addTarget:self action:@selector(logoutAF) forControlEvents:UIControlEventTouchUpInside];
    
    phontLoginButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    [phontLoginButtom setBackgroundImage:[UIImage imageNamed:@"phoneLogin.png"] forState:UIControlStateNormal];
    [phontLoginButtom setFrame:CGRectMake(15, 75, [[UIScreen mainScreen] bounds].size.width-30, 40)];
    [phontLoginButtom setTitle:@"電話登入" forState:UIControlStateNormal];
    [phontLoginButtom setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [phontLoginButtom setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [[phontLoginButtom layer] setCornerRadius:10];
    [[phontLoginButtom layer] setMasksToBounds:YES];
    [phontLoginButtom addTarget:self action:@selector(phoneLogin) forControlEvents:UIControlEventTouchUpInside];
    
    emailLoginButtom = [UIButton buttonWithType:UIButtonTypeCustom];
    [emailLoginButtom setBackgroundImage:[UIImage imageNamed:@"emailLogin.png"] forState:UIControlStateNormal];
    [emailLoginButtom setFrame:CGRectMake(15, 125, [[UIScreen mainScreen] bounds].size.width-30, 40)];
    [emailLoginButtom setTitle:@"Email登入" forState:UIControlStateNormal];
    [emailLoginButtom setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [emailLoginButtom setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    [[emailLoginButtom layer] setCornerRadius:10];
    [[emailLoginButtom layer] setMasksToBounds:YES];
    [emailLoginButtom addTarget:self action:@selector(emailLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoutButtom];
    [self.view addSubview:phontLoginButtom];
    [self.view addSubview:emailLoginButtom];
}
-(void)logoutAF
{
    NSLog(@"Logout");
    [_accountKit logOut];
}
-(void)phoneLogin
{
    [self loginWithPhone:nil];
}
-(void)emailLogin
{
    [self loginWithEmail:nil];
}
- (void)_prepareLoginViewController:(UIViewController<AKFViewController> *)loginViewController
{
    loginViewController.delegate = self;
    // Optionally, you may use the Advanced UI Manager or set a theme to customize the UI.
    loginViewController.advancedUIManager = nil;
    loginViewController.theme = [self bicycleTheme];
}
- (AKFTheme *)bicycleTheme
{
    AKFTheme *theme = [AKFTheme outlineThemeWithPrimaryColor:[self _colorWithHex:0xffff5a5f]
                                            primaryTextColor:[UIColor whiteColor]
                                          secondaryTextColor:[UIColor whiteColor]
                                              statusBarStyle:UIStatusBarStyleLightContent];
    theme.backgroundImage = [UIImage imageNamed:@"buttonBackground"];
    theme.backgroundColor = [self _colorWithHex:0x66000000];
    theme.inputBackgroundColor = [self _colorWithHex:0x00000000];
    theme.inputBorderColor = [UIColor whiteColor];
    return theme;
}

- (UIColor *)_colorWithHex:(NSUInteger)hex
{
    CGFloat alpha = ((CGFloat)((hex & 0xff000000) >> 24)) / 255.0;
    CGFloat red = ((CGFloat)((hex & 0x00ff0000) >> 16)) / 255.0;
    CGFloat green = ((CGFloat)((hex & 0x0000ff00) >> 8)) / 255.0;
    CGFloat blue = ((CGFloat)((hex & 0x000000ff) >> 0)) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAuthorizationCode:(NSString *)code state:(NSString *)state
{
    NSLog(@"\nCompleteLoginWithAuthorizationCode :%@\nstate :%@",code,state);
    [self proceedToMainScreen];
}

/*!
 @abstract Called when the login completes with an access token response type.
 
 @param viewController the AKFViewController that was used
 @param accessToken the access token for the logged in account
 @param state the state param value that was passed in at the beginning of the flow
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didCompleteLoginWithAccessToken:(id<AKFAccessToken>)accessToken state:(NSString *)state
{
    NSLog(@"\nCompleteLoginWithAccessToken :%@\nstate :%@",accessToken,state);
    [self proceedToMainScreen];
}

/*!
 @abstract Called when the login failes with an error
 
 @param viewController the AKFViewController that was used
 @param error the error that occurred
 */
- (void)viewController:(UIViewController<AKFViewController> *)viewController didFailWithError:(NSError *)error
{
    NSLog(@"\nViewControllerFailWithError :%@",[error localizedDescription]);
}

/*!
 @abstract Called when the login flow is cancelled through the UI.
 
 @param viewController the AKFViewController that was used
 */
- (void)viewControllerDidCancel:(UIViewController<AKFViewController> *)viewController
{
    NSLog(@"DidCancel");
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
