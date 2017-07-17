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

NS_ASSUME_NONNULL_BEGIN

/**
 * A view component representing an image collage view that loads the images from web URLs.
 */
@interface GILImageCollageComponent : NSObject<GILViewComponent>

/**
* Returns an instance of the view component.
*
* @param imageURLs The web URLs of the images in the collage.
* @param imagesContentMode The content mode of the image views in the collage.
* @param numberOfImagesToDisplay The number of images that will be displayed in the collage.
* @param sizeBlock The block that encapsulates the sizing logic of the entire image collage view.
*        Regardless of the actual implementation. The caller should always assume the block is
*        retained by the view component and be aware of creating retain cycles.
* @param backgroundColor The @c backgroundColor set on the background view of the image collage.
* @return An instance of the view component.
*/
- (instancetype)initWithImageURLs:(nullable NSArray<NSURL *> *)imageURLs
                imagesContentMode:(UIViewContentMode)imagesContentMode
          numberOfImagesToDisplay:(NSInteger)numberOfImagesToDisplay
                  backgroundColor:(nullable UIColor *)backgroundColor
                        sizeBlock:(GILViewComponentSizeBlock)sizeBlock NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer instead.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * The URLs of the images in the collage.
 */
@property(nullable, nonatomic, copy, readonly) NSArray<NSURL *> *imageURLs;

/**
 * The content mode applied to the image views in the collage.
 */
@property(nonatomic, readonly) UIViewContentMode imagesContentMode;

/**
 * The number of images that will be displayed in the collage.
 */
@property(nonatomic, readonly) NSInteger numberOfImagesToDisplay;

/**
 * The block that encapsulates the sizing logic of the entire image collage view.
 */
@property(nonatomic, copy, readonly) GILViewComponentSizeBlock sizeBlock;

/**
 * Intended for the @c backgroundColor property on the background view of the image collage.
 */
@property(nullable, nonatomic, readonly) UIColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
