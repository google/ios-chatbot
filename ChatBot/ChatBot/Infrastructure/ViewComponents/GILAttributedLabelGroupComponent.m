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

#import "GILAttributedLabelGroupComponent.h"

#import "GILAttributedLabelComponent.h"
#import "GILReusableView.h"
#import "GILVerticalStackViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

static const NSUInteger kMaximumLabelsCount = 5;

static NSArray<Class> *componentClasses(NSUInteger labelsCount) {
  Class attributedLabelComponent = [GILAttributedLabelComponent class];
  NSMutableArray<Class> *componentClasses = [NSMutableArray array];
  for (NSUInteger i = 0; i < labelsCount; i++) {
    [componentClasses addObject:attributedLabelComponent];
  }
  return [componentClasses copy];
}

static NSArray<GILAttributedLabelComponent *> *adjustedViewComponents(
    NSArray<GILAttributedLabelComponent *> *viewComponents) {
  if (viewComponents.count >= kMaximumLabelsCount) {
    NSCAssert(NO, @"More view components than expected. If this is intended, update the maximum labels "
            @"counts constant.");
  }

  NSMutableArray<id<GILViewComponent>> *adjustedViewComponents = [NSMutableArray array];
  for (NSUInteger i = 0; i < kMaximumLabelsCount; i++) {
    if (i < viewComponents.count) {
      [adjustedViewComponents addObject:viewComponents[i]];
    } else {
      [adjustedViewComponents addObject:[GILViewComponentNull null]];
    }
  }
  return [adjustedViewComponents copy];
}

@implementation GILAttributedLabelGroupComponent

- (instancetype)initWithViewComponents:(NSArray<GILAttributedLabelComponent *> *)viewComponents
                      componentSpacing:(CGFloat)componentSpacing
                               padding:(UIEdgeInsets)padding
                             alignment:(GILHorizontalAlignment)alignment
                      clipToLayoutArea:(BOOL)clipToLayoutArea
                       backgroundColor:(nullable UIColor *)backgroundColor
                             sizeBlock:(nullable GILViewComponentSizeBlock)sizeBlock {
  self = [super init];
  if (self) {
    _viewComponents = adjustedViewComponents(viewComponents);
    _componentSpacing = componentSpacing;
    _padding = padding;
    _clipToLayoutArea = clipToLayoutArea;
    _alignment = alignment;
    _backgroundColor = backgroundColor;
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

+ (BOOL)updateView:(UIView *)view
     withComponent:(nullable GILAttributedLabelGroupComponent *)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if (![view isKindOfClass:[GILReusableView class]]) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  } else if ([component isKindOfClass:[GILViewComponentNull class]] || !component) {
    return YES;
  } else if (![component isKindOfClass:[GILAttributedLabelGroupComponent class]]) {
    NSAssert(NO, @"Unexpected view component type.");
    return NO;
  } else {
    GILReusableView *reusableView = (GILReusableView *)view;
    GILVerticalStackViewAdapter *adapter = (GILVerticalStackViewAdapter *)reusableView.adapter;
    adapter.viewComponents = component.viewComponents;
    adapter.componentSpacing = component.componentSpacing;
    adapter.padding = component.padding;
    adapter.clipToLayoutArea = component.clipToLayoutArea;
    view.backgroundColor = component.backgroundColor;

    [view setNeedsLayout];
    return YES;
  }
}

+ (UIView *)view {
  GILVerticalStackViewAdapter *adapter = [[GILVerticalStackViewAdapter alloc]
      initWithViewComponentClasses:componentClasses(kMaximumLabelsCount)];
  GILReusableView *reusableView = [[GILReusableView alloc] initWithAdapter:adapter];

  return reusableView;
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(nullable id<GILViewComponent>)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if ([component isKindOfClass:[GILViewComponentNull class]] || !component) {
    return CGSizeZero;
  }

  if (![component isKindOfClass:[GILAttributedLabelGroupComponent class]]) {
    NSAssert(NO, @"Unexpected component type.");
    return CGSizeZero;
  }

  GILAttributedLabelGroupComponent *groupComponent = (GILAttributedLabelGroupComponent *)component;
  if (groupComponent.sizeBlock) {
    return groupComponent.sizeBlock(size, groupComponent);
  }

  // TODO(bobyliu): Implement a size cache.
  static GILVerticalStackViewAdapter *heightCalcuationAdapter = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    heightCalcuationAdapter =
        [[GILVerticalStackViewAdapter alloc]
            initWithViewComponentClasses:componentClasses(kMaximumLabelsCount)];
  });

  heightCalcuationAdapter.viewComponents = groupComponent.viewComponents;
  heightCalcuationAdapter.componentSpacing = groupComponent.componentSpacing;
  heightCalcuationAdapter.padding = groupComponent.padding;
  heightCalcuationAdapter.clipToLayoutArea = groupComponent.clipToLayoutArea;

  return [heightCalcuationAdapter sizeThatFits:size];
}

@end

NS_ASSUME_NONNULL_END
