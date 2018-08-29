/*
 * Rainbow
 *
 * Copyright (c) 2018, ALE International
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

@interface MediaPillarStatus : NSObject

/** The mediapillar jid  */
@property (nonatomic, readonly) NSString *jid;

/** The user mediapillar rainbowPhoneNumber  */
@property (nonatomic, readonly) NSString *rainbowPhoneNumber;

/** The rainbowPhoneNumber prefix needed to makecall  */
@property (nonatomic, readonly) NSString *prefix;

/** User's mediapillar feature rights */
@property (nonatomic, readonly) BOOL featureActivated;

/** Boolean indicating mediapillar voip activation */
@property (nonatomic, readonly) BOOL activated;

@end
