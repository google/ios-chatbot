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

#import "GILReusableViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * A block that encapsulates the logic to return a new view for an item index path.
 *
 * @param indexPath The index path of the item. See class comment on row and column.
 * @return a view for the grid index.
 */
typedef UIView *_Nonnull (^GILGridViewItemViewBuildBlock)(NSIndexPath *indexPath);

/**
 * A block that encapsulates the logic to calculate the item size for an item index path.
 *
 * @param view The view for the item index path.
 * @param width The maximum width expected for the item.
 * @param indexPath The index path for the grid item.
 * @return The expected size of the grid item.
 */
typedef CGSize (^GILGridViewItemViewSizeBlock)(UIView *view, CGFloat width, NSIndexPath *indexPath);

/**
 * Returns an index path based on the row and column specified. The host app should use this
 * function to ensure the same logic as the adapter does is always used.
 *
 * @param row The row index. See class comment on row.
 * @param column The column index. See class comment on column.
 * @return An index path representing a grid item.
 */
UIKIT_EXTERN NSIndexPath *GILGridAdapterIndexPath(NSInteger row, NSInteger column);

/**
 * An adapter for @c GILReusableView that creates a simple grid without forcing contents to
 * be bound to the views upon creation.
 *
 * The grid defines that the rows span through a view vertically while columns span through a view
 * horizontally.
 *
 * This adapter is intended for situations where a collection view may be too complicated / heavy
 * for the use case. However, it may not be suitable for all use cases. Best judgments should be
 * applied when determining whether this approach is suitable.
 */
@interface GILGridViewAdapter : NSObject<GILReusableViewAdapter>

/**
 * Creates an instance of the adapter.
 *
 * @param rows Number of rows for the grid. See class comment on row.
 * @param columns Number of columns for the grid. See class comment on column.
 * @param itemViewSpacing The horizontal and vertical spacing between the items.
 * @param buildBlock The block that encapsulates the logic to create new item views. Regardless of
 *        the actual implementation. The caller should always assume the block is retained by the
 *        adapter and be aware of creating retain cycles.
 * @param sizeBlock The block that encapsulates the logic to calculate the item sizes. If nil, the
 *        adapter calculates the item size by calling @c sizeThatFits: on the view. Regardless of
 *        the actual implementation. The caller should always assume the block is retained by the
 *        adapter and be aware of creating retain cycles.
 * @return An instance of the adapter.
 */
- (instancetype)initWithNumberNumberOfRows:(NSInteger)rows
                                   columns:(NSInteger)columns
                           itemViewSpacing:(CGFloat)itemViewSpacing
                                buildBlock:(GILGridViewItemViewBuildBlock)buildBlock
                                 sizeBlock:(nullable GILGridViewItemViewSizeBlock)sizeBlock;

/**
 * Returns the index path of an item view based on the same logic and states of the adapter. The
 * host app should use this method to ensure the same logic as the adapter does is always used.
 *
 * @param itemView The item view managed by the adapter.
 * @return The index path of the item view. Nil is returned if the grid view is not found.
 */
- (nullable NSIndexPath *)indexPathForItemView:(UIView *)itemView;

/**
 * Returns the item view of the index path based on the same logic and states of the adapter. The
 * host app should use this method to ensure the same logic as the adapter does is always used.
 *
 * @param indexPath The index path of the item view.
 * @return The item view. Nil is returned if the index path is not found.
 */
- (nullable UIView *)itemViewAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns the index path from the linear index based on the same logic and states of the adapter.
 *
 * Since the adapter manages its views in an array. Ultimately it converts a linearly stored array
 * into a grid. The host app can use this method to figure out the grid index of a content object
 * that may also be stored in a linear manner. The host app should use this method to ensure the
 * same logic and states as the adapter does is always used.
 *
 * @param linearIndex The index of the grid item if it is flattened into an linear array.
 * @return The index path. Nil is returned if the linear index path is not valid for the grid.
 */
- (nullable NSIndexPath *)indexPathForLinearIndex:(NSInteger)linearIndex;

/**
 * Returns the linear index of the index path based on the same logic and state of the adapter.
 *
 * @param indexPath The index of a grid item.
 * @return The linear index of the indexPath. NSNotFound is returned if the index path is invalid
 * for the grid.
 */
- (NSInteger)linearIndexForIndexPath:(NSIndexPath *)indexPath;

/**
 * The padding which affects the actual layout area of the component views.
 *
 * It is the caller's responsibility to trigger a relayout when the property is updated.
 */
@property(nonatomic) UIEdgeInsets padding;

@end

NS_ASSUME_NONNULL_END
