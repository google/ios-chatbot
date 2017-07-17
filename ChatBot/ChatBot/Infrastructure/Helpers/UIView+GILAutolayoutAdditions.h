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

#import <UIKit/UIKit.h>

/**
 * Provides more natural language friendly APIs to create auto layout constraints and encapsulates
 * away some boilerplate code to add auto layout constraints.
 */
@interface UIView (GILAutolayoutAdditions)

/**
 * Adds a top margin constraint to a subview.
 * @param margin The margin.
 * @param subview The subview.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addTopMargin:(CGFloat)margin
                               toSubview:(UIView *)subview
                      withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a leading margin constraint to a subview.
 * @param margin The margin.
 * @param subview The subview.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addLeadingMargin:(CGFloat)margin
                                   toSubview:(UIView *)subview
                          withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a bottom margin constraint to a subview.
 * @param margin The margin.
 * @param subview The subview.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addBottomMargin:(CGFloat)margin
                                  toSubview:(UIView *)subview
                         withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a trailing margin constraint to a subview.
 * @param margin The margin.
 * @param subview The subview.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addTrailingMargin:(CGFloat)margin
                                    toSubview:(UIView *)subview
                           withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a vertical spacing constraint between two sibling views.
 * @param spacing The spacing.
 * @param view1 The first view.
 * @param view2 The second view.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addVerticalSpacing:(CGFloat)spacing
                                      fromView:(UIView *)view1
                                        toView:(UIView *)view2
                            withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a horizontal spacing constraint between two sibling views.
 * @param spacing The spacing.
 * @param view1 The first view.
 * @param view2 The second view.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addHorizontalSpacing:(CGFloat)spacing
                                        fromView:(UIView *)view1
                                          toView:(UIView *)view2
                              withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a width constraint to a view with layout priority - UILayoutPriorityRequired.
 * @param width The width.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addWidthConstraint:(CGFloat)width
                            withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a width constraint to a view.
 * @param width The width.
 * @param layoutRelation The relation.
 * @param layoutPriority The layout priority.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addWidthConstraint:(CGFloat)width
                            withLayoutRelation:(NSLayoutRelation)layoutRelation
                                layoutPriority:(UILayoutPriority)layoutPriority;

/**
 * Adds a height constraint to a view with layout priority - UILayoutPriorityRequired.
 * @param height The height.
 * @param layoutRelation The relation.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addHeightConstraint:(CGFloat)height
                             withLayoutRelation:(NSLayoutRelation)layoutRelation;

/**
 * Adds a height constraint to a view.
 * @param height The height.
 * @param layoutRelation The relation.
 * @param layoutPriority The layout priority.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_addHeightConstraint:(CGFloat)height
                             withLayoutRelation:(NSLayoutRelation)layoutRelation
                                 layoutPriority:(UILayoutPriority)layoutPriority;

/**
 * Aligns a subview vertically within its parent view.
 * @param subview The subview.
 * @param offset The offset from the vertical center.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_verticalAlignSubview:(UIView *)subview withOffset:(CGFloat)offset;

/**
 * Aligns a subview horizontally within its parent view.
 * @param subview The subview.
 * @param offset The offset from the horizontal center.
 * @return The constraint added.
 */
- (NSLayoutConstraint *)gil_horizontalAlignSubview:(UIView *)subview withOffset:(CGFloat)offset;

/**
 * Adds the top, left, bottom, and right margins to a subview.
 * @param subview The subview.
 * @param margins The margins representing top, left, bottom, and right.
 * @return The constraints added in the following order: top, left, bottom, and right.
 */
- (NSArray<NSLayoutConstraint *> *)gil_pinSubview:(UIView *)subview
                                      withMargins:(UIEdgeInsets)margins;

@end
