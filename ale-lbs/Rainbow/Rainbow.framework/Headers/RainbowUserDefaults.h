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

@interface RainbowUserDefaults : NSObject

/**
 *  Set the suite name to use when init of NSUserDefaults, if nil we use the standart defaults
 */
+(void) setSuiteName:(NSString *_Nullable) newSuiteName;

+(NSString *_Nullable) suiteName;

/**
 *  Return a shared instance of user defaults
 */
+(RainbowUserDefaults*_Nonnull) sharedInstance;

- (nullable id)objectForKey:(NSString *_Nonnull)defaultName;
- (void) setObject:(id _Nonnull )value forKey:(NSString *_Nonnull)defaultName;
- (void)removeObjectForKey:(NSString *_Nonnull)defaultName;
- (NSString *_Nullable)stringForKey:(NSString *_Nonnull)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *_Nonnull)defaultName;
- (BOOL)boolForKey:(NSString *_Nonnull)defaultName;
- (nullable NSArray *)arrayForKey:(NSString *_Nonnull)defaultName;
- (void)registerDefaults:(NSDictionary<NSString *, id> *_Nonnull)registrationDictionary;

-(void) migrateNSUserDefaultsToSharedDefaults;
@end
