//
//  PREDCrashReportTextFormatter.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CrashReporter/CrashReporter.h>


/**
 *  PreDemObjc Crash Reporter error domain
 */
typedef NS_ENUM (NSInteger, PREDBinaryImageType) {
    /**
     *  App binary
     */
    PREDBinaryImageTypeAppBinary,
    /**
     *  App provided framework
     */
    PREDBinaryImageTypeAppFramework,
    /**
     *  Image not related to the app
     */
    PREDBinaryImageTypeOther
};


@interface PREDCrashReportTextFormatter : NSObject

+ (NSString *)stringValueForCrashReport:(PLCrashReport *)report crashReporterKey:(NSString *)crashReporterKey;
+ (BOOL)isReport:(PLCrashReport *)report euivalentWith:(PLCrashReport *)otherReport;
+ (NSString *)pres_archNameFromCPUType:(uint64_t)cpuType subType:(uint64_t)subType;
+ (PREDBinaryImageType)pres_imageTypeForImagePath:(NSString *)imagePath processPath:(NSString *)processPath;

@end
