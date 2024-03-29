//
//  PortalFeeds.m
//  iPortal
//
//  Created by Cleave Pokotea on 9/09/11.
//  Copyright (c) 2011 Tumunu. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>
#import "PortalFeeds.h"
#import "PortalViewsMediator.h"


@implementation PortalFeeds

@synthesize localNewsFeed, localAudioFeed, localVideoFeed;

- (BOOL)checkIfFeedArrayExists:(int)whatFeed
{
    LOG_CML;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    BOOL feedExists = YES;
    switch (whatFeed) 
    {
        case kNews:
            localNewsFeed = [NSMutableArray arrayWithArray:[prefs objectForKey:@"newsfeed"]];
            if([self.localNewsFeed count] == 0) 
            {
                feedExists = NO;
            }
            break;
        case kVideo:
            localVideoFeed = [NSMutableArray arrayWithArray:[prefs objectForKey:@"videofeed"]];
            if([self.localVideoFeed count] == 0) 
            {
                feedExists = NO;
            }
            break;
        case kAudio:
            localAudioFeed = [NSMutableArray arrayWithArray:[prefs objectForKey:@"audiofeed"]];
            if([self.localAudioFeed count] == 0) 
            {
                feedExists = NO;
            }
            break;
        default:
            break;
    }
    
    return feedExists;
}

- (void)grabArticles:(int)whatFeed url:(NSString *)portalAddress 
{
    LOG_CML;
    
    // Reset array because ... well ... yeah that.
    switch (whatFeed) 
    {
        case kNews:
            localNewsFeed = [[NSMutableArray alloc] init];
            break;
        case kVideo:
            localVideoFeed = [[NSMutableArray alloc] init];
            break;
        case kAudio:
            localAudioFeed = [[NSMutableArray alloc] init];
            break;
        default:
            break;
    }

    NSURL *url = [NSURL URLWithString: portalAddress];
    
    // Create a new rssParser object based on the TouchXML "CXMLDocument" class, this is the
    // object that actually grabs and processes the RSS data
    CXMLDocument *rssParser = [[[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:nil] autorelease];
    
    // Create a new Array object to be used with the looping of the results from the rssParser
    NSArray *resultNodes = NULL;
    
    // Set the resultNodes Array to contain an object for every instance of an  node in our RSS feed
    resultNodes = [rssParser nodesForXPath:@"//item" error:nil];
    
    // Loop through the resultNodes to access each items actual data
    for (CXMLElement *resultElement in resultNodes) 
    {
        NSMutableDictionary *newsItem = [[NSMutableDictionary alloc] init];
        int counter;
        
        for(counter = 0; counter < [resultElement childCount]; counter++) 
        {
            [newsItem setObject:[[resultElement childAtIndex:counter] stringValue] forKey:[[resultElement childAtIndex:counter] name]];
        }
        
        switch (whatFeed) 
        {
            case kNews:
                [localNewsFeed addObject:[newsItem copy]];
                break;
            case kVideo:
                [localVideoFeed addObject:[newsItem copy]];
                break;
            case kAudio:
                [localAudioFeed addObject:[newsItem copy]];
                break;
            default:
                break;
        }
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    switch (whatFeed) 
    {
        case kNews:
            LOG(@"Saving News Array");
            [prefs setObject:localNewsFeed forKey:@"newsfeed"];
            break;
        case kVideo:
            LOG(@"Saving Video Array");
            [prefs setObject:localVideoFeed forKey:@"videofeed"];
            break;
        case kAudio:
            LOG(@"Saving Audio Array");
            [prefs setObject:localAudioFeed forKey:@"audiofeed"];
            break;
        default:
            break;
    }
    
    [prefs synchronize];
}

- (BOOL)checkIsDataSourceAvailable 
{
    LOG_CML;
    
    static BOOL checkNetwork = YES;
    if (checkNetwork) 
    {
        checkNetwork = NO;
        
        Boolean success;    
        const char *host_name = "tumunu.com";
        
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        isDataSourceAvailable = success && (flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    
    return isDataSourceAvailable;
}

- (NSString *)springClean:(NSString *)sourceString 
{
    char charCode[28];
    int i;
    for(i=0x00;i<=0x08;i++) 
    {
        charCode[i]=i;
    }
    
    charCode[9]=0x0B;
    for(i=0x0E;i<=0x1F;i++) 
    {
        charCode[i]=i;
    }
    
    NSScanner *sourceScanner = [NSScanner scannerWithString:sourceString];
    NSMutableString *cleanedString = [[[NSMutableString alloc] init] autorelease];
    
    // create an array of chars for all control characters between 0×00 and 0×1F, apart from \t, \n, \f and \r (which are at code points 0×09, 0×0A, 0×0C and 0×0D respectively)
    
    // convert this array into an NSCharacterSet
    // http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/Reference/NSString.html#//apple_ref/doc/uid/20000154-BAJJAICE
    NSString *controlCharString = [NSString stringWithCString:charCode encoding:NSASCIIStringEncoding];
    NSCharacterSet *controlCharSet = [NSCharacterSet characterSetWithCharactersInString:controlCharString];
    
    // request that the scanner ignores these characters
    [sourceScanner setCharactersToBeSkipped:controlCharSet];
    
    // run through the string to remove control characters
    while ([sourceScanner isAtEnd] == NO) 
    {
        NSString *outString;
        if ([sourceScanner scanUpToCharactersFromSet:controlCharSet intoString:&outString])
        {
            [cleanedString appendString:outString];
        }
    }
    
    return cleanedString;
}


@end
