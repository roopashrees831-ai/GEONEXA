import 'dart:js_interop';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget buildGeonexaWebMap({required String html, required Key key}) {
  return HtmlElementView.fromTagName(
    key: key,
    tagName: 'iframe',
    onElementCreated: (Object element) {
      final iframe = element as web.HTMLIFrameElement;

      // WEB ONLY:
      // Use MapLibre's browser ES-module build.
      // Android does not use this file.

      final webHtml = html
          // Update web CSS only.
          .replaceAll(
            'https://unpkg.com/maplibre-gl@5.6.0/dist/maplibre-gl.css',
            'https://unpkg.com/maplibre-gl@6.10.0/dist/maplibre-gl.css',
          )
          // Remove the old classic JS loader.
          .replaceFirst(
            RegExp(
              r'<script\s+src="https://unpkg\.com/maplibre-gl@5\.6\.0/dist/maplibre-gl\.js">\s*</script>',
              multiLine: true,
            ),
            '',
          )
          // Turn the GEONEXA map script into an ES module
          // and import MapLibre directly.
          .replaceFirst('<script>', '''
<script type="module">
import * as maplibregl from
  "https://unpkg.com/maplibre-gl@6.10.0/dist/maplibre-gl.mjs";
''');

      iframe.srcdoc = webHtml.toJS;

      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.style.border = '0';
      iframe.style.margin = '0';
      iframe.style.padding = '0';
      iframe.style.display = 'block';
      iframe.style.pointerEvents = 'auto';
      iframe.style.touchAction = 'auto';
      iframe.style.backgroundColor = '#061724';

      iframe.setAttribute('allow', 'geolocation');

      iframe.setAttribute('title', 'GEONEXA 3D Risk Map');
    },
  );
}
