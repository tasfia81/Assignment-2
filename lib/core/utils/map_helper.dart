import 'map_helper_stub.dart'
    if (dart.library.js_interop) 'map_helper_web.dart';

/// Returns true if Google Maps SDK is loaded and ready to be initialized.
/// Returns false on web if window.google.maps is undefined or script failed to load.
bool isGoogleMapAvailable() {
  return isGoogleMapsWebLoaded();
}
