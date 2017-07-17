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

@protocol GILCellViewComponent;
@protocol GILViewComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 * Defines the horizontal alignment of the associated item.
 */
typedef NS_ENUM(NSInteger, GILHorizontalAlignment) {
  GILHorizontalAlignmentLeft,
  GILHorizontalAlignmentCenter,
  GILHorizontalAlignmentRight,
};

/**
 * A block that provides the sizing logic for a view component.
 *
 * @param layoutSize The layout size available to layout the component view.
 * @param component The view component used to update a component view.
 * @return The size the superview should use to lay out the view.
 */
typedef CGSize (^GILViewComponentSizeBlock)(CGSize layoutSize,
                                            id<GILViewComponent> _Nullable component);

/**
 * A block that provides the sizing logic for a view.
 *
 * @param layoutSize The layout size available to layout the view.
 * @param view The view to be laid out.
 * @return The size the superview should use to lay out the view.
 */
typedef CGSize (^GILViewSizeBlock)(CGSize layoutSize, UIView *view);

typedef CGSize (^GILCollectionComponentSizeBlock)(UICollectionView *collectionView,
                                                  UICollectionViewLayout *layout,
                                                  _Nullable id<GILCellViewComponent> component,
                                                  NSIndexPath *indexPath);

NS_ASSUME_NONNULL_END
