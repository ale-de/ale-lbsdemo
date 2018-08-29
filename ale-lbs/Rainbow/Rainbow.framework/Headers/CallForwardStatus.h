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

typedef NS_ENUM(NSInteger, CallForwardType) {
    /**
     *  Type not forwarded
     */
    CallForwardTypeNotForwarded = 0,
    /**
     *  Type voicemail
     */
    CallForwardTypeVoicemail,
    /**
     *  Type phone number
     */
    CallForwardTypePhoneNumber
    
};

@interface CallForwardStatus : NSObject

/** Boolean indicating the login or not state */
@property (nonatomic, readonly) CallForwardType type;

/** The nomadic destination's number  */
@property (nonatomic, readonly) PhoneNumber *destination;

@end
