//
//  Nao.h
//  nao-swift
//
//  Created by Dirk Evrard on 23/02/18.
//  Copyright © 2018 Dirk Evrard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBNAOERRORCODE.h"
#import "NAOSDK.h"
#import "DBTNAOFIXSTATUS.h"

@interface Nao : NSObject <NAOSyncDelegate, NAOLocationHandleDelegate, NAOSensorsDelegate, NAOGeofencingHandleDelegate, NAOBeaconProximityHandleDelegate>
    @property NAOLocationHandle* mLocationHandle;
    @property NAOGeofencingHandle* mGeofenceHandle;
    @property NAOBeaconProximityHandle* mBeaconProximityHandle;
@end
