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

#import "GILCarouselComponent.h"

#import "GILCarouselView.h"
#import "GILCollectionComponentController.h"
#import "GILComponentDataSource.h"
#import "GILComponentDataSourceSection.h"

NS_ASSUME_NONNULL_BEGIN

@implementation GILCarouselComponent {
  GILComponentDataSource *_data;
}

- (instancetype)initWithCellComponents:(NSArray<id<GILCellViewComponent>> *)cellComponents
                          contentInset:(UIEdgeInsets)contentInset
                               padding:(UIEdgeInsets)padding
                       backgroundColor:(UIColor *)backgroundColor
                         cellSizeBlock:(GILCollectionComponentSizeBlock)cellSizeBlock
                             sizeBlock:(GILViewComponentSizeBlock)sizeBlock {
  // Extract cell classes and reuse identifiers
  NSMutableOrderedSet *cellClassSet =
      [NSMutableOrderedSet orderedSetWithCapacity:cellComponents.count];
  NSMutableOrderedSet *cellReuseIdentifierSet =
      [NSMutableOrderedSet orderedSetWithCapacity:cellComponents.count];
  [cellComponents enumerateObjectsUsingBlock:^(id<GILCellViewComponent> _Nonnull obj,
                                               NSUInteger idx, BOOL *_Nonnull stop) {
    [cellClassSet addObject:[[obj class] cellClass]];
    [cellReuseIdentifierSet addObject:[[obj class] reuseIdentifier]];
  }];

  return [self initWithCellClasses:[cellClassSet array]
              cellReuseIdentifiers:[cellReuseIdentifierSet array]
                    cellComponents:cellComponents
                      contentInset:contentInset
                           padding:padding
                   backgroundColor:backgroundColor
                     cellSizeBlock:cellSizeBlock
                         sizeBlock:sizeBlock];
}

- (instancetype)initWithCellClasses:(NSArray<Class> *)cellClasses
               cellReuseIdentifiers:(NSArray<NSString *> *)cellReuseIdentifiers
                     cellComponents:(NSArray<id<GILCellViewComponent>> *)cellComponents
                       contentInset:(UIEdgeInsets)contentInset
                            padding:(UIEdgeInsets)padding
                    backgroundColor:(UIColor *)backgroundColor
                      cellSizeBlock:(GILCollectionComponentSizeBlock)cellSizeBlock
                          sizeBlock:(GILViewComponentSizeBlock)sizeBlock {
  self = [super init];
  _cellClasses = [cellClasses copy];
  _cellReuseIdentifiers = [cellReuseIdentifiers copy];
  _cellComponents = [cellComponents copy];
  _contentInset = contentInset;
  _padding = padding;
  _backgroundColor = [backgroundColor copy];

  if (!cellSizeBlock) {
    NSAssert(NO, @"cellSizeBlock is NULL.");
  }
  _cellSizeBlock = [cellSizeBlock copy];
  if (!sizeBlock) {
    NSAssert(NO, @"sizeBlock is NULL");
  }
  _sizeBlock = [sizeBlock copy];

  // Since the component is read only, build the data source so it is not rebuild every time the
  // carousel is updated.
  GILComponentDataSourceSection *section = [[GILComponentDataSourceSection alloc] init];
  if (cellComponents.count) {
    section.components = [NSMutableArray arrayWithArray:cellComponents];
  }
  _data = [[GILComponentDataSource alloc] init];
  [_data addSection:section];

  return self;
}

- (nullable instancetype)init {
  NSAssert(NO, @"");
  return nil;
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(nullable NSZone *)zone {
  return self;
}

#pragma mark - GILViewComponent

+ (UIView *)view {
  return [[GILCarouselView alloc] initWithFrame:CGRectZero];
}

+ (BOOL)updateView:(UIView *)view withComponent:(nullable id<GILViewComponent>)component {
  if (![view isKindOfClass:[GILCarouselView class]]) {
    NSAssert(NO, @"Unexpected view type.");
    return NO;
  }

  GILCarouselView *carouselView = (GILCarouselView *)view;

  GILCarouselComponent *carouselComponent = nil;
  if ([component isKindOfClass:[GILCarouselComponent class]]) {
    carouselComponent = (GILCarouselComponent *)component;
  } else if (component && ![component isKindOfClass:[self class]]) {
    NSAssert(NO, @"Unexpected view component type.");
  }

  if ([component isKindOfClass:[GILCarouselComponent class]]) {
    carouselComponent = (GILCarouselComponent *)component;
  }

  // Register cells
  if (carouselComponent.cellClasses.count == carouselComponent.cellReuseIdentifiers.count) {
    [carouselComponent.cellClasses
        enumerateObjectsUsingBlock:^(Class _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
          [carouselView.controller.collectionView
                           registerClass:obj
              forCellWithReuseIdentifier:carouselComponent.cellReuseIdentifiers[idx]];
        }];
  } else {
    NSAssert(NO, @"Numbers of cell classes and identifiers do not match.");
  }

  carouselView.controller.cellSizeBlock = carouselComponent.cellSizeBlock;

  GILCarouselViewSizeBlock sizeBlock = NULL;
  if (carouselComponent.sizeBlock) {
    sizeBlock = ^CGSize(CGSize layoutSize, GILCarouselView *aCarouselView) {
      return carouselComponent.sizeBlock(layoutSize, carouselComponent);
    };
  }
  carouselView.sizeBlock = sizeBlock;

  carouselView.controller.collectionView.contentInset = carouselComponent.contentInset;

  carouselView.controller.data = carouselComponent->_data;

  carouselView.controller.collectionView.backgroundColor = carouselComponent.backgroundColor;
  // Add more refined controls.
  [carouselView.controller.collectionView reloadData];

  return YES;
}

+ (CGSize)sizeThatFits:(CGSize)size forComponent:(nullable id<GILViewComponent>)component {
  if ([component isKindOfClass:[GILCarouselComponent class]]) {
    GILCarouselComponent *carouselComponent = (GILCarouselComponent *)component;
    if (carouselComponent.sizeBlock) {
      CGRect layoutArea = CGRectMake(0.0f, 0.0f, size.width, size.height);
      layoutArea = UIEdgeInsetsInsetRect(layoutArea, carouselComponent.padding);
      CGSize carouselSize = carouselComponent.sizeBlock(layoutArea.size, component);
      carouselSize.height += carouselComponent.padding.top + carouselComponent.padding.bottom;
      return carouselSize;
    } else {
      return size;
    }
  } else if (component && ![component isKindOfClass:[self class]]) {
    NSAssert(NO, @"Unexpected view component type.");
  }
  return CGSizeZero;
}

@end

NS_ASSUME_NONNULL_END
