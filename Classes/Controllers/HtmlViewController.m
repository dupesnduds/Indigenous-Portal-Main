//
//  WebViewController.m
//  iPortal
//
//  Created by Cleave Pokotea on 12/05/09.
//  Copyright 2009 Make Things Talk. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HtmlViewController.h"
#import "iPortalAppDelegate.h"
#import "MainViewController.h"
#import "VideoViewController.h"
#import "CustomAlertViewController.h"

@implementation HtmlViewController

@synthesize background;
@synthesize mvc;
@synthesize vvc;
@synthesize webView;
@synthesize btn;
@synthesize shareBtn;
@synthesize cavc;

- (void)dealloc 
{
    if(webView) 
    {
        [webView release];
    }
    if(btn) 
    {
        [btn release];
    }
    if(shareBtn) 
    {
        [shareBtn release];
    }   
    if(mvc) 
    {
        [mvc release];
    }
    if(vvc) 
    {
        [vvc release];
    }  
    if(cavc) 
    {
        [cavc release];
    }
    
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    LOG_CML;
    
    [self setupView];
    [super viewDidLoad];
}

- (IBAction)done 
{
    LOG_CML;
    
    [iPortalAppDelegate playEffect:kEffectButton];
    [iPortalAppDelegate playEffect:kEffectPage];
    MainViewController *tmvc = [[MainViewController alloc] initWithNibName:@"MainView" bundle:nil];
    self.mvc = tmvc;
    [tmvc release];
    
    VideoViewController *tvvc = [[VideoViewController alloc] initWithNibName:@"VideoView" bundle:nil];
    self.vvc = tvvc;
    [tvvc release];
    
    UIView *currentView = self.view;
	// get the the underlying UIWindow, or the view containing the current view view
	UIView *theWindow = [currentView superview];
    [currentView removeFromSuperview];
    
    switch ([iPortalAppDelegate get].what) 
    {
        case 1:
            [theWindow addSubview:[mvc view]];
            break;
        case 2:
            [theWindow addSubview:[vvc view]];
            break;
        default:
            break;
    }
	
	// set up an animation for the transition between the views
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.45];
	[animation setType:kCATransitionPush];
	[animation setSubtype:kCATransitionFromLeft];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	
	[[theWindow layer] addAnimation:animation forKey:@"swap"];    
}

- (IBAction)mail 
{
    LOG_CML;
	
	NSString *subjString = @"Indigenous Portal | Something you might be interested in";
    NSString *msgString = [NSString stringWithFormat: @"Here's an item I thought you might be interested in\r\n\r\n %@", [iPortalAppDelegate get].cellURL];

	NSString *urlString = [NSString stringWithFormat: @"mailto:?subject=%@&body=%@", 
						   [subjString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
						   [msgString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
	LOG(@"subjString = %@", subjString);
	LOG(@"msgString = %@", msgString);
	LOG(@"urlString = %@", urlString);
    
	NSURL *mailURL = [NSURL URLWithString: urlString];
	[[UIApplication sharedApplication] openURL: mailURL];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{}

- (void)setupView 
{
    LOG_CML;
    
#if __IPHONE_3_0
    // UIViewController slips up under status bar. We need to reset it to where it should be placed
    self.view.frame = [[UIScreen mainScreen] applicationFrame];
#endif
    
    [self setBackgroundImage]; 
    
    btn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 50.0f)];
    UIFont *displayFont = [UIFont fontWithName:@"Helvetica" size:14];

#if __IPHONE_3_0
    btn.titleLabel.font = displayFont;
#else
    btn.font = displayFont;
#endif
    
    [btn setBackgroundImage:[[UIImage imageNamed:@"back-163dpi.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [btn setCenter:CGPointMake(50.0f, 25.0f)];
    
    switch ([iPortalAppDelegate get].what) 
    {
        case 1:
            [btn setTitle:@"   News" forState:UIControlStateNormal];
            break;
        case 2:
            [btn setTitle:@"  Video" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    [btn setTitleColor:[UIColor colorWithRed:48.0/255.0 green:50.0/255.0 blue:47.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn setEnabled:NO];
    
    // Share
    shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 85.0f, 50.0f)];
    
#if __IPHONE_3_0
    shareBtn.titleLabel.font = displayFont;
#else
    shareBtn.font = displayFont;
#endif
    
    [shareBtn setBackgroundImage:[[UIImage imageNamed:@"share-163dpi.png"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [shareBtn setCenter:CGPointMake(278.0f, 25.0f)];
    [shareBtn setTitle:@"Share" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(mail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    [shareBtn setEnabled:NO];
    
    [self loadHtml];
}

- (void)loadHtml 
{
    
    if(![[iPortalAppDelegate get] checkIsDataSourceAvailable]) 
    {
        CustomAlertViewController * tcavc = [[CustomAlertViewController alloc] initWithNibName:@"CustomAlertView" bundle:nil];
        self.cavc = tcavc;
        [tcavc release];
        
        self.cavc.view.frame = [UIScreen mainScreen].applicationFrame;
        self.cavc.view.alpha = 0.0;
        //[[iPortalAppDelegate get].window addSubview:[cavc view]];
        
        [UIView beginAnimations:nil context:nil];  //Don't yell at me about not using NULL.  They're the same, it's just convention to use one for pointers and the other one for everything else.  
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.33];  //.25 looks nice as well.
        self.cavc.view.alpha = 1.0;
        [UIView commitAnimations];
    } 
    else 
    {
        
        //NSString *helpPath = [iPortalAppDelegate get].cellURL;
        NSURL *helpURL = [NSURL URLWithString:helpPath];
        [self.webView loadRequest:[NSURLRequest requestWithURL:helpURL]];
    }
}

- (void)setShouldYouLoadIndicator:(BOOL)what 
{
    shouldYouLoadIndicator = what;
}

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
    LOG_CML;
    
    [btn setEnabled:NO];
    if(shouldYouLoadIndicator == YES) 
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    } 
    else 
    {
        shouldYouLoadIndicator = YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
    LOG_CML;
    
    if(shouldYouLoadIndicator == YES) 
    {
        LOG(@"Indicator is showing. Now end");
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
        
        [shareBtn setEnabled:YES];
        [btn setEnabled:YES];
        LOG(@"DEBUG:disable uiButton:%@:%d", btn, [btn isEnabled]);
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
    LOG_CML;
    
    shouldYouLoadIndicator = NO;
    
	// load error, hide the activity indicator in the status bar
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// report the error inside the webview
    if (error != NULL && [error code] != -999) 
    {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle: [error localizedDescription]
                                   message: [error localizedFailureReason]
                                   delegate:nil
                                   cancelButtonTitle:@"OK" 
                                   otherButtonTitles:nil];
        [errorAlert show];
        [errorAlert release];
    }
}

- (void)setBackgroundImage 
{
	LOG_CML;
    
	UIImageView *customBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Bkgnd-standard.png"]];
	self.background = customBackground;
	[customBackground release];
	
	[self.view addSubview:background];
	[self.view sendSubviewToBack:background];
}


@end
