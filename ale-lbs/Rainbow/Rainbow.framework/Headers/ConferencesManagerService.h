/*
 * Rainbow
 *
 * Copyright (c) 2016, ALE International
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

#import "Conference.h"
#import "ConfEndpoint.h"
#import "ConferenceParticipant.h"
#import "Room.h"

#define kMeetingJoinBeforeStartIntervalInSeconds 10*60

FOUNDATION_EXPORT NSString *const kConferencesManagerDidAddConference;
FOUNDATION_EXPORT NSString *const kConferencesManagerDidUpdateConference;
FOUNDATION_EXPORT NSString *const kConferencesManagerDidRemoveConference;

FOUNDATION_EXPORT NSString *const kConferenceKey;
FOUNDATION_EXPORT NSString *const kConferenceChangedAttributesKey;

@interface ConferencesManagerService : NSObject

typedef void (^ConferenceManagerCompletionHandler) (NSError *error);

@property (nonatomic, readonly) NSArray<Conference *> *conferences;

@property (nonatomic) BOOL hasWebRTCInstantConference;
@property (nonatomic) BOOL hasPstnInstantConference;

/**
 *  webRTC conference end point
 */
-(ConfEndpoint *) webRTCConferenceEndPoint;

-(ConfEndpoint *) pstnInstantConferenceEndPoint;

/**
 *  Create a conference room for the given room with a start date and a endDate
 *  @param  room                the room in which we want to create a conference
 *  @param  startDate           the starting date of the meeting
 *  @param  endDate             the end date of the meeting
 *  @param  completionHandler   use in return of the create action
 */
-(void) createConferenceForRoom:(Room *) room startDate:(NSDate *) startDate endDate:(NSDate*) endDate completionHandler:(ConferenceManagerCompletionHandler) completionHandler;

/**
 *  Update the given conference with the new startDate and the new endDate
 *  @param  room                The room in which we want to update a conference
 *  @param  startDate           The new starting date
 *  @param  endDate             The new end date
 *  @param  completionHandler   use in return of the update action
 */
-(void) updateConferenceForRoom:(Room *) room startDate:(NSDate *) startDate endDate:(NSDate *) endDate completionHandler:(ConferenceManagerCompletionHandler) completionHandler;

/**
 * Request conference details for the given conference
 * `kConferencesManagerDidUpdateConference` will be trigger when the update is done
 *
 *  @param conference           the conference that we want more details
 *  @param completionHandler    the completionHandler use to return error in case there is one
 */
-(void) fetchConferenceDetails:(Conference *) conference completionBlock:(ConferenceManagerCompletionHandler) completionHandler;

/**
 * Delete a conference
 *
 * @param conference        the conference to delete
 * @param completionHandler the block called at the completion
 */
-(void) deleteConference:(Conference *) conference completionBlock:(ConferenceManagerCompletionHandler) completionHandler;

/**
 * join a audio conference 
 *
 * @param conference        the conference to join
 * @param phoneNumber       phone number in E.164 format
 * @param role              the role in the conference : member or moderator
 * @param completionHandler the block called at the completion
 */
-(void) joinConference:(Conference *)conference phoneNumber:(NSString *) phoneNumber role:(ParticipantRole)role completionBlock:(ConferenceManagerCompletionHandler)completionHandler;

/**
 * join a conference
 */
-(void) joinConference:(Conference *)conference role:(ParticipantRole)role completionBlock:(ConferenceManagerCompletionHandler) completionHandler;

/**
 * disconnect the conference participant using its participant id
 *
 * @param participant       the participant to disconnect
 * @param conference     the conference where we can find the participant
 */
-(void) disconnectParticipant:(ConferenceParticipant *) participant inConference:(Conference *) conference;

/**
 * mute the given participant in the given conference
 *
 * @param participant       the participant to mute
 * @param conference        the conference where the participant is attending
 */
-(void) muteParticipant:(ConferenceParticipant *) participant inConference:(Conference *) conference;

/**
 * unmute the given participant in the given conference
 *
 * @param participant       the participant to unmute
 * @param conference        the conference where the participant is attending
 */
-(void) unmuteParticipant:(ConferenceParticipant *) participant inConference:(Conference *) conference;

/**
 * mute All participants in the given conference
 *
 * @param conference        the conference where all participants must be muted
 */
-(void) muteAllParticipantsInConference:(Conference *) conference;

/**
 * mute All participants in the given conference
 *
 * @param conference        the conference where all participants must be muted
 */
-(void) unmuteAllParticipantsInConference:(Conference *) conference;

/**
 * Initiate a audio conference
 *
 * @param conference the conference to start
 * @param completionHandler the block called at the completion
 */
-(void) startConference:(Conference *) conference completionHandler:(ConferenceManagerCompletionHandler) completionHandler;

/**
 * Initiate, if needed, a audio conference then join it
 *
 * @param conference        the conference to join
 * @param phoneNumber       phone number in E.164 format
 * @param role              the role in the conference : member or moderator
 * @param completionHandler the block called at the completion
 */
-(void) startAndJoinConference:(Conference *)conference phoneNumber:(NSString *) phoneNumber role:(ParticipantRole)role completionBlock:(ConferenceManagerCompletionHandler)completionHandler;

/**
 * Terminate a audio conference
 *
 * @param conference        the conference to terminate
 * @param completionHandler the block called at the completion
 */
-(void) terminateConference:(Conference *) conference completionHandler:(ConferenceManagerCompletionHandler) completionHandler;

/**
 *  Invite given participants to join the given conference
 *  @param  participants        Array of Participant to invite
 *  @param  conference          Conference where participants are invited
 *  @param  room                Room where participants are invited
 *  @param  completionHandler   The block invoked when the invitations are sent
 */
-(void) inviteParticipants:(NSArray <Participant *> *) participants toJoinConference:(Conference *) conference inRoom:(Room *) room completionBlock:(ConferenceManagerCompletionHandler) completionHandler;

/**
 *  Cancel invitations for the given conference sent to given participant list
 *  @param  participants        Array of Participant to sent a cancel notification
 *  @param  conference          Conference where participants are invited
 *  @param  room                Room where participatns are invited
 *  @param  completionHandler   The block invoked when the invitations are cancelled
 */
-(void) cancelInvitationSentToParticipants:(NSArray <Participant *> *) participants toConference:(Conference *) conference inRoom:(Room *) room completionBlock:(ConferenceManagerCompletionHandler) completionHandler;
@end
