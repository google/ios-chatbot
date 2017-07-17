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

#import "CBImageMessageCellComponent.h"

#import "CBChatBubbleView.h"
#import "CBImageMessageCell.h"
#import "GILDefines.h"
#import "GILWebImageView.h"

@implementation CBImageMessageCellComponent

- (instancetype)initWithImage:(UIImage *)image
                arrowPosition:(CBChatBubbleArrowPosition)arrowPosition
              backgroundColor:(UIColor *)backgroundColor
                  bubbleColor:(UIColor *)bubbleColor
                      padding:(UIEdgeInsets)padding
     maxBubbleWidthPercentage:(CGFloat)maxBubbleWidthPercentage
           imageViewSizeBlock:(GILViewSizeBlock)imageViewSizeBlock {
  self = [super init];
  if (self) {
    _image = image;
    _arrowPosition = arrowPosition;
    _backgroundColor = backgroundColor;
    _bubbleColor = bubbleColor;
    _padding = padding;
    _maxBubbleWidthPercentage = maxBubbleWidthPercentage;
    _imageViewSizeBlock = [imageViewSizeBlock copy];
  }
  return self;
}

- (instancetype)initWithImageName:(NSString *)imageName
                    arrowPosition:(CBChatBubbleArrowPosition)arrowPosition
                  backgroundColor:(UIColor *)backgroundColor
                      bubbleColor:(UIColor *)bubbleColor
                          padding:(UIEdgeInsets)padding
         maxBubbleWidthPercentage:(CGFloat)maxBubbleWidthPercentage
               imageViewSizeBlock:(GILViewSizeBlock)imageViewSizeBlock {
  self = [super init];
  if (self) {
    _imageName = [imageName copy];
    _arrowPosition = arrowPosition;
    _backgroundColor = backgroundColor;
    _bubbleColor = bubbleColor;
    _padding = padding;
    _maxBubbleWidthPercentage = maxBubbleWidthPercentage;
    _imageViewSizeBlock = [imageViewSizeBlock copy];
  }
  return self;
}

- (instancetype)initWithImageURL:(NSURL *)imageURL
                   arrowPosition:(CBChatBubbleArrowPosition)arrowPosition
                 backgroundColor:(UIColor *)backgroundColor
                     bubbleColor:(UIColor *)bubbleColor
                         padding:(UIEdgeInsets)padding
        maxBubbleWidthPercentage:(CGFloat)maxBubbleWidthPercentage
              imageViewSizeBlock:(GILViewSizeBlock)imageViewSizeBlock {
  self = [super init];
  if (self) {
    _imageURL = [imageURL copy];
    _arrowPosition = arrowPosition;
    _backgroundColor = backgroundColor;
    _bubbleColor = bubbleColor;
    _padding = padding;
    _maxBubbleWidthPercentage = maxBubbleWidthPercentage;
    _imageViewSizeBlock = [imageViewSizeBlock copy];
  }
  return self;
}

#pragma mark - GILCellViewComponent

+ (Class)cellClass {
  return [CBImageMessageCell class];
}

+ (NSString *)reuseIdentifier {
  return NSStringFromClass([self class]);
}

#pragma mark - GILViewComponent

+ (UIView *)view {
  CBImageMessageCell *cell = [[CBImageMessageCell alloc] init];
  return cell;
}

+ (BOOL)updateView:(UIView *)view withComponent:(id<GILViewComponent>)component {
  CBImageMessageCell *cell = (CBImageMessageCell *)GILViewClassCast(view, [[self class] cellClass]);
  if (!cell) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  }

  CBImageMessageCellComponent *cellComponent = GILViewComponentClassCast(component, [self class]);
  cell.backgroundColor = cellComponent.backgroundColor;
  cell.bubbleColor = cellComponent.bubbleColor;

  if (cellComponent.image) {
    [cell.imageView setImageURL:nil placehoderImage:nil];
    cell.imageView.image = cellComponent.image;
  } else if (cellComponent.imageName) {
    [cell.imageView setImageURL:nil placehoderImage:nil];
    cell.imageView.image = [UIImage imageNamed:cellComponent.imageName];
  } else if (cellComponent.imageURL) {
    [cell.imageView setImageURL:cellComponent.imageURL placehoderImage:nil];
  }

  [self updateSizingPropertiesOnView:view withComponent:component];

  [cell setNeedsLayout];
  return YES;
}

// NOTE(bobyliu): Separated out from updateView:withComponent: for size calculation purpose.
+ (BOOL)updateSizingPropertiesOnView:(UIView *)view withComponent:(id<GILViewComponent>)component {
  CBImageMessageCell *cell = (CBImageMessageCell *)GILViewClassCast(view, [[self class] cellClass]);
  if (!cell) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  }

  CBImageMessageCellComponent *cellComponent = GILViewComponentClassCast(component, [self class]);
  cell.arrowPosition = cellComponent.arrowPosition;
  cell.padding = cellComponent.padding;
  cell.maxBubbleWidthPercentage = cellComponent.maxBubbleWidthPercentage;
  cell.messageBubbleView.contentViewSizeBlock = cellComponent.imageViewSizeBlock;

  return YES;
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(id<GILViewComponent>)component {
  CBImageMessageCellComponent *cellComponent = GILViewComponentClassCast(component, [self class]);
  if (!cellComponent) {
    return CGSizeZero;
  } else {
    static CBImageMessageCell *messageCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      messageCell = [[CBImageMessageCell alloc] init];
    });
    [self updateSizingPropertiesOnView:messageCell withComponent:component];
    return [messageCell sizeThatFits:size];
  }
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
  return self;
}

@end
