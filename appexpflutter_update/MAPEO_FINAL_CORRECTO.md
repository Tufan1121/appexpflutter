# MAPEO CORRECTO - VERSIÓN FINAL
## Fecha: 2026-01-19

---

## 🎯 REGLA FUNDAMENTAL

**TODOS los métodos de pago requieren una cuenta bancaria (banco + número de cuenta + dig):**
- **Efectivo:** Se selecciona la cuenta donde se depositará el efectivo
- **Transferencia:** Se selecciona la cuenta donde se hará la transferencia
- **Tarjeta:** Se selecciona la cuenta donde se depositará + el terminal que se usó

**Los endpoints `/cuentas/` y `/terminales/` devuelven JSON casi igual:**
- Ambos tienen: `banco`, `cuenta`, `dig`
- Terminales adicionalmente tienen: `terminal` (ID de la terminal)

---

## 📊 ESTRUCTURA DE LOS ENDPOINTS

### Endpoint: `/cuentas/`
```json
[
  {
    "banco": "BBVA",
    "cuenta": "012345678901",
    "dig": "89"
  }
]
```

### Endpoint: `/terminales/`
```json
[
  {
    "terminal": "TERM-001",
    "banco": "BBVA",
    "cuenta": "012345678901",
    "dig": "89"
  }
]
```

---

## ✅ ESCENARIO 1: Efectivo
**Usuario selecciona:** "01 Efectivo" + Cuenta "BBVA - 012345678901"

### JSON enviado:
```json
{
  "id_metodopago": 1,
  "banco1": "BBVA",
  "cuenta1": "012345678901",
  "dig1": "89",
  "terminal1": ""
}
```

**Explicación:**
- `banco1`, `cuenta1`, `dig1` → De la cuenta seleccionada
- `terminal1` → Vacío (no se usa terminal para efectivo)

---

## ✅ ESCENARIO 2: Transferencia
**Usuario selecciona:** "03 Transferencia" + Cuenta "Santander - 987654321098"

### JSON enviado:
```json
{
  "id_metodopago": 3,
  "banco1": "Santander",
  "cuenta1": "987654321098",
  "dig1": "12",
  "terminal1": ""
}
```

**Explicación:**
- `banco1`, `cuenta1`, `dig1` → De la cuenta seleccionada
- `terminal1` → Vacío (no se usa terminal para transferencia)

---

## ✅ ESCENARIO 3: Tarjeta de Crédito
**Usuario selecciona:** "04 Tarjeta de Crédito" + Terminal "TERM-001"

### JSON enviado:
```json
{
  "id_metodopago": 4,
  "banco1": "BBVA",
  "cuenta1": "012345678901",
  "dig1": "89",
  "terminal1": "TERM-001"
}
```

**Explicación:**
- `banco1`, `cuenta1`, `dig1` → Del terminal seleccionado (el terminal tiene cuenta asociada)
- `terminal1` → ID del terminal seleccionado

---

## ✅ ESCENARIO 4: Efectivo + Tarjeta
**Usuario selecciona:**
- Método 1: "01 Efectivo" + Cuenta "BBVA - 111222333444" ($3,000)
- Método 2: "04 Tarjeta" + Terminal "TERM-001" ($5,000)

### JSON enviado:
```json
{
  "id_metodopago": 1,
  "banco1": "BBVA",
  "cuenta1": "111222333444",
  "dig1": "56",
  "terminal1": "",
  
  "id_metodopago2": 4,
  "banco2": "BBVA",
  "cuenta2": "012345678901",
  "dig2": "89",
  "terminal2": "TERM-001"
}
```

**Explicación:**
- **Método 1 (Efectivo):**
  - `banco1`, `cuenta1`, `dig1` → De la cuenta seleccionada
  - `terminal1` → Vacío
  
- **Método 2 (Tarjeta):**
  - `banco2`, `cuenta2`, `dig2` → Del terminal seleccionado
  - `terminal2` → ID del terminal

---

## ✅ ESCENARIO 5: Tres Métodos
**Usuario selecciona:**
- Método 1: "01 Efectivo" + Cuenta "HSBC - 123456789012" ($8,000)
- Método 2: "03 Transferencia" + Cuenta "Santander - 321098765432" ($7,000)
- Método 3: "04 Tarjeta" + Terminal "TERM-002" ($5,000)

### JSON enviado:
```json
{
  "id_metodopago": 1,
  "banco1": "HSBC",
  "cuenta1": "123456789012",
  "dig1": "90",
  "terminal1": "",
  
  "id_metodopago2": 3,
  "banco2": "Santander",
  "cuenta2": "321098765432",
  "dig2": "45",
  "terminal2": "",
  
  "id_metodopago3": 4,
  "banco3": "Banamex",
  "cuenta3": "555444333222",
  "dig3": "67",
  "terminal3": "TERM-002"
}
```

---

## 🔄 LÓGICA DE MAPEO EN EL CÓDIGO

```dart
// banco/cuenta/dig SIEMPRE se llenan:
// - Si hay cuenta seleccionada → usa datos de la cuenta
// - Si NO hay cuenta pero hay terminal → usa datos del terminal
// terminal solo se llena cuando hay terminal

'banco1': cuenta1?.banco ?? terminal1?.banco ?? '',
'cuenta1': cuenta1?.cuenta ?? terminal1?.cuenta ?? '',
'dig1': cuenta1?.dig ?? terminal1?.dig ?? '',
'terminal1': terminal1?.id ?? '',
```

---

## 📋 TABLA RESUMEN

| Método | Selecciona | banco1 | cuenta1 | dig1 | terminal1 |
|--------|-----------|--------|---------|------|-----------|
| Efectivo | Cuenta | ✅ De cuenta | ✅ De cuenta | ✅ De cuenta | ❌ Vacío |
| Transferencia | Cuenta | ✅ De cuenta | ✅ De cuenta | ✅ De cuenta | ❌ Vacío |
| Tarjeta | Terminal | ✅ De terminal | ✅ De terminal | ✅ De terminal | ✅ ID terminal |

---

## 🛠️ MODELOS ACTUALIZADOS

### CuentaModel
```dart
class CuentaModel {
  final String id;
  final String nombre;
  final String banco;
  final String cuenta;
  final String? dig;
}
```

### TerminalModel
```dart
class TerminalModel {
  final String id;
  final String nombre;
  final String? banco;
  final String? cuenta;
  final String? dig;
}
```

**Nota:** Ambos modelos tienen `banco`, `cuenta` y `dig` porque ambos endpoints devuelven esta información.

---

## ✅ RESUMEN

1. **SIEMPRE** se llena `banco`, `cuenta` y `dig` (sin importar el método de pago)
2. **SOLO** se llena `terminal` cuando el método es Tarjeta
3. Los datos de `banco`, `cuenta`, `dig` vienen de:
   - La **cuenta** seleccionada (para Efectivo/Transferencia)
   - El **terminal** seleccionado (para Tarjeta, porque el terminal tiene cuenta asociada)
