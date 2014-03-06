//
//  LLViewController.m
//  ExampleProject
//
//  Created by Mats Melke on 2014-02-28.
//

#import "LLViewController.h"
#import "DDLog.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface LLViewController ()

@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logButtonTapped:(id)sender {
    DDLogVerbose(@"{\"log_button_tapped\":\"The log button was tapped at %@\"}", [[[NSDate alloc] init] description]);
}

@end
