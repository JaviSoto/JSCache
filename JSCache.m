/* 
 Copyright 2012 Javier Soto (ios@javisoto.es)
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. 
 */

#import "JSCache.h"

#import "EGOCache.h"

#define JSCACHE_ENABLED 1

#define kJSCacheImageCacheDurationInSeconds 1296000 // 15 days
#define kJSCacheDataCacheDurationInSeconds 604800 // 7 days

#define JSCacheDebug 0

#if JSCacheDebug
    #define JSCacheDebugLog(s,...) NSLog([NSString stringWithFormat:@"[%@] %@", NSStringFromClass[self class], ##__VA_ARGS__])
#else
    #define JSCacheDebugLog(s,...)
#endif

@interface JSCache()
{
    dispatch_queue_t _jsCacheQueue;
}
@end

@implementation JSCache

#pragma mark - Singleton

+ (JSCache *)sharedCache
{
    static dispatch_once_t dispatchOncePredicate;
    static JSCache *myInstance = nil;
    
    dispatch_once(&dispatchOncePredicate, ^{
        myInstance = [[self alloc] init];
        
        myInstance->_jsCacheQueue = dispatch_queue_create("JSCacheQueue", DISPATCH_QUEUE_CONCURRENT);
        
        #if !JSCACHE_ENABLED
            JSCacheDebugLog(@"CACHE NOT ENABLED");
            [myInstance invalidateAllCachedObjects];
        #endif
    });
    
    return myInstance;
}

#pragma mark -

- (void)cacheObject:(id<NSObject, NSCoding>)object forKey:(NSString *)key
{
    #if JSCACHE_ENABLED
    	id objectToArchive = object;
    
	    if ([objectToArchive isKindOfClass:[NSMutableArray class]] || [objectToArchive isKindOfClass:[NSMutableDictionary class]] || [objectToArchive isKindOfClass:[NSMutableSet class]]) // If its'a mutable collection, make a copy to avoid it being mutated while archiving
	    {
	        objectToArchive = [[(NSObject *)object copy] autorelease];
	    }
    
	    dispatch_async(_jsCacheQueue, ^{        
	        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:objectToArchive]; 
	        JSCacheDebugLog(@"Caching object %@ for key %@", object, key);
            
	        dispatch_async(dispatch_get_main_queue(), ^{
	            [[EGOCache currentCache] setData:data forKey:key withTimeoutInterval:kJSCacheDataCacheDurationInSeconds];
	        });

	    });
	#endif
}

- (id)cachedObjectForKey:(NSString *)key
{
    #if !JSCACHE_ENABLED
        return nil;
    #else
    	id cachedObject = [[EGOCache currentCache] dataForKey:key];
    
	    if (cachedObject)
	    {
	        JSCacheDebugLog(@"Returning cached object for key %@", key);
	        id object = [NSKeyedUnarchiver unarchiveObjectWithData:cachedObject];
	        return object;   
	    }
	    else
	    {
	        JSCacheDebugLog(@"Cache miss for key %@", key);
	        return nil;
	    }
	#endif
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key
{
    #if JSCACHE_ENABLED
    	[self cacheImageData:UIImagePNGRepresentation(image) forKey:key];
	#endif
}

- (UIImage *)cachedImageForKey:(NSString *)key
{
    #if !JSCACHE_ENABLED
        return nil;
    #else 
   	 	UIImage *cachedImage = [[EGOCache currentCache] imageForKey:key];
    
	    if (cachedImage)
	    {
	        JSCacheDebugLog(@"Returning cached image for key %@", key);
	        return cachedImage;
	    }
	    else
	    {
	        JSCacheDebugLog(@"Cache miss for key %@", key);
	        return nil;
	    }
	#endif
}
#endif

- (void)cacheImageData:(NSData *)data forKey:(NSString *)key
{
    #if JSCACHE_ENABLED    
	    JSCacheDebugLog(@"Caching image for key %@", key);
	    [[EGOCache currentCache] setData:data forKey:key withTimeoutInterval:kJSCacheImageCacheDurationInSeconds];
    #endif
}

- (NSData *)cachedImageDataForKey:(NSString *)key
{
    #if !JSCACHE_ENABLED
        return nil;
    #else
    	NSData *cachedImageData = [[EGOCache currentCache] dataForKey:key];
    
	    if (cachedImageData)
	    {
	        JSCacheDebugLog(@"Returning cached image data for key %@", key);
	        return cachedImageData;
	    }
	    else
	    {
	        JSCacheDebugLog(@"Cache miss for key %@", key);
	        return nil;
	    }
	#endif
}

- (void)invalidateCachedObjectForKey:(NSString *)key
{
    JSCacheDebugLog(@"Invalidating cached object for key %@", key);
    [[EGOCache currentCache] removeCacheForKey:key];
}

- (void)invalidateAllCachedObjects
{
    NSLog(@"[JSCache] Invalidating all cached objects");
    [[EGOCache currentCache] clearCache];
}

- (void)dealloc
{
    dispatch_release(_jsCacheQueue);
    
    [super dealloc];
}

@end