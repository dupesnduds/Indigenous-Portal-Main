//
//  Feeds.m
//  iPortal
//
//  Created by Cleave Pokotea on 9/09/11.
//  Copyright (c) 2011 Tumunu. All rights reserved.
//

#import "Feeds.h"
#import "Article.h"

@implementation Feeds

@synthesize localNewsFeed, localAudioFeed, localVideoFeed;

-(void)checkFeed:(int)whatFeed 
{
    LOG_CML;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    localNewsFeed = [NSMutableArray arrayWithArray:[prefs objectForKey:@"newsfeed"]];
    localVideoFeed = [NSMutableArray arrayWithArray:[prefs objectForKey:@"videofeed"]];
    localAudioFeed = [NSMutableArray arrayWithArray:[prefs objectForKey:@"audiofeed"]];
    
    switch (whatFeed) 
    {
        case kNews:
            if([self.localNewsFeed count] == 0) 
            {
                NSString * newsAddress = @"http://www.tumunu.com/iportal/main-feed.php";
                [self grabFeed:newsAddress];
            } 
            else 
            {
                LOG(@"News Feed: %2f", [localNewsFeed count]);
            }
            break;
        case kVideo:
            if([self.localVideoFeed count] == 0) 
            {
                NSString * videoAddress = @"http://www.tumunu.com/iportal/video-feed.php";
                [self grabFeed:videoAddress];
            } 
            else 
            {
                LOG(@"Video Feed: %2f", [localVideoFeed count]);
            }
            break;
        case kAudio:
            if([self.localAudioFeed count] == 0) 
            {
                NSString * audioAddress = @"http://www.tumunu.com/iportal/audio-feed.php";
                [self grabFeed:audioAddress];
            } 
            else 
            {
                LOG(@"Audio Feed: %2f", [localAudioFeed count]);
            }
            break;
        default:
            break;
    }
}

-(void) grabFeed:(int)whatFeed url:(NSString *)portalAddress 
{
    LOG_CML;
    
    // Reset arrays
    localNewsFeed = [[NSMutableArray alloc] init];
	localVideoFeed = [[NSMutableArray alloc] init];
	localAudioFeed = [[NSMutableArray alloc] init];
    
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
                LOG(@"Video Array - %@",[newsItem copy]);
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
    [self hideActivityIndicator];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


@end
