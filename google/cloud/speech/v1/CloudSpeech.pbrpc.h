#import "google/cloud/speech/v1/CloudSpeech.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/longrunning/Operations.pbobjc.h"
#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
  #import <Protobuf/Any.pbobjc.h>
#else
  #import "google/protobuf/Any.pbobjc.h"
#endif
#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
  #import <Protobuf/Duration.pbobjc.h>
#else
  #import "google/protobuf/Duration.pbobjc.h"
#endif
#if GPB_USE_PROTOBUF_FRAMEWORK_IMPORTS
  #import <Protobuf/Timestamp.pbobjc.h>
#else
  #import "google/protobuf/Timestamp.pbobjc.h"
#endif
#import "google/rpc/Status.pbobjc.h"


NS_ASSUME_NONNULL_BEGIN

@protocol Speech <NSObject>

#pragma mark Recognize(RecognizeRequest) returns (RecognizeResponse)

/**
 * Performs synchronous speech recognition: receive results after all audio
 * has been sent and processed.
 */
- (void)recognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(RecognizeResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Performs synchronous speech recognition: receive results after all audio
 * has been sent and processed.
 */
- (GRPCProtoCall *)RPCToRecognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(RecognizeResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark LongRunningRecognize(LongRunningRecognizeRequest) returns (Operation)

/**
 * Performs asynchronous speech recognition: receive results via the
 * google.longrunning.Operations interface. Returns either an
 * `Operation.error` or an `Operation.response` which contains
 * a `LongRunningRecognizeResponse` message.
 */
- (void)longRunningRecognizeWithRequest:(LongRunningRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;

/**
 * Performs asynchronous speech recognition: receive results via the
 * google.longrunning.Operations interface. Returns either an
 * `Operation.error` or an `Operation.response` which contains
 * a `LongRunningRecognizeResponse` message.
 */
- (GRPCProtoCall *)RPCToLongRunningRecognizeWithRequest:(LongRunningRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;


#pragma mark StreamingRecognize(stream StreamingRecognizeRequest) returns (stream StreamingRecognizeResponse)

/**
 * Performs bidirectional streaming speech recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (void)streamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * Performs bidirectional streaming speech recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (GRPCProtoCall *)RPCToStreamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler;


@end

/**
 * Basic service implementation, over gRPC, that only does
 * marshalling and parsing.
 */
@interface Speech : GRPCProtoService<Speech>
- (instancetype)initWithHost:(NSString *)host NS_DESIGNATED_INITIALIZER;
+ (instancetype)serviceWithHost:(NSString *)host;
@end

NS_ASSUME_NONNULL_END
