const loadScript = (url) => {
    try {
        importScripts(url);
        return true;
    } catch (error) {
        return false;
    }
};

let workboxLoaded = loadScript("https://storage.googleapis.com/workbox-cdn/releases/6.4.1/workbox-sw.js");

if (workbox) {
    const scriptURL = self.location.href;
    const urlParams = new URL(scriptURL).searchParams;
    const versionParam = urlParams.get("v");

    const getCacheVersion = () => {
        return versionParam || new Date().getTime().toString();
    };

    const CACHE_VERSION = getCacheVersion();

    const CACHE_NAMES = {
        static: `static-assets-${CACHE_VERSION}`,
        dynamic: `dynamic-content-${CACHE_VERSION}`,
        flutter: `flutter-runtime-${CACHE_VERSION}`,
        images: `sanity-images-${CACHE_VERSION}`,
    };

    self.addEventListener("activate", (event) => {
        event.waitUntil(
            caches.keys().then((cacheNames) => {
                return Promise.all(
                    cacheNames
                        .map((cacheName) => {
                            const isOldCache = Object.values(CACHE_NAMES).every(
                                (currentCache) => !cacheName.includes(currentCache)
                            );

                            if (isOldCache) {
                                return caches.delete(cacheName);
                            }
                            return null;
                        })
                        .filter(Boolean)
                );
            })
        );

        self.clients.claim();
    });

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
        "/canvaskit/canvaskit.js",
        "/canvaskit/canvaskit.wasm",
        "/canvaskit/skwasm.js",
        "/canvaskit/skwasm.wasm",
        "/canvaskit/skwasm_st.js",
        "/canvaskit/skwasm_st.wasm",
        "/assets/AssetManifest.json",
        "/assets/FontManifest.json",
        "/assets/fonts/MaterialIcons-Regular.otf",
        "/assets/google_fonts/Lato-Regular.ttf",
        "/assets/google_fonts/Lato-Bold.ttf",
        "/assets/google_fonts/Lato-Italic.ttf",
        "/assets/google_fonts/Lato-BoldItalic.ttf",
        "/assets/google_fonts/Lato-Black.ttf",
        "/assets/assets/images/logo.svg",
        "/assets/assets/images/mowcy.jpg",
        "/assets/assets/images/regulamin.jpg",
        "/assets/assets/images/teksty.jpg",
    ];

    self.addEventListener("install", (event) => {
        event.waitUntil(
            Promise.all([
                caches.open(CACHE_NAMES.static).then((cache) => {
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
                                    return cache.put(url, response);
                                } else {
                                    return Promise.resolve();
                                }
                            })
                            .catch((error) => {
                                return Promise.resolve();
                            });
                    });

                    return Promise.allSettled(cachePromises);
                }),
                caches.open(CACHE_NAMES.flutter).then((cache) => {
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
                                    return cache.put(url, response);
                                } else {
                                    return Promise.resolve();
                                }
                            })
                            .catch((error) => {
                                return Promise.resolve();
                            });
                    });

                    return Promise.allSettled(cachePromises);
                }),
            ])
        );

        self.skipWaiting();
    });

    workbox.routing.registerRoute(
        ({ url }) => url.pathname.endsWith("manifest.json"),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.static,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60,
                }),
            ],
        })
    );

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
                    maxAgeSeconds: 30 * 24 * 60 * 60,
                }),
                {
                    cacheKeyWillBeUsed: async ({ request }) => {
                        const url = new URL(request.url);
                        return url.origin + url.pathname;
                    },
                    fetchDidFail: async ({ originalRequest, request, error }) => {
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
                            }
                        } catch (retryError) { }
                    },
                },
            ],
        })
    );

    workbox.routing.registerRoute(
        ({ url }) => url.pathname.startsWith("/assets/"),
        new workbox.strategies.CacheFirst({
            cacheName: CACHE_NAMES.static,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxAgeSeconds: 30 * 24 * 60 * 60,
                }),
                {
                    requestWillFetch: async ({ request }) => {
                        const url = new URL(request.url);
                        if (
                            url.pathname.includes("/google_fonts/") ||
                            url.pathname.includes("/fonts/") ||
                            url.pathname.endsWith("AssetManifest.json") ||
                            url.pathname.endsWith("FontManifest.json")
                        ) {
                            return new Request(request.url, {
                                mode: "no-cors",
                                cache: "reload",
                            });
                        }
                        return request;
                    },
                    cacheKeyWillBeUsed: async ({ request }) => {
                        const url = new URL(request.url);
                        return url.origin + url.pathname;
                    },
                },
            ],
        })
    );

    workbox.routing.setDefaultHandler(
        new workbox.strategies.StaleWhileRevalidate({
            cacheName: CACHE_NAMES.dynamic,
            plugins: [
                new workbox.expiration.ExpirationPlugin({
                    maxEntries: 100,
                    maxAgeSeconds: 7 * 24 * 60 * 60,
                }),
            ],
        })
    );

    workbox.routing.setCatchHandler(({ event }) => {
        const request = event.request;
        const url = new URL(request.url);

        if (
            url.pathname.endsWith(".mjs") ||
            url.pathname.endsWith(".wasm") ||
            url.pathname.endsWith(".js") ||
            url.pathname.includes("canvaskit")
        ) {
            return caches.match(request).then((response) => {
                if (response) {
                    return response;
                }

                const urlWithoutQuery = url.origin + url.pathname;
                return caches.match(urlWithoutQuery).then((response) => {
                    if (response) {
                        return response;
                    }
                    return Response.error();
                });
            });
        }

        if (request.destination === "document" || request.mode === "navigate") {
            return caches
                .match("/index.html")
                .then((response) => {
                    if (response) return response;
                    return caches.match("/");
                })
                .catch(() => caches.match("/"));
        }

        if (request.destination === "image") {
            return caches.match("/assets/offline_image.png").catch(() => Response.error());
        }

        return Response.error();
    });

    self.addEventListener("fetch", (event) => {
        const url = new URL(event.request.url);

        if (
            url.origin !== self.location.origin &&
            !(
                url.pathname.includes("canvaskit") ||
                url.pathname.includes("cdn.onesignal.com")
            )
        ) {
            return;
        }
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
            event.respondWith(
                caches.match(event.request).then((cachedResponse) => {
                    if (cachedResponse) {
                        return cachedResponse;
                    }

                    const urlWithoutQuery = url.origin + url.pathname;
                    return caches.match(urlWithoutQuery).then((cachedResponseNoQuery) => {
                        if (cachedResponseNoQuery) {
                            return cachedResponseNoQuery;
                        }

                        return fetch(event.request)
                            .then((networkResponse) => {
                                if (networkResponse && networkResponse.status === 200) {
                                    const clonedResponse = networkResponse.clone();
                                    const cacheName =
                                        url.pathname.includes("canvaskit") ||
                                            url.pathname.endsWith(".wasm") ||
                                            url.pathname.endsWith(".mjs") ||
                                            url.pathname.endsWith(".js")
                                            ? CACHE_NAMES.flutter
                                            : CACHE_NAMES.static;

                                    caches.open(cacheName).then((cache) => {
                                        cache.put(event.request, networkResponse.clone());
                                        if (event.request.url !== urlWithoutQuery) {
                                            cache.put(urlWithoutQuery, clonedResponse);
                                        }
                                    });
                                }
                                return networkResponse;
                            })
                            .catch((error) => {
                                return caches.match(url.pathname).then((response) => response || Response.error());
                            });
                    });
                })
            );
        } else if (url.pathname.includes("/assets/")) {
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
