/// Central API and Application Configuration for Orgaflow.
///
/// Update [baseUrl] here to change the backend endpoint across the entire app.
class AppConfig {
  /// Base URL of the backend service.
  ///
  /// - Render Blueprint (service: orgaflow-backend):
  ///     https://orgaflow-backend.onrender.com
  /// - Alternative Render domain:
  ///     https://orgaflow-app.onrender.com
  /// - Android Emulator (local PC):
  ///     http://10.0.2.2:8000
  /// - Physical Phone with `adb reverse tcp:8000 tcp:8000`:
  ///     http://127.0.0.1:8000
  static const String baseUrl = 'https://orgaflow-app.onrender.com';

  /// Google Server Client ID for OAuth token verification.
  static const String googleServerClientId =
      '449981088129-fptar4p18jkmsgk6avhigqintmv0qha3.apps.googleusercontent.com';

  /// Default timeout for HTTP requests.
  static const Duration requestTimeout = Duration(seconds: 30);
}
