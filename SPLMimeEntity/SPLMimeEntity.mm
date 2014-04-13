//
//  SPLMimeEntity.m
//  cashier
//
//  Created by Oliver Letterer on 17.03.14.
//  Copyright 2014 Sparrowlabs. All rights reserved.
//

#import "SPLMimeEntity.h"
#import <NSString+CTOpenSSL.h>

#include <iostream>
#include <mimetic/mimetic.h>

using namespace std;
using namespace mimetic;



@implementation SPLMailbox

- (instancetype)initWithMailbox:(const Mailbox &)mailbox
{
    if (self = [super init]) {
        if (mailbox.mailbox(0).length() > 0) {
            _mailbox = [NSString stringWithUTF8String:mailbox.mailbox(0).c_str()];
        }

        if (mailbox.domain(0).length() > 0) {
            _domain = [NSString stringWithFormat:@"%s", mailbox.domain(0).c_str()];
        }

        if (mailbox.label(0).length() > 0) {
            _label = [NSString stringWithUTF8String:mailbox.label(0).c_str()];
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: mailbox = %@, domain = %@, label = %@", [super description], self.mailbox, self.domain, self.label];
}

@end



@implementation SPLBodyPart

- (instancetype)initWithMimeEntitiy:(const MimeEntity &)mimeEntity
{
    if (self = [super init]) {
        _contentType = [NSString stringWithUTF8String:mimeEntity.header().contentType().str().c_str()];

        NSString *encoding = [NSString stringWithUTF8String:mimeEntity.header().contentTransferEncoding().str().c_str()];
        NSString *bodyString = [NSString stringWithUTF8String:mimeEntity.body().c_str()];

        if ([encoding.lowercaseString isEqualToString:@"base64"]) {
            _data = [bodyString dataFromBase64EncodedString];
        } else {
            _data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        }

        if (mimeEntity.header().hasField("Subject")) {
            _name = [NSString stringWithUTF8String:mimeEntity.header().subject().c_str()];
        }
    }
    return self;
}

- (NSString *)description
{
    NSStringEncoding encoding = [self.contentType rangeOfString:@"utf8"].location != NSNotFound ? NSUTF8StringEncoding : NSASCIIStringEncoding;

    NSString *string = [[NSString alloc] initWithData:_data encoding:encoding];
    NSString *substring = string.length > 100 ? [[string substringToIndex:100] stringByAppendingString:@"..."] : string;

    return [NSString stringWithFormat:@"%@[%@ - %@]: %@", [super description], self.name, self.contentType, substring];
}

@end



@interface SPLMimeEntity ()

@property (nonatomic, assign) MimeEntity mimeEntity;
@property (nonatomic, strong) NSString *string;

@end



@implementation SPLMimeEntity

#pragma mark - Initialization

- (instancetype)initWithMimeEntitiy:(const MimeEntity &)mimeEntitiy
{
    if (self = [super init]) {
        _mimeEntity = mimeEntitiy;

        _sender = [[SPLMailbox alloc] initWithMailbox:_mimeEntity.header().sender()];

        if (_mimeEntity.header().hasField("Subject")) {
            _subject = [NSString stringWithUTF8String:_mimeEntity.header().subject().c_str()];
        }

        if (_mimeEntity.header().messageid().str().length() > 0) {
            _messageId = [NSString stringWithUTF8String:_mimeEntity.header().messageid().str().c_str()];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity.header().from().begin();
            while (i != _mimeEntity.header().from().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:*i] ];
                ++i;
            }
            _from = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity.header().to().begin();
            while (i != _mimeEntity.header().to().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _to = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity.header().replyto().begin();
            while (i != _mimeEntity.header().replyto().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _replyTo = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity.header().cc().begin();
            while (i != _mimeEntity.header().cc().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _cc = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity.header().bcc().begin();
            while (i != _mimeEntity.header().bcc().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _bcc = [array copy];
        }

        _body = [NSString stringWithUTF8String:_mimeEntity.body().c_str()];

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity.body().parts().begin();
            while (i != _mimeEntity.body().parts().end()) {
                [array addObject:[[SPLBodyPart alloc] initWithMimeEntitiy:**i] ];
                ++i;
            }
            _bodyParts = [array copy];
        }
    }

    return self;
}

- (instancetype)initWithString:(NSString *)string
{
    if (!string) {
        return nil;
    }

    istringstream str(string.UTF8String);

    istreambuf_iterator<char> bit(str), eit;
    return [self initWithMimeEntitiy:MimeEntity(bit,eit)];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@: %@\n"
            "\t sender: %@\n"
            "\t from: %@\n"
            "\t to: %@\n"
            "\t replyTo: %@\n"
            "\t cc: %@\n"
            "\t bcc: %@\n\n"
            "\t bodyParts: %@"
            , [super description], self.subject, self.sender, self.from, self.to, self.replyTo, self.cc, self.bcc, self.bodyParts];
}

#pragma mark - Memory management

- (void)dealloc
{
    
}

#pragma mark - Private category implementation ()

@end
