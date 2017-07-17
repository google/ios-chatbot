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

#import <Foundation/Foundation.h>

#import "GILViewComponent.h"
#import "GILViewComponentConstants.h"

@class GILAttributedLabelComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 * A view component representing a group of @c GILAttributedLabelComponent instances laid out
 * vertically.
 *
 * NOTE(bobyliu): The component currently expects anywhere from 0 - 5 label components. Support
 * for maximum number of labels will be added as needed.
 */
@interface GILAttributedLabelGroupComponent : NSObject<GILViewComponent>

/**
 * Returns an instance of the view component that represents a group of
 * @c GILAttributedLabelComponent instances.
 *
 * @param viewComponents The attributed label components associated with the group component. This
 *        can be anywhere from 0 - 5 instances of @c GILAttributedLabelComponent.
 * @param componentSpacing The vertical spacing between components with height greater than 0.
 * @param padding The padding which affects the actual layout area of the component.
 * @param alignment The horizontal alignment of the components if their widths do not fill up
 *        the width of the superview.
 * @param clipToLayoutArea Clips the components that go beyond the layout area. This affects
 *        the layout logic of the adapter. The layout area excludes the @c padding.
 * @param backgroundColor The @c backgroundColor set on the background view of the label group.
 * @param sizeBlock The size block that provides an alternative size logic from the default size
 *        behavior of the component.
 * @return An instance of the view component.
 */
- (instancetype)initWithViewComponents:(NSArray<GILAttributedLabelComponent *> *)viewComponents
                      componentSpacing:(CGFloat)componentSpacing
                               padding:(UIEdgeInsets)padding
                             alignment:(GILHorizontalAlignment)alignment
                      clipToLayoutArea:(BOOL)clipToLayoutArea
                       backgroundColor:(nullable UIColor *)backgroundColor
                             sizeBlock:(nullable GILViewComponentSizeBlock)sizeBlock
    NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer instead.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * The attributed label components associated with the group component.
 */
@property(nonatomic, copy, readonly) NSArray<GILAttributedLabelComponent *> *viewComponents;

/**
 * The vertical spacing between each component if it has a height greater than 0.
 */
@property(nonatomic, readonly) CGFloat componentSpacing;

/**
 * The padding which affects the actual layout area of the component.
 */
@property(nonatomic, readonly) UIEdgeInsets padding;

/**
 * The horizontal alignment of the components if their widths do not fill up the width of the
 * superview.
 */
@property(nonatomic, readonly) GILHorizontalAlignment alignment;

/**
 * Clips the components that go beyond the layout area. This affects the layout logic.
 * The layout area excludes the @c padding.
 */
@property(nonatomic, readonly) BOOL clipToLayoutArea;

/**
 * By default the size of the component is dynamic and determined by its label components with @c
 * [UILabel sizeThatFits:]. For example, if a label component has its @c numberOfLines set to 2 and
 * the actual text can fit within a single line, only the height of the single line label will be
 * counted toward the total height of the component. With the same logic, a nil / empty text will
 * result in a 0.0f height label. If a size block is provided, the height of component will be
 * determined by the size block instead.
 */
@property(nullable, nonatomic, readonly) GILViewComponentSizeBlock sizeBlock;

/**
 * Intended for the @c backgroundColor property on the background view of the label group.
 */
@property(nullable, nonatomic, readonly) UIColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
