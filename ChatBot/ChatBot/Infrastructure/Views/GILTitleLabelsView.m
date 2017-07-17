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

#import "GILTitleLabelsView.h"

#import "GILDefines.h"

static const CGFloat kLabelsVerticalSpacing = 4.0f;

@implementation GILTitleLabelsView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self GIL_commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
    [self GIL_commonInit];
  }
  return self;
}

- (void)GIL_commonInit {
  _title = [[UILabel alloc] initWithFrame:CGRectZero];
  [self addSubview:_title];
  _subtitle = [[UILabel alloc] initWithFrame:CGRectZero];
  [self addSubview:_subtitle];
  _primaryAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];
  [self addSubview:_primaryAccessoryView];
  _secondaryAccessoryView = [[UIView alloc] initWithFrame:CGRectZero];
  [self addSubview:_secondaryAccessoryView];
  _titleLabelsSpacing = kLabelsVerticalSpacing;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGRect layoutArea =
      CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
  layoutArea = UIEdgeInsetsInsetRect(layoutArea, self.padding);
  CGRect remainLayoutArea = layoutArea;

  // Calculate the size of the primary accessory view.
  CGSize primaryAccessoryViewSize = CGSizeZero;
  if (self.primaryAccessoryViewSizeBlock) {
    primaryAccessoryViewSize =
        self.primaryAccessoryViewSizeBlock(layoutArea.size, self.primaryAccessoryView);
  }

  // If the primary accessory view is visible, account for the spacing between the accessory view
  // and the labels.
  CGRect primaryAccessoryViewFrame = CGRectZero;
  if ((NSInteger)primaryAccessoryViewSize.width > 0 &&
      (NSInteger)primaryAccessoryViewSize.height > 0) {
    CGRectDivide(remainLayoutArea, &primaryAccessoryViewFrame, &remainLayoutArea,
                 primaryAccessoryViewSize.width, CGRectMinXEdge);
    primaryAccessoryViewFrame.size = primaryAccessoryViewSize;
    // Adjust for spacing between the primary accessory view and the titles.
    remainLayoutArea.origin.x += self.primaryAccessoryViewLabelsSpacing;
    remainLayoutArea.size.width -= self.primaryAccessoryViewLabelsSpacing;
  }

  // Calculate the size of the secondary accessory view.
  CGSize secondaryAccessoryViewSize = CGSizeZero;
  if (self.secondaryAccessoryViewSizeBlock) {
    secondaryAccessoryViewSize =
        self.secondaryAccessoryViewSizeBlock(layoutArea.size, self.secondaryAccessoryView);
  }

  // If the secondary accessory view is visible, account for the spacing between the accessory view
  // and the labels.
  CGRect titlesLayoutArea = remainLayoutArea;
  CGRect secondaryAccessoryViewFrame = CGRectZero;
  if ((NSInteger)secondaryAccessoryViewSize.width > 0 &&
      (NSInteger)secondaryAccessoryViewSize.height > 0) {
    CGFloat titlesAreaAvailableWidth = CGRectGetWidth(remainLayoutArea) -
                                       secondaryAccessoryViewSize.width -
                                       self.secondaryAccessoryViewLabelsSpacing;
    CGRectDivide(remainLayoutArea, &titlesLayoutArea, &secondaryAccessoryViewFrame,
                 titlesAreaAvailableWidth, CGRectMinXEdge);
    // Adjust for spacing between titles and the secondary accessory view.
    secondaryAccessoryViewFrame.origin.x += self.secondaryAccessoryViewLabelsSpacing;
    secondaryAccessoryViewFrame.size = secondaryAccessoryViewSize;
  }

  // Layout the title label.
  CGRect titleFrame = CGRectZero;
  CGSize titleSize = [self.title sizeThatFits:titlesLayoutArea.size];
  CGRectDivide(titlesLayoutArea, &titleFrame, &titlesLayoutArea, titleSize.height, CGRectMinYEdge);

  if ((NSInteger)titleSize.height > 0) {
    titlesLayoutArea.origin.y += _titleLabelsSpacing;
    titlesLayoutArea.size.height -= _titleLabelsSpacing;
  }
  // Layout the subtitle label.
  CGRect subtitleFrame = CGRectZero;
  CGSize subtitleSize = [self.subtitle sizeThatFits:titlesLayoutArea.size];
  if ((NSInteger)subtitleSize.height > 0) {
    CGRectDivide(titlesLayoutArea, &subtitleFrame, &titlesLayoutArea, subtitleSize.height,
                 CGRectMinYEdge);
  }

  // Vertically center the accessory views and labels in the layout area that excludes the padding.
  CGFloat originYOffset =
      (CGRectGetHeight(layoutArea) - CGRectGetHeight(primaryAccessoryViewFrame)) / 2.0f;
  primaryAccessoryViewFrame.origin.y += originYOffset;

  CGFloat labelsHeight = CGRectGetHeight(titleFrame) + CGRectGetHeight(subtitleFrame);
  if ((NSInteger)CGRectGetHeight(titleFrame) > 0 && (NSInteger)CGRectGetHeight(subtitleFrame) > 0) {
    labelsHeight += _titleLabelsSpacing;
  }
  originYOffset = (CGRectGetHeight(layoutArea) - labelsHeight) / 2.0f;
  titleFrame.origin.y += originYOffset;
  subtitleFrame.origin.y += originYOffset;

  originYOffset =
      (CGRectGetHeight(layoutArea) - CGRectGetHeight(secondaryAccessoryViewFrame)) / 2.0f;
  secondaryAccessoryViewFrame.origin.y += originYOffset;

  self.primaryAccessoryView.frame = CGRectIntegral(primaryAccessoryViewFrame);
  self.title.frame = CGRectIntegral(titleFrame);
  self.subtitle.frame = CGRectIntegral(subtitleFrame);
  self.secondaryAccessoryView.frame = CGRectIntegral(secondaryAccessoryViewFrame);
}

- (CGSize)sizeThatFits:(CGSize)size {
  CGFloat height = 0.0f;

  CGSize layoutSize = size;
  layoutSize.width -= self.padding.left + self.padding.right;
  layoutSize.height -= self.padding.top + self.padding.bottom;

  // Calculate the primary accessory view size.
  CGSize primaryAccessoryViewSize = CGSizeZero;
  if (self.primaryAccessoryViewSizeBlock) {
    primaryAccessoryViewSize =
        self.primaryAccessoryViewSizeBlock(layoutSize, self.primaryAccessoryView);
  }

  // Calculate the secondary accessory view size.
  CGSize secondaryAccessoryViewSize = CGSizeZero;
  if (self.secondaryAccessoryViewSizeBlock) {
    secondaryAccessoryViewSize =
        self.secondaryAccessoryViewSizeBlock(layoutSize, self.secondaryAccessoryView);
  }

  CGFloat layoutWidthForLabels = layoutSize.width;

  CGFloat primaryAccessoryAreaHeight = 0.0f;
  if ((NSInteger)primaryAccessoryViewSize.width > 0 && (NSInteger)primaryAccessoryViewSize.height) {
    layoutWidthForLabels -= primaryAccessoryViewSize.width + self.primaryAccessoryViewLabelsSpacing;
    primaryAccessoryAreaHeight =
        primaryAccessoryViewSize.height + self.padding.top + self.padding.bottom;
  }

  CGFloat secondaryAccessoryAreaHeight = 0.0f;
  if ((NSInteger)secondaryAccessoryViewSize.width > 0 &&
      (NSInteger)secondaryAccessoryViewSize.height) {
    layoutWidthForLabels -=
        secondaryAccessoryViewSize.width + self.secondaryAccessoryViewLabelsSpacing;
    secondaryAccessoryAreaHeight =
        secondaryAccessoryViewSize.height + self.padding.top + self.padding.bottom;
  }

  // Calculate title heights.
  CGSize labelsLayoutSize = CGSizeMake(layoutWidthForLabels, CGFLOAT_MAX);
  CGFloat titleHeight = GIL_CGFloatCeil([self.title sizeThatFits:labelsLayoutSize].height);
  CGFloat subtitleHeight = GIL_CGFloatCeil([self.subtitle sizeThatFits:labelsLayoutSize].height);
  CGFloat allTitlesHeight = titleHeight + subtitleHeight;

  // Apply padding if the labels have a total height of greater than 0.
  if ((NSInteger)allTitlesHeight) {
    allTitlesHeight += self.padding.top + self.padding.bottom;
  }
  // Apply label spacing if both labels have height greater than 0.
  if ((NSInteger)titleHeight > 0 && (NSInteger)subtitleHeight) {
    allTitlesHeight += _titleLabelsSpacing;
  }

  height = GIL_CGFloatMax(primaryAccessoryAreaHeight, secondaryAccessoryAreaHeight);
  height = GIL_CGFloatMax(height, allTitlesHeight);

  return CGSizeMake(size.width, height);
}

#pragma mark - Property overrides

- (void)setTitleLabelsSpacing:(CGFloat)titleLabelsSpacing {
  _titleLabelsSpacing = titleLabelsSpacing;
  [self setNeedsLayout];
}

- (void)setPrimaryAccessoryViewSizeBlock:(GILViewSizeBlock)primaryAccessoryViewSizeBlock {
  _primaryAccessoryViewSizeBlock = [primaryAccessoryViewSizeBlock copy];
  [self setNeedsLayout];
}

- (void)setPrimaryAccessoryViewLabelsSpacing:(CGFloat)primaryAccessoryViewLabelsSpacing {
  _primaryAccessoryViewLabelsSpacing = primaryAccessoryViewLabelsSpacing;
  [self setNeedsLayout];
}

- (void)setSecondaryAccessoryViewSizeBlock:(GILViewSizeBlock)secondaryAccessoryViewSizeBlock {
  _secondaryAccessoryViewSizeBlock = [secondaryAccessoryViewSizeBlock copy];
  [self setNeedsLayout];
}

- (void)setSecondaryAccessoryViewLabelsSpacing:(CGFloat)secondaryAccessoryViewLabelsSpacing {
  _secondaryAccessoryViewLabelsSpacing = secondaryAccessoryViewLabelsSpacing;
  [self setNeedsLayout];
}

@end
