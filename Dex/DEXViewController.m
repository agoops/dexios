//
//  DEXViewController.m
//  Dex
//
//  Created by Ankit Gupta on 7/20/14.
//  Copyright (c) 2014 Ankit Gupta. All rights reserved.
//

#import "DEXViewController.h"
#import "DEXConfig.h"

@interface DEXViewController ()


@property (strong, nonatomic) IBOutlet UIView *BaseView;

@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UITextField *appIdTextView;
@property (strong, nonatomic) NSMutableArray *textviews;
@property (strong, nonatomic) NSString *baseurl;
@property (strong, nonatomic) NSString *appid1;
@property (strong, nonatomic) NSString *appid2;
@end

@implementation DEXViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    mobileServiceAppKey = @"OiCxIlqbIdACRODFNrWmSEMTDslbrK95";
    baseurl = @"https://usddev.azure-mobile.net/tables/ConfigDetails?$filter=appid+eq+'%@'";
    appid1 = @"77e251f7-7407-43d0-9112-123b90ede83a";
    appid2 = @"27e73a61-4a7b-4998-bb71-12a766b83f3a";
    
    textviews = [[NSMutableArray alloc] init];
    self.appIdTextView.delegate = self;
    self.appIdTextView.returnKeyType = UIReturnKeyDone;
    
    
    self.appIdTextView.text = appid2;
    self.appIdTextView.delegate = self;
    
    [_refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    [_refreshButton addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
//    NSMutableArray *configvals = [self makeRequest:_appIdTextView.text];
//    if (configvals == nil){
//        return;
//    }
//    [self deleteViews];
//    [self populateViews:configvals];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.appIdTextView resignFirstResponder];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextView *)textView
{
    CGRect frame = textView.frame;
    NSLog(@"frame y position: %f",frame.origin.y);
    frame.origin.y -= 170;
    textView.frame = frame;
}
- (void)textFieldDidEndEditing:(UITextView *)textView
{
    CGRect frame = textView.frame;
    NSLog(@"frame y position: %f",frame.origin.y);
    frame.origin.y += 170;
    textView.frame = frame;
}

-(void) buttonAction
{
    NSString *appid = _appIdTextView.text;
    NSMutableArray *configvals = [self makeRequest:appid];
    if (configvals == nil){
        return;
    }
    [self deleteViews];
    [self populateViews:configvals];
    
}
- (void) deleteViews
{
    for (UILabel *label in textviews){
        NSLog(@"inside deleteviews");
        [label removeFromSuperview];
    }
    [textviews removeAllObjects];
}
-(void) populateViews : (NSMutableArray *) configVals {
    int height = 20;
    for (DEXConfig *config in configVals) {
        NSString *toPrint = [NSString stringWithFormat:@"Key: %@    Value: %@",config.key,config.value];
        UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, height, 300, 40)];
        [yourLabel setTextColor:[UIColor blackColor]];
        [yourLabel setBackgroundColor:[UIColor clearColor]];
        [yourLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 10.0f]];
        [yourLabel setText:toPrint];
        [yourLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_BaseView addSubview:yourLabel];
        [textviews addObject:yourLabel];
        height += 20;
    }
}
- (NSMutableArray*) makeRequest : (NSString*) appid
{
    
    NSString *url = [NSString stringWithFormat:baseurl, appid];
//    
//    NSString *urlapp2 = @"https://usddev.azure-mobile.net/tables/ConfigDetails?$filter=appid+eq+'27e73a61-4a7b-4998-bb71-12a766b83f3a'";
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue: mobileServiceAppKey forHTTPHeaderField:@"X-ZUMO-APPLICATION"];
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&requestError];
    
   
    
    NSString *content = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    NSLog(@"Got response: %@", urlResponse);
    
    
    
    
    
    NSError *parseError = nil;
    
    
    
    
    NSArray *parsedArray = [NSJSONSerialization JSONObjectWithData:response options:0 error:&parseError];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (parsedArray.count == 0) {
        NSLog(@"No config vals parsed");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No config vals"
                                                        message:@"Check the app id and try again"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
        
    }
    parseError = nil;
    for (NSDictionary *groupDic in parsedArray) {
        NSString *configvals = [groupDic valueForKey:@"configvalues"];
        NSData * configdata = [configvals dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *configArray = [NSJSONSerialization JSONObjectWithData:configdata options:0 error:&parseError];
        for (NSDictionary *configDic in configArray){
            NSString *key = [configDic valueForKey:@"Key"];
            NSString *value = [configDic valueForKey:@"Value"];
            NSLog(@"Configvals: %@",configvals);
            NSLog(@"Key: %@  Value: %@", key, value);
            DEXConfig *thing = [[DEXConfig alloc] init];
            thing.key = key;
            thing.value = value;
            [result addObject:thing];
        }
        
    }
    
    
    return result;
    
}

@end
