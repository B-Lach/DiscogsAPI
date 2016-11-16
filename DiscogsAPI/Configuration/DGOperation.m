// DGOperation.m
//
// Copyright (c) 2016 Maxime Epain
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "DGOperation.h"

// The error domain for Discogs generated errors
NSString * const DGErrorDomain = @"com.discogs.api";

@implementation DGOperation {
    Class _responseClass;
}

+ (instancetype)operationWithRequest:(NSURLRequest *)request responseClass:(Class<DGResponseObject>)responseClass {
    return [[self alloc] initWithRequest:request responseClass:responseClass];
}

- (instancetype)initWithRequest:(NSURLRequest *)request responseClass:(Class<DGResponseObject>)responseClass {
    NSMutableArray *responseDescriptors = [NSMutableArray arrayWithObject:[NSError responseDescriptor]];
    if (responseClass) {
        [responseDescriptors addObject:[responseClass responseDescriptor]];
    }
    
    self = [super initWithRequest:request responseDescriptors:responseDescriptors];
    if (self) {
        _responseClass = responseClass;
    }
    return self;
}

- (void)setCompletionBlockWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    __weak typeof(self) weakSelf = self;
    [super setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        __typeof(self) const strongSelf = weakSelf;
        
        NSError *error;
        [strongSelf validateResult:result error:&error];
        if (!error) {
            success(strongSelf.response);
        } else if (failure) {
            failure(error);
        }
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        if (failure) {
            NSInteger code = operation.HTTPRequestOperation.response.statusCode;
            NSString *description = error.userInfo[NSLocalizedDescriptionKey];
            failure([NSError errorWithCode:code description:description]);
        }
    }];
}

- (void)validateResult:(RKMappingResult *)result error:(NSError **)error {
    if (!self->_responseClass) {
        return;
    }
    
    id object = result.dictionary[[NSNull null]];
    if (object) {
        if ([object isKindOfClass:_responseClass]) {
            _response = object;
        }
        return;
    }
    
    NSArray *array = result.array;
    if (array.count < 0 || [array.firstObject isKindOfClass:_responseClass]) {
        _response = array;
        return;
    }
    
    *error = [NSError errorWithCode:NSURLErrorCannotParseResponse description:@"Bad response from Discogs server"];
}

@end

@implementation RKObjectManager (DGOperation)

- (DGOperation *)operationWithRequest:(id<DGRequestObject>)request method:(RKRequestMethod)method {
    return [self operationWithRequest:request method:method responseClass:nil];
}

- (DGOperation *)operationWithRequest:(id<DGRequestObject>)request method:(RKRequestMethod)method responseClass:(Class<DGResponseObject>)responseClass {
    NSDictionary *parameters = nil;
    if ([request respondsToSelector:@selector(parameters)]) {
        parameters = request.parameters;
    }
    
    NSURLRequest *requestURL = [self requestWithObject:request method:method path:nil parameters:parameters];
    return [DGOperation operationWithRequest:requestURL responseClass:responseClass];
}

@end

@implementation NSError (Discogs)

+ (instancetype)errorWithCode:(NSInteger)code description:(NSString *)description {
    return [self errorWithDomain:DGErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : description}];
}

+ (RKResponseDescriptor *)responseDescriptor {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    
    [mapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:@"message" toKeyPath:@"errorMessage"]];
    
    return [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
}

@end
