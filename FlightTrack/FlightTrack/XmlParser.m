#import "XmlParser.h"


@interface XmlParser ()

/// The current parsing position.
@property (nonatomic, retain) NSMutableArray *nodeNames;

- (id)pushNode:(id)newName attributes:(NSDictionary*)attributes to:(id)object;
- (id)setCurrentNodeTo:(id)object;
- (void)popNode;

@end

@implementation XmlParser

@synthesize result, parserError;
@synthesize nodeNames;

- (void)dealloc {
    
    self.result = nil;
    self.parserError = nil;
    
    [super dealloc];
}

- (NSMutableArray*)nodeNames {
    
    if(!nodeNames)
        nodeNames = [NSMutableArray new];
    
    return nodeNames;
}

- (NSMutableDictionary*)result {
    
    if(!result)
        result = [NSMutableDictionary new];
    
    return result;
}

- (id)getNode {
    
    NSMutableDictionary *ptr = self.result;
    
    for(id key in self.nodeNames)
        ptr = [ptr objectForKey:key];
    
    return ptr;
}

/// Returns object again
- (id)pushNode:(id)newName attributes:(NSDictionary *)attributes to:(id)object {
    
    NSMutableDictionary *ptr = self.result;
    
    for(id key in self.nodeNames)
        ptr = [ptr objectForKey:key];
    
    // If the parent node has text, erase it and restart.
    if([ptr isKindOfClass:[NSMutableString class]]) {
        
        [self setCurrentNodeTo:[NSMutableDictionary dictionary]];
        
        return [self pushNode:newName attributes:attributes to:object];
    }
    
    NSMutableArray *array = [ptr objectForKey:newName];
    
    if(!array) {
        
        [ptr setObject:attributes forKey:newName];
    }
    else {
        
        if(![array isKindOfClass:NSArray.class])
            array = [NSMutableArray arrayWithObject:array];
        
        [array addObject:attributes];
        
        [ptr setObject:array forKey:newName];
    }
    
    [self.nodeNames addObject:newName];
    
    return object;
}

/// Returns object again
- (id)setCurrentNodeTo:(id)object {
    
    NSMutableDictionary *ptr = self.result;
    
    for(int i = 0; i < [self.nodeNames count]; i++) {
        
        id key = [self.nodeNames objectAtIndex:i];
        
        if(i == [self.nodeNames count] - 1)
            [ptr setObject:object forKey:key];
        else
            ptr = [ptr objectForKey:key];
    }
    
    return object;
}

- (void)popNode {
    
    if([self.nodeNames count])
        [self.nodeNames removeLastObject];
}

- (void)reset {
    
    self.parserError = nil;
    self.result = nil;
}

- (BOOL)parse:(NSXMLParser*)parser {
    
    [self reset];
    
    parser.delegate = self;
    
    BOOL ret = [parser parse];
    
    self.parserError = parser.parserError;
    
    return ret;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    [self pushNode:elementName attributes:attributeDict to:[NSMutableDictionary dictionary]];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    id object = [self getNode];
    
    if(![object isKindOfClass:[NSMutableString class]]) {
        
        if([object isKindOfClass:[NSMutableDictionary class]]) {
            
            // If this node has kids, ignore these characters.
            if([(NSDictionary*)object count])
                return;
        }
        
        object = [self setCurrentNodeTo:[NSMutableString string]];
    }
    
    [(NSMutableString*)object appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    [self popNode];
}

- (BOOL)parseUrl:(NSURL*)url {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    
    BOOL ret = [self parse:parser];
    
    [parser release];
    
    return ret;
}

- (BOOL)parseData:(NSData*)data {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    
    BOOL ret = [self parse:parser];
    
    [parser release];
    
    return ret;
}

- (BOOL)parseStream:(NSInputStream*)stream {
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithStream:stream];
    
    BOOL ret = [self parse:parser];
    
    [parser release];
    
    return ret;
}

- (id)queryResult:(NSArray*)nodeNamesQuery {
    
    id ret = self.result;
    
    for(NSString *nodeName in nodeNamesQuery) {
        
        if(![ret isKindOfClass:[NSDictionary class]])
            return nil;
        
        ret = [ret objectForKey:nodeName];
    }
    
    return ret;
}

@end
