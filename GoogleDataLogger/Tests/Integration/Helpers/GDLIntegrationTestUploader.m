/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "GDLIntegrationTestUploader.h"

#import "GDLIntegrationTestPrioritizer.h"

#import "GDLTestServer.h"

@implementation GDLIntegrationTestUploader {
  /** The current upload task. */
  NSURLSessionUploadTask *_currentUploadTask;

  /** The server URL to upload to. */
  NSURL *_serverURL;
}

- (instancetype)initWithServerURL:(NSURL *)serverURL {
  self = [super init];
  if (self) {
    _serverURL = serverURL;
    [[GDLRegistrar sharedInstance] registerUploader:self logTarget:kGDLIntegrationTestTarget];
  }
  return self;
}

- (void)uploadLogs:(NSSet<NSURL *> *)logFiles onComplete:(GDLUploaderCompletionBlock)onComplete {
  NSAssert(!_currentUploadTask, @"An upload shouldn't be initiated with another in progress.");
  NSURL *serverURL = arc4random_uniform(2) ? [_serverURL URLByAppendingPathComponent:@"log"]
                                           : [_serverURL URLByAppendingPathComponent:@"logBatch"];
  NSURLSession *session = [NSURLSession sharedSession];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:serverURL];
  request.HTTPMethod = @"POST";
  NSMutableData *uploadData = [[NSMutableData alloc] init];

  NSLog(@"Uploading batch of %lu logs: ", (unsigned long)logFiles.count);

  // In real usage, you'd create an instance of whatever request proto your server needs.
  for (NSURL *logFile in logFiles) {
    NSData *fileData = [NSData dataWithContentsOfURL:logFile];
    NSAssert(fileData, @"A log file shouldn't be empty");
    [uploadData appendData:fileData];
  }
  NSURLSessionUploadTask *uploadTask =
      [session uploadTaskWithRequest:request
                            fromData:uploadData
                   completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response,
                                       NSError *_Nullable error) {
                     NSLog(@"Batch upload complete.");
                     // Remove from the prioritizer if there were no errors.
                     NSAssert(!error, @"There should be no errors uploading logs: %@", error);
                     if (onComplete) {
                       // In real usage, the server would/should return a desired next upload time.
                       GDLClock *nextUploadTime = [GDLClock clockSnapshotInTheFuture:1000];
                       onComplete(kGDLIntegrationTestTarget, nextUploadTime, error);
                     }
                   }];
  [uploadTask resume];
}

@end