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

#import "CBViewController.h"

#import <AVFoundation/AVFoundation.h>

#import "CBChatBubbleView.h"
#import "CBDefines.h"
#import "CBImageMessageCellComponent.h"
#import "CBLoadingIndicatorMessageCellComponent.h"
#import "CBMessageCellComponent.h"
#import "CBSystemMessageCellComponent.h"
#import "CBTranslationService.h"
#import "DemoMapViewController.h"
#import "GILAttributedLabelComponent.h"
#import "GILCollectionComponentController.h"
#import "GILComponentDataSource.h"
#import "GILComponentDataSourceSection.h"
#import "GILImageLabelsComponent.h"
#import "SpeechRecognitionService.h"
#import "CBLandmarkDetectionService.h"
#import "UIColor+GILAdditions.h"
#import "UIView+GILAutolayoutAdditions.h"
#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"

typedef void (^ActionButtonTapEventBlock)(void);

static UIEdgeInsets MessageInsets(void) { return UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 8.0f); }

static const NSUInteger kUserBubbleColor = 0xFF2A9AF3;
static const NSUInteger kUserMessageColor = 0xFFFFFFFF;
static const NSUInteger kAgentBubbleColor = 0xFFE5E5EA;
static const NSUInteger kAgentMessageColor = 0xFF000000;

static const NSString *kInquiryParadesActionKey = @"inquiry.parades";
static const NSString *kInquiryWhereActionKey = @"inquiry.where";
static const NSString *kInquiryTranslateActionKey = @"inquiry.translate";
static const NSString *kUploadUserImageActionKey = @"upload-user-image";
static const NSString *kInquiryWhereLocationMapActionKey = @"inquiry.where.location.map";

static const CGFloat kInputAreaHeight = 64.0f;

static NSString *const kMicRecordingAnimationKey = @"kMicRecordingAnimationKey";

static UIFont *SystemMessageFont(void) { return [UIFont fontWithName:@"HelveticaNeue" size:16.0f]; }

static UIFont *MessageFont(void) { return [UIFont fontWithName:@"HelveticaNeue" size:20.0f]; }

static NSDictionary *TextAttributes(UIFont *font, UIColor *foregroundColor) {
  NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
  if (font) {
    [attributes setValue:font forKey:NSFontAttributeName];
  }
  NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
  paragraph.maximumLineHeight = font.lineHeight;
  paragraph.minimumLineHeight = font.lineHeight;
  [attributes setValue:paragraph forKey:NSParagraphStyleAttributeName];

  if (foregroundColor) {
    [attributes setValue:foregroundColor forKey:NSForegroundColorAttributeName];
  }

  return [attributes copy];
}

static NSAttributedString *AttributedText(NSString *titleText,
                                          UIFont *font,
                                          UIColor *_Nullable textColor) {
  NSCAssert(titleText, @"Title text cannot be nil");
  NSCAssert(font, @"Font cannot be nil");
  NSDictionary *attributes = TextAttributes(font, textColor ?: [UIColor blackColor]);
  NSAttributedString *titleString =
      [[NSAttributedString alloc] initWithString:titleText ?: @"" attributes:attributes];
  return titleString;
}

static CBMessageCellComponent *MessageCellComponent(NSString *message,
                                                    NSString *actionButtonImageName,
                                                    ActionButtonTapEventBlock eventBlock,
                                                    CBChatBubbleArrowPosition arrowPosition) {
  UIColor *messageColor = nil;
  if (arrowPosition == CBChatBubbleArrowPositionRight) {
    messageColor = [UIColor gil_colorWithARGB:kUserMessageColor];
  } else {
    messageColor = [UIColor gil_colorWithARGB:kAgentMessageColor];
  }
  NSAttributedString *attributedText = AttributedText(message, MessageFont(), messageColor);
  GILAttributedLabelComponent *labelComponent =
      [[GILAttributedLabelComponent alloc] initWithAttributedString:attributedText
                                                      numberOfLines:0
                                                      textAlignment:NSTextAlignmentNatural
                                                      lineBreakMode:NSLineBreakByWordWrapping
                                                    backgroundColor:[UIColor clearColor]];
  UIColor *bubbleColor = nil;
  if (arrowPosition == CBChatBubbleArrowPositionRight) {
    bubbleColor = [UIColor gil_colorWithARGB:kUserBubbleColor];
  } else {
    bubbleColor = [UIColor gil_colorWithARGB:kAgentBubbleColor];
  }
  CBMessageCellComponent *messageCellComponent =
      [[CBMessageCellComponent alloc] initWithMessageComponent:labelComponent
                                         actionButtonImageName:actionButtonImageName
                                     actionButtonTapEventBlock:eventBlock
                                                 arrowPosition:arrowPosition
                                               backgroundColor:[UIColor whiteColor]
                                                   bubbleColor:bubbleColor
                                                       padding:MessageInsets()
                                      maxBubbleWidthPercentage:0.7];
  return messageCellComponent;
}

static CBImageMessageCellComponent *ImageMessageCellComponent(
    UIImage *image, CBChatBubbleArrowPosition arrowPosition) {
  UIColor *messageColor = nil;
  if (arrowPosition == CBChatBubbleArrowPositionRight) {
    messageColor = [UIColor gil_colorWithARGB:kUserMessageColor];
  } else {
    messageColor = [UIColor gil_colorWithARGB:kAgentMessageColor];
  }

  UIColor *bubbleColor = nil;
  if (arrowPosition == CBChatBubbleArrowPositionRight) {
    bubbleColor = [UIColor gil_colorWithARGB:kUserBubbleColor];
  } else {
    bubbleColor = [UIColor gil_colorWithARGB:kAgentBubbleColor];
  }
  CBImageMessageCellComponent *imageMessageCellComponent = [[CBImageMessageCellComponent alloc]
                 initWithImage:image
                 arrowPosition:arrowPosition
               backgroundColor:[UIColor whiteColor]
                   bubbleColor:bubbleColor
                       padding:MessageInsets()
      maxBubbleWidthPercentage:0.7
            imageViewSizeBlock:^CGSize(CGSize layoutSize, UIView *_Nonnull view) {
              layoutSize.height = 200.0f;
              return layoutSize;
            }];
  return imageMessageCellComponent;
}

static CBLoadingIndicatorMessageCellComponent *LoadingIndicatorCellComponent(
    CBChatBubbleArrowPosition arrowPosition) {
  UIColor *messageColor = nil;
  if (arrowPosition == CBChatBubbleArrowPositionRight) {
    messageColor = [UIColor gil_colorWithARGB:kUserMessageColor];
  } else {
    messageColor = [UIColor gil_colorWithARGB:kAgentMessageColor];
  }

  UIColor *bubbleColor = nil;
  if (arrowPosition == CBChatBubbleArrowPositionRight) {
    bubbleColor = [UIColor gil_colorWithARGB:kUserBubbleColor];
  } else {
    bubbleColor = [UIColor gil_colorWithARGB:kAgentBubbleColor];
  }
  CBLoadingIndicatorMessageCellComponent *indicatorCellComponent =
      [[CBLoadingIndicatorMessageCellComponent alloc] initWithArrowPosition:arrowPosition
                                                            backgroundColor:[UIColor whiteColor]
                                                                bubbleColor:bubbleColor
                                                                    padding:MessageInsets()
                                                   maxBubbleWidthPercentage:0.7
                                                         indicatorSizeBlock:NULL];
  return indicatorCellComponent;
}

static CBSystemMessageCellComponent *SystemMessageCellComponent(NSString *message) {
  NSAttributedString *attributedText =
      AttributedText(message, SystemMessageFont(), [UIColor lightGrayColor]);
  GILAttributedLabelComponent *labelComponent =
      [[GILAttributedLabelComponent alloc] initWithAttributedString:attributedText
                                                      numberOfLines:0
                                                      textAlignment:NSTextAlignmentNatural
                                                      lineBreakMode:NSLineBreakByWordWrapping
                                                    backgroundColor:[UIColor clearColor]];

  CBSystemMessageCellComponent *messageCellComponent =
      [[CBSystemMessageCellComponent alloc] initWithMessageComponent:labelComponent
                                                     backgroundColor:[UIColor whiteColor]
                                                             padding:MessageInsets()];
  return messageCellComponent;
}

static NSError *CustomError(NSString *message) {
  NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: message ?: @"" };
  return [NSError errorWithDomain:@"com.chatbot.customerror" code:-1 userInfo:userInfo];
}

@interface CBViewController () <UITextFieldDelegate> {
  UIView *_contentView;
  UIView *_inputWrapperView;
  UITextField *_inputTextField;
  GILCollectionComponentController *_collectionController;
  NSLayoutConstraint *_contentViewTopLayoutConstraint;
  NSLayoutConstraint *_contentViewBottomLayoutConstraint;
  NSString *_sessionIdentifier;
  NSDateFormatter *_RFC3339DateFormatter;
  BOOL _recording;
  AudioComponentInstance _remoteIOUnit;
  NSMutableData *_audioData;
  UIButton *_micButton;
}
@end

@implementation CBViewController

- (void)dealloc {
  AudioComponentInstanceDispose(_remoteIOUnit);
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _audioData = [[NSMutableData alloc] init];
  self.view.backgroundColor = [UIColor whiteColor];

  // Add the content view for all subviews in this controller.
  _contentView = [[UIView alloc] initWithFrame:CGRectZero];
  _contentView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:_contentView];
  NSArray<NSLayoutConstraint *> *constraints =
      [self.view gil_pinSubview:_contentView withMargins:UIEdgeInsetsZero];
  _contentViewTopLayoutConstraint = constraints.firstObject;
  _contentViewBottomLayoutConstraint = constraints[2];

  // Add input wrapper
  _inputWrapperView = [[UIView alloc] initWithFrame:CGRectZero];
  _inputWrapperView.translatesAutoresizingMaskIntoConstraints = NO;
  [_contentView addSubview:_inputWrapperView];
  [_inputWrapperView gil_addHeightConstraint:kInputAreaHeight
                          withLayoutRelation:NSLayoutRelationEqual];
  [_contentView gil_addLeadingMargin:0.0f
                           toSubview:_inputWrapperView
                  withLayoutRelation:NSLayoutRelationEqual];
  [_contentView gil_addBottomMargin:0.0f
                          toSubview:_inputWrapperView
                 withLayoutRelation:NSLayoutRelationEqual];
  [_contentView gil_addTrailingMargin:0.0f
                            toSubview:_inputWrapperView
                   withLayoutRelation:NSLayoutRelationEqual];

  // Add input view.
  _inputTextField = [[UITextField alloc] initWithFrame:CGRectZero];
  _inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
  _inputTextField.borderStyle = UITextBorderStyleRoundedRect;
  [_inputWrapperView addSubview:_inputTextField];
  [_inputWrapperView gil_pinSubview:_inputTextField
                        withMargins:UIEdgeInsetsMake(8.0f, 8.0f, 8.0f, 60.0f)];
  _inputTextField.delegate = self;
  _inputTextField.placeholder = @"Message";
  _inputTextField.font = MessageFont();

  // Add Mic button
  _micButton = [UIButton buttonWithType:UIButtonTypeSystem];
  [_micButton addTarget:self
                 action:@selector(didTapMic:)
       forControlEvents:UIControlEventTouchUpInside];
  _micButton.translatesAutoresizingMaskIntoConstraints = NO;
  [_micButton setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
  [_inputWrapperView addSubview:_micButton];
  [_inputWrapperView gil_addTopMargin:8.0f
                            toSubview:_micButton
                   withLayoutRelation:NSLayoutRelationEqual];
  [_inputWrapperView gil_addTrailingMargin:8.0f
                                 toSubview:_micButton
                        withLayoutRelation:NSLayoutRelationEqual];
  [_inputWrapperView gil_addBottomMargin:8.0f
                               toSubview:_micButton
                      withLayoutRelation:NSLayoutRelationEqual];
  [_inputWrapperView gil_addHorizontalSpacing:8.0f
                                     fromView:_inputTextField
                                       toView:_micButton
                           withLayoutRelation:NSLayoutRelationEqual];

  // Add the connection view.
  _collectionController =
      [[GILCollectionComponentController alloc] initWithCollectionView:nil cellSizeBlock:NULL];
  UICollectionView *collectionView = _collectionController.collectionView;
  collectionView.translatesAutoresizingMaskIntoConstraints = NO;
  collectionView.backgroundColor = [UIColor whiteColor];
  collectionView.alwaysBounceVertical = YES;

  // Register cell types.
  [collectionView registerClass:[CBMessageCellComponent cellClass]
      forCellWithReuseIdentifier:[CBMessageCellComponent reuseIdentifier]];
  [collectionView registerClass:[CBSystemMessageCellComponent cellClass]
      forCellWithReuseIdentifier:[CBSystemMessageCellComponent reuseIdentifier]];
  [collectionView registerClass:[CBImageMessageCellComponent cellClass]
      forCellWithReuseIdentifier:[CBImageMessageCellComponent reuseIdentifier]];
  [collectionView registerClass:[CBLoadingIndicatorMessageCellComponent cellClass]
      forCellWithReuseIdentifier:[CBLoadingIndicatorMessageCellComponent reuseIdentifier]];

  [_contentView addSubview:_collectionController.collectionView];
  [_contentView gil_addTopMargin:0.0f
                       toSubview:collectionView
              withLayoutRelation:NSLayoutRelationEqual];
  [_contentView gil_addLeadingMargin:0.0f
                           toSubview:collectionView
                  withLayoutRelation:NSLayoutRelationEqual];
  [_contentView gil_addTrailingMargin:0.0f
                            toSubview:collectionView
                   withLayoutRelation:NSLayoutRelationEqual];
  [_contentView gil_addVerticalSpacing:0.0f
                              fromView:collectionView
                                toView:_inputWrapperView
                    withLayoutRelation:NSLayoutRelationEqual];

  GILComponentDataSourceSection *section = [[GILComponentDataSourceSection alloc] init];
  [section addComponent:SystemMessageCellComponent(@"The agent is online.")];

  GILComponentDataSource *data = [[GILComponentDataSource alloc] init];
  [data addSection:section];
  _collectionController.data = data;

  _sessionIdentifier = [NSUUID UUID].UUIDString;
  NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
  _RFC3339DateFormatter = [[NSDateFormatter alloc] init];
  [_RFC3339DateFormatter setLocale:enUSPOSIXLocale];
  [_RFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
  [_RFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

  if (!self.automaticallyAdjustsScrollViewInsets) {
    _collectionController.collectionView.contentInset = _scrollAreaInset;
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection
              withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];

  [_contentView setNeedsLayout];
  [_collectionController.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  if (self.automaticallyAdjustsScrollViewInsets) {
    CGFloat insetTop = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    _collectionController.collectionView.contentInset =
        UIEdgeInsetsMake(insetTop, 0.0f, 0.0f, 0.0f);
  }
}

#pragma mark - Property overrides

- (void)setScrollAreaInset:(UIEdgeInsets)scrollAreaInset {
  _scrollAreaInset = scrollAreaInset;
  _collectionController.collectionView.contentInset = scrollAreaInset;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  NSString *queryText = textField.text;
  if (queryText.length > 0) {
    textField.text = @"";
    [self sendText:queryText];
  }
  return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];
  CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
  NSInteger curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

  [UIView animateWithDuration:duration
                        delay:0
                      options:curve
                   animations:^{
                     self->_contentViewTopLayoutConstraint.constant = -keyboardSize.height;
                     self->_contentViewBottomLayoutConstraint.constant = keyboardSize.height;
                     [self.view setNeedsLayout];
                     [self.view layoutIfNeeded];
                   }
                   completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *info = [notification userInfo];
  NSInteger curve = [info[UIKeyboardAnimationCurveUserInfoKey] integerValue];
  NSTimeInterval duration = [info[UIKeyboardAnimationDurationUserInfoKey] doubleValue];

  [UIView animateWithDuration:duration
                        delay:0
                      options:curve
                   animations:^{
                     self->_contentViewTopLayoutConstraint.constant = 0.0f;
                     self->_contentViewBottomLayoutConstraint.constant = 0.0f;
                     [self.view setNeedsLayout];
                     [self.view layoutIfNeeded];
                   }
                   completion:nil];
}

#pragma mark - Request operations

- (void)sendAIRequestWithQuery:(NSString *)query
                    completion:(void (^)(NSDictionary *JSONData, NSError *error))completion {
  if (!completion) {
    return;
  }

  NSURLComponents *URLComponents = [[NSURLComponents alloc] init];
  URLComponents.scheme = @"https";
  URLComponents.host = @"api.api.ai";
  URLComponents.path = @"/api/query";
  NSURLQueryItem *versionItem = [NSURLQueryItem queryItemWithName:@"v" value:@"20150910"];
  NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:@"query" value:query];
  NSURLQueryItem *sessionIDItem =
      [NSURLQueryItem queryItemWithName:@"sessionId" value:_sessionIdentifier];
  NSURLQueryItem *languageItem = [NSURLQueryItem queryItemWithName:@"lang" value:@"en"];
  NSString *dateString = [_RFC3339DateFormatter stringFromDate:[NSDate date]];
  NSURLQueryItem *timezoneItem = [NSURLQueryItem queryItemWithName:@"timezone" value:dateString];

  URLComponents.queryItems = @[versionItem, queryItem, sessionIDItem, languageItem, timezoneItem];

  NSURLSession *session = [NSURLSession sharedSession];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URLComponents.URL];

  NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", _clientAccessToken];
  [request addValue:authorizationString forHTTPHeaderField:@"Authorization"];

  NSURLSessionDataTask *task = [session
      dataTaskWithRequest:request
        completionHandler:^(
            NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
          NSDictionary *JSONData = nil;
          NSHTTPURLResponse *httpURLResponse = nil;
          if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpURLResponse = (NSHTTPURLResponse *)response;
          }
          if (httpURLResponse.statusCode < 200 || httpURLResponse.statusCode >= 300) {
            NSString *errorString = [NSString
                stringWithFormat:@"Unexpected status code: %@", @(httpURLResponse.statusCode)];
            error = CustomError(errorString);
          } else if (!error) {
            id parsedData =
                [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            if ([parsedData isKindOfClass:[NSDictionary class]]) {
              JSONData = parsedData;
            } else {
              error = CustomError(@"Empty server response.");
            }
          }
          dispatch_async(dispatch_get_main_queue(), ^{
            completion(JSONData, error);
          });
        }];
  [task resume];
}

#pragma mark - Helpers

- (void)sendText:(NSString *)text {
  [self addCellComponent:MessageCellComponent(text, nil, NULL, CBChatBubbleArrowPositionRight)];
  __weak CBViewController *weakSelf = self;
  NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
  [self sendAIRequestWithQuery:text
                    completion:^(NSDictionary *JSONData, NSError *error) {
                      CBViewController *strongSelf = weakSelf;
                      if (!strongSelf) {
                        return;
                      }
                      [strongSelf processResponseJSONData:JSONData
                                                    error:error
                                         requestStartTime:startTime];
                    }];
}

- (void)addMessage:(NSString *)message
    actionButtonImageName:(NSString *)actioinButtonImageName
            tapEventBlock:(ActionButtonTapEventBlock)tapEventBlock
            arrowPosition:(CBChatBubbleArrowPosition)arrowPosition
                    delay:(NSTimeInterval)delay {
  __weak CBViewController *weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                 dispatch_get_main_queue(),
                 ^{
                   CBMessageCellComponent *component = MessageCellComponent(
                       message, actioinButtonImageName, tapEventBlock, arrowPosition);
                   [weakSelf addCellComponent:component];
                 });
  AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:message];
  utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:CBLanguage];
  AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
  [synthesizer speakUtterance:utterance];
}

- (void)addCellComponent:(id<GILCellViewComponent>)cellComponent {
  id<GILComponentDataSourceSection> section = [_collectionController.data section:0];
  [section addComponent:cellComponent];
  [_collectionController.collectionView reloadData];
  NSIndexPath *lastItem = [NSIndexPath indexPathForItem:[section componentsCount] - 1 inSection:0];
  [_collectionController.collectionView scrollToItemAtIndexPath:lastItem
                                               atScrollPosition:UICollectionViewScrollPositionBottom
                                                       animated:YES];
}

- (void)replaceCellComponent:(id<GILCellViewComponent>)oldCellComponent
           withCellComponent:(id<GILCellViewComponent>)newCellComponent {
  if (!oldCellComponent || !newCellComponent) {
    NSAssert(NO, @"Nil objects.");
    return;
  }
  GILComponentDataSourceSection *section = [_collectionController.data section:0];
  NSUInteger index = [section.components indexOfObject:oldCellComponent];
  if (index != NSNotFound) {
    [section.components replaceObjectAtIndex:index withObject:newCellComponent];
    [_collectionController.collectionView reloadData];
    NSIndexPath *lastItem = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionController.collectionView
        scrollToItemAtIndexPath:lastItem
               atScrollPosition:UICollectionViewScrollPositionBottom
                       animated:YES];
  } else {
    NSAssert(NO, @"Old object not found.");
  }
}

- (void)processResponseJSONData:(NSDictionary *)JSONData
                          error:(NSError *)error
               requestStartTime:(NSTimeInterval)requestStartTime {
  if (error) {
    [self alertError:error];
  } else {
    NSString *message = nil;
    NSString *action = nil;
    NSString *mapKey = nil;
    BOOL actionIncomplete = YES;
    NSDictionary *result = JSONData[@"result"];
    if ([result isKindOfClass:[NSDictionary class]]) {
      action = result[@"action"];
      actionIncomplete = [result[@"actionIncomplete"] boolValue];
      NSDictionary *fullfillment = result[@"fulfillment"];
      if ([fullfillment isKindOfClass:[NSDictionary class]]) {
        message = fullfillment[@"speech"];
        NSDictionary *data = fullfillment[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
          id mapKeyValue = data[@"mapKey"];
          if ([mapKeyValue isKindOfClass:[NSString class]]) {
            mapKey = mapKeyValue;
          }
        }
      }
    }
    // Check aganist all known actions.
    if ([action isEqual:kInquiryTranslateActionKey]) {
      NSDictionary *parameters = result[@"parameters"];
      NSString *location = parameters[@"location"];
      NSString *language = parameters[@"language"];
      NSString *code;
      if ([language.lowercaseString isEqualToString:@"chinese"]) {
        code = @"zh-Hans";
      } else if ([language.lowercaseString isEqualToString:@"英文"]
                 || [language.lowercaseString isEqualToString:@"英语"]) {
        code = @"en";
      }
      if (code) {
        CBTranslationService *translation = [CBTranslationService sharedService];
        [translation translate:location
            targetLangaugeCode:code
                    completion:^(NSString *translatedText,
                                 NSString *sourceLangauge,
                                 NSError *translationError) {
                      [self addMessage:translatedText
                          actionButtonImageName:nil
                                  tapEventBlock:nil
                                  arrowPosition:CBChatBubbleArrowPositionLeft
                                          delay:0];
                    }];
      } else {
        NSLog(@"%@ is not supported yet.", language);
      }
    }
    if ([action isEqual:kInquiryWhereActionKey]) {
      [self requestUserImage:YES];
    }
    if ([action isEqual:kUploadUserImageActionKey] && actionIncomplete) {
      // Prompt the user to upload photo.
      [self requestUserImage:NO];
    } else if (message) {
      if ([action isEqual:kInquiryParadesActionKey]) {
        UIImage *image = [UIImage imageNamed:@"parade"];
        id<GILCellViewComponent> imageComponent =
            ImageMessageCellComponent(image, CBChatBubbleArrowPositionLeft);
        [self addCellComponent:imageComponent];
      }
      NSString *actionButtonImageName = nil;
      ActionButtonTapEventBlock actionButtonTapEventBlock = NULL;
      if (mapKey || [action isEqual:kInquiryWhereLocationMapActionKey]) {
        if (!mapKey) {
          // Map key for Chinese support.
          mapKey = @"Mickey";
        }
        // Hardcode walk action button for now.
        actionButtonImageName = @"walk";
        __weak CBViewController *weakSelf = self;
        actionButtonTapEventBlock = ^void(void) {
          CBViewController *strongSelf = weakSelf;
          if (strongSelf.delegate) {
            SEL selector = @selector(chatBotController:shouldPresentViewController:);
            if (![strongSelf.delegate respondsToSelector:selector]) {
              NSCAssert(NO, @"Required delegate method not implemented.");
            } else {
              DemoMapViewController *viewController =
                  [[DemoMapViewController alloc] initWithNibName:nil bundle:nil];
              viewController.mapImage = [UIImage imageNamed:@"direction"];
              [strongSelf.delegate chatBotController:strongSelf
                         shouldPresentViewController:viewController];
            }
          }
        };
      }
      [self addMessage:message
          actionButtonImageName:actionButtonImageName
                  tapEventBlock:actionButtonTapEventBlock
                  arrowPosition:CBChatBubbleArrowPositionLeft
                          delay:0];
    } else {
      [self alertError:CustomError(@"Message not found in the server response.")];
    }
  }
}

- (void)requestUserImage:(BOOL)useVisionAPI {
  if (!self.delegate) {
    return;
  }

  if (![self.delegate respondsToSelector:@selector(chatBotController:
                                             didRequestUserImageWithCompletionBlock:)]) {
    NSAssert(NO, @"Missing delegate method.");
  }

  __weak typeof(self) weakSelf = self;
  // Set up the block to be executed after the uer has selected a photo.
  [self.delegate chatBotController:self
      didRequestUserImageWithCompletionBlock:^(UIImage *image) {
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
          return;
        }
        // Create the loading indicator.
        CBLoadingIndicatorMessageCellComponent *loadingComponent =
            LoadingIndicatorCellComponent(CBChatBubbleArrowPositionRight);
        [strongSelf addCellComponent:loadingComponent];
        strongSelf->_inputTextField.enabled = NO;

        if (image) {
          if (useVisionAPI) {
            CBLandmarkDetectionService *service = [CBLandmarkDetectionService sharedService];
            [service analyze:image
                  completion:^(NSDictionary *response, NSError *error) {
                    NSDictionary *annotation = response[@"landmarkAnnotations"][0];
                    NSString *description = annotation[@"description"];
                    NSString *text = [NSString stringWithFormat:@"I am near %@", description];
                    if ([CBLanguage isEqualToString:@"en-US"]) {
                      [strongSelf simulateImageUpload:image
                                     loadingComponent:loadingComponent
                                                 text:text];
                    } else {
                      CBTranslationService *translation = [CBTranslationService sharedService];
                      [translation translate:text
                          targetLangaugeCode:CBLanguage
                                  completion:^(NSString *translatedText,
                                               NSString *sourceLangauge,
                                               NSError *translationError) {
                                    NSLog(@"Translated: %@", translatedText);
                                    [strongSelf simulateImageUpload:image
                                                   loadingComponent:loadingComponent
                                                               text:translatedText];
                                  }];
                    }
                  }];
          } else {
            [strongSelf simulateImageUpload:image
                           loadingComponent:loadingComponent
                                       text:[NSUUID UUID].UUIDString];
          }
        }
      }];
}

// Temp code. Simulate the image upload delay and UUID generated by the server.
- (void)simulateImageUpload:(UIImage *)image
           loadingComponent:(id<GILCellViewComponent>)loadingComponent
                       text:(NSString *)text {
  __weak typeof(self) weakSelf = self;
  dispatch_after(
      dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        typeof(self) strongSelf = weakSelf;
        if (!strongSelf) {
          return;
        }
        id<GILCellViewComponent> imageComponent =
            ImageMessageCellComponent(image, CBChatBubbleArrowPositionRight);
        [strongSelf replaceCellComponent:loadingComponent withCellComponent:imageComponent];
        strongSelf->_inputTextField.enabled = YES;
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];

        // Inform the bot the image is uploaded.
        [strongSelf sendAIRequestWithQuery:text
                                completion:^(NSDictionary *JSONData, NSError *error) {
                                  [weakSelf processResponseJSONData:JSONData
                                                              error:error
                                                   requestStartTime:startTime];
                                }];
      });
}

- (void)alertError:(NSError *)error {
  UIAlertController *alertController =
      [UIAlertController alertControllerWithTitle:@"Error"
                                          message:error.localizedDescription
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *action =
      [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:NULL];
  [alertController addAction:action];
  [self presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark - Recording

- (void)didTapMic:(UIButton *)sender {
  _recording = !_recording;
  if (_recording) {
    [_micButton setTintColor:[UIColor redColor]];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];

    _audioData = [[NSMutableData alloc] init];
    [self prepare];
    AudioOutputUnitStart(self->_remoteIOUnit);

    CAKeyframeAnimation *scaleAnimation =
        [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[@1.0f, @1.2f, @1.0f];
    scaleAnimation.keyTimes = @[@0.0f, @0.5f, @1.0f];
    scaleAnimation.repeatCount = INFINITY;
    scaleAnimation.duration = 1.0f;

    [_micButton.layer addAnimation:scaleAnimation forKey:kMicRecordingAnimationKey];
  } else {
    [_micButton setTintColor:nil];
    [_micButton.layer removeAnimationForKey:kMicRecordingAnimationKey];
    AudioOutputUnitStop(self->_remoteIOUnit);
    [[SpeechRecognitionService sharedInstance]
        processAudioData:_audioData
          withCompletion:^(id object) {
            NSLog(@"%@", object);
            RecognizeResponse *response = object;
            if (response && response.resultsArray_Count) {
              SpeechRecognitionResult *result = response.resultsArray[0];
              if (result.alternativesArray_Count) {
                [self sendText:result.alternativesArray[0].transcript];
              }
            }
          }];
  }
}

- (void)processSampleData:(NSData *)data {
  [_audioData appendData:data];
  NSInteger frameCount = [data length] / 2;
  int16_t *samples = (int16_t *)[data bytes];
  int64_t sum = 0;
  for (int i = 0; i < frameCount; i++) {
    sum += abs(samples[i]);
  }
  // log the number of audio samples and their average magnitude
  NSLog(@"audio %d %d", (int)frameCount, (int)(sum * 1.0 / frameCount));
}

static OSStatus CheckError(OSStatus error, const char *operation) {
  if (error == noErr) {
    return error;
  }
  char errorString[20];
  // See if it appears to be a 4-char-code
  *(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
  if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) &&
      isprint(errorString[4])) {
    errorString[0] = errorString[5] = '\'';
    errorString[6] = '\0';
  } else {
    // No, format it as an integer
    sprintf(errorString, "%d", (int)error);
  }
  fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
  return error;
}

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
  OSStatus status;

  CBViewController *audioController = (__bridge CBViewController *)inRefCon;

  int channelCount = 1;

  // build the AudioBufferList structure
  AudioBufferList *bufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList));
  bufferList->mNumberBuffers = channelCount;
  bufferList->mBuffers[0].mNumberChannels = 1;
  bufferList->mBuffers[0].mDataByteSize = inNumberFrames * 2;
  bufferList->mBuffers[0].mData = NULL;

  // get the recorded samples
  status = AudioUnitRender(audioController->_remoteIOUnit,
                           ioActionFlags,
                           inTimeStamp,
                           inBusNumber,
                           inNumberFrames,
                           bufferList);
  if (status != noErr) {
    return status;
  }

  NSData *data = [[NSData alloc] initWithBytes:bufferList->mBuffers[0].mData
                                        length:bufferList->mBuffers[0].mDataByteSize];
  dispatch_async(dispatch_get_main_queue(), ^{
    [audioController processSampleData:data];
  });

  return noErr;
}

- (OSStatus)prepare {
  OSStatus status = noErr;

  AVAudioSession *session = [AVAudioSession sharedInstance];

  NSError *error;
  BOOL ok = [session setCategory:AVAudioSessionCategoryRecord error:&error];
  NSLog(@"set category %d", ok);

// This doesn't seem to really indicate a problem (iPhone 6s Plus)
#ifdef IGNORE
  NSInteger inputChannels = session.inputNumberOfChannels;
  if (!inputChannels) {
    NSLog(@"ERROR: NO AUDIO INPUT DEVICE");
    return -1;
  }
#endif

  [session setPreferredIOBufferDuration:10 error:&error];

  double sampleRate = session.sampleRate;
  NSLog(@"hardwareSampleRate = %f", sampleRate);
  sampleRate = 16000;

  // Describe the RemoteIO unit
  AudioComponentDescription audioComponentDescription;
  audioComponentDescription.componentType = kAudioUnitType_Output;
  audioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
  audioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  audioComponentDescription.componentFlags = 0;
  audioComponentDescription.componentFlagsMask = 0;

  // Get the RemoteIO unit
  AudioComponent remoteIOComponent = AudioComponentFindNext(NULL, &audioComponentDescription);
  status = AudioComponentInstanceNew(remoteIOComponent, &(self->_remoteIOUnit));
  if (CheckError(status, "Couldn't get RemoteIO unit instance")) {
    return status;
  }

  UInt32 oneFlag = 1;
  AudioUnitElement bus0 = 0;
  AudioUnitElement bus1 = 1;

  if ((NO)) {
    // Configure the RemoteIO unit for playback
    status = AudioUnitSetProperty(self->_remoteIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  bus0,
                                  &oneFlag,
                                  sizeof(oneFlag));
    if (CheckError(status, "Couldn't enable RemoteIO output")) {
      return status;
    }
  }

  // Configure the RemoteIO unit for input
  status = AudioUnitSetProperty(self->_remoteIOUnit,
                                kAudioOutputUnitProperty_EnableIO,
                                kAudioUnitScope_Input,
                                bus1,
                                &oneFlag,
                                sizeof(oneFlag));
  if (CheckError(status, "Couldn't enable RemoteIO input")) {
    return status;
  }

  AudioStreamBasicDescription asbd;
  memset(&asbd, 0, sizeof(asbd));
  asbd.mSampleRate = sampleRate;
  asbd.mFormatID = kAudioFormatLinearPCM;
  asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
  asbd.mBytesPerPacket = 2;
  asbd.mFramesPerPacket = 1;
  asbd.mBytesPerFrame = 2;
  asbd.mChannelsPerFrame = 1;
  asbd.mBitsPerChannel = 16;

  // Set format for output (bus 0) on the RemoteIO's input scope
  status = AudioUnitSetProperty(self->_remoteIOUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                bus0,
                                &asbd,
                                sizeof(asbd));
  if (CheckError(status, "Couldn't set the ASBD for RemoteIO on input scope/bus 0")) {
    return status;
  }

  // Set format for mic input (bus 1) on RemoteIO's output scope
  status = AudioUnitSetProperty(self->_remoteIOUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Output,
                                bus1,
                                &asbd,
                                sizeof(asbd));
  if (CheckError(status, "Couldn't set the ASBD for RemoteIO on output scope/bus 1")) {
    return status;
  }

  // Set the recording callback
  AURenderCallbackStruct callbackStruct;
  callbackStruct.inputProc = recordingCallback;
  callbackStruct.inputProcRefCon = (__bridge void *)self;
  status = AudioUnitSetProperty(self->_remoteIOUnit,
                                kAudioOutputUnitProperty_SetInputCallback,
                                kAudioUnitScope_Global,
                                bus1,
                                &callbackStruct,
                                sizeof(callbackStruct));
  if (CheckError(status, "Couldn't set RemoteIO's render callback on bus 0")) {
    return status;
  }

  // Initialize the RemoteIO unit
  status = AudioUnitInitialize(self->_remoteIOUnit);
  if (CheckError(status, "Couldn't initialize the RemoteIO unit")) {
    return status;
  }

  return status;
}

@end
