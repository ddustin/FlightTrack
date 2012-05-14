

#import <Foundation/Foundation.h>


@interface XmlParser : NSObject<NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableDictionary *result;

/// non-nil means an error occured.
@property (nonatomic, retain) NSError *parserError;

- (BOOL)parseUrl:(NSURL*)url;
- (BOOL)parseData:(NSData*)data;
- (BOOL)parseStream:(NSInputStream*)stream;

/// Given an array of NSStrings, we traverse down the result
/// dictionary tree and return what's found.  If nothing
/// is found we return nil.  Depending on the node, you might
/// get a NSString or a NSDictionary.
///
/// Example:
/// 
/// NSString *str =
/// @"<Bob>"
/// @"   <Jane>Dancing</Jane>"
/// @"</Bob>";
/// 
/// XmlParser *parser = [XmlParser new];
/// 
/// [parser parseData:[str dataUsingEncoding:NSUTF8StringEncoding]];
/// 
/// NSString *str = queryXmlResult(parser, @"Bob", @"Jane");
/// 
/// if([str isEqual:@"Dancing"])
///     NSLog(@"str == Dancing");
- (id)queryResult:(NSArray*)nodeNames;

#define queryXmlResult(xmlParser, ...) ([(xmlParser) queryResult:[NSArray arrayWithObjects:__VA_ARGS__, nil]])

@end
