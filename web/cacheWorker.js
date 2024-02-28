// This is a service worker responsible for caching the assets of the web app as it goes for PWA support and offline capabilities.

const IMAGE_CACHE_NAME = 'image-cache';
const SCRIPT_CACHE_NAME = 'script-cache';
const CACHE_VERSION = '1.0.1';

self.addEventListener('install', function (event) {
    event.waitUntil(
        caches.open(IMAGE_CACHE_NAME)
            .then(function (cache) {
                console.log('Opened cache');
            })
    );
});

self.addEventListener('fetch', function (event) {
    // Don't cache on localhost
    if (event.request.url.match('localhost')) {
        return;
    }

    if (event.request.url.match(/\.(jpg|jpeg|png|gif|svg)$/)) {
        event.respondWith(
            caches.match(event.request)
                .then(function (response) {
                    // Cache hit - return response
                    if (response) {
                        return response;
                    }
                    // Not in cache, return from network and cache it
                    return fetch(event.request).then(function (response) {
                        return caches.open(`${IMAGE_CACHE_NAME}_${CACHE_VERSION}`).then(function (cache) {
                            cache.put(event.request.url, response.clone());
                            return response;
                        });
                    });
                })
        );
    }

    if (event.request.url.match(/\.(js|css)$/)) {
        event.respondWith(
            caches.match(event.request)
                .then(function (response) {
                    // Cache hit - return response
                    if (response) {
                        return response;
                    }
                    // Not in cache, return from network and cache it
                    return fetch(event.request).then(function (response) {
                        return caches.open(`${SCRIPT_CACHE_NAME}_${CACHE_VERSION}`).then(function (cache) {
                            cache.put(event.request.url, response.clone());
                            return response;
                        });
                    });
                })
        );
    }
});

self.addEventListener('activate', function (event) {
    var cacheWhitelist = [`${IMAGE_CACHE_NAME}_${CACHE_VERSION}`, `${SCRIPT_CACHE_NAME}_${CACHE_VERSION}`];
    event.waitUntil(
        caches.keys().then(function (cacheNames) {
            return Promise.all(
                cacheNames.map(function (cacheName) {
                    if (cacheWhitelist.indexOf(cacheName) === -1) {
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});