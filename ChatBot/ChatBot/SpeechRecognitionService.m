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

#import "SpeechRecognitionService.h"

#import <GRPCClient/GRPCCall.h>
#import <ProtoRPC/ProtoRPC.h>

#import "CBDefines.h"
#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"

#define HOST @"speech.googleapis.com"

@implementation SpeechRecognitionService

+ (instancetype)sharedInstance {
  static SpeechRecognitionService *instance = nil;
  if (!instance) {
    instance = [[self alloc] init];
  }
  return instance;
}

- (void)processAudioData:(NSData *)audioData
          withCompletion:(SpeechRecognitionCompletionHandler)completion {
  NSAssert(![CBApiKey isEqualToString:@"your google api key"],
           @"Get Google API key: https://cloud.google.com/storage/docs/json_api/v1/how-tos/authorizing#APIKey");
  // construct a request for synchronous speech recognition
  RecognitionConfig *recognitionConfig = [RecognitionConfig message];
  recognitionConfig.encoding = RecognitionConfig_AudioEncoding_Linear16;
  recognitionConfig.sampleRateHertz = 16000;
  recognitionConfig.languageCode = CBLanguage;
  recognitionConfig.maxAlternatives = 1;

  RecognitionAudio *recognitionAudio = [RecognitionAudio message];
  recognitionAudio.content = audioData;

  RecognizeRequest *syncRecognizeRequest = [RecognizeRequest message];
  syncRecognizeRequest.config = recognitionConfig;
  syncRecognizeRequest.audio = recognitionAudio;

  Speech *client = [[Speech alloc] initWithHost:HOST];

  // prepare a single gRPC call to make the request
  GRPCProtoCall *call = [client
      RPCToRecognizeWithRequest:syncRecognizeRequest
                            handler:^(RecognizeResponse *response, NSError *error) {
                              NSLog(@"RESPONSE RECEIVED %@", response);
                              if (error) {
                                NSLog(@"ERROR: %@", error);
                                completion([error description]);
                              } else {
                                for (SpeechRecognitionResult *result in response.resultsArray) {
                                  NSLog(@"RESULT");
                                  for (SpeechRecognitionAlternative *alternative in result
                                           .alternativesArray) {
                                    NSLog(@"ALTERNATIVE %0.4f %@",
                                          alternative.confidence,
                                          alternative.transcript);
                                  }
                                }
                                completion(response);
                              }
                            }];

  // authenticate using an API key obtained from the Google Cloud Console
  call.requestHeaders[@"X-Goog-Api-Key"] = CBApiKey;
  // if the API key has a bundle ID restriction, specify the bundle ID like this
  call.requestHeaders[@"X-Ios-Bundle-Identifier"] = [[NSBundle mainBundle] bundleIdentifier];
  NSLog(@"HEADERS: %@", call.requestHeaders);

  // perform the gRPC request
  [call start];
}

@end
