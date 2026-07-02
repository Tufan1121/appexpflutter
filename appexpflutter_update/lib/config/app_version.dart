/// Versión de la app en UN SOLO lugar. Súbela en cada release.
///
/// - [kAppVersion]: texto que se muestra en el login (ej. "1.1.10").
/// - [kAppBuild]: entero incremental que usa el "gate" de actualización.
///   Se compara contra `min_build` que devuelve el backend en `/appVersion`.
///   Convención: major*10000 + minor*100 + patch  →  1.1.10 = 10110.
///
/// Para forzar que todos actualicen a una versión nueva: sube [kAppBuild] aquí,
/// compila el APK, y en el backend pon `APP_MIN_BUILD` igual (o menor) a ese
/// número. Quien tenga un build menor verá la pantalla de "Actualiza".
const String kAppVersion = '1.1.10';
const int kAppBuild = 10110;
