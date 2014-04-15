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

@interface SPLBodyPart : NSObject

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSString *contentType;
@property (nonatomic, readonly) NSData *data;

@end



/**
 @abstract  <#abstract comment#>
 */
@interface SPLMimeEntity : NSObject

@property (nonatomic, readonly) SPLMailbox *sender;
@property (nonatomic, readonly) NSArray *from;
@property (nonatomic, readonly) NSArray *to;

@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSString *timeStamp;

@property (nonatomic, readonly) NSArray *replyTo;
@property (nonatomic, readonly) NSArray *cc;
@property (nonatomic, readonly) NSArray *bcc;

@property (nonatomic, readonly) NSString *messageId;

@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSArray *bodyParts;

- (instancetype)initWithString:(NSString *)string;

@end
