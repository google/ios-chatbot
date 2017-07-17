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

#import "GILVerticalStackViewAdapter.h"

#import "GILDefines.h"
#import "GILViewComponent.h"

@implementation GILVerticalStackViewAdapter {
  NSArray<Class> *_viewComponentClasses;
}

@synthesize managedViews = _managedViews;

- (instancetype)initWithViewComponentClasses:(NSArray<Class> *)classes {
  self = [super init];
  _viewComponentClasses = [classes copy];
  [self setUpManagedViewsWithClasses:(NSArray<Class> *)classes];
  return self;
}

- (instancetype)init {
  NSAssert(NO, @"Use the designated initializer instead.");
  return nil;
}

- (void)setViewComponents:(NSArray<id<GILViewComponent>> *)viewComponents {
  _viewComponents = viewComponents;
  if (![self verifyAndAssertInternalStateConsistencies]) {
    return;
  }

  [_viewComponentClasses enumerateObjectsUsingBlock:^(Class obj, NSUInteger idx, BOOL *stop) {
    UIView *view = self->_managedViews[idx];
    id<GILViewComponent> viewComponent = [self viewComponentAtIndex:idx];

    if ([obj respondsToSelector:@selector(updateView:withComponent:)]) {
      [obj updateView:view withComponent:viewComponent];
    } else {
      NSAssert(NO, @"Object does not respond to selector: %@",
               NSStringFromSelector(@selector(updateView:withComponent:)));
    }

  }];
}

#pragma mark - GMOReusableViewAdapter

- (void)layoutManagedViewsForSize:(CGSize)size {
  if (![self verifyAndAssertInternalStateConsistencies]) {
    return;
  }
  CGSize adjustedLayoutSize = [self paddingAdjustedLayoutSize:size];

  __block CGFloat currentOriginX = self.padding.left;
  __block CGFloat currentOriginY = self.padding.top;

  [_managedViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
    Class viewComponentClass = self->_viewComponentClasses[idx];

    CGSize layoutSize = CGSizeMake(adjustedLayoutSize.width, CGFLOAT_MAX);
    CGSize managedViewSize = CGSizeZero;
    if ([viewComponentClass respondsToSelector:@selector(sizeThatFits:forComponent:)]) {
      id<GILViewComponent> viewComponent = [self viewComponentAtIndex:idx];
      managedViewSize = [viewComponentClass sizeThatFits:layoutSize forComponent:viewComponent];
    } else {
      managedViewSize = [view sizeThatFits:layoutSize];
    }

    CGFloat managedViewWidth = GIL_CGFloatCeil(managedViewSize.width);
    CGFloat managedViewHeight = GIL_CGFloatCeil(managedViewSize.height);
    if (managedViewWidth > adjustedLayoutSize.width) {
      managedViewWidth = adjustedLayoutSize.width;
    }

    CGFloat adjustedOriginX = currentOriginX;
    if (self->_alignment == GILHorizontalAlignmentCenter && managedViewWidth < layoutSize.width) {
      adjustedOriginX += (layoutSize.width - managedViewWidth) / 2.0f;
    } else if (self->_alignment == GILHorizontalAlignmentRight &&
               managedViewWidth < layoutSize.width) {
      adjustedOriginX += layoutSize.width - managedViewWidth;
    }

    CGRect managedViewFrame = CGRectIntegral(
        CGRectMake(adjustedOriginX, currentOriginY, managedViewWidth, managedViewHeight));
    view.frame = managedViewFrame;

    if (self.clipToLayoutArea) {
      view.hidden = (CGRectGetMaxY(managedViewFrame) > adjustedLayoutSize.height);
    } else {
      // Since clipToLayoutArea is a read/write property, ensure the component views do not have a
      // state affected by the previous clipToLayoutArea state.
      view.hidden = NO;
    }
    if (!view.hidden && (NSInteger)CGRectGetHeight(managedViewFrame) > 0) {
      // Update the origin Y for the next view.
      currentOriginY += CGRectGetHeight(managedViewFrame);
      currentOriginY += self.componentSpacing;
    }
  }];
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (![self verifyAndAssertInternalStateConsistencies]) {
    return CGSizeZero;
  }
  CGSize adjustedLayoutSize = [self paddingAdjustedLayoutSize:size];

  __block NSUInteger visibleViewsCount = 0;
  __block CGFloat height = 0.0f;
  [_managedViews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
    Class viewComponentClass = self->_viewComponentClasses[idx];

    CGSize layoutSize = CGSizeMake(adjustedLayoutSize.width, CGFLOAT_MAX);
    CGSize managedViewSize = CGSizeZero;
    if ([viewComponentClass respondsToSelector:@selector(sizeThatFits:forComponent:)]) {
      id<GILViewComponent> viewComponent = [self viewComponentAtIndex:idx];
      managedViewSize = [viewComponentClass sizeThatFits:layoutSize forComponent:viewComponent];
    } else {
      managedViewSize = [view sizeThatFits:layoutSize];
    }

    CGFloat normalizedHeight = GIL_CGFloatCeil(managedViewSize.height);
    if ((NSInteger)normalizedHeight > 0) {
      height += normalizedHeight;
      // Only add spacing to the height if there are already visible views before this view.
      if (visibleViewsCount) {
        height += self.componentSpacing;
      }
      visibleViewsCount++;
    }
  }];

  height += (self.padding.top + self.padding.bottom);
  return CGSizeMake(size.width, height);
}

#pragma mark - Private helpers.

- (void)setUpManagedViewsWithClasses:(NSArray<Class> *)classes {
  NSMutableArray<UIView *> *managedViews = [NSMutableArray array];
  // NOTE(bobyliu): Since the adapter displays and orders the component views through a view model
  // driven manner, it always expects the same number of view components as the defined view
  // component classes. The adapter expects GILViewComponentNull be used to represent a nil
  // view component and explicitly enforces matching component class and component counts by using
  // debug build assertions.
  NSMutableArray<GILViewComponentNull *> *nullComponents = [NSMutableArray array];
  [classes enumerateObjectsUsingBlock:^(Class obj, NSUInteger idx, BOOL *stop) {
    if (![obj respondsToSelector:@selector(view)]) {
      NSAssert(NO, @"Class does not respond to selector: %@",
               NSStringFromSelector(@selector(view)));
      return;
    }
    UIView *view = [obj view];
    [managedViews addObject:view];
    [nullComponents addObject:[GILViewComponentNull null]];
  }];
  _managedViews = [managedViews copy];
  _viewComponents = [nullComponents copy];
}

- (CGSize)paddingAdjustedLayoutSize:(CGSize)size {
  CGFloat sizeHorizontalAdjust = self.padding.left + self.padding.right;
  CGFloat sizeVerticalAdjust = self.padding.top + self.padding.bottom;
  CGSize adjustedLayoutSize = size;
  adjustedLayoutSize.width -= sizeHorizontalAdjust;
  adjustedLayoutSize.height -= sizeVerticalAdjust;
  return adjustedLayoutSize;
}

- (BOOL)verifyAndAssertInternalStateConsistencies {
  if (_viewComponentClasses.count != _managedViews.count) {
    NSAssert(NO,
             @"Number of view component classes and managed views do not match due to regression.");
    return NO;
  }
  if (_viewComponentClasses.count != _viewComponents.count) {
    NSAssert(
        NO,
        @"Number of view component classes and view components do not match due to regression.");
    return NO;
  }
  return YES;
}

- (id<GILViewComponent>)viewComponentAtIndex:(NSUInteger)index {
  if (index >= _viewComponents.count) {
    return nil;
  }
  return _viewComponents[index];
}

@end
