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

#import "GILCarouselView.h"

#import "GILCollectionComponentController.h"
#import "GILComponentDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GILCarouselView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self GIL_commonInit];
  return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self GIL_commonInit];
  return self;
}

- (void)GIL_commonInit {
  UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
  // Configure layout.
  layout.minimumLineSpacing = 8.0f;
  layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

  UICollectionView *collectionView =
      [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
  // Register the classes externally.

  GILCollectionComponentController *controller =
      [[GILCollectionComponentController alloc] initWithCollectionView:collectionView
                                                         cellSizeBlock:NULL];

  GILComponentDataSource *data = [[GILComponentDataSource alloc] init];
  controller.data = data;
  _controller = controller;
  [self addSubview:controller.collectionView];
}

- (CGSize)sizeThatFits:(CGSize)size {
  if (_sizeBlock) {
    CGRect layoutArea = CGRectMake(0.0f, 0.0f, size.width, size.height);
    layoutArea = UIEdgeInsetsInsetRect(layoutArea, _padding);
    CGSize carouselSize = _sizeBlock(size, self);
    carouselSize.height += self.padding.top + self.padding.bottom;
    return carouselSize;
  } else {
    return size;
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGRect layoutArea = UIEdgeInsetsInsetRect(self.bounds, _padding);
  _controller.collectionView.frame = layoutArea;
}

@end

NS_ASSUME_NONNULL_END
