//
//  PYNickAppDelegate.m
//  PinYinNick
//
//  Created by 陈宇飞 on 12-4-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PYNickAppDelegate.h"
#import "Hanzi2Pinyin/Hanzi2Pinyin.h"

@implementation PYNickAppDelegate

@synthesize window = _window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib {
    // numberOfRowsInTableView will be called before applicationDidFinishLaunching.
    // So initialization should be done here.
    _ab = [ABAddressBook sharedAddressBook];
    NSArray *people = [_ab people];
    _people = [[NSMutableArray alloc] initWithCapacity:[people count]];
    
    for (ABPerson *person in people) {
        NSMutableString *fullName = [self fullNameForPerson:person];
        
        // If the person has nick name, use it. Otherwise, create pinyin nick
        NSString *nick = [person valueForProperty:kABNicknameProperty];
        BOOL modified = NO;
        if (!nick) {
            nick = [self pynickForPerson:person fullName:fullName];
            modified = [nick isEqualToString:@""] ? NO : YES;
        }

        NSArray *record = [[NSArray alloc] initWithObjects:person,
                           fullName,
                           nick,
                           [NSNumber numberWithBool:modified],
                           nil];
        [_people addObject:record];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tv {
    NSInteger count = [_people count];
//    NSLog(@"number of rows: %ld", count);
    return count;
}

- (NSMutableString *)fullNameForPerson:(ABPerson *)person {
    NSString *firstName = [person valueForProperty:kABFirstNameProperty];
    NSString *lastName = [person valueForProperty:kABLastNameProperty];
    NSMutableString *fullName = [[NSMutableString alloc] initWithCapacity:4];
    if (lastName != nil) {
        [fullName appendString:lastName];
    }
    if (firstName != nil) {
        if (lastName == nil)
            [fullName appendString:firstName];
        else
            [fullName appendFormat:@" %@", firstName];
    }
    return fullName;
}

- (NSMutableString *)pynickForPerson:(ABPerson *)person fullName:(NSString *)fullName {
    NSMutableString *pynick;
    
    if (!fullName) {
        fullName = [self fullNameForPerson:person];
    }
    pynick = [Hanzi2Pinyin convertToAbbreviation:fullName];
    // If the full name does not include Chinese, don't create nick
    if ([pynick isEqualToString:fullName]) {
        pynick = [NSMutableString stringWithString:@""];
    }

    return pynick;
}

- (id)tableView:(NSTableView *)tv objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
//    NSLog(@"%@ %ld", tableColumn, row);
    NSArray *record = [_people objectAtIndex:row];
    if ([[tableColumn identifier] isEqualToString:@"fullName"]) {
        return [record objectAtIndex:1];
    } else {
        return [record objectAtIndex:2];
    }
}

@end
