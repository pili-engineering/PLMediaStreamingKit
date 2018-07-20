/*
 * Copyright (C) 2011 Michael Dippery <mdippery@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NSString+Random.h"
#include <stdlib.h>

#define DEFAULT_LENGTH  8

@implementation NSString (Randomized)

+ (NSString *)defaultAlphabet
{
    return @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
}

+ (id)randomizedString
{
    return [self randomizedStringWithAlphabet:[self defaultAlphabet]];
}

+ (id)randomizedStringWithAlphabet:(NSString *)alphabet
{
    return [self randomizedStringWithAlphabet:alphabet length:DEFAULT_LENGTH];
}

+ (id)randomizedStringWithAlphabet:(NSString *)alphabet length:(NSUInteger)len
{
    return [[self alloc] initWithAlphabet:alphabet length:len];
}

- (id)initWithDefaultAlphabet
{
    return [self initWithAlphabet:[NSString defaultAlphabet]];
}

- (id)initWithAlphabet:(NSString *)alphabet
{
    return [self initWithAlphabet:alphabet length:DEFAULT_LENGTH];
}

- (id)initWithAlphabet:(NSString *)alphabet length:(NSUInteger)len
{
    NSMutableString *s = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0U; i < len; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [NSString stringWithString:s];
}

@end
