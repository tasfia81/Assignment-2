import 'dart:js_interop';

@JS('google.maps')
external JSObject? get googleMaps;

bool isGoogleMapsWebLoaded() {
  try {
    return googleMaps != null;
  } catch (_) {
    return false;
  }
}
