//
//  SPLMimeEntity.m
//  cashier
//
//  Created by Oliver Letterer on 17.03.14.
//  Copyright 2014 Sparrowlabs. All rights reserved.
//

#import "SPLMimeEntity.h"

#include <iostream>
#include <mimetic/mimetic.h>

using namespace std;
using namespace mimetic;

inline NSString *MimeEntityGetHeaderValue(MimeEntity *mimeEntity, NSString *headerKey)
{
    if (mimeEntity->header().hasField(headerKey.UTF8String)) {
        return [NSString stringWithUTF8String:mimeEntity->header().field(headerKey.UTF8String).value().c_str()];
    }

    return nil;
}

static NSData *dataFromStringWithEncoding(NSString *bodyString, NSString *encoding)
{
    if ([encoding.lowercaseString isEqualToString:@"base64"]) {
        return [[bodyString dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    } else {
        if ([encoding rangeOfString:@"quoted-printable"].length > 0) {
            bodyString = [bodyString stringByReplacingOccurrencesOfString:@"=\r\n" withString:@""];
            bodyString = [bodyString stringByReplacingOccurrencesOfString:@"=" withString:@"%"];
            bodyString = [bodyString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }

        return [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    }
}



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



@interface SPLMimeEntity ()

@property (nonatomic, assign) MimeEntity *mimeEntity;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, assign) BOOL retainsOwnership;

@end



@implementation SPLMimeEntity

#pragma mark - Initialization

- (NSArray *)inlineBodyParts
{
    NSMutableArray *inlineBodyParts = [NSMutableArray array];

    for (SPLMimeEntity *bodyPart in self.bodyParts) {
        if (bodyPart.bodyParts.count > 0) {
            [inlineBodyParts addObjectsFromArray:bodyPart.inlineBodyParts];
        } else if ([[bodyPart valueForHeaderKey:@"Content-Disposition"].lowercaseString rangeOfString:@"attachment"].length == 0) {
            [inlineBodyParts addObject:bodyPart];
        }
    }

    return [inlineBodyParts copy];
}

- (NSArray *)attachmentBodyParts
{
    NSMutableArray *attachmentBodyParts = [NSMutableArray array];

    for (SPLMimeEntity *bodyPart in self.bodyParts) {
        if (bodyPart.bodyParts.count > 0) {
            [attachmentBodyParts addObjectsFromArray:bodyPart.attachmentBodyParts];
        } else if ([[bodyPart valueForHeaderKey:@"Content-Disposition"].lowercaseString rangeOfString:@"attachment"].length > 0) {
            [attachmentBodyParts addObject:bodyPart];
        }
    }

    return [attachmentBodyParts copy];
}

- (NSString *)filename
{
    NSString *contentDisposition = [self valueForHeaderKey:@"Content-Disposition"];
    if ([contentDisposition.lowercaseString rangeOfString:@"attachment"].length > 0) {
        for (__strong NSString *keyValuePairString in [contentDisposition componentsSeparatedByString:@";"]) {
            keyValuePairString = [keyValuePairString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray *keyValuePair = [keyValuePairString componentsSeparatedByString:@"="];

            if (keyValuePair.count == 2) {
                NSString *key = keyValuePair[0];
                NSString *value = keyValuePair[1];

                if ([key isEqual:@"filename"] || [key isEqual:@"name"]) {
                    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
                    [characterSet addCharactersInString:@"\""];
                    return [value stringByTrimmingCharactersInSet:characterSet];
                }
            }
        }
    }

    return nil;
}

- (instancetype)initWithMimeEntitiy:(MimeEntity *)mimeEntitiy retainOwnership:(BOOL)retainOwnership
{
    if (self = [super init]) {
        _mimeEntity = mimeEntitiy;
        _retainsOwnership = retainOwnership;

        _sender = [[SPLMailbox alloc] initWithMailbox:_mimeEntity->header().sender()];

        _subject = [self valueForHeaderKey:@"Subject"];
        _timeStamp = [self valueForHeaderKey:@"Date"];
        _messageId = [self valueForHeaderKey:@"Message-ID"];
        _contentType = [self valueForHeaderKey:@"Content-Type"];

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity->header().from().begin();
            while (i != _mimeEntity->header().from().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:*i] ];
                ++i;
            }
            _from = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity->header().to().begin();
            while (i != _mimeEntity->header().to().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _to = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity->header().replyto().begin();
            while (i != _mimeEntity->header().replyto().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _replyTo = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity->header().cc().begin();
            while (i != _mimeEntity->header().cc().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _cc = [array copy];
        }

        {
            NSMutableArray *array = [NSMutableArray array];
            auto i = _mimeEntity->header().bcc().begin();
            while (i != _mimeEntity->header().bcc().end()) {
                [array addObject:[[SPLMailbox alloc] initWithMailbox:i->mailbox()] ];
                ++i;
            }
            _bcc = [array copy];
        }

        _bodyData = dataFromStringWithEncoding([NSString stringWithUTF8String:_mimeEntity->body().c_str()], [self valueForHeaderKey:@"Content-Transfer-Encoding"]);

        {
            NSMutableArray *bodyParts = [NSMutableArray array];

            auto i = _mimeEntity->body().parts().begin();
            while (i != _mimeEntity->body().parts().end()) {
                [bodyParts addObject:[[SPLMimeEntity alloc] initWithMimeEntitiy:*i retainOwnership:NO] ];
                ++i;
            }

            _bodyParts = [bodyParts copy];
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

    return [self initWithMimeEntitiy:new MimeEntity(bit,eit) retainOwnership:YES];
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

- (NSString *)valueForHeaderKey:(NSString *)headerKey
{
    return MimeEntityGetHeaderValue(_mimeEntity, headerKey);
}

#pragma mark - Memory management

- (void)dealloc
{
    if (_mimeEntity && _retainsOwnership) {
        delete _mimeEntity, _mimeEntity = NULL;
    }
}

#pragma mark - Private category implementation ()

@end
