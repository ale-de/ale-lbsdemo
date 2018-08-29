/*
 * Rainbow
 *
 * Copyright (c) 2017, ALE International
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
#import "Contact.h"

typedef NS_ENUM(NSInteger, FileType) {
    FileTypeImage,
    FileTypePDF,
    FileTypeDoc,
    FileTypePPT,
    FileTypeXLS,
    FileTypeAudio,
    FileTypeVideo,
    FileTypeOther
};
typedef NS_ENUM(NSInteger, FilterFileType) {
    FilterFilesAll,
    FilterTypeImage,
    FilterTypeAudioORVideo,
    FilterTypePDF,
    FilterTypeMicrosoftOffice

};
@interface File : NSObject
/**
 * file url on server
 */
@property (readonly) NSURL *url;

/**
 * file name
 */
@property (readonly) NSString *fileName;

/**
 * mimetype
 */
@property (readonly) NSString *mimeType;

// Type of file
@property (readonly) FileType type;

/**
 * file size
 */
@property (readonly) NSUInteger size;

/**
 * Data downloaded from server
 */
@property (readonly) NSData *data;


/**
 * Data downloaded thumbnail from server
 */
@property (readonly) NSData *thumbnailData;

/**
 * List of Peer (Contact or Room) allowed to see this file
 */
@property (readonly) NSArray<Peer*> *viewers;

/**
 *  Date of upload of this file
 */
@property (readonly) NSDate *uploadDate;

/**
 *  Date to use for sorting the files
 */
@property (readonly) NSDate *dateToSort;

/**
 *  File owner
 */
@property (readonly) Contact *owner;

/**
 *  @return `YES` if the download is available on server side (at init we suppose that the download is available, when the download failed this boolean is set to `NO`
 */
@property (readonly) BOOL isDownloadAvailable;

/**
 *  @return `NO` if the download is Failed from server (at init we suppose that we can Download File, when the download failed this boolean is set to `NO`
 */
@property (readwrite) BOOL canDownloadFile;
/**
 *  @return `YES` if the attchament is sent in offline Mode
 */
@property  BOOL isOfflineAttachment;

/**
 * File Tag 
 */

@property  NSString * tag;

/**
 * File value
 */

@property  float value;

/**
 *  @return `YES` if the file has a preview in the cloud
 */
@property (readonly) BOOL hasThumbnailOnServer;

@end
