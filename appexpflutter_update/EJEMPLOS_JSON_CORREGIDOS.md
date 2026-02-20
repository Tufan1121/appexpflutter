# EJEMPLOS CORREGIDOS DE JSON SEGÚN MÉTODO DE PAGO
## Fecha: 2026-01-19 (ACTUALIZADO)

---

## ✅ ESCENARIO 1: Solo Efectivo (01 Efectivo)
**Usuario selecciona:** "01 Efectivo" + Cuenta "BBVA - 012345678901"

### JSON enviado al backend:
```json
{
  "descripcio": "Juan Pérez García",
  "correo": "juan.perez@email.com",
  "telefono": "5551234567",
  "direccion": "Av. Principal #123, Col. Centro",
  
  "id_metodopago": 1,
  "banco1": "BBVA",
  "cuenta1": "012345678901",
  "dig1": "89",
  "terminal1": "",
  
  "observaciones": "Cliente prefiere pago en efectivo",
  "estatus": 1,
  "total_pagar": 5000.00,
  "anticipo": 5000.00,
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

**✅ Campos llenos:**
- `banco1` = "BBVA" (del CuentaModel)
- `cuenta1` = "012345678901" (del CuentaModel)
- `dig1` = "89" (del CuentaModel)

**✅ Campos vacíos:**
- `terminal1` = "" (porque es efectivo, no tarjeta)

---

## ✅ ESCENARIO 2: Solo Transferencia Electrónica (03 Transferencia)
**Usuario selecciona:** "03 Transferencia Electrónica" + Cuenta "Santander - 987654321098"

### JSON enviado al backend:
```json
{
  "descripcio": "María López Hernández",
  "correo": "maria.lopez@email.com",
  "telefono": "5559876543",
  "direccion": "Calle Reforma #456, Col. Juárez",
  
  "id_metodopago": 3,
  "banco1": "Santander",
  "cuenta1": "987654321098",
  "dig1": "12",
  "terminal1": "",
  
  "observaciones": "Transferencia bancaria confirmada",
  "estatus": 1,
  "total_pagar": 12500.50,
  "anticipo": 12500.50,
  "anticipo2": 0.0,
  "anticipo3": 0.0,
  "id_cliente": 87,
  "entregado": 1,
  
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

**✅ Campos llenos:**
- `banco1` = "Santander" (del CuentaModel)
- `cuenta1` = "987654321098" (del CuentaModel)
- `dig1` = "12" (del CuentaModel)

**✅ Campos vacíos:**
- `terminal1` = "" (porque es transferencia, no tarjeta)

---

## ✅ ESCENARIO 3: Solo Tarjeta de Crédito (04 Tarjeta de Crédito)
**Usuario selecciona:** "04 Tarjeta de Crédito" + Terminal "TERM-001"

### JSON enviado al backend:
```json
{
  "descripcio": "Pedro Sánchez Ruiz",
  "correo": "pedro.sanchez@email.com",
  "telefono": "5558527410",
  "direccion": "Av. Insurgentes #999, Col. Nápoles",
  
  "id_metodopago": 4,
  "banco1": "",
  "cuenta1": "",
  "dig1": "",
  "terminal1": "TERM-001",
  
  "observaciones": "Pago con tarjeta de crédito",
  "estatus": 1,
  "total_pagar": 7500.00,
  "anticipo": 7500.00,
  "anticipo2": 0.0,
  "anticipo3": 0.0,
  "id_cliente": 125,
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

**✅ Campos llenos:**
- `terminal1` = "TERM-001" (del TerminalModel)

**✅ Campos vacíos:**
- `banco1` = "" (porque es tarjeta, no cuenta bancaria)
- `cuenta1` = "" (porque es tarjeta, no cuenta bancaria)
- `dig1` = "" (porque es tarjeta, no cuenta bancaria)

---

## ✅ ESCENARIO 4: Efectivo + Transferencia (Pago Mixto con Cuentas)
**Usuario selecciona:**
- Método 1: "01 Efectivo" + Cuenta "BBVA - 111222333444" ($3,000)
- Método 2: "03 Transferencia" + Cuenta "Santander - 555666777888" ($5,000)

### JSON enviado al backend:
```json
{
  "descripcio": "Carlos Ramírez Soto",
  "correo": "carlos.ramirez@email.com",
  "telefono": "5552468135",
  "direccion": "Blvd. Insurgentes #789, Col. Roma",
  
  "id_metodopago": 1,
  "banco1": "BBVA",
  "cuenta1": "111222333444",
  "dig1": "56",
  "terminal1": "",
  
  "observaciones": "Anticipo en efectivo, resto por transferencia",
  "estatus": 1,
  "total_pagar": 8000.00,
  "anticipo": 3000.00,
  "anticipo2": 5000.00,
  "anticipo3": 0.0,
  "id_cliente": 156,
  "entregado": 0,
  
  "id_metodopago2": 3,
  "banco2": "Santander",
  "cuenta2": "555666777888",
  "dig2": "34",
  "terminal2": "",
  
  "id_metodopago3": 0,
  "banco3": "",
  "cuenta3": "",
  "dig3": "",
  "terminal3": ""
}
```

**✅ Método 1 (Efectivo):**
- `banco1` = "BBVA"
- `cuenta1` = "111222333444"
- `dig1` = "56"
- `terminal1` = ""

**✅ Método 2 (Transferencia):**
- `banco2` = "Santander"
- `cuenta2` = "555666777888"
- `dig2` = "34"
- `terminal2` = ""

---

## ✅ ESCENARIO 5: Efectivo + Tarjeta de Crédito (Pago Mixto)
**Usuario selecciona:**
- Método 1: "01 Efectivo" + Cuenta "Banorte - 999888777666" ($7,000)
- Método 2: "04 Tarjeta de Crédito" + Terminal "TERM-001" ($8,000)

### JSON enviado al backend:
```json
{
  "descripcio": "Ana Martínez Flores",
  "correo": "ana.martinez@email.com",
  "telefono": "5553691470",
  "direccion": "Paseo de la Reforma #321, Col. Polanco",
  
  "id_metodopago": 1,
  "banco1": "Banorte",
  "cuenta1": "999888777666",
  "dig1": "78",
  "terminal1": "",
  
  "observaciones": "Anticipo efectivo, saldo con tarjeta",
  "estatus": 1,
  "total_pagar": 15000.00,
  "anticipo": 7000.00,
  "anticipo2": 8000.00,
  "anticipo3": 0.0,
  "id_cliente": 203,
  "entregado": 0,
  
  "id_metodopago2": 4,
  "banco2": "",
  "cuenta2": "",
  "dig2": "",
  "terminal2": "TERM-001",
  
  "id_metodopago3": 0,
  "banco3": "",
  "cuenta3": "",
  "dig3": "",
  "terminal3": ""
}
```

**✅ Método 1 (Efectivo):**
- `banco1` = "Banorte"
- `cuenta1` = "999888777666"
- `dig1` = "78"
- `terminal1` = ""

**✅ Método 2 (Tarjeta):**
- `banco2` = "" ← **VACÍO porque es tarjeta**
- `cuenta2` = "" ← **VACÍO porque es tarjeta**
- `dig2` = "" ← **VACÍO porque es tarjeta**
- `terminal2` = "TERM-001"

---

## ✅ ESCENARIO 6: Tres Métodos (Efectivo + Transferencia + Tarjeta)
**Usuario selecciona:**
- Método 1: "01 Efectivo" + Cuenta "HSBC - 123456789012" ($8,000)
- Método 2: "03 Transferencia" + Cuenta "Santander - 321098765432" ($7,000)
- Método 3: "04 Tarjeta de Crédito" + Terminal "TERM-002" ($5,000)

### JSON enviado al backend:
```json
{
  "descripcio": "Roberto González Díaz",
  "correo": "roberto.gonzalez@email.com",
  "telefono": "5557531590",
  "direccion": "Av. Universidad #654, Col. Del Valle",
  
  "id_metodopago": 1,
  "banco1": "HSBC",
  "cuenta1": "123456789012",
  "dig1": "90",
  "terminal1": "",
  
  "observaciones": "Pago en tres partes según acuerdo",
  "estatus": 1,
  "total_pagar": 20000.00,
  "anticipo": 8000.00,
  "anticipo2": 7000.00,
  "anticipo3": 5000.00,
  "id_cliente": 345,
  "entregado": 1,
  
  "id_metodopago2": 3,
  "banco2": "Santander",
  "cuenta2": "321098765432",
  "dig2": "45",
  "terminal2": "",
  
  "id_metodopago3": 4,
  "banco3": "",
  "cuenta3": "",
  "dig3": "",
  "terminal3": "TERM-002"
}
```

**✅ Método 1 (Efectivo):**
- `banco1` = "HSBC"
- `cuenta1` = "123456789012"
- `dig1` = "90"
- `terminal1` = ""

**✅ Método 2 (Transferencia):**
- `banco2` = "Santander"
- `cuenta2` = "321098765432"
- `dig2` = "45"
- `terminal2` = ""

**✅ Método 3 (Tarjeta):**
- `banco3` = "" ← **VACÍO porque es tarjeta**
- `cuenta3` = "" ← **VACÍO porque es tarjeta**
- `dig3` = "" ← **VACÍO porque es tarjeta**
- `terminal3` = "TERM-002"

---

## 🎯 REGLA DE ORO DEL MAPEO

### Para Efectivo (01) o Transferencia (03):
```dart
'banco1': cuenta1?.banco ?? '',      // ✅ Llenar con banco de la cuenta
'cuenta1': cuenta1?.cuenta ?? '',    // ✅ Llenar con número de cuenta
'dig1': cuenta1?.dig ?? '',          // ✅ Llenar con dígitos de verificación
'terminal1': '',                     // ❌ Siempre vacío
```

### Para Tarjeta de Crédito (04) o Débito (82):
```dart
'banco1': '',                        // ❌ Siempre vacío
'cuenta1': '',                       // ❌ Siempre vacío
'dig1': '',                          // ❌ Siempre vacío
'terminal1': terminal1?.id ?? '',    // ✅ Llenar con ID de terminal
```

---

## 📊 TABLA RESUMEN

| Método de Pago | banco1 | cuenta1 | dig1 | terminal1 |
|----------------|--------|---------|------|-----------|
| 01 Efectivo | ✅ Llenar | ✅ Llenar | ✅ Llenar | ❌ Vacío |
| 03 Transferencia | ✅ Llenar | ✅ Llenar | ✅ Llenar | ❌ Vacío |
| 04 Tarjeta Crédito | ❌ Vacío | ❌ Vacío | ❌ Vacío | ✅ Llenar |
| 82 Tarjeta Débito | ❌ Vacío | ❌ Vacío | ❌ Vacío | ✅ Llenar |

---

## ✅ CÓDIGO CORREGIDO

```dart
final data = {
  'id_metodopago': metodo1,
  // Si hay cuenta, llenar banco/cuenta/dig; si hay terminal, llenar solo terminal
  'banco1': cuenta1?.banco ?? '',      // Solo se llena si cuenta1 != null
  'cuenta1': cuenta1?.cuenta ?? '',    // Solo se llena si cuenta1 != null
  'dig1': cuenta1?.dig ?? '',          // Solo se llena si cuenta1 != null
  'terminal1': terminal1?.id ?? '',    // Solo se llena si terminal1 != null
  // ... mismo patrón para método 2 y 3
};
```

**Nota:** Los campos son mutuamente excluyentes. Si el usuario selecciona Efectivo/Transferencia, solo `cuenta1` tendrá valor (y por lo tanto solo `banco1`, `cuenta1`, `dig1` se llenarán). Si selecciona Tarjeta, solo `terminal1` tendrá valor.
