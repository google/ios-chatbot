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

#import "GILReusableViewAdapter.h"
#import "GILViewComponentConstants.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GILViewComponent;

/**
 * An adapter following the @c GILReusableViewAdapter protocol that lays out
 * @c GILViewcomponent instances vertically.
 *
 * This allows layout and view update logic to be specified in a view-component-driven manner
 * without requiring data to be bound to the views upon creation. So that changes related to
 * individual components and their orders do not affect the overall layout and view update logic.
 * However, it may not be suitable for all use cases. Best judgments should be applied when
 * determining whether the adapter approach is suitable.
 */
@interface GILVerticalStackViewAdapter : NSObject<GILReusableViewAdapter>

/**
 * Creates an instance of the adapter with the specified view component classes. The view component
 * classes specify the views that will be managed by the adapter.
 *
 * @param classes An array of classes conforming to the @c GILViewComponent protocol. Each
 *        class represents a component view. Each component view will be laid out vertically based
 *        on its order in the adapter's @c viewComponents property.
 * @return An instance of the adapter.
 */
- (instancetype)initWithViewComponentClasses:(NSArray<Class> *)classes NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer instead.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * An array of view components that will be used to update the component views managed by the
 * adapter. The number of view components in the array must match the number of the component
 * classes used to initialize the adapter.
 *
 * Use @c GILViewComponentNull to represent a nil view component. A nil view component
 * may hide a component view depending on the implementation of the view component. A view component
 * class may return 0.0f height for some conditions in its @c sizeThatFits:forComponent:
 * implementation.
 *
 * It is the caller's responsibility to trigger a relayout on the associated view when the property
 * is updated.
 */
@property(nullable, nonatomic) NSArray<id<GILViewComponent>> *viewComponents;

/**
 * The vertical spacing between each component view if it has a height greater than 0.0f.
 *
 * It is the caller's responsibility to trigger a relayout on the associated view when the property
 * is updated.
 */
@property(nonatomic) CGFloat componentSpacing;

/**
 * The padding which affects the actual layout area of the component views.
 *
 * It is the caller's responsibility to trigger a relayout on the associated view when the property
 * is updated.
 */
@property(nonatomic) UIEdgeInsets padding;

/**
 * The horizontal alignment of the component views if their widths do not fill up the width of the
 * associated superview.
 *
 * It is the caller's responsibility to trigger a relayout on the associated view when the property
 * is updated.
 */
@property(nonatomic) GILHorizontalAlignment alignment;

/**
 * Clips the view components that go beyond the layout area. This affects the layout logic of the
 * adapter. The layout area accounts for the @c padding.
 *
 * It is the caller's responsibility to trigger a relayout on the associated view when the property
 * is updated.
 */
@property(nonatomic) BOOL clipToLayoutArea;

@end

NS_ASSUME_NONNULL_END
