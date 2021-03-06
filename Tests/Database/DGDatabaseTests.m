// DGDatabaseTests.m
//
// Copyright (c) 2017 Maxime Epain
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

#import "DGTestCase.h"

#import <DiscogsAPI/DGRelease+Mapping.h>
#import <DiscogsAPI/DGMaster+Mapping.h>
#import <DiscogsAPI/DGArtist+Mapping.h>
#import <DiscogsAPI/DGLabel+Mapping.h>
#import <DiscogsAPI/DGSearch+Mapping.h>

#import <DiscogsAPI/DGOperationQueue.h>

@interface DGDatabaseTests : DGTestCase<DGDatabase *>

@end

@implementation DGDatabaseTests

- (void)setUp {
    [super setUp];
    
    self.endpoint = [[DGDatabase alloc] initWithManager:self.manager];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Release

- (void)testReleaseMapping {
    id json = [RKTestFixture parsedObjectWithContentsOfFixture:@"release.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[DGRelease mapping] sourceObject:json destinationObject:nil];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title" value:@"Never Gonna Give You Up"]];
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"id" destinationKeyPath:@"ID" value:@249504]];
    XCTAssertTrue(test.evaluate);
}
    
- (void)testReleaseOperation {
    DGRelease *release = [DGRelease new];
    release.ID = @249504;
    
    DGOperation *operation = [self.manager operationWithRequest:release method:RKRequestMethodGET responseClass:[DGRelease class]];
    
    [operation start];
    [operation waitUntilFinished];
    
    XCTAssertEqual(operation.HTTPRequestOperation.response.statusCode, 200, @"Expected 200 response");
    XCTAssertTrue([operation.response isKindOfClass:[DGRelease class]], @"Expected to load a release");
}

#pragma mark Master

- (void)testMasterMapping {
    id json = [RKTestFixture parsedObjectWithContentsOfFixture:@"master.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[DGMaster mapping] sourceObject:json destinationObject:nil];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"title" destinationKeyPath:@"title" value:@"Stardiver"]];
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"id" destinationKeyPath:@"ID" value:@1000]];
    XCTAssertTrue(test.evaluate);
}

- (void)testMasterOperation {
    DGMaster *master = [DGMaster new];
    master.ID = @1000;
    
    DGOperation *operation = [self.manager operationWithRequest:master method:RKRequestMethodGET responseClass:[DGMaster class]];
    
    [operation start];
    [operation waitUntilFinished];
    
    XCTAssertEqual(operation.HTTPRequestOperation.response.statusCode, 200, @"Expected 200 response");
    XCTAssertTrue([operation.response isKindOfClass:[DGMaster class]], @"Expected to load a master");
}

#pragma mark Artist

- (void)testArtistMapping {
    id json = [RKTestFixture parsedObjectWithContentsOfFixture:@"artist.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[DGMaster mapping] sourceObject:json destinationObject:nil];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"id" destinationKeyPath:@"ID" value:@108713]];
    XCTAssertTrue(test.evaluate);
}

- (void)testArtistOperation {
    DGArtist *artist = [DGArtist new];
    artist.ID = @108713;
    
    DGOperation *operation = [self.manager operationWithRequest:artist method:RKRequestMethodGET responseClass:[DGArtist class]];
    
    [operation start];
    [operation waitUntilFinished];
    
    XCTAssertEqual(operation.HTTPRequestOperation.response.statusCode, 200, @"Expected 200 response");
    XCTAssertTrue([operation.response isKindOfClass:[DGArtist class]], @"Expected to load an artist");
}

#pragma mark Label

- (void)testLabelMapping {
    id json = [RKTestFixture parsedObjectWithContentsOfFixture:@"label.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:[DGLabel mapping] sourceObject:json destinationObject:nil];
    
    [test addExpectation:[RKPropertyMappingTestExpectation expectationWithSourceKeyPath:@"id" destinationKeyPath:@"ID" value:@1]];
    XCTAssertTrue(test.evaluate);
}

- (void)testLabelOperation {
    DGLabel *label = [DGLabel new];
    label.ID = @1;
    
    DGOperation *operation = [self.manager operationWithRequest:label method:RKRequestMethodGET responseClass:[DGLabel class]];
    
    [operation start];
    [operation waitUntilFinished];
    
    XCTAssertEqual(operation.HTTPRequestOperation.response.statusCode, 200, @"Expected 200 response");
    XCTAssertTrue([operation.response isKindOfClass:[DGLabel class]], @"Expected to load a label");
}

#pragma mark Search

- (void)testSearchMapping {
    DGSearchResponse *response =  [DGSearchResponse new];
    
    id json = [RKTestFixture parsedObjectWithContentsOfFixture:@"search.json"];
    RKMappingTest *test = [RKMappingTest testForMapping:DGSearchResponse.responseDescriptor.mapping sourceObject:json destinationObject:response];
    
    XCTAssertTrue(test.evaluate);
    
    XCTAssertEqualObjects(response.pagination.perPage, @3);
    XCTAssertEqualObjects(response.pagination.pages, @66);
    XCTAssertEqualObjects(response.pagination.page, @1);
    XCTAssertEqualObjects(response.pagination.items, @198);
    
    DGSearchResult *result = response.results[0];
    XCTAssertEqualObjects(result.title, @"Nirvana - Nevermind");
    XCTAssertEqualObjects(result.year, @"2005");
    XCTAssertEqualObjects(result.ID, @2028757);
}

- (void)testSearchOperation {
    
    DGSearchRequest *request = [DGSearchRequest new];
    request.releaseTitle = @"nevermind";
    request.artist = @"nirvana";
    request.pagination.perPage = @3;
    
    DGOperation *operation = [self.manager operationWithRequest:request method:RKRequestMethodGET responseClass:[DGSearchResponse class]];
    
    [operation start];
    [operation waitUntilFinished];
    
    XCTAssertEqual(operation.HTTPRequestOperation.response.statusCode, 200, @"Expected 200 response");
    XCTAssertTrue([operation.response isKindOfClass:[DGSearchResponse class]], @"Expected to load a label");
}

//- (void)testRateLimit {
//    DGOperationQueue *queue = [[DGOperationQueue alloc] init];
//
//    DGLabel *label = [DGLabel new];
//    label.ID = @1;
//
//    NSInteger count = 61;
//
//    NSDate *start = [NSDate date];
//
//    for (NSInteger i = 0; i < count; i++) {
//
//        DGOperation *operation = [self.manager operationWithRequest:label method:RKRequestMethodGET responseClass:[DGLabel class]];
//        operation.successCallbackQueue = callbackQueue;
//        operation.failureCallbackQueue = callbackQueue;
//
//        __weak DGOperation *weakOperation = operation;
//        [operation setCompletionBlockWithSuccess:^(id  _Nonnull response) {
//
//        } failure:^(NSError * _Nullable error) {
//            NSLog(@"Operation %li\n \
//                  After %f \n \
//                  Response Header %@\nError: %@", i, -start.timeIntervalSinceNow, weakOperation.HTTPRequestOperation.response.allHeaderFields, error);
//            XCTFail(@"");
//        }];
//
//        [queue addOperation:operation];
//    }
//
//    [queue waitUntilAllOperationsAreFinished];
//
//    NSTimeInterval estimatedTime = count * kDGRateLimitWindow / (queue.rateLimit - 1);
//    XCTAssertEqualWithAccuracy(-start.timeIntervalSinceNow, estimatedTime, 1);
//}

@end
