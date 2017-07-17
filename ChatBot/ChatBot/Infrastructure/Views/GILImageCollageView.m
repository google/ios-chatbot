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

#import "GILImageCollageView.h"

#import "GILWebImageView.h"

static const CGFloat kImageSpacingInCollage = 2.0f;
static const NSInteger kMaximumNumberOfImages = 3;

@implementation GILImageCollageView {
  NSArray<GILWebImageView *> *_imageViews;
}

- (instancetype)initWithMaximumNumberOfImages:(NSInteger)maximumNumberOfImages {
  self = [super initWithFrame:CGRectZero];
  [self GIL_commonInitWithMaximumNumberOfImages:maximumNumberOfImages
                                   imageSpacing:kImageSpacingInCollage];
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self GIL_commonInitWithMaximumNumberOfImages:kMaximumNumberOfImages
                                   imageSpacing:kImageSpacingInCollage];
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self GIL_commonInitWithMaximumNumberOfImages:kMaximumNumberOfImages
                                   imageSpacing:kImageSpacingInCollage];
  return self;
}

- (void)GIL_commonInitWithMaximumNumberOfImages:(NSInteger)maximumNumberOfImages
                                   imageSpacing:(CGFloat)imageSpacing {
  NSMutableArray<GILWebImageView *> *imageViews = [NSMutableArray array];
  for (NSInteger i = 0; i < maximumNumberOfImages; i++) {
    GILWebImageView *imageView = [[GILWebImageView alloc] init];
    // Enable clip to bounds on the image view by default.
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageViews addObject:imageView];
    [self addSubview:imageView];
  }
  _imageViews = [imageViews copy];
  _maximumNumberOfImages = maximumNumberOfImages;
  _imageSpacing = imageSpacing;
  _numberOfImagesToDisplay = maximumNumberOfImages;
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGRect remainderFrame =
      CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
  CGRectEdge edge = CGRectMinXEdge;
  for (NSInteger i = 0; i < _numberOfImagesToDisplay; i++) {
    CGRect imageViewFrame;
    if (i == _numberOfImagesToDisplay - 1) {
      imageViewFrame = remainderFrame;
    } else {
      CGFloat dividingLength = 0.0f;
      if (edge == CGRectMinXEdge) {
        dividingLength = CGRectGetWidth(remainderFrame) / 2.0f;
      } else {
        dividingLength = CGRectGetHeight(remainderFrame) / 2.0f;
      }

      CGRectDivide(remainderFrame, &imageViewFrame, &remainderFrame, dividingLength, edge);

      CGFloat collageSpacingAdjustment = _imageSpacing / 2.0f;
      if (edge == CGRectMinXEdge) {
        imageViewFrame.size.width -= collageSpacingAdjustment;
        remainderFrame.size.width -= collageSpacingAdjustment;
        remainderFrame.origin.x += collageSpacingAdjustment;
        edge = CGRectMinYEdge;
      } else {
        imageViewFrame.size.height -= collageSpacingAdjustment;
        remainderFrame.size.height -= collageSpacingAdjustment;
        remainderFrame.origin.y += collageSpacingAdjustment;
        edge = CGRectMinXEdge;
      }
    }
    _imageViews[i].frame = CGRectIntegral(imageViewFrame);
  }

  for (NSInteger i = _numberOfImagesToDisplay; i < _maximumNumberOfImages; i++) {
    _imageViews[i].frame = CGRectZero;
  }
}

#pragma mark - Property overrides.

- (void)setImageSpacing:(CGFloat)imageSpacing {
  if (_imageSpacing != imageSpacing) {
    _imageSpacing = imageSpacing;
    [self setNeedsLayout];
  }
}

- (void)setImageURLs:(NSArray<NSURL *> *)imageURLs {
  if (![_imageURLs isEqual:imageURLs]) {
    _imageURLs = [imageURLs copy];
    NSInteger URLCount = _imageURLs.count;

    if (URLCount > _maximumNumberOfImages) {
      NSAssert(NO, @"More image URLs than expected provided.");
    }

    for (NSInteger i = 0; i < _maximumNumberOfImages; i++) {
      if (i < URLCount) {
        [_imageViews[i] setImageURL:_imageURLs[i] placehoderImage:nil];
      } else {
        [_imageViews[i] setImageURL:nil placehoderImage:nil];
      }
    }
    [self setNeedsLayout];
  }
}

- (void)setImageContentMode:(UIViewContentMode)imageContentMode {
  if (_imageContentMode != imageContentMode) {
    _imageContentMode = imageContentMode;
    [_imageViews
        enumerateObjectsUsingBlock:^(GILWebImageView *imageView, NSUInteger idx, BOOL *stop) {
          imageView.contentMode = imageContentMode;
        }];
  }
}

- (void)setNumberOfImagesToDisplay:(NSInteger)numberOfImagesToDisplay {
  if (_numberOfImagesToDisplay != numberOfImagesToDisplay) {
    _numberOfImagesToDisplay = numberOfImagesToDisplay;
    [self setNeedsLayout];
  }
}

@end
