# ✅ ESTRUCTURA REAL DE LOS ENDPOINTS - CONFIRMADA

## 📊 Datos Reales del Backend

### Endpoint: `/cuentas/`
```json
[
  {
    "cuenta": "7030800",
    "clabe": "434343344334344343",
    "banco": "BANAMEX"
  },
  {
    "cuenta": "00445769361",
    "clabe": "0121804344334433415",
    "banco": "BANCOMER"
  },
  {
    "cuenta": "045451419",
    "clabe": "344343434343434354",
    "banco": "SANTANDE"
  },
  {
    "cuenta": "60254545457",
    "clabe": "4554546546534334334",
    "banco": "SANTANDE"
  }
]
```

**Campos:**
- ✅ `cuenta` (String): Número de cuenta
- ✅ `clabe` (String): CLABE interbancaria
- ✅ `banco` (String): Nombre del banco
- ❌ `dig`: **NO EXISTE**

---

### Endpoint: `/terminales/`
```json
[
  {
    "terminal": "CLIP REGULAR",
    "cuenta": "00445769361",
    "banco": "BANCOMER"
  },
  {
    "terminal": "CLIP 6 MSI",
    "cuenta": "00445769361",
    "banco": "BANCOMER"
  },
  {
    "terminal": "CLIP 12 MSI",
    "cuenta": "00445769361",
    "banco": "BANCOMER"
  },
  {
    "terminal": "BANCOMER REGULAR",
    "cuenta": "00445769361",
    "banco": "BANCOMER"
  },
  {
    "terminal": "BANCOMER 6 MSI",
    "cuenta": "00445769361",
    "banco": "BANCOMER"
  },
  {
    "terminal": "BANCOMER 12 MSI",
    "cuenta": "00445769361",
    "banco": "BANCOMER"
  }
]
```

**Campos:**
- ✅ `terminal` (String): Nombre de la terminal
- ✅ `cuenta` (String): Número de cuenta asociada
- ✅ `banco` (String): Nombre del banco
- ❌ `dig`: **NO EXISTE**
- ❌ `clabe`: **NO EXISTE** (solo en cuentas)

---

## 🎯 MAPEO CORRECTO AL BACKEND

### Estructura del JSON que se envía a `/insertprePos`:

```json
{
  "descripcio": "Nombre del cliente",
  "correo": "correo@ejemplo.com",
  "telefono": "5551234567",
  "direccion": "Dirección del cliente",
  
  "id_metodopago": 1,
  "banco1": "BANAMEX",
  "cuenta1": "7030800",
  "dig1": "",
  "terminal1": "",
  
  "observaciones": "Observaciones",
  "estatus": 1,
  "total_pagar": 5000.0,
  "anticipo": 5000.0,
  "anticipo2": 0.0,
  "anticipo3": 0.0,
  "id_cliente": 42,
  "entregado": 0,
  
  "id_metodopago2": 0,
  "banco2": "",
  "cuenta2": "",
  "dig2": "",
  "terminal2": "",
  
  "id_metodopago3": 0,
  "banco3": "",
  "cuenta3": "",
  "dig3": "",
  "terminal3": ""
}
```

---

## 📋 EJEMPLOS REALES

### ✅ ESCENARIO 1: Efectivo con cuenta BANAMEX
```json
{
  "id_metodopago": 1,
  "banco1": "BANAMEX",
  "cuenta1": "7030800",
  "dig1": "",
  "terminal1": ""
}
```

### ✅ ESCENARIO 2: Tarjeta con terminal CLIP REGULAR
```json
{
  "id_metodopago": 4,
  "banco1": "BANCOMER",
  "cuenta1": "00445769361",
  "dig1": "",
  "terminal1": "CLIP REGULAR"
}
```

### ✅ ESCENARIO 3: Efectivo + Tarjeta
```json
{
  "id_metodopago": 1,
  "banco1": "BANAMEX",
  "cuenta1": "7030800",
  "dig1": "",
  "terminal1": "",
  
  "id_metodopago2": 4,
  "banco2": "BANCOMER",
  "cuenta2": "00445769361",
  "dig2": "",
  "terminal2": "CLIP 6 MSI"
}
```

---

## 🔧 CAMBIOS APLICADOS

### 1. **CuentaModel actualizado:**
```dart
class CuentaModel {
  final String id;
  final String nombre;
  final String banco;
  final String cuenta;
  final String? clabe;  // ✅ NUEVO (antes era dig)
}
```

### 2. **TerminalModel actualizado:**
```dart
class TerminalModel {
  final String id;
  final String nombre;
  final String? banco;
  final String? cuenta;
  // ❌ dig eliminado (no existe)
}
```

### 3. **Mapeo en pantallas:**
```dart
'banco1': cuenta1?.banco ?? terminal1?.banco ?? '',
'cuenta1': cuenta1?.cuenta ?? terminal1?.cuenta ?? '',
'dig1': '',  // ❌ Siempre vacío (el backend lo requiere pero no existe en endpoints)
'terminal1': terminal1?.id ?? '',
```

---

## ⚠️ NOTA IMPORTANTE

El campo `dig1`, `dig2`, `dig3` se envía **VACÍO** porque:
1. ❌ NO existe en `/cuentas/`
2. ❌ NO existe en `/terminales/`
3. ✅ Pero el backend lo requiere en el JSON

**Solución:** Se envía como string vacío `""` para cumplir con el contrato del backend.

---

## ✅ RESUMEN

| Campo | Cuentas | Terminales | Se envía al backend |
|-------|---------|------------|---------------------|
| banco | ✅ | ✅ | ✅ |
| cuenta | ✅ | ✅ | ✅ |
| clabe | ✅ | ❌ | ❌ |
| terminal | ❌ | ✅ | ✅ (solo para tarjetas) |
| dig | ❌ | ❌ | ✅ (vacío) |
