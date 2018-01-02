#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

@implementation Speech

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:@"google.cloud.speech.v1" serviceName:@"Speech"]);
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


#pragma mark Recognize(RecognizeRequest) returns (RecognizeResponse)

/**
 * Performs synchronous speech recognition: receive results after all audio
 * has been sent and processed.
 */
- (void)recognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(RecognizeResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToRecognizeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Performs synchronous speech recognition: receive results after all audio
 * has been sent and processed.
 */
- (GRPCProtoCall *)RPCToRecognizeWithRequest:(RecognizeRequest *)request handler:(void(^)(RecognizeResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"Recognize"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[RecognizeResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark LongRunningRecognize(LongRunningRecognizeRequest) returns (Operation)

/**
 * Performs asynchronous speech recognition: receive results via the
 * google.longrunning.Operations interface. Returns either an
 * `Operation.error` or an `Operation.response` which contains
 * a `LongRunningRecognizeResponse` message.
 */
- (void)longRunningRecognizeWithRequest:(LongRunningRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToLongRunningRecognizeWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Performs asynchronous speech recognition: receive results via the
 * google.longrunning.Operations interface. Returns either an
 * `Operation.error` or an `Operation.response` which contains
 * a `LongRunningRecognizeResponse` message.
 */
- (GRPCProtoCall *)RPCToLongRunningRecognizeWithRequest:(LongRunningRecognizeRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"LongRunningRecognize"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark StreamingRecognize(stream StreamingRecognizeRequest) returns (stream StreamingRecognizeResponse)

/**
 * Performs bidirectional streaming speech recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (void)streamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  [[self RPCToStreamingRecognizeWithRequestsWriter:requestWriter eventHandler:eventHandler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Performs bidirectional streaming speech recognition: receive results while
 * sending audio. This method is only available via the gRPC API (not REST).
 */
- (GRPCProtoCall *)RPCToStreamingRecognizeWithRequestsWriter:(GRXWriter *)requestWriter eventHandler:(void(^)(BOOL done, StreamingRecognizeResponse *_Nullable response, NSError *_Nullable error))eventHandler{
  return [self RPCToMethod:@"StreamingRecognize"
            requestsWriter:requestWriter
             responseClass:[StreamingRecognizeResponse class]
        responsesWriteable:[GRXWriteable writeableWithEventHandler:eventHandler]];
}
@end
