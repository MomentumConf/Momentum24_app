importScripts("https://cdn.onesignal.com/sdks/web/v16/OneSignalSDK.sw.js");
importScripts("https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js");

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
    const versionParam = urlParams.get("v");

    // Function to use version value in cache names
    const getCacheVersion = () => {
        return versionParam || new Date().getTime().toString();
    };

    // Get cache version
    const CACHE_VERSION = getCacheVersion();

    // Cache names with version
    const CACHE_NAMES = {
        static: `static-assets-${CACHE_VERSION}`,
        dynamic: `dynamic-content-${CACHE_VERSION}`,
        flutter: `flutter-runtime-${CACHE_VERSION}`,
    };

    logger(`Cache version: ${CACHE_VERSION}`);
    logger(`Using URL parameter version: ${versionParam ? "Yes" : "No"}`);

    // Clean up old caches during activation
    self.addEventListener("activate", (event) => {
        logger("Service worker activating");

        // Get all cache keys
        event.waitUntil(
            caches.keys().then((cacheNames) => {
                logger(`Found caches: ${cacheNames.join(", ")}`);

                // Filter caches to delete old versions
                return Promise.all(
                    cacheNames
                        .map((cacheName) => {
                            const isOldCache = Object.values(CACHE_NAMES).every(
                                (currentCache) => !cacheName.includes(currentCache)
                            );

                            if (isOldCache) {
                                logger(`Deleting old cache: ${cacheName}`);
                                return caches.delete(cacheName);
                            }
                            return null;
                        })
                        .filter(Boolean)
                );
            })
        );

        // Claim clients to ensure updates are applied immediately
        self.clients.claim();
    });

    // Precache essential files during installation
    const precacheFiles = [
        "/",
        "/index.html",
        "/flutter.js",
        "/flutter_bootstrap.js",
        "/main.dart.js",
        "/main.dart.wasm",
        "/main.dart.mjs",
        "/manifest.json",
        "/favicon.png",
        // Flutter runtime files
        "/canvaskit/canvaskit.js",
        "/canvaskit/canvaskit.wasm",
        "/canvaskit/skwasm.js",
        "/canvaskit/skwasm.wasm",
        "/canvaskit/skwasm_st.js",
        "/canvaskit/skwasm_st.wasm",
        // Important assets
        "/assets/AssetManifest.json",
        "/assets/FontManifest.json",
        "/assets/fonts/MaterialIcons-Regular.otf",
        // Google fonts
        "/assets/google_fonts/Lato-Regular.ttf",
        "/assets/google_fonts/Lato-Bold.ttf",
        "/assets/google_fonts/Lato-Italic.ttf",
        "/assets/google_fonts/Lato-BoldItalic.ttf",
        "/assets/google_fonts/Lato-Black.ttf",
        // App assets
        "/assets/assets/images/logo.svg",
        "/assets/assets/images/mowcy.jpg",
        "/assets/assets/images/regulamin.jpg",
        "/assets/assets/images/teksty.jpg",
    ];

    // Install event handler to cache essential files
    self.addEventListener("install", (event) => {
        logger("Service worker installing");

        // Użycie Promise.allSettled zamiast addAll, żeby jeden błąd nie przerywał całego procesu
        event.waitUntil(
            Promise.all([
                caches.open(CACHE_NAMES.static).then((cache) => {
                    logger("Precaching static files");

                    const staticFiles = precacheFiles.filter(
                        (url) =>
                            !url.includes("canvaskit") &&
                            !url.endsWith(".js") &&
                            !url.endsWith(".wasm") &&
                            !url.endsWith(".mjs")
                    );

                    const cachePromises = staticFiles.map((url) => {
                        return fetch(
                            new Request(url, {
                                cache: "reload",
                                mode: url.includes("/fonts/") || url.includes("/google_fonts/") ? "no-cors" : undefined,
                            })
                        )
                            .then((response) => {
                                if (response && (response.status === 200 || response.type === "opaque")) {
                                    logger(`Successfully cached: ${url}`);
                                    return cache.put(url, response);
                                } else {
                                    logger(
                                        `Failed to cache: ${url} - status: ${
                                            response ? response.status : "unknown"
                                        }, type: ${response.type}`
                                    );
                                    return Promise.resolve();
                                }
                            })
                            .catch((error) => {
                                logger(`Error fetching ${url}: ${error}`);
                                return Promise.resolve();
                            });
                    });

                    return Promise.allSettled(cachePromises);
                }),
                caches.open(CACHE_NAMES.flutter).then((cache) => {
                    logger("Precaching Flutter runtime files");

                    const flutterFiles = precacheFiles.filter(
                        (url) =>
                            url.includes("canvaskit") ||
                            url.endsWith(".js") ||
                            url.endsWith(".wasm") ||
                            url.endsWith(".mjs")
                    );

                    const cachePromises = flutterFiles.map((url) => {
                        return fetch(new Request(url, { cache: "reload" }))
                            .then((response) => {
                                if (response && response.status === 200) {
                                    logger(`Successfully cached Flutter file: ${url}`);
                                    return cache.put(url, response);
                                } else {
                                    logger(
                                        `Failed to cache Flutter file: ${url} - status: ${
                                            response ? response.status : "unknown"
                                        }`
                                    );
                                    return Promise.resolve();
                                }
                            })
                            .catch((error) => {
                                logger(`Error fetching Flutter file ${url}: ${error}`);
                                return Promise.resolve();
                            });
                    });

                    return Promise.allSettled(cachePromises);
                }),
            ])
                .then((results) => {
                    const [staticResults, flutterResults] = results;
                    const staticSuccess = staticResults.filter((r) => r.status === "fulfilled").length;
                    const flutterSuccess = flutterResults.filter((r) => r.status === "fulfilled").length;
                    const staticTotal = staticResults.length;
                    const flutterTotal = flutterResults.length;

                    logger(
                        `Precaching completed - Static: ${staticSuccess}/${staticTotal}, Flutter: ${flutterSuccess}/${flutterTotal}`
                    );
                })
                .catch((error) => {
                    logger(`Cache error during installation: ${error}`);
                    return Promise.resolve();
                })
        );

        // Zainstaluj natychmiast
        self.skipWaiting();
    });

    // Handle manifest.json with query parameters
    workbox.routing.registerRoute(
        ({ url }) => url.pathname.endsWith("manifest.json"),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.static,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                }),
            ],
        })
    );

    // Strategy for Flutter runtime files (cache first with improved handling)
    workbox.routing.registerRoute(
        ({ url }) =>
            url.pathname.endsWith(".mjs") ||
            url.pathname.endsWith(".wasm") ||
            url.pathname.endsWith(".js") ||
            url.pathname.includes("canvaskit") ||
            url.pathname.includes("flutter"),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.flutter,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60, // 30 dni
                }),
                {
                    // Plugin do obsługi pominięcia parametrów URL
                    cacheKeyWillBeUsed: async ({ request }) => {
                        const url = new URL(request.url);
                        // Użyj tylko ścieżki bez parametrów jako klucza cache
                        return url.origin + url.pathname;
                    },
                    // Plugin do zapisywania odpowiedzi w cache nawet po błędzie
                    fetchDidFail: async ({ originalRequest, request, error }) => {
                        logger(`Fetch failed for ${request.url}: ${error}`);
                        // Próba pobrania z serwera ponownie z opcjami no-cache
                        try {
                            const retryRequest = new Request(request.url, {
                                method: request.method,
                                headers: request.headers,
                                mode: "no-cors",
                                cache: "reload",
                            });
                            const response = await fetch(retryRequest);
                            if (response && response.status === 200) {
                                const cache = await caches.open(CACHE_NAMES.flutter);
                                await cache.put(request, response);
                                logger(`Retry successful for ${request.url}`);
                            }
                        } catch (retryError) {
                            logger(`Retry also failed for ${request.url}: ${retryError}`);
                        }
                    },
                },
            ],
        })
    );

    // Strategy for assets (cache first with improved font handling)
    workbox.routing.registerRoute(
        ({ url }) => url.pathname.startsWith("/assets/"),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.static,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
                }),
                {
                    // Szczególna obsługa dla czcionek i ważnych zasobów
                    requestWillFetch: async ({ request }) => {
                        const url = new URL(request.url);
                        // Dla czcionek i ważnych zasobów JSON, używaj trybu no-cors by uniknąć problemów CORS
                        if (
                            url.pathname.includes("/google_fonts/") ||
                            url.pathname.includes("/fonts/") ||
                            url.pathname.endsWith("AssetManifest.json") ||
                            url.pathname.endsWith("FontManifest.json")
                        ) {
                            logger(`Special handling for font/asset: ${url.pathname}`);
                            return new Request(request.url, {
                                mode: "no-cors",
                                cache: "reload",
                            });
                        }
                        return request;
                    },
                    // Cachuj ścieżkę bez parametrów
                    cacheKeyWillBeUsed: async ({ request }) => {
                        const url = new URL(request.url);
                        return url.origin + url.pathname;
                    },
                },
            ],
        })
    );

    // Strategy for navigation requests (app shell)
    workbox.routing.registerRoute(
        ({ request }) => request.mode === "navigate",
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
            url.pathname.endsWith(".mjs") ||
            url.pathname.endsWith(".wasm") ||
            url.pathname.endsWith(".js") ||
            url.pathname.includes("canvaskit")
        ) {
            logger(`Trying to serve Flutter runtime file from cache: ${url.pathname}`);

            // First try the exact URL
            return caches.match(request).then((response) => {
                if (response) {
                    logger(`Found exact match for: ${url.pathname}`);
                    return response;
                }

                // Try without query parameters
                const urlWithoutQuery = url.origin + url.pathname;
                logger(`Trying without query parameters: ${urlWithoutQuery}`);
                return caches.match(urlWithoutQuery).then((response) => {
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
        if (request.destination === "document" || request.mode === "navigate") {
            logger("Serving fallback for navigation request");
            return caches
                .match("/index.html")
                .then((response) => {
                    if (response) return response;
                    return caches.match("/");
                })
                .catch(() => caches.match("/"));
        }

        // For image requests, return a placeholder if available
        if (request.destination === "image") {
            return caches.match("/assets/offline_image.png").catch(() => Response.error());
        }

        logger(`No fallback available for: ${request.url}`);
        return Response.error();
    });

    // Rozszerzona obsługa fetch dla wszystkich istotnych plików
    self.addEventListener("fetch", (event) => {
        if (DEBUG) {
            logger(`Fetching: ${event.request.url}`);
        }

        const url = new URL(event.request.url);

        // Ignoruj zewnętrzne żądania
        if (
            url.origin !== self.location.origin &&
            !url.pathname.includes("canvaskit") &&
            !url.pathname.includes("cdn.onesignal.com")
        ) {
            return;
        }

        // Lista strategicznych plików Flutter, które wymagają specjalnej obsługi
        const isStrategicFile =
            url.pathname.endsWith(".mjs") ||
            url.pathname.endsWith(".wasm") ||
            url.pathname.endsWith("flutter.js") ||
            url.pathname.endsWith("flutter_bootstrap.js") ||
            url.pathname.endsWith("main.dart.js") ||
            url.pathname.includes("canvaskit") ||
            url.pathname.includes("skwasm") ||
            url.pathname === "/" ||
            url.pathname === "/index.html";

        if (isStrategicFile) {
            logger(`Strategic file handling: ${url.pathname}`);

            event.respondWith(
                caches.match(event.request).then((cachedResponse) => {
                    if (cachedResponse) {
                        logger(`Serving from cache: ${url.pathname}`);
                        return cachedResponse;
                    }

                    // Spróbuj bez parametrów zapytania
                    const urlWithoutQuery = url.origin + url.pathname;
                    return caches.match(urlWithoutQuery).then((cachedResponseNoQuery) => {
                        if (cachedResponseNoQuery) {
                            logger(`Serving from cache (no query): ${urlWithoutQuery}`);
                            return cachedResponseNoQuery;
                        }

                        logger(`Fetching from network: ${url.pathname}`);
                        return fetch(event.request)
                            .then((networkResponse) => {
                                if (networkResponse && networkResponse.status === 200) {
                                    // Cache the response for future
                                    const clonedResponse = networkResponse.clone();
                                    const cacheName =
                                        url.pathname.includes("canvaskit") ||
                                        url.pathname.endsWith(".wasm") ||
                                        url.pathname.endsWith(".mjs") ||
                                        url.pathname.endsWith(".js")
                                            ? CACHE_NAMES.flutter
                                            : CACHE_NAMES.static;

                                    caches
                                        .open(cacheName)
                                        .then((cache) => {
                                            // Zapisz zarówno pod oryginalnym URL jak i bez parametrów zapytania
                                            cache.put(event.request, networkResponse.clone());
                                            if (event.request.url !== urlWithoutQuery) {
                                                cache.put(urlWithoutQuery, clonedResponse);
                                            }
                                        })
                                        .catch((err) => logger(`Cache put error: ${err}`));
                                }
                                return networkResponse;
                            })
                            .catch((error) => {
                                logger(`Fetch error for ${url.pathname}: ${error}`);
                                // Ostatnia próba odzyskania z cache dla jakiegokolwiek podobnego URL
                                return caches.match(url.pathname).then((response) => response || Response.error());
                            });
                    });
                })
            );
        } else if (url.pathname.includes("/assets/")) {
            // Obsługa zasobów (assets)
            event.respondWith(
                caches.match(event.request).then((response) => {
                    if (response) {
                        return response;
                    }

                    return fetch(event.request).then((networkResponse) => {
                        if (networkResponse && networkResponse.status === 200) {
                            const clonedResponse = networkResponse.clone();
                            caches.open(CACHE_NAMES.static).then((cache) => {
                                cache.put(event.request, clonedResponse);
                            });
                        }
                        return networkResponse;
                    });
                })
            );
        }
    });
}
