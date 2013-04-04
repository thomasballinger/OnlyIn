//
//  Address+Additions.m
//  MultiContactsSelector
//
//  Created by Sergio on 19/01/12.
//  Copyright (c) 2012 Sergio. All rights reserved.
//

#import "Address+Additions.h"
#import <AddressBook/AddressBook.h>

@implementation NSObject (RecordID)

+ (ABRecordRef)infoWithRecordID:(NSInteger)recordID
{
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	
    ABRecordRef person = NULL;
	for (int i = 0; i < nPeople; i++)
	{
		person = CFArrayGetValueAtIndex(allPeople, i);
        
        int currentID = (int)ABRecordGetRecordID(person);
        
        if (currentID == recordID) 
            break;
    }

    return person;
}

+ (NSArray *)getAllRecordIDs
{
    NSMutableArray *items = [NSMutableArray new];
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL,&error);	CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople( addressBook );
	CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
	
	for (int i = 0; i < nPeople; i++)
	{
		ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        int recordID = (int)ABRecordGetRecordID(person);
        
        [items addObject:[NSNumber numberWithInt:recordID]];
    }
    
    return (NSArray *)items;
}

@end
