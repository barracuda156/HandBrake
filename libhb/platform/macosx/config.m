/* config.m

   Copyright (c) 2003-2025 HandBrake Team
   This file is part of the HandBrake source code
   Homepage: <http://handbrake.fr/>.
   It may be used under the terms of the GNU General Public License v2.
   For full terms see the file COPYING file or visit http://www.gnu.org/licenses/gpl-2.0.html
 */

#import <Foundation/Foundation.h>

static NSURL * macOS_last_modified_url(NSURL *url1, NSURL* url2)
{
    NSString *presetFile = @"HandBrake/UserPresets.json";

    NSURL *presetsUrl1 = [url1 URLByAppendingPathComponent:presetFile isDirectory:NO];
    NSURL *presetsUrl2 = [url2 URLByAppendingPathComponent:presetFile isDirectory:NO];

    NSDate *date1 = nil;
    [presetsUrl1 getResourceValue:&date1 forKey:NSURLAttributeModificationDateKey error:nil];

    NSDate *date2 = nil;
    [presetsUrl2 getResourceValue:&date2 forKey:NSURLAttributeModificationDateKey error:nil];

    // Return url2 if presetsUrl2 exists and date2 is newer than date1 (or date1 is nil)
    if (presetsUrl2 != nil && (date1 == nil || [date2 compare:date1] == NSOrderedDescending))
    {
        return url2;
    }
    return url1;
}

static NSURL * macOS_get_application_support_url()
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *applicationSupportUrls = [fileManager URLsForDirectory:NSApplicationSupportDirectory
                                                           inDomains:NSUserDomainMask];

    NSURL *appSupportURL = [applicationSupportUrls objectAtIndex:0];

    NSArray *libraryUrls = [fileManager URLsForDirectory:NSLibraryDirectory
                                                inDomains:NSUserDomainMask];
    NSString *sandboxPath = @"Containers/fr.handbrake.HandBrake/Data/Library/Application Support";
    NSURL *sandboxAppSupportURL = [[libraryUrls objectAtIndex:0] URLByAppendingPathComponent:sandboxPath isDirectory:YES];

    return macOS_last_modified_url(appSupportURL, sandboxAppSupportURL);
}

int macOS_get_user_config_directory(char path[512])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSURL *url = macOS_get_application_support_url();

    if (url == nil)
    {
        [pool release];
        return -1;
    }

    strncpy(path, [url fileSystemRepresentation], 511);
    path[511] = 0;
    
    [pool release];
    return 0;
}
