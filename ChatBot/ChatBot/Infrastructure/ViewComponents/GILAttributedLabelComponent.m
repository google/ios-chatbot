/*
 *
 * Copyright 2017, Google Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GILAttributedLabelComponent.h"

@implementation GILAttributedLabelComponent

- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString
                           numberOfLines:(NSInteger)numberOfLines
                           textAlignment:(NSTextAlignment)textAlignment
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         backgroundColor:(UIColor *)backgroundColor {
  self = [super init];
  if (self) {
    _attributedString = [attributedString copy];
    _numberOfLines = numberOfLines;
    _textAlignment = textAlignment;
    _lineBreakMode = lineBreakMode;
    _backgroundColor = backgroundColor;
  }
  return self;
}

- (instancetype)init {
  NSAssert(NO, @"Use the designated initializer instead.");
  return nil;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
  return self;
}

#pragma mark - GILViewComponent

+ (BOOL)updateView:(UIView *)view withComponent:(GILAttributedLabelComponent *)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if (![view isKindOfClass:[UILabel class]]) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  } else if ([component isKindOfClass:[GILViewComponentNull class]] || !component) {
    // NOTE(bobyliu): GILViewComponentNull is considered as nil. See GILViewComponentNull
    // for details.
    UILabel *label = (UILabel *)view;
    label.attributedText = nil;
    return YES;
  } else if (![component isKindOfClass:[GILAttributedLabelComponent class]]) {
    NSAssert(NO, @"Unexpected view component type.");
    return NO;
  } else {
    UILabel *label = (UILabel *)view;
    label.attributedText = component.attributedString;

    // NOTE(bobyliu): Properties such as lineBreakMode and textAlignment are overwritten after
    // the attributed text is set. Therefore, always set these properties last. Use the properties
    // specified on the view component to ensure logic consistency.
    label.numberOfLines = component.numberOfLines;
    label.textAlignment = component.textAlignment;
    label.lineBreakMode = component.lineBreakMode;
    label.backgroundColor = component.backgroundColor;

    return YES;
  }
}

+ (UIView *)view {
  return [[UILabel alloc] initWithFrame:CGRectZero];
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(id<GILViewComponent>)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  // NOTE(bobyliu): Temp logic to use a height calculation view. See TODO below for more details.
  // On the other hand, height calculation views may sometimes be good fits when used with height
  // caching logic in table views and collection views to reduce height calculation logic
  // complexity.
  static UILabel *heightCalculationLabel = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    heightCalculationLabel = [[UILabel alloc] init];
  });

  [self updateView:heightCalculationLabel withComponent:component];
  CGSize expectedSize = [heightCalculationLabel sizeThatFits:size];

  // TODO(bobyliu): sizeThatFits: on a view returns the 'best-fit' size based on its implementation.
  // It is observed that UILabel's 'best-fit' size when numberOfLines is set to 1 ignores the width
  // even if the lineBreakMode is set to truncating. An alternative will be laying out using
  // boundingRectWithSize:options:attributes:context: through NSString. However, this will be
  // evaluated alongside with the final logic for numberOfLines based on the intended behavior of
  // the design specs. Additional logic may be needed to consider numberOfLines and
  // maximumNumberOfLines differently.
  if (expectedSize.width > size.width) {
    expectedSize.width = size.width;
  }

  return expectedSize;
}

@end
