//
//  TSDataEncryptor.m
//  DataEncryptor
//
//  Created by Mirzanejad on 2/10/15.
//  Copyright (c) 2015 Mirzanejad. All rights reserved.
//

#import "TSDataEncryptor.h"

@implementation TSDataEncryptor

//openssl des3 -salt -in 1.png -out 2.txt -k pass1
+ (void)encryptFileWithPath:(NSString *)inFilePath
                outFilePath:(NSString *)outFilePath
                       pass:(NSString *)pass
                      error:(NSError **)error
{
    NSString *command = [NSString stringWithFormat:@"openssl des3 -salt -in '%@' -out '%@' -k '%@'", inFilePath, outFilePath, pass];
    [self runTerminalCommand:command error:error];
}

//openssl des3 -d -salt -in 2.txt -out 3.png -k pass1
+ (void)decryptFileWithPath:(NSString *)inFilePath
                outFilePath:(NSString *)outFilePath
                       pass:(NSString *)pass
                      error:(NSError **)error
{
    NSString *command = [NSString stringWithFormat:@"openssl des3 -d -salt -in '%@' -out '%@' -k '%@'", inFilePath, outFilePath, pass];
    [self runTerminalCommand:command error:error];
}

+ (void)runTerminalCommand:(NSString *)commandString error:(NSError **)error
{
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-c", commandString];
    task.standardError = pipe;
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    if (0 != data.length && nil != error)
    {
        *error = [[NSError alloc] initWithDomain:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                                            code:101
                                        userInfo:nil];
    }
}

@end
