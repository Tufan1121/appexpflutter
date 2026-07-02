# Guía de release y actualización obligatoria — Tufan Expo

Distribución actual: **APK servido desde el propio servidor** (Apache) en
`https://tapetestufan.mx/apps/expo/app-release.apk`. El link es **fijo**: en
cada release solo reemplazas ese archivo. Firebase App Distribution queda como
opción de pruebas, no para usuarios finales.

## Checklist rápido (sacar una versión)

**Siempre (publicar la versión):**
1. Sube el número en `pubspec.yaml` (ej. `1.1.11+10111` → `1.1.12+10112`). ← manual, antes de compilar
2. Compila: `flutter build apk --release`  (APK "gordo", cubre todos los dispositivos)
3. **Reemplaza** el APK en el servidor con el nuevo `app-release.apk`, en:
   `apps/expo/app-release.apk`  (mismo nombre → el link no cambia)
   > Hasta aquí la versión ya está disponible; quien abra el link la instala.

**Solo si quieres OBLIGAR / avisar:** en `mainExpo.py` (servidor):
4. Para **avisar** (banner suave): `APP_LATEST_BUILD = 10112`, `APP_LATEST_VERSION = "1.1.12"`.
   Para **obligar** (bloqueo): además `APP_MIN_BUILD = 10112`.
5. `git pull` + **reinicia** `mainExpo`.

> ⚠️ **REGLA DE ORO:** primero reemplaza el APK del servidor (paso 3) y **luego**
> sube `APP_MIN_BUILD`. Si obligas a un build que no está servido, dejas a la
> gente en bucle.

## Versión: un solo lugar
La versión vive **únicamente** en `pubspec.yaml`:

```yaml
version: 1.1.11+10111   # nombre+build
```

- `1.1.11` (nombre) → se ve en el login.
- `10111` (build) → entero que compara el gate. Convención: `major*10000 + minor*100 + patch`.

El login y el gate leen de aquí (vía `package_info_plus`). No hay otro número
que mantener en la app.

## Compilar el APK
```
flutter build apk --release
```
- Genera el APK **multi-arquitectura** (arm64 + arm32 + x86_64) → funciona en
  prácticamente cualquier Android. Pesa ~116 MB.
- Resultado: `build/app/outputs/flutter-apk/app-release.apk`
- Alternativa más ligera (solo teléfonos modernos, ~66 MB, menos RAM al
  compilar): `flutter build apk --release --target-platform android-arm64`.

## Cómo instalan / actualizan los usuarios
Comparte este link (fijo, nunca cambia):
```
https://tapetestufan.mx/apps/expo/app-release.apk
```
- El usuario lo abre en Android → **descarga** el APK → **instala**.
- La primera vez Android pide permitir *"instalar apps de fuentes desconocidas"*
  para el navegador → aceptar.
- **Sin cuentas, sin App Tester.** El mismo link siempre trae la última versión
  (porque reemplazas el archivo en el servidor).
- Regla mental: **"que baje/actualice" → comparto ese link**.
- Es actualización **manual** (el usuario toca). Para forzar, usa el gate (abajo).

## Obligar a actualizar (bloqueo)
Interruptor: `APP_MIN_BUILD` en `mainExpo.py`.

Para forzar a la 1.1.11 (build 10111), **ya reemplazado el APK en el servidor**:
```python
APP_MIN_BUILD = 10111
APP_LATEST_VERSION = "1.1.11"
```
`git pull` + reiniciar `mainExpo`. Todos con build < 10111 verán
**"Actualización requerida"**; el botón "Actualizar ahora" abre el link del
servidor → descarga e instala. Para **bajar** el bloqueo: regresa
`APP_MIN_BUILD` a un valor menor y reinicia.

## Aviso suave (opcional, no obligatorio)
Banner descartable ("hay versión nueva", *Actualizar* / *Ahora no*) sin obligar.
Lo controla `APP_LATEST_BUILD`:

- Si el build instalado es **menor** que `APP_LATEST_BUILD` pero **≥**
  `APP_MIN_BUILD` → banner suave. (Si es menor que `APP_MIN_BUILD` → bloqueo.)

Ejemplo al publicar 1.1.12 **avisando pero sin forzar**:
```python
APP_MIN_BUILD    = 10111   # no obliga
APP_LATEST_BUILD = 10112   # avisa (suave)
APP_LATEST_VERSION = "1.1.12"
```

## Probar el bloqueo
1. En el servidor, `APP_MIN_BUILD = <build mayor al instalado>` y reinicia `mainExpo`.
2. En el teléfono: **cierra la app por completo** y ábrela de nuevo (el gate se
   verifica al **arranque en frío**, no al volver de segundo plano).
3. Debe salir la pantalla de actualización. **Revierte** `APP_MIN_BUILD` al terminar.

## Notas importantes
- **Solo aplica a versiones con el gate** (1.1.10 en adelante). A quien esté en
  una versión previa (sin gate) **no** se le puede forzar: hay que llevarlo una
  vez a la ≥1.1.10 a mano (comparte el link del servidor).
- **Fail-open**: si el backend no responde o falla, la app **no bloquea**.
- **Endpoint** (sin token): `GET /appVersion` →
  `{min_build, latest_build, latest_version, update_url, message}`.
- `APP_UPDATE_URL` = link estático del servidor (no cambia entre releases).
- **Memoria de compilación**: `android/gradle.properties` usa `-Xmx2G` + 1 worker
  (esta máquina tiene poca RAM libre). En una máquina con más RAM puedes subirlo.
- Los backends `mainTienda.py` / `mainPromos.py` **aún no** tienen `/appVersion`
  (pendiente si esas apps también deben forzar/avisar).
- Firebase App Distribution sigue disponible para **pruebas internas**, pero su
  onboarding (cuenta Google + App Tester) es engorroso para usuarios finales.
