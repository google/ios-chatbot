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

#import "UIView+GILAutolayoutAdditions.h"

@implementation UIView (GILAutolayoutAdditions)

- (NSLayoutConstraint *)gil_addTopMargin:(CGFloat)margin
                               toSubview:(UIView *)subview
                      withLayoutRelation:(NSLayoutRelation)layoutRelation {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subview
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:layoutRelation
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:margin];
  [self addConstraint:constraint];

  return constraint;
}

- (NSLayoutConstraint *)gil_addTrailingMargin:(CGFloat)margin
                                    toSubview:(UIView *)subview
                           withLayoutRelation:(NSLayoutRelation)layoutRelation {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:layoutRelation
                                                                   toItem:subview
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:margin];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_addBottomMargin:(CGFloat)margin
                                  toSubview:(UIView *)subview
                         withLayoutRelation:(NSLayoutRelation)layoutRelation {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:layoutRelation
                                                                   toItem:subview
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1
                                                                 constant:margin];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_addLeadingMargin:(CGFloat)margin
                                   toSubview:(UIView *)subview
                          withLayoutRelation:(NSLayoutRelation)layoutRelation {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subview
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:layoutRelation
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1
                                                                 constant:margin];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_addVerticalSpacing:(CGFloat)spacing
                                      fromView:(UIView *)view1
                                        toView:(UIView *)view2
                            withLayoutRelation:(NSLayoutRelation)layoutRelation {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view2
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:layoutRelation
                                                                   toItem:view1
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1
                                                                 constant:spacing];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_addHorizontalSpacing:(CGFloat)spacing
                                        fromView:(UIView *)view1
                                          toView:(UIView *)view2
                              withLayoutRelation:(NSLayoutRelation)layoutRelation {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view2
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:layoutRelation
                                                                   toItem:view1
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:spacing];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_addWidthConstraint:(CGFloat)width
                            withLayoutRelation:(NSLayoutRelation)layoutRelation {
  return [self gil_addWidthConstraint:width
                   withLayoutRelation:layoutRelation
                       layoutPriority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)gil_addWidthConstraint:(CGFloat)width
                            withLayoutRelation:(NSLayoutRelation)layoutRelation
                                layoutPriority:(UILayoutPriority)layoutPriority {
  NSLayoutConstraint *constraint =
      [NSLayoutConstraint constraintWithItem:self
                                   attribute:NSLayoutAttributeWidth
                                   relatedBy:layoutRelation
                                      toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1
                                    constant:width];
  constraint.priority = layoutPriority;
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_addHeightConstraint:(CGFloat)height
                             withLayoutRelation:(NSLayoutRelation)layoutRelation {
  return [self gil_addHeightConstraint:height
                    withLayoutRelation:layoutRelation
                        layoutPriority:UILayoutPriorityRequired];
}

- (NSLayoutConstraint *)gil_addHeightConstraint:(CGFloat)height
                             withLayoutRelation:(NSLayoutRelation)layoutRelation
                                 layoutPriority:(UILayoutPriority)layoutPriority {
  NSLayoutConstraint *constraint =
      [NSLayoutConstraint constraintWithItem:self
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:layoutRelation
                                      toItem:nil
                                   attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:1
                                    constant:height];
  constraint.priority = layoutPriority;
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_verticalAlignSubview:(UIView *)subview withOffset:(CGFloat)offset {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subview
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:offset];
  [self addConstraint:constraint];
  return constraint;
}

- (NSLayoutConstraint *)gil_horizontalAlignSubview:(UIView *)subview withOffset:(CGFloat)offset {
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:subview
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:offset];
  [self addConstraint:constraint];
  return constraint;
}

- (NSArray<NSLayoutConstraint *> *)gil_pinSubview:(UIView *)subview
                                      withMargins:(UIEdgeInsets)margins {
  NSMutableArray<NSLayoutConstraint *> *constraints = [NSMutableArray array];

  NSLayoutConstraint *constraint = [self gil_addTopMargin:margins.top
                                                toSubview:subview
                                       withLayoutRelation:NSLayoutRelationEqual];
  [constraints addObject:constraint];

  constraint = [self gil_addLeadingMargin:margins.left
                                toSubview:subview
                       withLayoutRelation:NSLayoutRelationEqual];
  [constraints addObject:constraint];

  constraint = [self gil_addBottomMargin:margins.bottom
                               toSubview:subview
                      withLayoutRelation:NSLayoutRelationEqual];
  [constraints addObject:constraint];

  constraint = [self gil_addTrailingMargin:margins.right
                                 toSubview:subview
                        withLayoutRelation:NSLayoutRelationEqual];
  [constraints addObject:constraint];

  return [constraints copy];
}

@end
