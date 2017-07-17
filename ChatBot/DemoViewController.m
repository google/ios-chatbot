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

#import "DemoViewController.h"

#import <WebKit/WebKit.h>

#import "CBDefines.h"
#import "CBViewController.h"
#import "UIColor+GILAdditions.h"

static const NSUInteger kChatBubbleColor = 0xFF2A9AF3;

static const CGSize kButtonSize = {64.0f, 64.0f};
static const CGFloat kButtonSideMargin = 32.0f;

@interface DemoViewController () <WKNavigationDelegate, CBViewControllerDelegate,
                                  UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
  NSURL *_URL;
  NSString *_name;
  NSString *_agentAccessToken;
  WKWebView *_webview;
  UIButton *_button;
  CBUserImageSelectedCompletionBlock _userImageSelectedCompletionBlock;
}
@end

@implementation DemoViewController

- (instancetype)initWithURL:(NSURL *)URL
                       name:(NSString *)name
           agentAccessToken:(NSString *)agentAccessToken {
  self = [super initWithNibName:nil bundle:nil];
  _URL = [URL copy];
  _name = [name copy];
  _agentAccessToken = [agentAccessToken copy];
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
  _webview = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
  _webview.navigationDelegate = self;
  [self.view addSubview:_webview];

  _button = [UIButton buttonWithType:UIButtonTypeCustom];
  UIImage *image =
      [[UIImage imageNamed:@"chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  [_button setImage:image forState:UIControlStateNormal];
  _button.tintColor = [UIColor gil_colorWithARGB:kChatBubbleColor];
  _button.backgroundColor = [UIColor whiteColor];
  _button.layer.cornerRadius = kButtonSize.width / 2.0f;
  _button.layer.shadowColor = [UIColor blackColor].CGColor;
  _button.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
  _button.layer.shadowOpacity = 0.5f;
  _button.layer.shadowRadius = 2.0f;
  [self.view addSubview:_button];

  [_button addTarget:self
                action:@selector(didTapLiveChatButton:)
      forControlEvents:UIControlEventTouchUpInside];

  if (_URL) {
    NSURLRequest *request = [NSURLRequest requestWithURL:_URL];
    [_webview loadRequest:request];
  }
}

- (void)viewDidLayoutSubviews {
  UIEdgeInsets frameInsets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
  CGRect webviewFrame = UIEdgeInsetsInsetRect(self.view.bounds, frameInsets);
  _webview.frame = CGRectIntegral(webviewFrame);

  _button.frame =
      CGRectMake(CGRectGetMaxX(self.view.bounds) - kButtonSize.width - kButtonSideMargin,
                 CGRectGetMaxY(self.view.bounds) - kButtonSize.height - kButtonSideMargin,
                 kButtonSize.width, kButtonSize.height);
}

#pragma mark - Private methods

- (void)didTapLiveChatButton:(UIButton *)button {
  CBViewController *viewController = [[CBViewController alloc] init];
  viewController.clientAccessToken = _agentAccessToken;
  viewController.title = _name;

  UIImage *closeImage = [UIImage imageNamed:@"close"];
  UIBarButtonItem *closeButton =
      [[UIBarButtonItem alloc] initWithImage:closeImage
                                       style:UIBarButtonItemStylePlain
                                      target:self
                                      action:@selector(didTapLiveChatCloseButton:)];
  viewController.navigationItem.rightBarButtonItem = closeButton;
  viewController.delegate = self;

  UINavigationController *navigationController =
      [[UINavigationController alloc] initWithRootViewController:viewController];
  [self presentViewController:navigationController animated:YES completion:NULL];
}

- (void)didTapLiveChatCloseButton:(UIButton *)button {
  [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView
    decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView
    didFailNavigation:(WKNavigation *)navigation
            withError:(NSError *)error {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}

#pragma mark - CBViewControllerDelegate

- (void)chatBotController:(CBViewController *)controller
    didRequestUserImageWithCompletionBlock:(CBUserImageSelectedCompletionBlock)completionBlock {
  _userImageSelectedCompletionBlock = [completionBlock copy];

  // Present the image picker
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [((UINavigationController *)self.presentedViewController).topViewController
      presentViewController:picker
                   animated:YES
                 completion:NULL];
}

- (void)chatBotController:(CBViewController *)controller
    shouldPresentViewController:(UIViewController *)viewController {
  UINavigationController *chatBotNavigationController =
      (UINavigationController *)self.presentedViewController;
  [chatBotNavigationController pushViewController:viewController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
  [((UINavigationController *)self.presentedViewController).topViewController
      dismissViewControllerAnimated:YES
                         completion:NULL];
  if (_userImageSelectedCompletionBlock) {
    _userImageSelectedCompletionBlock(info[UIImagePickerControllerOriginalImage]);
  }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [((UINavigationController *)self.presentedViewController).topViewController
      dismissViewControllerAnimated:YES
                         completion:NULL];
  if (_userImageSelectedCompletionBlock) {
    _userImageSelectedCompletionBlock(nil);
  }
}

@end
