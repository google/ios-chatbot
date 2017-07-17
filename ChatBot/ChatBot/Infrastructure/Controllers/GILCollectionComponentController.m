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

#import "GILCollectionComponentController.h"

#import "GILCellViewComponent.h"
#import "GILComponentDataSource.h"
#import "GILComponentDataSourceSection.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GILCollectionComponentController

- (nullable instancetype)init {
  NSAssert(NO, @"Init is not available.");
  return nil;
}

- (instancetype)initWithCollectionView:(nullable UICollectionView *)collectionView
                         cellSizeBlock:(nullable GILCollectionComponentSizeBlock)cellSizeBlock {
  self = [super init];
  if (!collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView =
        [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
  } else {
    _collectionView = collectionView;
  }
  _collectionView.delegate = self;
  _collectionView.dataSource = self;
  _cellSizeBlock = [cellSizeBlock copy];
  return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return [self.data sectionCount];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
  return [[self.data section:section] componentsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  id<GILCellViewComponent> component = [self cellComponentForIndexPath:indexPath];
  if (component) {
    UICollectionViewCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:[[component class] reuseIdentifier]
                                                  forIndexPath:indexPath];
    [[component class] updateView:cell withComponent:component];
    return cell;
  } else {
    return nil;
  }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  id<GILCellViewComponent> component = [self cellComponentForIndexPath:indexPath];
  if (!component) {
    NSAssert(NO, @"");
    return CGSizeZero;
  }
  if (_cellSizeBlock) {
    return _cellSizeBlock(collectionView, collectionViewLayout, component, indexPath);
  } else if ([[component class] respondsToSelector:@selector(sizeThatFits:forComponent:)]) {
    return [[component class] sizeThatFits:collectionView.bounds.size forComponent:component];
  } else {
    return collectionView.bounds.size;
  }
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  if ([self.delegate respondsToSelector:@selector(controller:didScrollWithContentOffset:)]) {
    [self.delegate controller:self didScrollWithContentOffset:scrollView.contentOffset];
  }
}

#pragma mark - Private helpers.

- (id<GILCellViewComponent>)cellComponentForIndexPath:(NSIndexPath *)indexPath {
  id<GILViewComponent> component = [self.data componentForIndexPath:indexPath];
  if ([component conformsToProtocol:@protocol(GILCellViewComponent)]) {
    return (id<GILCellViewComponent>)component;
  }
  return nil;
}

- (void)dealloc {
  _collectionView.dataSource = nil;
  _collectionView.delegate = nil;
}

@end

NS_ASSUME_NONNULL_END
