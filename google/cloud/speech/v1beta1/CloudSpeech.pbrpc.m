#import "google/cloud/speech/v1beta1/CloudSpeech.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

@implementation Speech

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:@"google.cloud.speech.v1beta1" serviceName:@"Speech"]);
}

// Override superclass initializer to disallow different package and service names.
- (instancetype)initWithHost:(NSString *)host
                 packageName:(NSString *)packageName
                 serviceName:(NSString *)serviceName {
  return [self initWithHost:host];
}

+ (instancetype)serviceWithHost:(NSString *)host {
  return [[self alloc] initWithHost:host];
}


#pragma mark SyncRecognize(SyncRecognizeRequest) returns (SyncRecognizeResponse)

/**
 * Perform synchronous speech-recognition: receive results after all audio
 * has been sent and processed.
 */
- (void)syncRecognizeWithRequest:(SyncRecognizeRequest *)request handler:(void(^)(SyncRecognizeResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToSyncRecognizeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Perform synchronous speech-recognition: receive results after all audio
 * has been sent and processed.
 */
- (GRPCProtoCall *)RPCToSyncRecognizeWithRequest:(SyncRecognizeRequest *)request handler:(void(^)(SyncRecognizeResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"SyncRecognize"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[SyncRecognizeResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark AsyncRecognize(AsyncRecognizeRequest) returns (Operation)

/**
 * Perform asynchronous speech-recognition: receive results via the
 * google.longrunning.Operations interface. `Operation.response` returns
 * `AsyncRecognizeResponse`.
 */
- (void)asyncRecognizeWithRequest:(AsyncRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToAsyncRecognizeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Perform asynchronous speech-recognition: receive results via the
 * google.longrunning.Operations interface. `Operation.response` returns
 * `AsyncRecognizeResponse`.
 */
- (GRPCProtoCall *)RPCToAsyncRecognizeWithRequest:(AsyncRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"AsyncRecognize"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark StreamingRecognize(stream StreamingRecognizeRequest) returns (stream StreamingRecognizeResponse)

/**
 * Perform bidirectional streaming speech-recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (void)streamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToStreamingRecognizeWithRequestsWriter:requestWriter eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Perform bidirectional streaming speech-recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (GRPCProtoCall *)RPCToStreamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"StreamingRecognize"
            requestsWriter:requestWriter
             responseClass:[StreamingRecognizeResponse class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
@end
