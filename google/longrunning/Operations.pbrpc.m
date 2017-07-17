#import "google/longrunning/Operations.pbrpc.h"

#import <ProtoRPC/ProtoRPC.h>
#import <RxLibrary/GRXWriter+Immediate.h>

@implementation Operations

// Designated initializer
- (instancetype)initWithHost:(NSString *)host {
  return (self = [super initWithHost:host packageName:@"google.longrunning" serviceName:@"Operations"]);
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


#pragma mark GetOperation(GetOperationRequest) returns (Operation)

/**
 * Gets the latest state of a long-running operation.  Clients may use this
 * method to poll the operation result at intervals as recommended by the API
 * service.
 */
- (void)getOperationWithRequest:(GetOperationRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToGetOperationWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Gets the latest state of a long-running operation.  Clients may use this
 * method to poll the operation result at intervals as recommended by the API
 * service.
 */
- (GRPCProtoCall *)RPCToGetOperationWithRequest:(GetOperationRequest *)request handler:(void(^)(Operation *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"GetOperation"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[Operation class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark ListOperations(ListOperationsRequest) returns (ListOperationsResponse)

/**
 * Lists operations that match the specified filter in the request. If the
 * server doesn't support this method, it returns
 * `google.rpc.Code.UNIMPLEMENTED`.
 */
- (void)listOperationsWithRequest:(ListOperationsRequest *)request handler:(void(^)(ListOperationsResponse *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToListOperationsWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Lists operations that match the specified filter in the request. If the
 * server doesn't support this method, it returns
 * `google.rpc.Code.UNIMPLEMENTED`.
 */
- (GRPCProtoCall *)RPCToListOperationsWithRequest:(ListOperationsRequest *)request handler:(void(^)(ListOperationsResponse *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"ListOperations"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[ListOperationsResponse class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark CancelOperation(CancelOperationRequest) returns (Empty)

/**
 * Starts asynchronous cancellation on a long-running operation.  The server
 * makes a best effort to cancel the operation, but success is not
 * guaranteed.  If the server doesn't support this method, it returns
 * `google.rpc.Code.UNIMPLEMENTED`.  Clients may use
 * [Operations.GetOperation] or other methods to check whether the
 * cancellation succeeded or the operation completed despite cancellation.
 */
- (void)cancelOperationWithRequest:(CancelOperationRequest *)request handler:(void(^)(GPBEmpty *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToCancelOperationWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Starts asynchronous cancellation on a long-running operation.  The server
 * makes a best effort to cancel the operation, but success is not
 * guaranteed.  If the server doesn't support this method, it returns
 * `google.rpc.Code.UNIMPLEMENTED`.  Clients may use
 * [Operations.GetOperation] or other methods to check whether the
 * cancellation succeeded or the operation completed despite cancellation.
 */
- (GRPCProtoCall *)RPCToCancelOperationWithRequest:(CancelOperationRequest *)request handler:(void(^)(GPBEmpty *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"CancelOperation"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
#pragma mark DeleteOperation(DeleteOperationRequest) returns (Empty)

/**
 * Deletes a long-running operation.  It indicates the client is no longer
 * interested in the operation result. It does not cancel the operation.
 */
- (void)deleteOperationWithRequest:(DeleteOperationRequest *)request handler:(void(^)(GPBEmpty *_Nullable response, NSError *_Nullable error))handler{
  [[self RPCToDeleteOperationWithRequest:request handler:handler] start];
}
// Returns a not-yet-started RPC object.
/**
 * Deletes a long-running operation.  It indicates the client is no longer
 * interested in the operation result. It does not cancel the operation.
 */
- (GRPCProtoCall *)RPCToDeleteOperationWithRequest:(DeleteOperationRequest *)request handler:(void(^)(GPBEmpty *_Nullable response, NSError *_Nullable error))handler{
  return [self RPCToMethod:@"DeleteOperation"
            requestsWriter:[GRXWriter writerWithValue:request]
             responseClass:[GPBEmpty class]
        responsesWriteable:[GRXWriteable writeableWithSingleHandler:handler]];
}
@end
