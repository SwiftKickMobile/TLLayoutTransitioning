//
//  TLIndexPathItem.m
//
//  Copyright (c) 2013 Tim Moose (http://tractablelabs.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TLIndexPathItem.h"

@implementation TLIndexPathItem

- (id)initWithIdentifier:(id)identifier sectionName:(NSString *)sectionName cellIdentifier:(NSString *)cellIdentifier data:(id)data
{
    if (self = [super init]) {
        _identifier = identifier;
        _sectionName = sectionName;
        _cellIdentifier = cellIdentifier;
        _data = data;
    }
    return self;
}

+ (NSString *)keyPathForDataKeyPath:(NSString *)dataKeyPath
{
    return [NSString stringWithFormat:@"data.%@", dataKeyPath];
}

+ (NSArray *)identifiersForIndexPathItems:(NSArray *)indexPathItems
{
    NSArray *identifiers = [indexPathItems valueForKeyPath:@"@distinctUnionOfObjects.identifier"];
    return identifiers;
}

- (NSUInteger)hash
{
    NSInteger hash = 0;
    hash += 31 * hash + [self.identifier hash];
    hash += 31 * hash + [self.sectionName hash];
    hash += 31 * hash + [self.cellIdentifier hash];
    if (self.shouldCompareData) {
        hash += 31 * hash + [self.data hash];
    }
    return hash;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) return YES;
    if (object == nil) return NO;
    if (![object isKindOfClass:[TLIndexPathItem class]]) return NO;
    TLIndexPathItem *other = (TLIndexPathItem *)object;
    if (![TLIndexPathItem nilSafeObject:self.identifier isEqual:other.identifier]) return NO;
    if (![TLIndexPathItem nilSafeObject:self.sectionName isEqual:other.sectionName]) return NO;
    if (![TLIndexPathItem nilSafeObject:self.cellIdentifier isEqual:other.cellIdentifier]) return NO;
    if (self.shouldCompareData) {
        if (![TLIndexPathItem nilSafeObject:self.data isEqual:other.data]) return NO;
    }
    return YES;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"sectionName=%@, identifier=%@", self.sectionName, self.identifier];
}

+ (BOOL) nilSafeObject:(NSObject *)object isEqual:(NSObject *)other
{
    if (object == nil && other == nil) return YES;
    if (object == nil || other == nil) return NO;
    return [object isEqual:other];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    // return nil instead of the default behavior of throwing an exception so that
    // items of this type can be mixed into data models that use an `identifierKeyPath`.
    return nil;
}

@end
