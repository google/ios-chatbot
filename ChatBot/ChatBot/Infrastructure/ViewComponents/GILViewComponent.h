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

NS_ASSUME_NONNULL_BEGIN

/**
 * A view component protocol defines the required implementations of a view component. A view
 * component is essentially a view model capturing the view state data and logic on how to update a
 * particular type of view.
 *
 * A component level abstraction allows better logic reusability in higher level abstractions such
 * as the @c GILReusableViewAdapter.
 *
 * A view component following the protocol should be read only objects to ensure thread safety and
 * reduce the risk of unintended regressions. The class methods are intended for main thread usages
 * since they interact with UIView and its subclasses. Therefore, they should be designed with
 * considerations of being used on the main thread.
 */
@protocol GILViewComponent<NSObject, NSCopying>

/**
 * Updates a view with the specified view component if the class method is able to update the
 * view with the view component specified.
 *
 * @return If the view can be updated with the view component, YES is returned. Otherwise, NO is
 *         returned.
 */
+ (BOOL)updateView:(UIView *)view withComponent:(nullable id<GILViewComponent>)component;

/**
 * Returns a new instance of the view associated with the component.
 */
+ (UIView *)view;

@optional

/**
 * Allow more specific size calculation logic to be associated to the view component. If
 * implementation is not provided, it indicates the default @c sizeThatFits: method on the
 * associated view should be used.
 *
 * Per Apple doc, @c sizeThatFits: returns 'the size for which the view should calculate its
 * best-fitting size.' The implementation depends on the type of view sizeThatFits: is invoked on
 * such as UIButton, UILabel, and UIImageView. Therefore, the default implementation of a view's
 * sizeThatFits: may be very different from a size calculated based on a 'constrained' size.
 *
 * This method is intended to return the 'best-fitting' size based according to the view component.
 *
 * @param size The size that the view component should rely on using to calculated the expected
 *        size.
 * @param component The view component, which is be the class implementing this protocol, used for
 *        height calculation.
 * @return The expected size of the view based on the behaviors the view component class expects.
 */
+ (CGSize)sizeThatFits:(CGSize)size forComponent:(nullable id<GILViewComponent>)component;

@end

/**
 * A component representing a null GILViewComponent. This is used in arrays with generic types
 * specified.
 */
@interface GILViewComponentNull : NSObject<GILViewComponent>

/**
 * Returns an instance of @c GILViewComponentNull.
 */
+ (instancetype)null;

@end

NS_ASSUME_NONNULL_END
