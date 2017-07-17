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

@protocol GILReusableViewAdapter;

NS_ASSUME_NONNULL_BEGIN

/**
 * A completion block intended to be executed at the end of a layoutSubviews pass.
 */
typedef void (^GILReusableViewLayoutCompletionBlock)(void);

/**
 * A reusable view managed by the associated adapter. The view is intended to be used as a composite
 * view or a standalone view in situations where the view is recycled such as a UICollectionView
 * or UITableView. The adapter allows the subview layout and data-binding logic be reused and
 * encapsulated. The adapter must conform to the @c GILReusableViewAdapter protocol and may
 * utilize additional abstractions to facilitate logic consistency and scalability.
 *
 * However, this may not be suitable for all use cases. Best judgments should be applied when
 * determining whether the adapter managed approach is suitable.
 *
 * See @c GILVerticalStackViewAdapter for examples.
 */
@interface GILReusableView : UIView

/**
 * Creates an instance of the reusable view and associate it with the adapter specified.
 *
 * The initializer calls @c initWithFrame: on the super class. Therefore, it does not support direct
 * usage with storyboards or xibs. However, it can still be used as a composite view in a view
 * instantiated through a storyboard or xib.
 *
 * @param adapter A adapter that will manage the subviews' layout and data binding logic.
 * @return An instance of the reusable view.
 */
- (instancetype)initWithAdapter:(id<GILReusableViewAdapter>)adapter NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer instead.
 */
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/**
 * Use the designated initializer instead.
 */
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

/**
 * The adapter associated with the reusable view.
 */
@property(nonatomic, readonly) id<GILReusableViewAdapter> adapter;

/**
 * The completion block to be executed at the end of a @c layoutSubviews pass. The block provides a
 * convenient entry point to extend the @c layoutSubviews logic associated with the reusable view.
 * It can be used in situations where the @c UIBezierPath of the subviews needs to be updated.
 * However, just as any logic belonging to @c layoutSubviews, the extended logic should never
 * cause the view to re-lay out itself as it will cause an infinite loop.
 */
@property(nullable, nonatomic, copy) GILReusableViewLayoutCompletionBlock layoutCompletionBlock;

@end

NS_ASSUME_NONNULL_END
