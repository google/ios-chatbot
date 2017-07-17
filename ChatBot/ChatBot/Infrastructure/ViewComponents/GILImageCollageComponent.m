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

#import "GILImageCollageComponent.h"

#import "GILImageCollageView.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * The number of image views that will be created in the image collage.
 * NOTE(bobyliu): Since the collage separates view creation and data binding, a predetermined
 * number of images is needed for performance considerations.
 */
static NSInteger const kMaximumNumberOfImagesToDisplay = 3;

@implementation GILImageCollageComponent

- (instancetype)initWithImageURLs:(nullable NSArray<NSURL *> *)imageURLs
                imagesContentMode:(UIViewContentMode)imagesContentMode
          numberOfImagesToDisplay:(NSInteger)numberOfImagesToDisplay
                  backgroundColor:(nullable UIColor *)backgroundColor
                        sizeBlock:(GILViewComponentSizeBlock)sizeBlock {
  self = [super init];
  if (self) {
    _imageURLs = [imageURLs copy];
    _imagesContentMode = imagesContentMode;
    _numberOfImagesToDisplay = numberOfImagesToDisplay;
    _backgroundColor = backgroundColor;
    NSAssert(numberOfImagesToDisplay <= kMaximumNumberOfImagesToDisplay,
             @"Update kMaximumNumberOfImagesToDisplay to allow more images in the collage.");
    _sizeBlock = [sizeBlock copy];
  }
  return self;
}

- (nullable instancetype)init {
  NSAssert(NO, @"Use the designated initializer instead.");
  return nil;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
  return self;
}

#pragma mark - GILViewComponent

+ (BOOL)updateView:(UIView *)view withComponent:(nullable GILImageCollageComponent *)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if (![view isKindOfClass:[GILImageCollageView class]]) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  } else if ([component isKindOfClass:[GILViewComponentNull class]] || !component) {
    // NOTE(bobyliu): GILViewComponentNull is considered as nil. See GILViewComponentNull
    // for details.
    GILImageCollageView *collageView = (GILImageCollageView *)view;
    collageView.imageURLs = nil;
    return YES;
  } else if (![component isKindOfClass:[GILImageCollageComponent class]]) {
    NSAssert(NO, @"Unexpected view component type.");
    return NO;
  } else {
    GILImageCollageView *collageView = (GILImageCollageView *)view;
    GILImageCollageComponent *collageComponent = (GILImageCollageComponent *)component;
    collageView.imageURLs = collageComponent.imageURLs;
    collageView.numberOfImagesToDisplay = collageComponent.numberOfImagesToDisplay;
    collageView.backgroundColor = collageComponent.backgroundColor;
    return YES;
  }
}

+ (UIView *)view {
  return [[GILImageCollageView alloc]
             initWithMaximumNumberOfImages:kMaximumNumberOfImagesToDisplay];
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(nullable GILImageCollageComponent *)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if ([component isKindOfClass:[GILViewComponentNull class]] || !component) {
    return CGSizeZero;
  } else if (![component isKindOfClass:[GILImageCollageComponent class]]) {
    NSAssert(NO, @"Unexpected view component type.");
    return CGSizeZero;
  } else {
    // NOTE(bobyliu): GILViewComponentNull is considered as nil. See GILViewComponentNull
    // for details. Let the provider decide what to do for GILViewComponentNull as the
    // the expected behaviors is context dependent.
    GILImageCollageComponent *collageComponent = (GILImageCollageComponent *)component;
    if (!collageComponent.sizeBlock) {
      NSAssert(NO, @"Component does not have a size block.");
      return CGSizeZero;
    } else {
      return collageComponent.sizeBlock(size, collageComponent);
    }
  }
}

@end

NS_ASSUME_NONNULL_END
