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

#import "CBDefines.h"

@class CBViewController;

@protocol CBViewControllerDelegate <NSObject>

- (void)chatBotController:(CBViewController *)controller
    didRequestUserImageWithCompletionBlock:(CBUserImageSelectedCompletionBlock)completionBlock;

- (void)chatBotController:(CBViewController *)controller
    shouldPresentViewController:(UIViewController *)viewController;

@end

/**
 * A standalone view controller used to provide a quick ChatBot experience with api.ai backend
 * services. The view controller may be used as a child view controller or subclassed.
 */
@interface CBViewController : UIViewController

/**
 * The delegate of the view controller.
 */
@property(nonatomic, weak) id<CBViewControllerDelegate> delegate;

/**
 * The api.ai access token associated with an agent.
 */
@property(nonatomic, copy) NSString *clientAccessToken;

/**
 * The inset of the scroll area that can be used by a parent view controller or subclassed
 * view controller to adjust the message scroll area.
 *
 * Value is not in effect until @c automaticallyAdjustsScrollViewInsets is disabled.
 *
 * For simplier use cases with the out-of-the-box UINavigationController, consider relying on
 * @c automaticallyAdjustsScrollViewInsets bening enabled.
 */
@property(nonatomic) UIEdgeInsets scrollAreaInset;

@end
