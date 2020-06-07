'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "main.dart.js": "47accee86d0ae1b91d0b37b3ccebe095",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/FontManifest.json": "580ff1a5d08679ded8fcf5c6848cece7",
"assets/LICENSE": "511526fe6fee15e7b39447ac59d71d60",
"assets/AssetManifest.json": "99914b932bd37a50b983c5e7c90ae93b",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"manifest.json": "90ac897914a6e935161293237101f4c9",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"index.html": "4fb2c21eaadec9c0d451fca5d95dabd9",
"/": "4fb2c21eaadec9c0d451fca5d95dabd9"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
