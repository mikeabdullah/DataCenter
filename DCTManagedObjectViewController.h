//
//  DCTManagedObjectViewController.h
//  DCTCoreDataBrowser
//
//  Created by Daniel Tull on 23.02.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface DCTManagedObjectViewController : UITableViewController <UITextFieldDelegate>
{
	NSArray *relationships;
	NSArray *attributes;
    NSUInteger _editingDateRow;
}

@property (nonatomic, retain) NSManagedObject *managedObject;

@property (nonatomic, retain, readonly) UITextField *textField;

@end
