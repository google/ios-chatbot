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

#import "CBSystemMessageCellComponent.h"

#import "CBSystemMessageCell.h"
#import "GILAttributedLabelComponent.h"
#import "GILDefines.h"

@implementation CBSystemMessageCellComponent

- (instancetype)initWithMessageComponent:(GILAttributedLabelComponent *)messageComponent
                         backgroundColor:(UIColor *)backgroundColor
                                 padding:(UIEdgeInsets)padding {
  self = [super init];
  if (self) {
    _messageComponent = [messageComponent copy];
    _backgroundColor = backgroundColor;
    _padding = padding;
  }
  return self;
}

#pragma mark - GILCellViewComponent

+ (Class)cellClass {
  return [CBSystemMessageCell class];
}

+ (NSString *)reuseIdentifier {
  return NSStringFromClass([self class]);
}

#pragma mark - GILViewComponent

+ (UIView *)view {
  CBPaddingCell *cell = [[CBPaddingCell alloc] init];
  cell.customView = [GILAttributedLabelComponent view];
  return cell;
}

+ (BOOL)updateView:(UIView *)view withComponent:(id<GILViewComponent>)component {
  CBPaddingCell *cell = (CBPaddingCell *)GILViewClassCast(view, [[self class] cellClass]);
  if (!cell) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  }

  CBSystemMessageCellComponent *cellComponent = GILViewComponentClassCast(component, [self class]);
  cell.backgroundColor = cellComponent.backgroundColor;
  cell.padding = cellComponent.padding;
  BOOL updated = [GILAttributedLabelComponent updateView:cell.customView
                                           withComponent:cellComponent.messageComponent];
  [cell setNeedsLayout];
  return updated;
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(id<GILViewComponent>)component {
  CBSystemMessageCellComponent *cellComponent = GILViewComponentClassCast(component, [self class]);
  if (!cellComponent) {
    return CGSizeZero;
  } else {
    static CBSystemMessageCell *messageCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      messageCell = [[CBSystemMessageCell alloc] init];
    });
    [[self class] updateView:messageCell withComponent:cellComponent];
    return [messageCell sizeThatFits:size];
  }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
  return self;
}

@end
