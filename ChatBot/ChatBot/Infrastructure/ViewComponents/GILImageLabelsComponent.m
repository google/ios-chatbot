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

#import "GILImageLabelsComponent.h"

#import "GILTitleLabelsView.h"
#import "GILAttributedLabelComponent.h"
#import "GILImageViewComponent.h"
#import "GILWebImageComponent.h"

static const CGFloat kAccessoryViewLabelsSpacing = 8.0f;
static const NSInteger kWebImageViewTag = 1;
static const NSInteger kImageViewTag = 2;

static GILTitleLabelsView *ImageTitleLabelsView(void) {
  GILTitleLabelsView *titleLabelsView = [[GILTitleLabelsView alloc] initWithFrame:CGRectZero];
  titleLabelsView.primaryAccessoryViewLabelsSpacing = kAccessoryViewLabelsSpacing;
  UIView *webImageView = [GILWebImageComponent view];
  webImageView.clipsToBounds = YES;
  webImageView.tag = kWebImageViewTag;
  [titleLabelsView.primaryAccessoryView addSubview:webImageView];
  UIView *imageView = [GILImageViewComponent view];
  imageView.clipsToBounds = YES;
  [titleLabelsView.primaryAccessoryView addSubview:imageView];
  imageView.tag = kImageViewTag;
  return titleLabelsView;
}

@implementation GILImageLabelsComponent

- (instancetype)initWithWebImageComponent:(GILWebImageComponent *)webImageComponent
                           titleComponent:(GILAttributedLabelComponent *)titleComponent
                        subtitleComponent:(GILAttributedLabelComponent *)subtitleComponent
                                  padding:(UIEdgeInsets)padding
                          backgroundColor:(UIColor *)backgroundColor
                       imageViewSizeBlock:(GILViewComponentSizeBlock)imageViewSizeBlock {
  self = [super init];
  if (self) {
    _webImageComponent = [webImageComponent copy];
    _titleComponent = [titleComponent copy];
    _subtitleComponent = [subtitleComponent copy];
    _padding = padding;
    _backgroundColor = backgroundColor;
    _imageViewSizeBlock = [imageViewSizeBlock copy];
  }
  return self;
}

- (instancetype)initWithImageComponent:(GILImageViewComponent *)imageComponent
                        titleComponent:(GILAttributedLabelComponent *)titleComponent
                     subtitleComponent:(GILAttributedLabelComponent *)subtitleComponent
                               padding:(UIEdgeInsets)padding
                       backgroundColor:(UIColor *)backgroundColor
                    imageViewSizeBlock:(GILViewComponentSizeBlock)imageViewSizeBlock {
  self = [super init];
  if (self) {
    _imageComponent = [imageComponent copy];
    _titleComponent = [titleComponent copy];
    _subtitleComponent = [subtitleComponent copy];
    _padding = padding;
    _backgroundColor = backgroundColor;
    _imageViewSizeBlock = [imageViewSizeBlock copy];
  }
  return self;
}

- (instancetype)init {
  NSAssert(NO, @"Use the designated initializer instead.");
  return nil;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
  return self;
}

#pragma mark - GILViewComponent

+ (BOOL)updateView:(UIView *)view withComponent:(GILImageLabelsComponent *)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if (![view isKindOfClass:[GILTitleLabelsView class]]) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
    // NOTE(bobyliu): GILViewComponentNull is considered as nil. See GILViewComponentNull
    // for details. Use the regular update logic to handle the nil component case.
  } else if (![component isKindOfClass:[GILImageLabelsComponent class]] &&
             ![component isKindOfClass:[GILViewComponentNull class]] && component) {
    NSAssert(NO, @"Unexpected view component type.");
    return NO;
  } else {
    GILTitleLabelsView *titleLabelsView = (GILTitleLabelsView *)view;
    GILImageLabelsComponent *imageLabelsComponent = nil;
    if ([component isKindOfClass:[GILImageLabelsComponent class]]) {
      imageLabelsComponent = (GILImageLabelsComponent *)component;
    }
    GILWebImageComponent *webImageComponent = imageLabelsComponent.webImageComponent;
    GILImageViewComponent *imageComponent = imageLabelsComponent.imageComponent;
    UIView *webImageView = [view viewWithTag:kWebImageViewTag];
    UIView *imageView = [view viewWithTag:kImageViewTag];

    // Update the accessory view size block on the title labels view.
    titleLabelsView.primaryAccessoryViewSizeBlock = ^CGSize(CGSize layoutSize, UIView *aView) {
      if (!imageLabelsComponent.imageViewSizeBlock) {
        webImageView.frame = CGRectZero;
        imageView.frame = CGRectZero;
        return CGSizeZero;
      }
      CGSize accessoryViewSize =
          imageLabelsComponent.imageViewSizeBlock(layoutSize, imageLabelsComponent);
      // Center the image view inside the accessory view.
      CGRect imageViewFrame = CGRectZero;
      if (webImageComponent) {
        if (webImageComponent.sizeBlock) {
          CGSize imageSize = webImageComponent.sizeBlock(layoutSize, webImageComponent);
          imageViewFrame.origin.x = (accessoryViewSize.width - imageSize.width) / 2.0f;
          imageViewFrame.origin.y = (accessoryViewSize.height - imageSize.height) / 2.0f;
          imageViewFrame.size = imageSize;
        } else {
          NSCAssert(NO, @"Image component does not have a size block.");
        }
        webImageView.frame = CGRectIntegral(imageViewFrame);
        // REWORK.
        webImageView.layer.cornerRadius = CGRectGetWidth(imageViewFrame) / 2.0f;
      } else {
        webImageView.frame = CGRectZero;
      }
      if (imageComponent) {
        if (imageComponent.sizeBlock) {
          CGSize imageSize = imageComponent.sizeBlock(layoutSize, imageComponent);
          imageViewFrame.origin.x = (accessoryViewSize.width - imageSize.width) / 2.0f;
          imageViewFrame.origin.y = (accessoryViewSize.height - imageSize.height) / 2.0f;
          imageViewFrame.size = imageSize;
        } else {
          NSCAssert(NO, @"Image component does not have a size block.");
        }
        imageView.frame = CGRectIntegral(imageViewFrame);
      } else {
        imageView.frame = CGRectZero;
      }
      return accessoryViewSize;
    };

    // Update the image views.
    [GILWebImageComponent updateView:webImageView withComponent:webImageComponent];
    [GILImageViewComponent updateView:imageView withComponent:imageComponent];
    [titleLabelsView.primaryAccessoryView setNeedsLayout];

    // Update the titles.
    [GILAttributedLabelComponent updateView:titleLabelsView.title
                              withComponent:imageLabelsComponent.titleComponent];
    [GILAttributedLabelComponent updateView:titleLabelsView.subtitle
                              withComponent:imageLabelsComponent.subtitleComponent];
    titleLabelsView.padding = imageLabelsComponent.padding;
    titleLabelsView.backgroundColor = imageLabelsComponent.backgroundColor;

    [titleLabelsView setNeedsLayout];
    return YES;
  }
}

+ (UIView *)view {
  return ImageTitleLabelsView();
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(GILImageLabelsComponent *)component {
  NSAssert([NSThread isMainThread], @"Must be called on the main thread");

  if ([component isKindOfClass:[GILViewComponentNull class]] || !component) {
    return CGSizeZero;
  } else if (![component isKindOfClass:[GILImageLabelsComponent class]]) {
    NSAssert(NO, @"Unexpected view component type.");
    return CGSizeZero;
  } else {
    static GILTitleLabelsView *sizeCalculationView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sizeCalculationView = ImageTitleLabelsView();
    });

    // Populate data
    [GILImageLabelsComponent updateView:sizeCalculationView withComponent:component];
    return [sizeCalculationView sizeThatFits:size];
  }
}

@end
