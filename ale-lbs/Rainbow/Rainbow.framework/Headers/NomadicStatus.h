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
#import "PhoneNumber.h"

@interface NomadicStatus : NSObject

/** The nomadic destination's number  */
@property (nonatomic, readonly) PhoneNumber *destination;

/** User's nomadic telephonic feature rights */
@property (nonatomic, readonly) BOOL featureActivated;

/** Boolean indicating the login or not state */
@property (nonatomic, readonly) BOOL activated;

@end
