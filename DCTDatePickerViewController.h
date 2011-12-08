//
//  DCTDatePickerViewController.h
//  Climb Tracker
//
//  Created by Mike Abdullah on 08/12/2011.
//  Copyright (c) 2011 Karelia Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DCTDatePickerViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView    *tableView;
    IBOutlet UIDatePicker   *datePicker;
    
@private
    NSDateFormatter *_formatter;
}

@property(nonatomic, copy) NSDate *date;

- (IBAction)dateChanged:(id)sender;

@end
