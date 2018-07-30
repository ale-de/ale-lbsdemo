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
#import "Call.h"

/**
 *  RTCCall type
 */
typedef NS_ENUM(NSInteger, RTCCallFeatureFlags) {
    /**
     *  Audio feature
     */
    RTCCallFeatureAudio = 1 << 0,
    /**
     *  Remote Video available
     */
    RTCCallFeatureRemoteVideo = 1 << 1,
    /**
     * Local video available
     */
    RTCCallFeatureLocalVideo = 1 << 2,
    /**
     *  Remote sharing available
     */
    RTCCallFeatureRemoteSharing = 1 << 3,
    /**
     *  Media pillar feature
     */
    RTCCallFeatureMediaPillar = 1 << 4
};


@interface RTCCall : Call
@property (nonatomic, readonly) NSUUID *callID;

@property(nonatomic, readonly) NSString *jingleSessionID;

@property(nonatomic, readonly) RTCCallFeatureFlags features;

@property (nonatomic, readonly) BOOL isRecording;

-(BOOL) isAudioEnabled;

-(BOOL) isVideoEnabled;

-(BOOL) isLocalVideoEnabled;

-(BOOL) isRemoteVideoEnabled;

-(BOOL) isSharingEnabled;
@end
