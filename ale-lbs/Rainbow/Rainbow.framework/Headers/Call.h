/*
 * Rainbow
 *
 * Copyright (c) 2016-2017, ALE International
 * All rights reserved.
 *
 * ALE International Proprietary Information
 *
 * Contains proprietary/trade secret information which is the property of
 * ALE International and must not be made available to, or copied or used by
 * anyone outside ALE International without its written authorization
 *
 * Not to be disclosed or used except in accordance with applicable agreements.
 */

#import <Foundation/Foundation.h>
#import "CallProtocol.h"

@interface Call : NSObject
@property (nonatomic, readonly) NSString *callRef;
@property (nonatomic, readonly) Peer *peer;
@property (nonatomic, readonly) BOOL isIncoming;
@property (nonatomic, readonly) BOOL isMediaPillarCall;
@property (nonatomic, readonly) CallStatus status;
@property (nonatomic, readonly) NSDate *connectionDate;
@property (nonatomic, readonly) CallCapabilities capabilities;
@property (nonatomic, readonly) NSString *callCause;
// private ?
@property (nonatomic, readonly) BOOL readyToDisplay;
@end
