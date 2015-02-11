//
//  TSDataEncryptorController.m
//  DataEncryptor
//
//  Created by Mirzanejad on 1/12/15.
//  Copyright © 2015 Mirzanejad. All rights reserved.
//

#import "TSDataEncryptorController.h"
#import "TSDataEncryptorHelper.h"

@interface TSDataEncryptorController ()

@property (nonatomic, weak) IBOutlet NSTextField *encryptTextField;
@property (nonatomic, weak) IBOutlet NSTextField *decryptTextField;
@property (nonatomic, weak) IBOutlet NSSecureTextField *passTextField;

@property (nonatomic, weak) IBOutlet NSTextField *progressTextField;
@property (nonatomic, weak) IBOutlet NSTextField *progressLabelTextField;
@property (nonatomic, assign) IBOutlet NSTextView *infoTextView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *infoTextViewHeightConstraint;

@property (nonatomic, weak) IBOutlet NSButton *encryptButton;
@property (nonatomic, weak) IBOutlet NSButton *decryptButton;
@property (nonatomic, weak) IBOutlet NSButton *encryptOpenButton;
@property (nonatomic, weak) IBOutlet NSButton *decryptOpenButton;

@property (nonatomic, strong, readonly) NSOpenPanel *encryptPanel;
@property (nonatomic, strong, readonly) NSOpenPanel *decryptPanel;

- (IBAction)onEncrypt:(id)sender;
- (IBAction)onDecrypt:(id)sender;

- (IBAction)onEncryptOpen:(id)sender;
- (IBAction)onDecryptOpen:(id)sender;

@end

@implementation TSDataEncryptorController
@synthesize encryptPanel = _encryptPanel;
@synthesize decryptPanel = _decryptPanel;

#pragma mark - panels stuff

- (NSOpenPanel *)createPanel
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.prompt = @"Choose";
    panel.canChooseDirectories = YES;
    panel.canCreateDirectories = YES;
    
    return panel;
}

- (NSOpenPanel *)encryptPanel
{
    if (_encryptPanel == nil)
    {
        _encryptPanel = [self createPanel];
    }
    
    return _encryptPanel;
}

- (NSOpenPanel *)decryptPanel
{
    if (_decryptPanel == nil)
    {
        _decryptPanel = [self createPanel];
    }
    
    return _decryptPanel;
}

#pragma mark - IBAction's

- (IBAction)onEncrypt:(id)sender
{
    [self blockUI:YES];
    
    BOOL isDirectory = NO;
    NSString *filePath = self.encryptTextField.stringValue;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    if (isExist)
    {
        NSString *inputPath = nil;
        NSSet *filesSubpathes = nil;
        
        if (isDirectory)
        {
            inputPath = filePath;
            filesSubpathes = [TSDataEncryptorHelper allFilesSubpathesForDirectoryPath:filePath];
        }
        else
        {
            inputPath = [filePath stringByDeletingLastPathComponent];
            NSString *fileSubpath = [filePath lastPathComponent];
            filesSubpathes = [NSSet setWithObject:fileSubpath];
        }
        
        [TSDataEncryptorHelper encryptFilesWithInputPath:inputPath
                                          filesSubpathes:filesSubpathes
                                              outputPath:self.decryptTextField.stringValue
                                                password:self.passTextField.stringValue
                                             updateBlock:^(float progress, NSString *updateString) {
                                                 [self updateUIWithProgress:progress updateString:updateString];
                                             }];
    }
    else
    {
        [self updateUIWithProgress:1.0f updateString:@"There is no input file/directory!"];
    }
}

- (IBAction)onDecrypt:(id)sender
{
    [self blockUI:YES];
    
    BOOL isDirectory = NO;
    NSString *filePath = self.decryptTextField.stringValue;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    if (isExist)
    {
        NSString *inputPath = nil;
        NSSet *filesSubpathes = nil;
        
        if (isDirectory)
        {
            inputPath = filePath;
            filesSubpathes = [TSDataEncryptorHelper allFilesSubpathesForDirectoryPath:filePath];
        }
        else
        {
            inputPath = [filePath stringByDeletingLastPathComponent];
            NSString *fileSubpath = [filePath lastPathComponent];
            filesSubpathes = [NSSet setWithObject:fileSubpath];
        }
        
        [TSDataEncryptorHelper decryptFilesWithInputPath:inputPath
                                          filesSubpathes:filesSubpathes
                                              outputPath:self.encryptTextField.stringValue
                                                password:self.passTextField.stringValue
                                             updateBlock:^(float progress, NSString *updateString) {
                                                 [self updateUIWithProgress:progress updateString:updateString];
                                             }];
    }
    else
    {
        [self updateUIWithProgress:1.0f updateString:@"There is no input file/directory!"];
    }
}

- (IBAction)onEncryptOpen:(id)sender
{
    NSInteger clicked = [self.encryptPanel runModal];
    if (clicked == NSFileHandlingPanelOKButton)
    {
        self.encryptTextField.stringValue = self.encryptPanel.URL.path;
        
        if (0 == self.decryptTextField.stringValue.length)
        {
            NSURL *suggestedURL = [self suggestedDirectoryURLFromPanel:self.encryptPanel];
            self.decryptPanel.directoryURL = suggestedURL;
            self.decryptTextField.stringValue = suggestedURL.path;
        }
    }
}

- (IBAction)onDecryptOpen:(id)sender
{
    NSInteger clicked = [self.decryptPanel runModal];
    if (clicked == NSFileHandlingPanelOKButton)
    {
        self.decryptTextField.stringValue = self.decryptPanel.URL.path;
        
        if (0 == self.encryptTextField.stringValue.length)
        {
            NSURL *suggestedURL = [self suggestedDirectoryURLFromPanel:self.decryptPanel];
            self.encryptPanel.directoryURL = suggestedURL;
            self.encryptTextField.stringValue = suggestedURL.path;
        }
    }
}

#pragma mark - private methods

- (NSURL *)suggestedDirectoryURLFromPanel:(NSOpenPanel *)panel
{
    NSURL *suggestedDirectoryURL = nil;
    
    NSArray *pathes = panel.URLs;
    if (pathes.count == 1)
    {
        if ([[pathes firstObject] isEqualTo:panel.directoryURL]) //one directory has been chosen
        {
            suggestedDirectoryURL = panel.directoryURL.URLByDeletingLastPathComponent;
        }
        else //one file has been chosen
        {
            suggestedDirectoryURL = panel.directoryURL;
        }
    }
    else
    {
        suggestedDirectoryURL = panel.directoryURL;
    }
    
    return suggestedDirectoryURL;
}

- (void)updateUIWithProgress:(float)progress updateString:(NSString *)updateString
{
    if (nil != updateString)
    {
        NSString *appendingString = [NSString stringWithFormat:@"%@\n", updateString];
        self.infoTextView.string = [self.infoTextView.string stringByAppendingString:appendingString];
    }
    self.progressTextField.stringValue = [NSString stringWithFormat:@"%d%%", (int)(progress*100)];
    
    if (progress >= 1.0f)
    {
        [self blockUI:NO];
    }
}

- (void)blockUI:(BOOL)isBlock
{
    if (isBlock)
    {
        self.infoTextView.string = @"";
        self.progressTextField.stringValue = @"0%";
        
        self.progressLabelTextField.hidden = NO;
        self.infoTextView.editable = NO;
        self.infoTextViewHeightConstraint.animator.constant = 200;
    }
    
    self.encryptButton.enabled = !isBlock;
    self.decryptButton.enabled = !isBlock;
    self.encryptOpenButton.enabled = !isBlock;
    self.decryptOpenButton.enabled = !isBlock;
    
    self.encryptTextField.editable = !isBlock;
    self.decryptTextField.editable = !isBlock;
    self.passTextField.editable = !isBlock;
}

@end
