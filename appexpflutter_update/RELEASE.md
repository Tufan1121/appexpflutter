# Guía de release y actualización obligatoria — Tufan Expo

## Versión: un solo lugar
La versión vive **únicamente** en `pubspec.yaml`:

```yaml
version: 1.1.10+10110   # nombre+build
```

- `1.1.10` (nombre) → se ve en el login y en Firebase.
- `10110` (build) → entero que compara el gate. Convención: `major*10000 + minor*100 + patch`.

El login, Firebase y el gate de actualización leen de aquí (vía `package_info_plus`).
No hay otro número que mantener.

## Publicar una versión nueva
1. Sube `version:` en `pubspec.yaml` (ej. `1.1.11+10111`).
2. Compila el APK:
   ```
   flutter build apk --release --target-platform android-arm64
   ```
   - `arm64` cubre prácticamente todos los teléfonos de ~2015+ y usa menos RAM al compilar.
   - Resultado: `build/app/outputs/flutter-apk/app-release.apk`
3. Súbelo a **Firebase App Distribution** (grupo `vendedores`).

## Obligar a actualizar
El interruptor es `APP_MIN_BUILD` en `mainExpo.py` (servidor).

> **REGLA DE ORO:** primero publica el APK nuevo en Firebase y **luego** sube
> `APP_MIN_BUILD`. Nunca lo pongas más alto que el último build ya disponible,
> o bloquearías a todos sin salida.

Para forzar a la 1.1.11 (build 10111), ya publicada:
```python
APP_MIN_BUILD = 10111
APP_LATEST_VERSION = "1.1.11"
```
Luego en el servidor: `git pull` + reiniciar `mainExpo`.

Todos con build < 10111 verán **"Actualización requerida"**; el botón abre el
invite link de Firebase (última versión). Para **bajar** el bloqueo: regresa
`APP_MIN_BUILD` a un valor menor y reinicia.

## Probar el bloqueo (sin publicar nada)
1. En el servidor, `APP_MIN_BUILD = <build mayor al instalado>` y reinicia `mainExpo`.
2. En el teléfono: **cierra la app por completo** y ábrela de nuevo.
   El gate se verifica al **arranque en frío** (no al volver de segundo plano).
3. Debe salir la pantalla de actualización. **Revierte** `APP_MIN_BUILD` al terminar.

## Notas importantes
- **Solo aplica a versiones con el gate** (1.1.10 en adelante). A quien esté en
  una versión previa (sin gate) **no** se le puede forzar: hay que migrarlo a la
  1.1.10 una vez a mano (invite link de Firebase / Drive).
- **Fail-open**: si el backend no responde o falla, la app **no bloquea**.
- **Endpoint** (sin token): `GET /appVersion` →
  `{min_build, latest_version, update_url, message}`.
- `APP_UPDATE_URL` = invite link estable de Firebase (no cambia entre releases).
- **Memoria de compilación**: `android/gradle.properties` usa `-Xmx2G` + 1 worker
  porque esta máquina tiene poca RAM libre. En una máquina con más RAM puedes
  subirlo (o compilar sin `--target-platform` para el APK multi-arquitectura).
- Los backends `mainTienda.py` / `mainPromos.py` **aún no** tienen el endpoint
  `/appVersion` (pendiente si esas apps también deben forzar).
