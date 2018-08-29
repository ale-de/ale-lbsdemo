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

#define OTCLog(format, ...) NSLog(@"[%@:%d] %@", NSStringFromClass([self class]), __LINE__, [NSString stringWithFormat:(format), ##__VA_ARGS__])


@interface Tools : NSObject
NSString* NSStringFromBOOL(BOOL aBoolean);

+ (NSString *) applicationName;
+ (NSString *) applicationVersion;
+ (NSString *) currentOS;
+ (NSString *) currentOSVersion;
+ (NSString *) encodeToPercentEscapeString:(NSString *) string;
+ (NSString *)generateUniqueID;
+ (BOOL) isValidEmailAddress:(NSString *) emailAddress;

+ (NSString *) byteSizeToFormattedString:(id)value;
+ (NSDate *) dateWithLastModifiedHeaderString:(NSString *) dateString;
+ (NSDate *) dateFromString:(NSString *) dateString withFormat: (NSString *) formatString;
+ (NSString *) anonymizeString:(NSString *) string;
+ (NSString *) anonymizeNotificationRequest:(NSString *) request;
+ (NSString *) anonymizeNotificationUserInfo:(NSDictionary *) userInfo;
+ (NSString *)valueForKey:(NSString *)key fromURL:(NSURL *)url;
+ (NSURLQueryItem *)containsQueryItem:(NSString *)key fromURL:(NSURL *)url;
+ (NSString *) resourceName;
+ (NSString *) rainbowAppGroupPath;
@end
