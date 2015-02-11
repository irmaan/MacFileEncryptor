//
//  TSDataEncryptorHelper.m
//  DataEncryptor
//
//  Created by Mirzanejad on 2/10/15.
//  Copyright © 2015 Mirzanejad. All rights reserved.
//

#import "TSDataEncryptorHelper.h"
#import "TSDataEncryptor.h"

@implementation TSDataEncryptorHelper

#pragma mark - public methods

+ (NSSet *)allFilesSubpathesForDirectoryPath:(NSString *)directoryPath
{
    NSMutableSet *allFilesSubpathes = [[NSMutableSet alloc] init];
    NSSet *allFilesPathes = [self allFilesForDirectoryPath:directoryPath];
    
    for (NSString *filePath in allFilesPathes)
    {
        NSString *fileSubpath = [filePath substringFromIndex:[directoryPath length]];
        [allFilesSubpathes addObject:fileSubpath];
    }
    return allFilesSubpathes;
}

+ (void)decryptFilesWithInputPath:(NSString *)inputPath
                   filesSubpathes:(NSSet *)filesSubpathes
                       outputPath:(NSString *)outputPath
                         password:(NSString *)password
                      updateBlock:(void(^)(float progress, NSString *updateString))updateBlock
{
    [self encryptFiles:NO
             inputPath:inputPath
        filesSubpathes:filesSubpathes
            outputPath:outputPath
              password:password
           updateBlock:updateBlock];
}


+ (void)encryptFilesWithInputPath:(NSString *)inputPath
                   filesSubpathes:(NSSet *)filesSubpathes
                       outputPath:(NSString *)outputPath
                         password:(NSString *)password
                      updateBlock:(void(^)(float progress, NSString *updateString))updateBlock
{
    [self encryptFiles:YES
             inputPath:inputPath
        filesSubpathes:filesSubpathes
            outputPath:outputPath
              password:password
           updateBlock:updateBlock];
}

#pragma mark - private methods

+ (NSSet *)allFilesForDirectoryPath:(NSString *)directoryPath
{
    NSMutableSet *allFiles = [[NSMutableSet alloc] init];
    
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager]
                                         enumeratorAtURL:[NSURL fileURLWithPath:directoryPath]
                                         includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                         errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
                                             if (error)
                                             {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             return YES;
                                         }];
    
    for (NSURL *fileURL in enumerator)
    {
        NSString *filename = nil;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory = nil;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        if (![isDirectory boolValue])
        {
            [allFiles addObject:fileURL.path];
        }
        else
        {
            [allFiles unionSet:[self allFilesForDirectoryPath:fileURL.path]];
        }
    }
    return allFiles;
}

+ (void)encryptFiles:(BOOL)isEncrypt
           inputPath:(NSString *)inputPath
      filesSubpathes:(NSSet *)filesSubpathes
          outputPath:(NSString *)outputPath
            password:(NSString *)password
         updateBlock:(void(^)(float progress, NSString *updateString))updateBlock
{
    if (0 == filesSubpathes.count)
    {
        updateBlock(1.0f, @"There is no file in choosen directory!");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        
        NSError *error = nil;
        NSUInteger currentIndex = 0;
        for (NSString *filesSubpath in filesSubpathes)
        {
            float currentProgress = (float)currentIndex/filesSubpathes.count;
            currentIndex++;
            
            NSString *inputFilePath = [inputPath stringByAppendingPathComponent:filesSubpath];
            NSString *outputFilePath = [outputPath stringByAppendingPathComponent:filesSubpath];
            
            NSString *outputDirectory = [outputFilePath stringByDeletingLastPathComponent];
            
            BOOL isDirectory = NO;
            BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:outputDirectory isDirectory:&isDirectory];
            if (!isExist)
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:outputDirectory
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:&error];
                if (nil != error)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        updateBlock(currentProgress, [NSString stringWithFormat:@"Directory creation error: %@, directory: %@", error.description, outputDirectory]);
                    });
                }
            }
            
            if (isEncrypt)
            {
                [TSDataEncryptor encryptFileWithPath:inputFilePath outFilePath:outputFilePath pass:password error:&error];
            }
            else
            {
                [TSDataEncryptor decryptFileWithPath:inputFilePath outFilePath:outputFilePath pass:password error:&error];
            }
            
            if (nil != error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateBlock(currentProgress, [NSString stringWithFormat:@"Error: %@, file: %@", error.description, inputFilePath]);
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateBlock(currentProgress, [NSString stringWithFormat:@"+ %@", inputFilePath]);
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            updateBlock(1.0f, @"Done!");
        });
    });
}

@end
