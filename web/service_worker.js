importScripts("https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.sw.js");
importScripts('https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js');

// Debug flag to enable console logging
const DEBUG = true;

// Custom logger function
function logger(message) {
    if (DEBUG) {
        console.log(`[Service Worker] ${message}`);
    }
}

// Check if Workbox loaded correctly
if (!workbox) {
    logger("Workbox failed to load!");
} else {
    logger("Workbox loaded successfully");

    // Skip waiting to ensure the new service worker activates immediately
    self.skipWaiting();

    // Restore previous versioning mechanism
    const scriptURL = self.location.href;
    const urlParams = new URL(scriptURL).searchParams;
    const versionParam = urlParams.get('v');

    // Function to use version value in cache names
    const getCacheVersion = () => {
        return versionParam || (new Date()).getTime().toString();
    };

    // Get cache version
    const CACHE_VERSION = getCacheVersion();

    // Cache names with version
    const CACHE_NAMES = {
        static: `static-assets-${CACHE_VERSION}`,
        dynamic: `dynamic-content-${CACHE_VERSION}`,
        flutter: `flutter-runtime-${CACHE_VERSION}`
    };

    logger(`Cache version: ${CACHE_VERSION}`);
    logger(`Using URL parameter version: ${versionParam ? 'Yes' : 'No'}`);

    // Clean up old caches during activation
    self.addEventListener('activate', event => {
        logger('Service worker activating');

        // Get all cache keys
        event.waitUntil(
            caches.keys().then(cacheNames => {
                logger(`Found caches: ${cacheNames.join(', ')}`);

                // Filter caches to delete old versions
                return Promise.all(
                    cacheNames.map(cacheName => {
                        const isOldCache = Object.values(CACHE_NAMES).every(
                            currentCache => !cacheName.includes(currentCache)
                        );

                        if (isOldCache) {
                            logger(`Deleting old cache: ${cacheName}`);
                            return caches.delete(cacheName);
                        }
                        return null;
                    }).filter(Boolean)
                );
            })
        );

        // Claim clients to ensure updates are applied immediately
        self.clients.claim();
    });

    // Precache essential files during installation
    const precacheFiles = [
        '/',
        '/index.html',
        'flutter.js',
        'flutter_bootstrap.js',
        'main.dart.js',
        'main.dart.wasm',
        'main.dart.mjs',
        'manifest.json',
        'favicon.png',
        // Flutter runtime files
        'canvaskit/canvaskit.js',
        'canvaskit/canvaskit.wasm',
        'canvaskit/skwasm.js',
        'canvaskit/skwasm.wasm',
        'canvaskit/skwasm_st.js',
        'canvaskit/skwasm_st.wasm',
        // Important assets
        'assets/AssetManifest.json',
        'assets/FontManifest.json',
        'assets/fonts/MaterialIcons-Regular.otf'
    ];

    // Install event handler to cache essential files
    self.addEventListener('install', event => {
        logger('Service worker installing');

        event.waitUntil(
            caches.open(CACHE_NAMES.static).then(cache => {
                logger('Precaching essential files');
                return cache.addAll(precacheFiles).then(() => {
                    logger('Precaching completed successfully');
                }).catch(error => {
                    logger(`Precaching error: ${error}`);
                    // Continue installing even if some files fail to cache
                    return Promise.resolve();
                });
            })
        );
    });

    // Handle manifest.json with query parameters
    workbox.routing.registerRoute(
        ({ url }) => url.pathname.endsWith('manifest.json'),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.static,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                }),
            ],
        })
    );

    // Strategy for Flutter runtime files (cache first)
    workbox.routing.registerRoute(
        ({ url }) =>
            url.pathname.endsWith('.mjs') ||
            url.pathname.endsWith('.wasm') ||
            url.pathname.endsWith('.js') ||
            url.pathname.includes('canvaskit') ||
            url.pathname.includes('flutter'),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.flutter,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                }),
            ],
        })
    );

    // Strategy for assets (cache first)
    workbox.routing.registerRoute(
        ({ url }) => url.pathname.startsWith('/assets/'),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.static,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                })
            ]
        })
    );

    // Strategy for navigation requests (app shell)
    workbox.routing.registerRoute(
        ({ request }) => request.mode === 'navigate',
        new workbox.strategies.NetworkFirst({
            cacheName: CACHE_NAMES.dynamic,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxEntries: 50,
                    maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
                }),
            ],
        })
    );

    // Default strategy for other requests (stale-while-revalidate)
    workbox.routing.setDefaultHandler(
        new workbox.strategies.StaleWhileRevalidate({
            cacheName: CACHE_NAMES.dynamic,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxEntries: 100,
                    maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
                }),
            ],
        })
    );

    // Offline fallback for navigation requests
    workbox.routing.setCatchHandler(({ event }) => {
        const request = event.request;
        const url = new URL(request.url);

        logger(`Fallback triggered for: ${request.url}`);

        // Check for Flutter runtime files first
        if (
            url.pathname.endsWith('.mjs') ||
            url.pathname.endsWith('.wasm') ||
            url.pathname.endsWith('.js') ||
            url.pathname.includes('canvaskit')
        ) {
            logger(`Trying to serve Flutter runtime file from cache: ${url.pathname}`);

            // First try the exact URL
            return caches.match(request).then(response => {
                if (response) {
                    logger(`Found exact match for: ${url.pathname}`);
                    return response;
                }

                // Try without query parameters
                const urlWithoutQuery = url.origin + url.pathname;
                logger(`Trying without query parameters: ${urlWithoutQuery}`);
                return caches.match(urlWithoutQuery).then(response => {
                    if (response) {
                        logger(`Found match without query params for: ${url.pathname}`);
                        return response;
                    }

                    logger(`No cache found for Flutter file: ${url.pathname}`);
                    return Response.error();
                });
            });
        }

        // Handle navigation requests
        if (request.destination === 'document' || request.mode === 'navigate') {
            logger('Serving fallback for navigation request');
            return caches.match('/index.html')
                .then(response => {
                    if (response) return response;
                    return caches.match('/');
                })
                .catch(() => caches.match('/'));
        }

        // For image requests, return a placeholder if available
        if (request.destination === 'image') {
            return caches.match('/assets/offline_image.png')
                .catch(() => Response.error());
        }

        logger(`No fallback available for: ${request.url}`);
        return Response.error();
    });

    // Force cache for important requests
    self.addEventListener('fetch', event => {
        if (DEBUG) {
            logger(`Fetching: ${event.request.url}`);
        }

        const url = new URL(event.request.url);

        // Special handling for SKWASM files which seem to be problematic
        if (url.pathname.includes('skwasm_st') ||
            url.pathname.endsWith('main.dart.mjs')) {

            logger(`Special handling for critical file: ${url.pathname}`);

            event.respondWith(
                caches.match(event.request).then(cachedResponse => {
                    if (cachedResponse) {
                        logger(`Serving from cache: ${url.pathname}`);
                        return cachedResponse;
                    }

                    // Try without query parameters
                    const urlWithoutQuery = url.origin + url.pathname;
                    return caches.match(urlWithoutQuery).then(cachedResponseNoQuery => {
                        if (cachedResponseNoQuery) {
                            logger(`Serving from cache (no query): ${urlWithoutQuery}`);
                            return cachedResponseNoQuery;
                        }

                        logger(`Fetching from network: ${url.pathname}`);
                        return fetch(event.request).then(networkResponse => {
                            if (networkResponse && networkResponse.status === 200) {
                                // Cache the response for future
                                const clonedResponse = networkResponse.clone();
                                caches.open(CACHE_NAMES.flutter).then(cache => {
                                    cache.put(event.request, clonedResponse);
                                });
                            }
                            return networkResponse;
                        }).catch(error => {
                            logger(`Fetch error for ${url.pathname}: ${error}`);
                            return Response.error();
                        });
                    });
                })
            );
        }
    });
}