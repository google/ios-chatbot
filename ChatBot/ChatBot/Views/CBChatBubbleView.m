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

#import "CBChatBubbleView.h"

static const CGFloat kArrowTopSpacing = 10.0f;
static const CGFloat kArrowWidth = 10.0f;
static const CGFloat kArrowHeight = 10.0f;
static const CGFloat kCornerRadius = 10.0f;

static UIEdgeInsets BubbleInsets(CBChatBubbleArrowPosition position) {
  UIEdgeInsets contentInsets = UIEdgeInsetsZero;
  if (position == CBChatBubbleArrowPositionLeft) {
    contentInsets = UIEdgeInsetsMake(0.0f, kArrowWidth, 0.0f, 0.0f);
  } else if (position == CBChatBubbleArrowPositionRight) {
    contentInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, kArrowWidth);
  }
  return contentInsets;
}

UIBezierPath *CBChatBubblePath(CGRect rect, CBChatBubbleArrowPosition position, BOOL drawArrow) {
  UIEdgeInsets bubbleInsets = BubbleInsets(position);
  CGRect bubbleRect = UIEdgeInsetsInsetRect(rect, bubbleInsets);
  CGFloat minX = CGRectGetMinX(bubbleRect);
  CGFloat maxX = CGRectGetMaxX(bubbleRect);
  CGFloat minY = CGRectGetMinY(bubbleRect);
  CGFloat maxY = CGRectGetMaxY(bubbleRect);

  UIBezierPath *bubblePath = [UIBezierPath bezierPath];

  [bubblePath addArcWithCenter:CGPointMake(maxX - kCornerRadius, maxY - kCornerRadius)
                        radius:kCornerRadius
                    startAngle:0
                      endAngle:M_PI_2
                     clockwise:YES];

  [bubblePath addArcWithCenter:CGPointMake(minX + kCornerRadius, maxY - kCornerRadius)
                        radius:kCornerRadius
                    startAngle:2 * M_PI / 3
                      endAngle:M_PI
                     clockwise:YES];

  if (drawArrow && position == CBChatBubbleArrowPositionLeft) {
    // Triangle
    [bubblePath addLineToPoint:CGPointMake(minX, kArrowTopSpacing + kArrowHeight)];
    [bubblePath addLineToPoint:CGPointMake(minX - bubbleInsets.left,
                                           kArrowTopSpacing + kArrowHeight / 2.0f)];
    [bubblePath addLineToPoint:CGPointMake(minX, kArrowTopSpacing)];
  }

  [bubblePath addArcWithCenter:CGPointMake(minX + kCornerRadius, minY + kCornerRadius)
                        radius:kCornerRadius
                    startAngle:M_PI
                      endAngle:3 * M_PI_2
                     clockwise:YES];

  [bubblePath addArcWithCenter:CGPointMake(maxX - kCornerRadius, minY + kCornerRadius)
                        radius:kCornerRadius
                    startAngle:3 * M_PI / 2
                      endAngle:2 * M_PI
                     clockwise:YES];

  if (drawArrow && position == CBChatBubbleArrowPositionRight) {
    // Triangle
    [bubblePath addLineToPoint:CGPointMake(maxX, kArrowTopSpacing + kArrowHeight)];
    [bubblePath addLineToPoint:CGPointMake(maxX + bubbleInsets.right,
                                           kArrowTopSpacing + kArrowHeight / 2.0f)];
    [bubblePath addLineToPoint:CGPointMake(maxX, kArrowTopSpacing)];
  }

  [bubblePath closePath];

  return bubblePath;
}

@implementation CBChatBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self CBChatBubbleViewInit];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self CBChatBubbleViewInit];
  return self;
}

- (void)CBChatBubbleViewInit {
  CAShapeLayer *bubbleLayer = [CAShapeLayer layer];
  UIBezierPath *path = CBChatBubblePath(self.bounds, _arrowPosition, YES);
  bubbleLayer.path = path.CGPath;
  self.layer.mask = bubbleLayer;
  self.offsetContentViewWithArrowWidth = YES;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CAShapeLayer *bubbleLayer = (CAShapeLayer *)self.layer.mask;
  bubbleLayer.path = CBChatBubblePath(self.bounds, _arrowPosition, YES).CGPath;

  UIEdgeInsets bubbleInsets =
      _offsetContentViewWithArrowWidth ? BubbleInsets(_arrowPosition) : UIEdgeInsetsZero;
  CGRect contentViewFrame = UIEdgeInsetsInsetRect(self.bounds, bubbleInsets);

  contentViewFrame = UIEdgeInsetsInsetRect(contentViewFrame, _padding);
  _contentView.frame = CGRectIntegral(contentViewFrame);
}

- (void)setContentView:(UIView *)contentView {
  [_contentView removeFromSuperview];
  _contentView = contentView;
  if (contentView) {
    [self addSubview:contentView];
  }
  [self setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
  UIEdgeInsets bubbleInsets =
      _offsetContentViewWithArrowWidth ? BubbleInsets(_arrowPosition) : UIEdgeInsetsZero;
  CGFloat layoutWidth =
      size.width - bubbleInsets.left - bubbleInsets.right - _padding.left - _padding.right;
  CGSize contentSize = CGSizeZero;
  if (_contentViewSizeBlock) {
    contentSize = _contentViewSizeBlock(CGSizeMake(layoutWidth, CGFLOAT_MAX), _contentView);
  } else {
    contentSize = [_contentView sizeThatFits:CGSizeMake(layoutWidth, CGFLOAT_MAX)];
  }
  CGFloat width =
      contentSize.width + bubbleInsets.left + bubbleInsets.right + _padding.left + _padding.right;
  CGFloat height =
      contentSize.height + bubbleInsets.top + bubbleInsets.bottom + _padding.top + _padding.bottom;
  return CGSizeMake(width, height);
}

@end
