'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "f8c08877cc393ed4544cfe94fe05a0eb",
"assets/AssetManifest.bin.json": "ca1bd964f3c8c2436ebcaf0733eb960e",
"assets/AssetManifest.json": "41cfa34e6fb0e573dc020abb9cb6e210",
"assets/assets/fonts/JetBrains_Mono,Noto_Sans/Noto_Sans/static/NotoSans-Italic.ttf": "a6d070775dd5e6bfff61870528c6248a",
"assets/assets/fonts/JetBrains_Mono,Noto_Sans/Noto_Sans/static/NotoSans-Regular.ttf": "f46b08cc90d994b34b647ae24c46d504",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-Black.ttf": "c7cf13f6288ece850a978a0cfa764cd4",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-Bold.ttf": "1bdb5bf9e923e1bc6418342bcf6fb3e0",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-ExtraBold.ttf": "a4f1e854cd8a6816fccea648d4b1b7ac",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-ExtraLight.ttf": "e9d5260a35768a256df2ad79d376c262",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-Light.ttf": "b248483f59d25fca6fb75ba8196f7037",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-Medium.ttf": "7aa0d1123977dab52b1e01f61f0a9a7f",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-Regular.ttf": "dd4fa7df965b4d3227bf42b9a77da3e0",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-SemiBold.ttf": "c44d4e4829263260330f8a6b181ec9a8",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Noto_Sans_JP/static/NotoSansJP-Thin.ttf": "9b3a9c37f57376f4572cc30aa6506367",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Zen_Maru_Gothic/ZenMaruGothic-Black.ttf": "0644b76f5bac60c2cf15c0b51a9148bb",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Zen_Maru_Gothic/ZenMaruGothic-Bold.ttf": "9f7ca0ac0401f8135ae3902400717c30",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Zen_Maru_Gothic/ZenMaruGothic-Light.ttf": "c04f70835ac22c523238fd1a18a054f0",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Zen_Maru_Gothic/ZenMaruGothic-Medium.ttf": "416b8693a548b04c6868a66340e303ce",
"assets/assets/fonts/Noto_Sans_JP,Zen_Maru_Gothic/Zen_Maru_Gothic/ZenMaruGothic-Regular.ttf": "7d2ffbbc81c697cd223084da3e221da0",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-Black.ttf": "c8577af67a3637f763a76e3233b34f4c",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-Bold.ttf": "f7857b9909d59d2d8484133541c9a834",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-ExtraBold.ttf": "025964d38d7d0c1b764e6f99c558aa27",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-ExtraLight.ttf": "82e93c22d847d928c6aed91531d18677",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-Light.ttf": "7032df96167d98bfb67f4ac0529429f6",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-Medium.ttf": "3b911933a923a4f7890b3370dcac405b",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-Regular.ttf": "4f85eb828784848a144bbf90a563c029",
"assets/assets/fonts/Noto_Serif_JP/static/NotoSerifJP-SemiBold.ttf": "aa8b447e18810e7add83815d5d77758c",
"assets/FontManifest.json": "ed793a99c2e7c7543e2a3d5a53b6f487",
"assets/fonts/MaterialIcons-Regular.otf": "db20c27dbb640166824c4b7049e6ab72",
"assets/NOTICES": "49bcf0590ed07bc979c35f0050caa6a8",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "86e461cf471c1640fd2b461ece4589df",
"canvaskit/canvaskit.js.symbols": "68eb703b9a609baef8ee0e413b442f33",
"canvaskit/canvaskit.wasm": "efeeba7dcc952dae57870d4df3111fad",
"canvaskit/chromium/canvaskit.js": "34beda9f39eb7d992d46125ca868dc61",
"canvaskit/chromium/canvaskit.js.symbols": "5a23598a2a8efd18ec3b60de5d28af8f",
"canvaskit/chromium/canvaskit.wasm": "64a386c87532ae52ae041d18a32a3635",
"canvaskit/skwasm.js": "f2ad9363618c5f62e813740099a80e63",
"canvaskit/skwasm.js.symbols": "80806576fa1056b43dd6d0b445b4b6f7",
"canvaskit/skwasm.wasm": "f0dfd99007f989368db17c9abeed5a49",
"canvaskit/skwasm_st.js": "d1326ceef381ad382ab492ba5d96f04d",
"canvaskit/skwasm_st.js.symbols": "c7e7aac7cd8b612defd62b43e3050bdd",
"canvaskit/skwasm_st.wasm": "56c3973560dfcbf28ce47cebe40f3206",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "76f08d47ff9f5715220992f993002504",
"flutter_bootstrap.js": "a767d08f87b7bf329e1a4625f5be1b00",
"icons/icon_192x192.png": "c0b3a570db3cb131a8e2e43f8d8f33d8",
"icons/icon_512x512.png": "fccf65bb532f9a5ec2fd376cdda3d20b",
"icons/icon_favicon_32x32.png": "592eae52353b7a617b62b9e639c00ae5",
"icons/icon_maskable_192x192.png": "509d92e892059fd272c1d46666f0e7f8",
"icons/icon_maskable_512x512.png": "fb0aff6ee09c11075f517354336f0ddb",
"index.html": "f3a69cf8a2a0c7d25f7c8284095dc9d5",
"/": "f3a69cf8a2a0c7d25f7c8284095dc9d5",
"main.dart.js": "888b76986ac4f4486c9bcb1e5d3a2acc",
"manifest.json": "ea197ed02e0876385319057f992bb02b",
"version.json": "97144a1d275b1db8d6ea25235fd71288"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
