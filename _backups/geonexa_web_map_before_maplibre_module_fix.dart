import 'dart:js_interop';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget buildGeonexaWebMap({required String html, required Key key}) {
  return HtmlElementView.fromTagName(
    key: key,
    tagName: 'iframe',
    onElementCreated: (Object element) {
      final iframe = element as web.HTMLIFrameElement;

      iframe.srcdoc = html.toJS;

      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.style.border = '0';
      iframe.style.margin = '0';
      iframe.style.padding = '0';
      iframe.style.display = 'block';
      iframe.style.backgroundColor = '#061724';

      iframe.setAttribute('allow', 'geolocation');

      iframe.setAttribute('title', 'GEONEXA 3D Risk Map');
    },
  );
}
