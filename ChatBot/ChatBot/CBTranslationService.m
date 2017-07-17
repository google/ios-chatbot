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

#import "CBTranslationService.h"

#import "CBDefines.h"

@implementation CBTranslationService

+ (instancetype)sharedService {
  static CBTranslationService *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void)translate:(NSString *)query
    targetLangaugeCode:(NSString *)targetLangaugeCode
            completion:(CBTranslationCallback)completion {
  NSAssert(![CBApiKey isEqualToString:@"your google api key"],
           @"Get Google API key: https://cloud.google.com/storage/docs/json_api/v1/how-tos/authorizing#APIKey");
  // Create our request URL
  NSString *urlString = @"https://translation.googleapis.com/language/translate/v2?key=";

  NSString *requestString = [NSString stringWithFormat:@"%@%@", urlString, CBApiKey];

  NSURL *url = [NSURL URLWithString:requestString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  [request addValue:[[NSBundle mainBundle] bundleIdentifier]
      forHTTPHeaderField:@"X-Ios-Bundle-Identifier"];

  // Build our API request
  NSDictionary *paramsDictionary = @{ @"q": query, @"target": targetLangaugeCode };

  NSError *jsonError;
  NSData *requestData =
      [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&jsonError];
  [request setHTTPBody:requestData];

  NSURLSession *session =
      [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                    delegate:nil
                               delegateQueue:[NSOperationQueue mainQueue]];
  NSURLSessionDataTask *task = [session
      dataTaskWithRequest:request
        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
          NSError *e = nil;
          NSDictionary *json =
              [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&e];
          NSLog(@"%@", json);
          NSArray *responses = [[json objectForKey:@"data"] objectForKey:@"translations"];
          NSDictionary *responseData = [responses objectAtIndex:0];
          NSDictionary *errorObj = [json objectForKey:@"error"];

          // Check for errors
          if (errorObj) {
            NSInteger errorCode = [errorObj[@"code"] intValue];
            NSError *responseError =
                [NSError errorWithDomain:@"Translation API Error" code:errorCode userInfo:errorObj];
            completion(nil, nil, responseError);
          } else {
            NSString *translatedText = responseData[@"translatedText"];
            NSString *sourceLangauge = responseData[@"detectedSourceLanguage"];
            completion(translatedText, sourceLangauge, error);
          }
        }];
  [task resume];
}

#pragma mark - Private

@end
