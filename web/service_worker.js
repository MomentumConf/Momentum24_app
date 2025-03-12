importScripts("https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.sw.js");
importScripts('https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js');

if (!workbox) {
    console.log("Workbox didn't load");
} else {
    console.log('Workbox loaded - time for magic!');

    // Checking for version parameter
    const scriptURL = self.location.href;
    const urlParams = new URL(scriptURL).searchParams;
    const versionParam = urlParams.get('v');
    console.log('Service Worker Version parameter:', versionParam);

    // Function to use version value in cache names
    const getCacheVersion = () => {
        return versionParam || (new Date()).getTime().toString();
    };

    // Adding version to cache names
    const CACHE_VERSION = getCacheVersion();
    const CACHE_NAMES = {
        static: `static-assets-${CACHE_VERSION}`,
        dynamic: `dynamic-content-${CACHE_VERSION}`,
        pages: `pages-${CACHE_VERSION}`,
        flutter: `flutter-runtime-${CACHE_VERSION}`,
        maps: `maps-${CACHE_VERSION}`,
        api: `api-${CACHE_VERSION}`,
        images: `images-${CACHE_VERSION}`,
    };

    // Using version in service worker activation
    self.addEventListener('activate', event => {
        event.waitUntil(
            Promise.all(
                caches.keys().map(async (cacheName) => {
                    if (!Object.values(CACHE_NAMES).includes(cacheName)) {
                        return caches.delete(cacheName);
                    }
                })
            )
        );
        self.clients.claim();
    });

    // Check if hostname starts with localhost
    const isLocalhost = self.location.hostname.startsWith('localhost');

    if (isLocalhost) {
        console.log('Catching for localhost is disabled');
        // Disable caching for localhost
        workbox.core.setCacheNameDetails({ prefix: 'no-cache' });

        // Skip waiting and claim clients immediately to ensure no caching
        self.skipWaiting();
        self.clients.claim();
    } else {
        // Explicitly add homepage to precache
        workbox.precaching.precache([
            { url: '/', revision: CACHE_NAMES.static },
            { url: '/index.html', revision: CACHE_NAMES.static }
        ]);

        // Function to load manifest.json with a network-first strategy and fallback to cache
        const loadManifest = () => {
            return fetch('manifest.json')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response not ok');
                    }
                    if (!caches.match('manifest.json')) {
                        caches.open('manifest-cache').then(cache => {
                            console.log('Storing manifest.json in cache');
                            cache.put('manifest.json', response);
                        });
                    }
                    return response.json();
                })
                .catch(() => {
                    // Network failed, try to retrieve manifest.json from cache
                    return caches.match('manifest.json')
                        .then(cachedResponse => {
                            if (cachedResponse) {
                                return cachedResponse.json();
                            }
                            throw new Error('No cached manifest.json');
                        });
                })
                .catch(err => {
                    console.error('Error fetching manifest.json:', err);
                    return { version: '1' };
                });
        };

        // Download manifest.json, to get the version for revision
        const precachePromise = loadManifest().then(manifestData => {
            const version = manifestData.version;
            const precacheFiles = [
                { url: '/', revision: version },
                { url: 'index.html', revision: version },
                { url: 'flutter_bootstrap.js', revision: version },
                { url: 'version.json', revision: version },
                { url: 'flutter.js', revision: version },
                { url: 'favicon.png', revision: version },
                { url: 'icons/Icon-256.png', revision: version },
                { url: 'icons/Icon-120.png', revision: version },
                { url: 'icons/Icon-144.png', revision: version },
                { url: 'icons/Icon-192.png', revision: version },
                { url: 'icons/Icon-384.png', revision: version },
                { url: 'icons/Icon-76.png', revision: version },
                { url: 'icons/Icon-60.png', revision: version },
                { url: 'icons/Icon-152.png', revision: version },
                { url: 'icons/Icon-180.png', revision: version },
                { url: 'icons/Icon-72.png', revision: version },
                { url: 'icons/Icon-57.png', revision: version },
                { url: 'icons/Icon-96.png', revision: version },
                { url: 'icons/Icon-128.png', revision: version },
                { url: 'icons/Icon-114.png', revision: version },
                { url: 'icons/Icon-512.png', revision: version },
                { url: 'manifest.json', revision: version },
                { url: 'main.dart.wasm', revision: version },
                { url: 'main.dart.mjs', revision: version },
                { url: 'assets/AssetManifest.json', revision: version },
                { url: 'assets/NOTICES', revision: version },
                { url: 'assets/FontManifest.json', revision: version },
                { url: 'assets/AssetManifest.bin.json', revision: version },
                { url: 'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf', revision: version },
                { url: 'assets/shaders/ink_sparkle.frag', revision: version },
                { url: 'assets/AssetManifest.bin', revision: version },
                { url: 'assets/fonts/MaterialIcons-Regular.otf', revision: version },
                { url: 'assets/assets/images/regulamin.jpg', revision: version },
                { url: 'assets/assets/images/icon.png', revision: version },
                { url: 'assets/assets/images/mowcy.jpg', revision: version },
                { url: 'assets/assets/images/logo.svg', revision: version },
                { url: 'assets/assets/images/teksty.jpg', revision: version },
                { url: 'assets/google_fonts/Lato-Italic.ttf', revision: version },
                { url: 'assets/google_fonts/Lato-Bold.ttf', revision: version },
                { url: 'assets/google_fonts/Lato-Black.ttf', revision: version },
                { url: 'assets/google_fonts/Lato-Regular.ttf', revision: version },
                { url: 'assets/google_fonts/Lato-BoldItalic.ttf', revision: version },
                { url: 'canvaskit/skwasm_st.js', revision: version },
                { url: 'canvaskit/skwasm.js', revision: version },
                { url: 'canvaskit/skwasm.js.symbols', revision: version },
                { url: 'canvaskit/canvaskit.js.symbols', revision: version },
                { url: 'canvaskit/skwasm.wasm', revision: version },
                { url: 'canvaskit/chromium/canvaskit.js.symbols', revision: version },
                { url: 'canvaskit/chromium/canvaskit.js', revision: version },
                { url: 'canvaskit/chromium/canvaskit.wasm', revision: version },
                { url: 'canvaskit/skwasm_st.js.symbols', revision: version },
                { url: 'canvaskit/canvaskit.js', revision: version },
                { url: 'canvaskit/canvaskit.wasm', revision: version },
                { url: 'canvaskit/skwasm_st.wasm', revision: version },
            ];
            workbox.precaching.precacheAndRoute(precacheFiles);
        });

        // Wait for manifest download before completing installation
        self.addEventListener('install', event => {
            event.waitUntil(precachePromise);
            self.skipWaiting();
        });


        // Strategy for assets: Offline First with 30-day cache
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

        // Strategy for Carto basemaps (maps) – dark_all and light_all
        workbox.routing.registerRoute(
            ({ url }) => url.hostname.match(/^cartodb-basemaps-.*\.global\.ssl\.fastly\.net$/),
            new workbox.strategies.CacheFirst({
                cacheName: CACHE_NAMES.maps
            })
        );

        // Strategy for Sanity API – online-first, fallback to cache for 1 day
        workbox.routing.registerRoute(
            ({ url }) => url.origin.match(/\.apicdn\.sanity\.io$/) &&
                !(url.searchParams.get('query') && url.searchParams.get('query').includes('notification')),
            new workbox.strategies.NetworkFirst({
                cacheName: CACHE_NAMES.api,
                networkTimeoutSeconds: 5,
                plugins: [
                    new workbox.expiration.ExpirationPlugin({
                        maxAgeSeconds: 24 * 60 * 60, // 1 day
                    })
                ]
            })
        );

        // Strategy for Sanity Images – cache-first, revision aware
        workbox.routing.registerRoute(
            ({ url }) => url.origin === 'https://cdn.sanity.io',
            new workbox.strategies.CacheFirst({
                cacheName: CACHE_NAMES.images,
                plugins: [
                    new workbox.expiration.ExpirationPlugin({
                        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                    })
                ]
            })
        );

        // Handle Flutter runtime files
        workbox.routing.registerRoute(
            ({ url }) => url.pathname.endsWith('.mjs') ||
                url.pathname.endsWith('.wasm'),
            new workbox.strategies.CacheFirst({
                cacheName: CACHE_NAMES.flutter,
                plugins: [
                    new workbox.expiration.ExpirationPlugin({
                        maxAgeSeconds: 7 * 24 * 60 * 60, // 7 days
                    }),
                ],
            })
        );


        // Offline fallback for all navigation requests
        workbox.routing.setCatchHandler(({ event }) => {
            if (event.request.destination === 'document' || event.request.mode === 'navigate') {
                return caches.match('/index.html')
                    .then(response => {
                        if (response) return response;
                        return caches.match('/');
                    })
                    .catch(() => caches.match('/'));
            }
            return Response.error();
        });
    }
}