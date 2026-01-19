# ANÁLISIS DE ENDPOINTS Y MAPEO DE DATOS
## Fecha: 2026-01-19

---

## 📊 ESTRUCTURA ESPERADA DE LOS ENDPOINTS

### Endpoint: `/cuentas/`
**Método:** GET  
**Headers:** `Authorization: Bearer {token}`

**Estructura JSON esperada (basada en CuentaModel):**
```json
[
  {
    "banco": "BBVA",
    "cuenta": "0123451",
    "dig": "89"
  },
  {
    "banco": "Santander",
    "cuenta": "98768",
    "dig": "12"
  }
]
```

**Campos:**
- `banco` (string): Nombre del banco
- `cuenta` (string): Número de cuenta bancaria
- `dig` (string, opcional): Dígitos de verificación

---

### Endpoint: `/terminales/`
**Método:** GET  
**Headers:** `Authorization: Bearer {token}`

**Estructura JSON esperada (basada en TerminalModel):**
```json
[
  {
    "terminal": "TERM-001",
    "banco": "BBVA"
  },
  {
    "terminal": "TERM-002",
    "banco": "Banamex"
  }
]
```

**Campos:**
- `terminal` (string): ID o nombre de la terminal
- `banco` (string, opcional): Banco asociado a la terminal

---

## 🔄 MAPEO ACTUAL EN LA APLICACIÓN

### CuentaModel.fromJson()
```dart
factory CuentaModel.fromJson(Map<String, dynamic> json) {
  final banco = json['banco']?.toString() ?? '';
  final cuenta = json['cuenta']?.toString() ?? '';
  
  return CuentaModel(
    id: cuenta,                    // ID = número de cuenta
    nombre: '$banco - $cuenta',    // Nombre para mostrar en UI
    banco: banco,                  // Nombre del banco
    cuenta: cuenta,                // Número de cuenta
    dig: json['dig']?.toString(),  // Dígitos de verificación
  );
}
```

### TerminalModel.fromJson()
```dart
factory TerminalModel.fromJson(Map<String, dynamic> json) {
  return TerminalModel(
    id: json['terminal']?.toString() ?? '',      // ID de la terminal
    nombre: json['terminal']?.toString() ?? '',  // Nombre para mostrar
    banco: json['banco']?.toString(),            // Banco asociado
  );
}
```

---

## 📤 MAPEO AL BACKEND (Endpoint: `/insertprePos`)

### Cuando se selecciona EFECTIVO (01) o TRANSFERENCIA (03):
Se usa **CuentaModel** y se mapea así:
```dart
'banco1': cuenta1?.banco ?? '',      // "BBVA"
'cuenta1': cuenta1?.cuenta ?? '',    // "012345678901"
'dig1': cuenta1?.dig ?? '',          // "89"
'terminal1': '',                     // Vacío para efectivo/transferencia
```

### Cuando se selecciona TARJETA DE CRÉDITO (04) o DÉBITO (82):
Se usa **TerminalModel** y se mapea así:
```dart
'banco1': terminal1?.banco ?? '',    // "BBVA" (del terminal)
'cuenta1': '',                       // Vacío para tarjetas
'dig1': '',                          // Vacío para tarjetas
'terminal1': terminal1?.id ?? '',    // "TERM-001"
```

---

## ✅ VALIDACIÓN DE LA LÓGICA

### Escenario 1: Pago en Efectivo
**Usuario selecciona:** "01 Efectivo" + Cuenta "BBVA - 012345678901"

**Datos enviados:**
```json
{
  "id_metodopago": 1,
  "banco1": "BBVA",
  "cuenta1": "012345678901",
  "dig1": "89",
  "terminal1": ""
}
```

### Escenario 2: Pago con Tarjeta
**Usuario selecciona:** "04 Tarjeta de Crédito" + Terminal "TERM-001"

**Datos enviados:**
```json
{
  "id_metodopago": 4,
  "banco1": "BBVA",
  "cuenta1": "",
  "dig1": "",
  "terminal1": "TERM-001"
}
```

### Escenario 3: Pago Mixto (Efectivo + Tarjeta)
**Usuario selecciona:**
- Método 1: "01 Efectivo" + Cuenta "BBVA - 012345678901"
- Método 2: "04 Tarjeta de Crédito" + Terminal "TERM-001"

**Datos enviados:**
```json
{
  "id_metodopago": 1,
  "banco1": "BBVA",
  "cuenta1": "012345678901",
  "dig1": "89",
  "terminal1": "",
  
  "id_metodopago2": 4,
  "banco2": "BBVA",
  "cuenta2": "",
  "dig2": "",
  "terminal2": "TERM-001"
}
```

---

## 🔍 VERIFICACIÓN NECESARIA

### Para confirmar que el mapeo es correcto, necesitas verificar:

1. **Estructura real de `/cuentas/`:**
   - ¿El endpoint devuelve `banco`, `cuenta` y `dig`?
   - ¿Los nombres de los campos son exactamente esos?

2. **Estructura real de `/terminales/`:**
   - ¿El endpoint devuelve `terminal` y `banco`?
   - ¿El campo `banco` está presente en las terminales?

3. **Expectativa del backend en `/insertprePos`:**
   - ¿El backend espera `banco1`, `cuenta1`, `dig1`, `terminal1` como strings?
   - ¿Acepta strings vacíos o prefiere `null`?

---

## 🛠️ CÓDIGO DE PRUEBA

### Para probar manualmente los endpoints:

```bash
# 1. Login
curl -X POST "https://tapetestufan.mx:6002/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=&username=omar@protonmail.com&password=x5sa/85w&scope=&client_id=&client_secret="

# 2. Obtener token de la respuesta y usarlo:
TOKEN="tu_token_aqui"

# 3. Obtener cuentas
curl -X GET "https://tapetestufan.mx:6002/cuentas/" \
  -H "Authorization: Bearer $TOKEN"

# 4. Obtener terminales
curl -X GET "https://tapetestufan.mx:6002/terminales/" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📝 RECOMENDACIONES

1. **Prueba desde la aplicación Flutter:**
   - Ejecuta la app en modo debug
   - Agrega prints en `PaymentInfoDataSourceImpl` para ver la respuesta real
   - Verifica que los datos se mapean correctamente

2. **Verifica el backend:**
   - Contacta al equipo de backend para confirmar la estructura esperada
   - Pide ejemplos de JSON de respuesta de `/cuentas/` y `/terminales/`

3. **Ajusta si es necesario:**
   - Si los campos tienen nombres diferentes, actualiza los modelos
   - Si el backend espera `null` en lugar de `''`, ajusta el mapeo

---

## 🎯 ESTADO ACTUAL

✅ **Modelos actualizados:**
- `CuentaModel` incluye: `banco`, `cuenta`, `dig`
- `TerminalModel` incluye: `terminal`, `banco`

✅ **Pantallas actualizadas:**
- `GenerarPedidoVentaScreen` mapea correctamente los datos
- `SesionPedidoScreen` mapea correctamente los datos

⚠️ **Pendiente de verificar:**
- Estructura real de los endpoints `/cuentas/` y `/terminales/`
- Prueba end-to-end con datos reales

---

## 📞 CONTACTO PARA VERIFICACIÓN

**Credenciales de prueba:**
- Usuario: omar@protonmail.com
- Password: x5sa/85w

**Endpoints a verificar:**
- POST https://tapetestufan.mx:6002/token
- GET https://tapetestufan.mx:6002/cuentas/
- GET https://tapetestufan.mx:6002/terminales/
