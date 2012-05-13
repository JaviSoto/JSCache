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

@interface JSCache : NSObject

+ (JSCache *)sharedCache;

- (void)cacheObject:(id<NSObject, NSCoding>)object forKey:(NSString *)key;
- (id)cachedObjectForKey:(NSString *)key;

#if __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)cacheImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)cachedImageForKey:(NSString *)key;
#endif

- (void)cacheImageData:(NSData *)data forKey:(NSString *)key;
- (NSData *)cachedImageDataForKey:(NSString *)key;

- (void)invalidateCachedObjectForKey:(NSString *)key;
- (void)invalidateAllCachedObjects;

@end