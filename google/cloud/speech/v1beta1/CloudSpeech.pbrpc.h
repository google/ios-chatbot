#import "google/cloud/speech/v1beta1/CloudSpeech.pbobjc.h"

#import <ProtoRPC/ProtoService.h>
#import <RxLibrary/GRXWriteable.h>
#import <RxLibrary/GRXWriter.h>

#import "google/api/Annotations.pbobjc.h"
#import "google/longrunning/Operations.pbobjc.h"
#import "google/rpc/Status.pbobjc.h"


NS_ASSUME_NONNULL_BEGIN

@protocol Speech <NSObject>

#pragma mark SyncRecognize(SyncRecognizeRequest) returns (SyncRecognizeResponse)

/**
 * Perform synchronous speech-recognition: receive results after all audio
 * has been sent and processed.
 */
- (void)syncRecognizeWithRequest:(SyncRecognizeRequest *)request handler:(void(^)(SyncRecognizeResponse *_Nullable response, NSError *_Nullable error))handler;

/**
 * Perform synchronous speech-recognition: receive results after all audio
 * has been sent and processed.
 */
- (GRPCProtoCall *)RPCToSyncRecognizeWithRequest:(SyncRecognizeRequest *)request handler:(void(^)(SyncRecognizeResponse *_Nullable response, NSError *_Nullable error))handler;


#pragma mark AsyncRecognize(AsyncRecognizeRequest) returns (Operation)

/**
 * Perform asynchronous speech-recognition: receive results via the
 * google.longrunning.Operations interface. `Operation.response` returns
 * `AsyncRecognizeResponse`.
 */
- (void)asyncRecognizeWithRequest:(AsyncRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;

/**
 * Perform asynchronous speech-recognition: receive results via the
 * google.longrunning.Operations interface. `Operation.response` returns
 * `AsyncRecognizeResponse`.
 */
- (GRPCProtoCall *)RPCToAsyncRecognizeWithRequest:(AsyncRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler;


#pragma mark StreamingRecognize(stream StreamingRecognizeRequest) returns (stream StreamingRecognizeResponse)

/**
 * Perform bidirectional streaming speech-recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (void)streamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler;

/**
 * Perform bidirectional streaming speech-recognition: receive results while
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
