# Description
- JSCache is a simple and fast thread-safe key-value cache class to easily archive objects and cache images to disk.
- It is built on top of [EGOCache](https://github.com/enormego/EGOCache)
- It can be easily turned off for debugging just by setting 

```objective-c
#define JSCACHE_ENABLED 0
```

- The default cache durations are these (but can be easily changed)

```objective-c
#define kJSCacheImageCacheDurationInSeconds 1296000 // 15 days
#define kJSCacheDataCacheDurationInSeconds 604800 // 7 days
```

# Usage

- You can get a shared instance by calling:

```objective-c
+ (JSCache *)sharedCache;
```

## Data caching

- To cache objects you simply call -cacheObject:forKey: passing an object which can be serialized (conforms to the NSCoding protocol)

```objective-c
- (void)cacheObject:(id<NSObject, NSCoding>)object forKey:(NSString *)key;
```

- This method will archive the object in a background queue for avoiding unnecessarily blocking the UI and then pass the NSData to EGOCache to save it to disk.
- You can later on access that object by calling -cachedObjectForKey: and passing the same key.

## Image caching

- To cache an image object you call -cacheImage:forKey: with an UIImage object or -cacheImageData:forKey: with an NSData representing the image. Usually you will want the URL from where you got the image to be the key.

```objective-c
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;
- (void)cacheImageData:(NSData *)data forKey:(NSString *)key;
```

- And then to retrieve a cached image you just call -cachedImageForKey: or -cachedImageDataForKey:.

## Invalidation of cached objects

- You can call -invalidateAllCachedObjects to purge the whole cache, or you can call -invalidateCachedObjectForKey: to invalidate a certain cached object.

```objective-c
- (void)invalidateCachedObjectForKey:(NSString *)key;
- (void)invalidateAllCachedObjects;
```

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/JaviSoto/jscache/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

