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

#import "GILLabeledImageView.h"

#import "UIColor+GILAdditions.h"
#import "GILWebImageView.h"

static const CGFloat kImageLabelFontSize = 14.0f;
static const NSUInteger kImageLabelTextColor = 0xFFFFFFFF;
static const NSUInteger kImageLabelBackgroundColor = 0xFF000000;
static const CGFloat kImageLabelRighPadding = 8.0f;
static const CGFloat kImageLabelLeftPadding = -2.0f;
static const CGFloat kImageLabelTopPadding = 4.0f;

@implementation GILLabeledImageView {
  GILWebImageView *_imageView;
  UILabel *_imageLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self GIL_commonInit];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self GIL_commonInit];
  return self;
}

- (void)GIL_commonInit {
  _imageView = [[GILWebImageView alloc] init];
  _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _imageView.contentMode = UIViewContentModeScaleAspectFill;
  [self addSubview:_imageView];
  _imageLabel = [[UILabel alloc] init];
  _imageLabel.font = [UIFont systemFontOfSize:kImageLabelFontSize];
  _imageLabel.textColor = [UIColor gil_colorWithARGB:kImageLabelTextColor];
  _imageLabel.backgroundColor = [UIColor gil_colorWithARGB:kImageLabelBackgroundColor];
  [self addSubview:_imageLabel];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  if (_imageLabel.text) {
    [_imageLabel sizeToFit];
    CGFloat imageWidth =
        CGRectGetWidth(self.bounds) - kImageLabelRighPadding - kImageLabelLeftPadding;
    CGFloat imageHeight = CGRectGetHeight(_imageLabel.bounds);
    CGRect imageLabelFrame =
        CGRectMake(kImageLabelLeftPadding, kImageLabelTopPadding, imageWidth, imageHeight);
    _imageLabel.frame = CGRectIntegral(imageLabelFrame);
  } else {
    _imageLabel.frame = CGRectZero;
  }
}

#pragma mark - Property overrides

- (void)setImageLabelText:(NSString *)imageLabelText {
  _imageLabelText = imageLabelText;
  _imageLabel.text = imageLabelText;
  [self setNeedsLayout];
}

- (void)setImageURL:(NSURL *)imageURL {
  _imageURL = imageURL;
  // TODO(bobyliu): Handle network related image download race conditions if GMONowFIFEImageView
  // doesn't already handle it.
  [((GILWebImageView *)_imageView) setImageURL:imageURL placehoderImage:nil];
}

@end
