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
@class GILImageViewComponent;
@class GILWebImageComponent;

NS_ASSUME_NONNULL_BEGIN

/**
 * A view component representing a view with an image to the left and two title labels stacked on
 * top of each other to the right.
 */
@interface GILImageLabelsComponent : NSObject<GILViewComponent>

/**
 * Returns an instance of the view component.
 *
 * @param webImageComponent The component representing the image loaded through the web URL
 *        specified. The size block associated with this component defines the actual size of the
 *        image. The image is centered in the image view associated with the parent
 *        (@c GILImageLabelsComponent) component.
 * @param titleComponent The component representing the title label.
 * @param subtitleComponent The component representing the subtitle label.
 * @param padding The padding that surrounds the image and title labels.
 * @param backgroundColor The @c backgroundColor on the composite view.
 * @param imageViewSizeBlock The block that encapsulates the sizing logic of the image view. The
 *        image is centered in the image view based on the size provided by the size block
 *        of the associated @c webImageComponent instance.
 * @return An instance of the view component.
 */
- (instancetype)initWithWebImageComponent:(nullable GILWebImageComponent *)webImageComponent
                           titleComponent:(nullable GILAttributedLabelComponent *)titleComponent
                        subtitleComponent:(nullable GILAttributedLabelComponent *)subtitleComponent
                                  padding:(UIEdgeInsets)padding
                          backgroundColor:(nullable UIColor *)backgroundColor
                       imageViewSizeBlock:(nullable GILViewComponentSizeBlock)imageViewSizeBlock
    NS_DESIGNATED_INITIALIZER;

// TODO(bobyliu): Consolidate GILImageViewComponent and GILWebImageComponent. Ideally
// only GILImageViewComponent is needed to support both locally bundled and web URL images with
// complete tinting support.
/**
 * Returns an instance of the view component.
 *
 * @param imageComponent The component representing the image loaded from a bundle within the
 *        application. The size block associated with this component defines the actual size of the
 *        image. The image is centered in the image view associated with the parent
 *        (@c GILImageLabelsComponent) component.
 * @param titleComponent The component representing the title label.
 * @param subtitleComponent The component representing the subtitle label.
 * @param padding The padding that surrounds the image and title labels.
 * @param backgroundColor The @c backgroundColor on the composite view.
 * @param imageViewSizeBlock The block that encapsulates the sizing logic of the image view. The
 *        image is centered in the image view based on the size provided by the size block
 *        of the associated @c webImageComponent instance.
 * @return An instance of the view component.
 */
- (instancetype)initWithImageComponent:(nullable GILImageViewComponent *)imageComponent
                        titleComponent:(nullable GILAttributedLabelComponent *)titleComponent
                     subtitleComponent:(nullable GILAttributedLabelComponent *)subtitleComponent
                               padding:(UIEdgeInsets)padding
                       backgroundColor:(nullable UIColor *)backgroundColor
                    imageViewSizeBlock:(nullable GILViewComponentSizeBlock)imageViewSizeBlock
    NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer instead.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * The associated web image component.
 */
@property(nullable, nonatomic, copy, readonly) GILWebImageComponent *webImageComponent;

/**
 * The associated image component.
 */
@property(nullable, nonatomic, copy, readonly) GILImageViewComponent *imageComponent;

/**
 * The associated title component.
 */
@property(nullable, nonatomic, copy, readonly) GILAttributedLabelComponent *titleComponent;

/**
 * The associated subtitle component.
 */
@property(nullable, nonatomic, copy, readonly) GILAttributedLabelComponent *subtitleComponent;

/**
 * The padding that surrounds the image and title labels.
 */
@property(nonatomic, readonly) UIEdgeInsets padding;

/**
 * Intended for the @c backgroundColor property on the composite view.
 */
@property(nullable, nonatomic, readonly) UIColor *backgroundColor;

/**
 * The block that encapsulates the sizing logic of the image view. The image is centered in the
 * image view based on the size provided by the size block of the associated @c webImageComponent
 * instance.
 */
@property(nonatomic, copy, readonly) GILViewComponentSizeBlock imageViewSizeBlock;

@end

NS_ASSUME_NONNULL_END
