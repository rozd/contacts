//
//  AddressBookProvider.m
//  Contacts
//
//  Created by Maxim on 9/9/13.
//  Copyright (c) 2013 Max Rozdobudko. All rights reserved.
//

#import <mach/mach_time.h>

#import "AddressBookProviderRoutines.h"

#import "AddressBookProvider.h"

@implementation AddressBookProvider

#pragma mark Properties

-(void) setAddressBook:(ABAddressBookRef)value
{
    _addressBook = value;
}

#pragma mark Main methods

-(BOOL) isModified:(NSDate *)since
{
    uint64_t start;
    uint64_t end;
    uint64_t elapsed;
    
    start = mach_absolute_time();
    
    BOOL result = FALSE;
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    
    NSLog(@"Since: %@", since);
    
    CFIndex n = CFArrayGetCount(people);
    for (int i = 0; i < n; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        CFDateRef creationDate = ABRecordCopyValue(person, kABPersonCreationDateProperty);
        CFDateRef modificationDate = ABRecordCopyValue(person, kABPersonModificationDateProperty);
        
        result = CFDateCompare(creationDate, (__bridge CFDateRef)(since), NULL) == kCFCompareGreaterThan ||
        CFDateCompare(modificationDate, (__bridge CFDateRef)(since), NULL) == kCFCompareGreaterThan;
        
        CFRelease(creationDate);
        CFRelease(modificationDate);
        
        if (result)
        {
            break;
        }
    }
    
    CFRelease(people);
    
    end = mach_absolute_time();
    
    elapsed = end - start;
    
    static mach_timebase_info_data_t info;
    
    mach_timebase_info(&info);
    
    uint64_t nanoseconds = elapsed * info.numer / info.denom;
    
    NSLog(@"isModified: before %llu, after %llu, time elapsed was: %llu", start, end, nanoseconds);
    
    return result;
}

-(NSArray*) getPeople:(NSRange)range withOptions:(NSDictionary *)options
{
    uint64_t start;
    uint64_t end;
    uint64_t elapsed;
    
    start = mach_absolute_time();

    NSMutableArray* result = [NSMutableArray array];
    
    if (range.location == NSNotFound)
        range.location = 0;
    
    if (range.length == NSNotFound)
        range.length = ABAddressBookGetPersonCount(_addressBook);
    
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(_addressBook);
    
    CFIndex n = NSMaxRange(range);
    for (int i = range.location; i < n; i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        NSDictionary* contact = [AddressBookProviderRoutines createContact:person];
        
        [result addObject:contact];
    }
    
    CFRelease(people);
    
    end = mach_absolute_time();
    
    elapsed = end - start;
    
    static mach_timebase_info_data_t info;
    
    mach_timebase_info(&info);
    
    uint64_t nanoseconds = elapsed * info.numer / info.denom;
    
    NSLog(@"getPeople: before %llu, after %llu, time elapsed was: %llu", start, end, nanoseconds);
    
    return result;
}

@end
