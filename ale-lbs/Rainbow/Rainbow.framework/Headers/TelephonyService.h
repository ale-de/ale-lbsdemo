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
#import "Contact.h"
#import "Call.h"

#define OTCLog(format, ...) NSLog(@"[%@:%d] %@", NSStringFromClass([self class]), __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])


/**
 Notification of new call, object following protocol `CallProtocol` will be sent in object parameter of the notification
 */
FOUNDATION_EXPORT NSString * _Nonnull const kTelephonyServiceDidAddCallNotification;
/**
 Notification for call updated, object following protocol `CallProtocol` will be sent in object parameter of the notification
 */
FOUNDATION_EXPORT NSString * _Nonnull const kTelephonyServiceDidUpdateCallNotification;
/**
 Notification for call removed, object following protocol `CallProtocol` will be sent in object parameter of the notification
 */
FOUNDATION_EXPORT NSString * _Nonnull const kTelephonyServiceDidRemoveCallNotification;

/**
 Notification for call failed action, notification object will contain the error that occur
 */
FOUNDATION_EXPORT NSString * _Nonnull const kTelephonyServiceDidFailedToCallNotification;

/**
 * Handler executed when the service is not able to perform the make call action
 */
typedef void (^TelephonyServiceMakeCallFallBack)(NSError * _Nonnull error, PhoneNumber * _Nonnull phoneNumber);
/**
 * Handler executed when the action is completed
 */
typedef void (^TelephonyServiceMakeCallCompletionHandler)(NSError * _Nullable error);

/**
 *  Telephony service
 */
@interface TelephonyService : NSObject

/**
 *  Activate telephony nomadic
 *
 *  @param phoneNumber the phone number to use
 */
-(void) nomadicLoginWithPhoneNumber:(PhoneNumber * _Nonnull)phoneNumber withVoIP:(BOOL)voip withCompletionBlock:( void (^ _Nullable )(NSError * _Nullable error))completionBlock;

/**
 *  Activate telephony nomadic
 *
 *  @param phoneNumber the string phone number to use
 */
-(void) nomadicLoginWithPhoneString:(NSString * _Nonnull)phoneNumber withVoIP:(BOOL)voip withCompletionBlock:(void (^ _Nullable)(NSError * _Nullable error))completionBlock;

/**
 *  Disable telephony nomadic
 *
 */
-(void) nomadicLogoutWithCompletionBlock:(void (^ _Nullable)(NSError * _Nullable error))completionBlock;

/**
 *  Enable forward to device
 *
 *  @param phoneNumber the phone number to use
 */
-(void) forwardToExternalPhoneNumber:(PhoneNumber * _Nonnull)phoneNumber withCompletionBlock:(void (^ _Nullable)(NSError * _Nullable error))completionBlock;

/**
 *  Enable forward to device
 *
 *  @param phoneNumber the string phone number to use
 */
-(void) forwardToExternalPhoneString:(NSString * _Nonnull)phoneNumber withCompletionBlock:(void (^ _Nullable)(NSError * _Nullable error))completionBlock;

/**
 *  Enable forward to voicemail
 *
 */
-(void) forwardToVoicemailWithCompletionBlock:(void (^ _Nullable)(NSError * _Nullable error))completionBlock;

/**
 *  Disable forward
 *
 */
-(void) cancelForwardWithCompletionBlock:(void (^ _Nullable)(NSError * _Nullable error))completionBlock;


/**
 *  Make call to the given phone number
 *  @param phoneNumber  the phoneNumber to call
 *  @param fallbackHandler  block of code executed when the service is not able to perform the make call action
 *  @param completionHandler    block of code executed when the action is completed
 *  @discussion this action will trigger an add call notification
 */
-(void) makeCallTo:(PhoneNumber *_Nonnull) phoneNumber fallBackHandler:(TelephonyServiceMakeCallFallBack _Nullable ) fallbackHandler completionHandler:(TelephonyServiceMakeCallCompletionHandler _Nullable ) completionHandler;

/**
 * Release the given call
 * @param call  the call to release
 * @discussion  this action will trigger a remove call notification
 */
-(void) releaseCall:(Call *_Nonnull) call;

/**
 *  Answer the given call
 *  @param call the call to answer
 *  @discussion  this action will trigger an update call notification
 */
-(void) answerCall:(Call * _Nonnull) call;

/**
 *  Deflect the given call to given phone number
 *  @param call the call to deflect
 *  @param phoneNumber  the phone number where the call must be deflected
 *  @discussion this action will trigger a update and a remove call notification
 */
-(void) deflectCall:(Call * _Nonnull) call toPhoneNumber:(PhoneNumber * _Nonnull) phoneNumber;

/**
 *  Hold the given call
 *  @param call the call to hold
 *  @discussion this action will trigger an update call notification
 */
-(void) holdCall:(Call * _Nonnull) call;

/**
 *  Retrieve the given call
 *  @param call the call to retrieve
 *  @discussion this action will trigger an update call notification
 */
-(void) retrieveCall:(Call * _Nonnull) call;

/**
 *  Transfer the given call to the given held call
 *  @param  call the current call to transfer
 *  @param  heldCall    the call in held state which "received" the transfered call
 *  @discussion this action will trigger an update and a remove call notification
 */
-(void) transferCall:(Call * _Nonnull) call toHeldCall:(Call * _Nonnull) heldCall;

/**
 *  Cancel current outgoing call (not yet displayed)
 */
-(void) cancelOutgoingCall;

@end
