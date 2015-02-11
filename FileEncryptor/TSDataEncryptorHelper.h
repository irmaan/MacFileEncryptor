//
//  TSDataEncryptorHelper.h
//  DataEncryptor
//
//  Created by Mirzanejad on 2/10/15.
//  Copyright © 2015 Mirzanejad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSDataEncryptorHelper : NSObject

+ (NSSet *)allFilesSubpathesForDirectoryPath:(NSString *)directoryPath;

+ (void)encryptFilesWithInputPath:(NSString *)inputPath
                   filesSubpathes:(NSSet *)filesSubpathes
                       outputPath:(NSString *)outputPath
                         password:(NSString *)password
                      updateBlock:(void(^)(float progress, NSString *updateString))updateBlock;

+ (void)decryptFilesWithInputPath:(NSString *)inputPath
                   filesSubpathes:(NSSet *)filesSubpathes
                       outputPath:(NSString *)outputPath
                         password:(NSString *)password
                      updateBlock:(void(^)(float progress, NSString *updateString))updateBlock;

@end
