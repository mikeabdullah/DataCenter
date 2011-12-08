//
//  DCTManagedObjectViewController.m
//  DCTCoreDataBrowser
//
//  Created by Daniel Tull on 23.02.2011.
//  Copyright 2011 Daniel Tull. All rights reserved.
//

NSInteger const DCTManagedObjectViewControllerAttributeSection = 1;
NSInteger const DCTManagedObjectViewControllerRelationshipSection = 2;

#import "DCTManagedObjectViewController.h"

#import "DCTDatePickerViewController.h"
#import "DCTManagedObjectRelationshipsViewController.h"
#import "NSManagedObject+DCTNiceDescription.h"


@interface DCTManagedObjectViewController ()
@end

@implementation DCTManagedObjectViewController

@synthesize managedObject;

#pragma mark - NSObject

- (id)init {
	return [self initWithStyle:UITableViewStyleGrouped];
}

#pragma mark - UIViewController

- (void)viewDidLoad {	
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark - DCTManagedObjectViewController

- (void)setManagedObject:(NSManagedObject *)mo {
	
	NSManagedObject *oldManagedObject = managedObject;
	managedObject = [mo retain];
	[oldManagedObject release];
	
	NSEntityDescription *entity = [managedObject entity];
	
	self.title = [entity name];
	
	[relationships release];
	relationships = [[[entity relationshipsByName] allKeys] retain];
	
	[attributes release];
	attributes = [[[entity attributesByName] allKeys] retain];
	
	if ([self isViewLoaded])
		[self.tableView reloadData];
}

#pragma mark - Editing

@synthesize textField = _textField;
- (UITextField *)textField;
{
    if (!_textField)
    {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
    }
    return _textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *attrName = [attributes objectAtIndex:textField.tag];
    [self.managedObject setValue:textField.text forKey:attrName];
    [self.tableView reloadData];
    
    if ([self.managedObject.managedObjectContext save:NULL])
    {
        [textField removeFromSuperview];
    }
    
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == DCTManagedObjectViewControllerAttributeSection)
		return [attributes count];
	
	if (section == DCTManagedObjectViewControllerRelationshipSection)
		return [relationships count];
	
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if (section == DCTManagedObjectViewControllerAttributeSection)
		return @"Attributes";
	
	if (section == DCTManagedObjectViewControllerRelationshipSection)
		return @"Relationships";
	
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *AttributeIdentifier = @"AttributeIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AttributeIdentifier];
	
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:AttributeIdentifier] autorelease];
	
	
	if ((NSInteger)indexPath.section == DCTManagedObjectViewControllerAttributeSection) {
		
		NSString *attributeName = [attributes objectAtIndex:indexPath.row];
		
		cell.textLabel.text = attributeName;
		cell.detailTextLabel.text = [[managedObject valueForKey:attributeName] description];
		
		BOOL isDate = [[[managedObject.entity attributesByName] objectForKey:attributeName] attributeType] == NSDateAttributeType;
        
		cell.selectionStyle = (isDate ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone);
        cell.accessoryType = (isDate ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
	}
	
	if ((NSInteger)indexPath.section == DCTManagedObjectViewControllerRelationshipSection) {
		
		NSString *relationshipName = [relationships objectAtIndex:indexPath.row];
		
		cell.textLabel.text = relationshipName;
		
		NSRelationshipDescription *relationship = [[[self.managedObject entity] relationshipsByName] objectForKey:relationshipName];
		
		if ([relationship isToMany])
			cell.detailTextLabel.text = [NSString stringWithFormat:@"Many %@s", [[relationship destinationEntity] name]];
		else
			cell.detailTextLabel.text = [[managedObject valueForKey:relationshipName] dct_niceDescription];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ((NSInteger)indexPath.section == DCTManagedObjectViewControllerRelationshipSection) {
		
		NSString *relationshipName = [relationships objectAtIndex:indexPath.row];
		
		NSRelationshipDescription *relationship = [[[self.managedObject entity] relationshipsByName] objectForKey:relationshipName];
		
		if (![relationship isToMany]) {
			
			NSManagedObject *mo = [managedObject valueForKey:relationshipName];
			
			DCTManagedObjectViewController *vc = [[DCTManagedObjectViewController alloc] init];
			vc.managedObject = mo;
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			
		} else {
			
			DCTManagedObjectRelationshipsViewController *vc = [[DCTManagedObjectRelationshipsViewController alloc] init];
			vc.managedObject = self.managedObject;
			vc.relationship = relationship;
			[self.navigationController pushViewController:vc animated:YES];
			[vc release];
			
			
		}
		
	}
	else if (indexPath.section == DCTManagedObjectViewControllerAttributeSection)
    {
        NSString *attrName = [attributes objectAtIndex:indexPath.row];
		NSAttributeDescription *attribute = [[[self.managedObject entity] attributesByName] objectForKey:attrName];
		
        switch (attribute.attributeType)
        {
            case NSStringAttributeType:
            {
                UILabel *label = [[tv cellForRowAtIndexPath:indexPath] detailTextLabel];
                UITextField *textField = self.textField;
                textField.backgroundColor = label.backgroundColor;
                textField.text = label.text;
                textField.font = label.font;
                textField.textColor = label.textColor;
                
                CGRect frame = label.frame;
                frame.size.width = label.superview.bounds.size.width - frame.origin.x;
                textField.frame = frame;
                [label.superview addSubview:textField];
                
                textField.tag = indexPath.row;
                [textField becomeFirstResponder];
                break;
            }
                
            case NSDateAttributeType:
            {
                DCTDatePickerViewController *detail = [[DCTDatePickerViewController alloc] init];
                detail.date = [self.managedObject valueForKey:attrName];
                
                UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDate)];
                detail.navigationItem.rightBarButtonItem = save;
                [save release];
                
                [self.navigationController pushViewController:detail animated:YES];
                [detail release];
                
                _editingDateRow = indexPath.row;
            }
        }
    }
}

- (void)saveDate;
{
    NSString *attrName = [attributes objectAtIndex:_editingDateRow];
    
    [self.managedObject setValue:[(DCTDatePickerViewController *)self.navigationController.topViewController date]
                          forKey:attrName];
    
    [self.tableView reloadData];
}

#pragma mark - Lifecycle

- (void)dealloc {
	[attributes release], attributes = nil;
	[relationships release], relationships = nil;
	[managedObject release], managedObject = nil;
    [_textField release];
    
    [super dealloc];
}

@end
