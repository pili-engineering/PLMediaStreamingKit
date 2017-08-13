//
//  PREDPrivate.h
//  PreDemObjc
//
//  Created by WangSiyu on 21/02/2017.
//  Copyright © 2017 pre-engineering. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PREDLogger.h"

#ifndef PreDemObjc_PREDPrivate_h
#define PreDemObjc_PREDPrivate_h

#define PRED_IDENTIFIER @"net.predem.sdk.ios"
#define PRED_CRASH_SETTINGS @"PREDCrashManager.plist"
#define PRED_DEFAULT_DOMAIN @"http://hriygkee.bq.cloudappl.com"

#ifndef TARGET_OS_SIMULATOR

#ifdef TARGET_IPHONE_SIMULATOR

#define TARGET_OS_SIMULATOR TARGET_IPHONE_SIMULATOR

#else

#define TARGET_OS_SIMULATOR 0

#endif /* TARGET_IPHONE_SIMULATOR */

#endif /* TARGET_OS_SIMULATOR */

#endif /* PreDemObjc_PREDPrivate_h */
