# SPLMimeEntity

Objective-C binding to [mimetic](http://www.codesink.org/mimetic_mime_library.html) for parsing eml files.

## Installation

```ruby
pod 'SPLMimeEntity', '~> 1.0'
```

## Usage

``` objc
NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sample" ofType:@"eml"]];
SPLMimeEntity *mimeEntity = [[SPLMimeEntity alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
```

## Public interface

``` objc
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



@interface SPLMimeEntity : NSObject

@property (nonatomic, readonly) SPLMailbox *sender;
@property (nonatomic, readonly) NSArray *from;
@property (nonatomic, readonly) NSArray *to;

@property (nonatomic, readonly) NSString *subject;
@property (nonatomic, readonly) NSArray *replyTo;
@property (nonatomic, readonly) NSArray *cc;
@property (nonatomic, readonly) NSArray *bcc;

@property (nonatomic, readonly) NSString *messageId;

@property (nonatomic, readonly) NSString *body;
@property (nonatomic, readonly) NSArray *bodyParts;

- (instancetype)initWithString:(NSString *)string;

@end
```

## Contact
Oliver Letterer

- http://github.com/OliverLetterer
- http://twitter.com/oletterer

## License
SPLMimeEntity is available under the MIT license. See the LICENSE file for more information.
