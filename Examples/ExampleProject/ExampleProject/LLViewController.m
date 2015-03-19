//
//  LLViewController.m
//  ExampleProject
//
//  Created by Mats Melke on 2014-02-28.
//

#import "LLViewController.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

static const int ddLogLevel = DDLogLevelVerbose;

@interface LLViewController ()

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)logButtonTapped:(id)sender {
    DDLogVerbose(@"{\"log_button_tapped\":\"The log button was tapped at %@\"}", [[[NSDate alloc] init] description]);
}

@end
