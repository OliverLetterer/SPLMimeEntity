//
//  SPLMimeEntity.h
//  cashier
//
//  Created by Oliver Letterer on 17.03.14.
//  Copyright 2014 Sparrowlabs. All rights reserved.
//

/**
 OliverLetterer (oliver.letterer@gmail.com)
 ^               ^               ^
 label           mailbox         domain
 */
@interface SPLMailbox : NSObject

@property (nonatomic, readonly) NSString *mailbox;
@property (nonatomic, readonly) NSString *domain;
@property (nonatomic, readonly) NSString *label;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLMimeEntity : NSObject

- (NSString *)valueForHeaderKey:(NSString *)headerKey;



- (instancetype)initWithString:(NSString *)string;

// EML properties
@property (nonatomic, readonly) SPLMailbox *sender;
@property (nonatomic, readonly) NSArray *from;
@property (nonatomic, readonly) NSArray *to;

@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *timeStamp;
@property (nonatomic, readonly) NSString *contentType;

@property (nonatomic, readonly) NSArray *replyTo;
@property (nonatomic, readonly) NSArray *cc;
@property (nonatomic, readonly) NSArray *bcc;

@property (nonatomic, readonly) NSString *messageId;

@property (nonatomic, readonly) NSArray *bodyParts;

- (NSArray *)inlineBodyParts;
- (NSArray *)attachmentBodyParts;

// body part
@property (nonatomic, readonly) NSData *bodyData;
@property (nonatomic, readonly) NSString *filename;

@end
