//
//  DCTDatePickerViewController.m
//  Climb Tracker
//
//  Created by Mike Abdullah on 08/12/2011.
//  Copyright (c) 2011 Karelia Software. All rights reserved.
//

#import "DCTDatePickerViewController.h"


@implementation DCTDatePickerViewController

- (NSDate *)date;
{
    return [datePicker date];
}
- (void)setDate:(NSDate *)date
{
    [self view];    // make sure it's loaded
    [datePicker setDate:date];
}

#pragma mark Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_formatter release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [self dateChanged:nil]; // make sure table & picker are up-to-date
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *fallsCellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:fallsCellIdentifier];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:fallsCellIdentifier] autorelease];
    }
    
    cell.textLabel.text = NSLocalizedString(@"Date", "cell title");
    
    if (!_formatter)
    {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateStyle = NSDateFormatterLongStyle;
        _formatter.timeStyle = NSDateFormatterShortStyle;
    }
    cell.detailTextLabel.text = [_formatter stringFromDate:self.date];
    
    
    return cell;
}

#pragma mark - Picker

- (void)dateChanged:(id)sender
{
    [tableView reloadData];
    [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

@end
