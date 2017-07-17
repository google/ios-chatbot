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

#import "GILGridViewAdapter.h"

#import "GILDefines.h"

NSIndexPath *GILGridAdapterIndexPath(NSInteger row, NSInteger column) {
  return [NSIndexPath indexPathForItem:column inSection:row];
}

@implementation GILGridViewAdapter {
  GILGridViewItemViewSizeBlock _sizeBlock;
  NSInteger _rows;
  NSInteger _columns;
  CGFloat _itemViewSpacing;
}

@synthesize managedViews = _managedViews;

- (instancetype)initWithNumberNumberOfRows:(NSInteger)rows
                                   columns:(NSInteger)columns
                           itemViewSpacing:(CGFloat)itemViewSpacing
                                buildBlock:(GILGridViewItemViewBuildBlock)buildBlock
                                 sizeBlock:(GILGridViewItemViewSizeBlock)sizeBlock {
  self = [super init];
  if (self) {
    _sizeBlock = [sizeBlock copy];
    _rows = rows;
    _columns = columns;
    _itemViewSpacing = itemViewSpacing;
    [self setUpManagedViewsWithBuildBlock:buildBlock];
  }
  return self;
}

- (void)setUpManagedViewsWithBuildBlock:(GILGridViewItemViewBuildBlock)buildBlock {
  if (!buildBlock) {
    NSAssert(NO, @"Build block cannot be nil");
    return;
  }
  NSMutableArray<UIView *> *managedViews = [NSMutableArray array];
  for (NSInteger i = 0; i < _rows; i++) {
    for (NSInteger j = 0; j < _columns; j++) {
      NSIndexPath *indexPath = GILGridAdapterIndexPath(i, j);
      UIView *view = buildBlock(indexPath);
      if ([view isKindOfClass:[UIView class]]) {
        [managedViews addObject:view];
      } else {
        NSAssert(NO, @"Build block did return a valid view");
      }
    }
  }
  _managedViews = [managedViews copy];
}

- (UIView *)itemViewAtIndexPath:(NSIndexPath *)indexPath {
  NSInteger itemViewIndex = [self linearIndexForIndexPath:indexPath];
  if ((NSUInteger)itemViewIndex >= _managedViews.count) {
    return nil;
  }
  return _managedViews[itemViewIndex];
}

- (NSIndexPath *)indexPathForItemView:(UIView *)itemView {
  if (!itemView) {
    return nil;
  }

  NSInteger viewIndex = [_managedViews indexOfObject:itemView];
  return [self indexPathForLinearIndex:viewIndex];
}

- (nullable NSIndexPath *)indexPathForLinearIndex:(NSInteger)linearIndex {
  if (_rows <= 0 || _columns <= 0 || linearIndex == NSNotFound) {
    return nil;
  }
  NSInteger row = linearIndex / _columns;
  NSInteger column = linearIndex % _columns;
  return GILGridAdapterIndexPath(row, column);
}

- (NSInteger)linearIndexForIndexPath:(NSIndexPath *)indexPath {
  if (!indexPath) {
    return NSNotFound;
  }
  if (indexPath.section < 0 || indexPath.item < 0 || indexPath.section > _rows ||
      indexPath.item > _columns) {
    return NSNotFound;
  }
  return (indexPath.section * _columns) + indexPath.item;
}

#pragma mark - GILReusableViewAdapter

- (void)layoutManagedViewsForSize:(CGSize)size {
  CGSize adjustedLayoutSize = [self paddingAdjustedLayoutSize:size];
  CGFloat itemViewWidth = [self itemViewWidthForGridViewWidth:adjustedLayoutSize.width];
  CGFloat originX = _padding.left;
  CGFloat originY = _padding.top;
  for (NSInteger i = 0; i < _rows; i++) {
    CGFloat maxRowHeight = 0;
    for (NSInteger j = 0; j < _columns; j++) {
      UIView *itemView = [self itemViewAtIndexPath:GILGridAdapterIndexPath(i, j)];
      CGSize itemViewSize = [self sizeOfItemView:itemView forWidth:itemViewWidth];
      CGRect itemViewFrame = CGRectMake(originX, originY, itemViewSize.width, itemViewSize.height);
      // Normalize frame so the view is not drawn on to the pixel boundary.
      itemViewFrame = CGRectIntegral(itemViewFrame);
      maxRowHeight = GIL_CGFloatMax(maxRowHeight, CGRectGetHeight(itemViewFrame));
      itemView.frame = itemViewFrame;
      if (j != _columns - 1) {
        originX = CGRectGetMaxX(itemViewFrame) + _itemViewSpacing;
      } else {
        originX = _padding.left;
        originY += maxRowHeight + _itemViewSpacing;
      }
    }
  }
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGSize adjustedLayoutSize = [self paddingAdjustedLayoutSize:size];
  CGFloat height = 0;
  CGFloat itemViewWidth = [self itemViewWidthForGridViewWidth:adjustedLayoutSize.width];

  for (NSInteger i = 0; i < _rows; i++) {
    CGFloat maxRowHeight = 0;
    for (NSInteger j = 0; j < _columns; j++) {
      UIView *itemView = [self itemViewAtIndexPath:GILGridAdapterIndexPath(i, j)];
      CGSize itemViewSize = [self sizeOfItemView:itemView forWidth:itemViewWidth];
      // Normalize the height.
      CGFloat itemHeight = GIL_CGFloatCeil(itemViewSize.height);
      maxRowHeight = GIL_CGFloatMax(maxRowHeight, itemHeight);
      if (j == _columns - 1) {
        height += maxRowHeight;
      }
    }
  }

  height += (_rows - 1) * _itemViewSpacing;
  height += (self.padding.top + self.padding.bottom);
  return CGSizeMake(size.width, height);
}

#pragma mark - Helpers

- (CGFloat)itemViewWidthForGridViewWidth:(CGFloat)gridViewWidth {
  if (_rows <= 0 || _columns <= 0) {
    return 0.0f;
  }
  CGFloat availableWidthForItems = gridViewWidth - ((_columns - 1) * _itemViewSpacing);
  return availableWidthForItems / _columns;
}

- (CGSize)sizeOfItemView:(UIView *)itemView forWidth:(CGFloat)width {
  if (_sizeBlock) {
    return _sizeBlock(itemView, width, [self indexPathForItemView:itemView]);
  } else {
    return [itemView sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
  }
}

- (CGSize)paddingAdjustedLayoutSize:(CGSize)size {
  CGFloat sizeHorizontalAdjust = self.padding.left + self.padding.right;
  CGFloat sizeVerticalAdjust = self.padding.top + self.padding.bottom;
  CGSize adjustedLayoutSize = size;
  adjustedLayoutSize.width -= sizeHorizontalAdjust;
  adjustedLayoutSize.height -= sizeVerticalAdjust;
  return adjustedLayoutSize;
}

@end
