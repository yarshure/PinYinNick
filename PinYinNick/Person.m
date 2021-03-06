//  Created by Chen Yufei on 12-5-3.
//  Copyright (c) 2012. All rights reserved.

#import "Person.h"
#import "Hanzi2Pinyin/Hanzi2Pinyin.h"

@implementation Person

@synthesize nickName = _nickName;
@synthesize fullName = _fullName;
@synthesize fullNamePinyin = _fullNamePinyin;
@synthesize abPerson = _abPerson;
@synthesize modified = _modified;

- (id)initWithPerson:(ABPerson *)abPerson {
    self = [super init];
    if (self) {
        _modified = NO;
        if (!abPerson) {
            return self;
        }

        _abPerson = abPerson;
        _fullName = [Person fullNameForPerson:abPerson];
        _fullNamePinyin = [Hanzi2Pinyin convert:_fullName];
        _nickName = [abPerson valueForProperty:kABNicknameProperty];
        if (!_nickName) {
            _nickName = [Person pynickForPerson:abPerson fullName:_fullName];
            if (_nickName)
                _modified = YES;
        }
    }
    return self;
}

- (id)init {
    return [self initWithPerson:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Person fullName:%@ nickName:%@ modified:%d",
            _fullName, _nickName, _modified];
}

- (void)setNickName:(NSString *)nickName {
    if ([nickName isEqualToString:_nickName]) {
        return;
    }
    _nickName = nickName;
    
    [self willChangeValueForKey:@"modified"];
    _modified = YES;
    [self didChangeValueForKey:@"modified"];
}

+ (NSString *)fullNameForPerson:(ABPerson *)abPerson {
    NSString *firstName = [abPerson valueForProperty:kABFirstNameProperty];
    NSString *lastName = [abPerson valueForProperty:kABLastNameProperty];
    NSMutableString *fullName = [[NSMutableString alloc] initWithCapacity:10];
    if (lastName != nil) {
        [fullName appendString:lastName];
    }
    if (firstName != nil) {
        if (lastName == nil)
            [fullName appendString:firstName];
        else
            [fullName appendFormat:@" %@", firstName];
    }
    return [NSString stringWithString:fullName];
}

+ (NSString *)pynickForPerson:(ABPerson *)abPerson fullName:(NSString *)fullName {
    if (!fullName) {
        fullName = [self fullNameForPerson:abPerson];
    }
    fullName = [fullName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *pynick = [Hanzi2Pinyin convertToAbbreviation:fullName];
    // If the full name does not include Chinese, don't create nick
    if ([pynick isEqualToString:fullName]) {
        pynick = nil;
    }

    return pynick;
}

@end
