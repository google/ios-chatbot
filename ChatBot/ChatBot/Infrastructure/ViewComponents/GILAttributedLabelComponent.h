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

NS_ASSUME_NONNULL_BEGIN

/**
 * A view component representing a UILabel with attributed string. This is essentially a view model
 * capturing the view state data and the corresponding logic to update a UILabel. This is not
 * intended to be used for all situations where a UILabel uses an attributed string. The view
 * component abstraction is used to enable better code reusability in higher level abstractions.
 */
@interface GILAttributedLabelComponent : NSObject<GILViewComponent>

/**
 * Creates an instance of the view component. Although the attributed string may contain
 * textAlignment and lineBreakMode attributes, they are overwritten by the properties specified on
 * the view component to ensure logic consistency.
 *
 * @param attributedString The attributed string set on a UILabel.
 * @param numberOfLines The @c numberOfLines set on a UILabel.
 * @param textAlignment The @c textAlignment set on a UILabel.
 * @param lineBreakMode The @c lineBreakMode set on a UILabel.
 * @param backgroundColor The @c backgroundColor set on a UILabel.
 * @return An instance of the view component.
 */
- (instancetype)initWithAttributedString:(NSAttributedString *)attributedString
                           numberOfLines:(NSInteger)numberOfLines
                           textAlignment:(NSTextAlignment)textAlignment
                           lineBreakMode:(NSLineBreakMode)lineBreakMode
                         backgroundColor:(nullable UIColor *)backgroundColor
                             NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer instead.
 */
- (nullable instancetype)init NS_UNAVAILABLE;

/**
 * Intended for the @c attributedText property on a @c UILabel.
 */
@property(nonatomic, readonly) NSAttributedString *attributedString;

/**
 * Intended for the @c numberOfLines property on a @c UILabel.
 */
@property(nonatomic, readonly) NSInteger numberOfLines;

/**
 * Intended for the @c numberOfLines property on a @c UILabel. This overwrites any @c lineBreakMode
 * value specified in the attributed string.
 */
@property(nonatomic, readonly) NSTextAlignment textAlignment;

/**
 * Intended for the @c lineBreakMode property on a @c UILabel. This overwrites any @c lineBreakMode
 * value specified in the attributed string.
 */
@property(nonatomic, readonly) NSLineBreakMode lineBreakMode;

/**
 * Intended for the @c backgroundColor property on a @c UILabel.
 */
@property(nullable, nonatomic, readonly) UIColor *backgroundColor;

@end

NS_ASSUME_NONNULL_END
