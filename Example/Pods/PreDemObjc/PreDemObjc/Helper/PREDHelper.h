//
//  PREDHelper.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDEnums.h"

@interface PREDHelper : NSObject

FOUNDATION_EXPORT NSString *const kPREDExcludeApplicationSupportFromBackup;

@property(class, readonly) BOOL isURLSessionSupported;
@property(class, readonly) NSString *settingsDir;
@property(class, readonly) NSString *keychainPreDemObjcServiceName;
@property(class, readonly) NSString *mainBundleIdentifier;
@property(class, readonly) NSString *UUID;
@property(class, readonly) BOOL isPreiOS8Environment;
@property(class, readonly) BOOL isAppStoreReceiptSandbox;
@property(class, readonly) BOOL hasEmbeddedMobileProvision;
@property(class, readonly) BOOL isRunningInAppExtension;
@property(class, readonly) BOOL isDebuggerAttached;
@property(class, readonly) NSString *deviceType;
@property(class, readonly) NSString *osVersionBuild;
@property(class, readonly) NSString *osPlatform;
@property(class, readonly) NSString *deviceLocale;
@property(class, readonly) NSString *deviceLanguage;
@property(class, readonly) NSString *sdkVersion;
@property(class, readonly) NSString *sdkBuild;
@property(class, readonly) NSString *appVersion;
@property(class, readonly) NSString *appBuild;
@property(class, readonly) NSString *appName;
@property(class, readonly) NSString *appBundleId;
@property(class, readonly) NSString *osVersion;
@property(class, readonly) NSString *osBuild;
@property(class, readonly) NSString *deviceModel;
@property(class, readonly) NSString *executableUUID;
@property(class, strong) NSString *tag;

+ (NSString *)encodeAppIdentifier:(NSString *)inputString;
+ (NSString *)appName:(NSString *)placeHolderString;
+ (NSString *)URLEncodedString:(NSString *)inputString;
+ (NSDictionary*)getObjectData:(id)obj;
+ (NSString *)MD5:(NSString *)mdStr;

@end
