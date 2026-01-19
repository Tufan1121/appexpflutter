# 🧪 GUÍA DE PRUEBAS - ESCENARIOS DE PAGO

## 📋 Preparación

1. **Ejecuta la aplicación:**
   ```bash
   flutter run
   ```

2. **Inicia sesión:**
   - Usuario: `omar@protonmail.com`
   - Password: `x5sa/85w`

3. **Abre la consola de debug** para ver los logs

---

## 🎯 ESCENARIOS A PROBAR

### ✅ ESCENARIO 1: Solo Efectivo

**Pasos:**
1. Ve a "Generar Pedido"
2. Selecciona "01 Efectivo" en Método de Pago 1
3. Selecciona una cuenta del dropdown (ej: "BBVA - 012345678901")
4. Ingresa un monto (ej: $5000)
5. Presiona "GUARDAR"

**Salida esperada en consola:**
```
═══════════════════════════════════════════════════════════════
🚀 ENVIANDO PEDIDO AL BACKEND
═══════════════════════════════════════════════════════════════
💰 MÉTODO DE PAGO 1:
  ID Método: 1 (01 Efectivo)
  Banco: "BBVA"
  Cuenta: "012345678901"
  Dig: "89"
  Terminal: ""
  Anticipo: $5000.0
```

**✅ Verificar:**
- `banco1` tiene valor (nombre del banco)
- `cuenta1` tiene valor (número de cuenta)
- `dig1` tiene valor (dígitos de verificación)
- `terminal1` está vacío ("")

---

### ✅ ESCENARIO 2: Solo Transferencia

**Pasos:**
1. Ve a "Generar Pedido"
2. Selecciona "03 Transferencia Electrónica" en Método de Pago 1
3. Selecciona una cuenta del dropdown
4. Ingresa un monto (ej: $8000)
5. Presiona "GUARDAR"

**Salida esperada en consola:**
```
💰 MÉTODO DE PAGO 1:
  ID Método: 3 (03 Transferencia Electrónica)
  Banco: "Santander"
  Cuenta: "987654321098"
  Dig: "12"
  Terminal: ""
  Anticipo: $8000.0
```

**✅ Verificar:**
- `banco1` tiene valor
- `cuenta1` tiene valor
- `dig1` tiene valor
- `terminal1` está vacío ("")

---

### ✅ ESCENARIO 3: Solo Tarjeta de Crédito

**Pasos:**
1. Ve a "Generar Pedido"
2. Selecciona "04 Tarjeta de Crédito" en Método de Pago 1
3. Selecciona un terminal del dropdown (ej: "TERM-001")
4. Ingresa un monto (ej: $7500)
5. Presiona "GUARDAR"

**Salida esperada en consola:**
```
💰 MÉTODO DE PAGO 1:
  ID Método: 4 (04 Tarjeta de Crédito)
  Banco: "BBVA"
  Cuenta: "012345678901"
  Dig: "89"
  Terminal: "TERM-001"
  Anticipo: $7500.0
```

**✅ Verificar:**
- `banco1` tiene valor (del terminal)
- `cuenta1` tiene valor (del terminal)
- `dig1` tiene valor (del terminal)
- `terminal1` tiene valor ("TERM-001")

---

### ✅ ESCENARIO 4: Efectivo + Transferencia

**Pasos:**
1. Ve a "Generar Pedido"
2. **Método 1:** Selecciona "01 Efectivo" + Cuenta + $3000
3. **Método 2:** Selecciona "03 Transferencia" + Cuenta + $5000
4. Presiona "GUARDAR"

**Salida esperada en consola:**
```
💰 MÉTODO DE PAGO 1:
  ID Método: 1 (01 Efectivo)
  Banco: "BBVA"
  Cuenta: "111222333444"
  Dig: "56"
  Terminal: ""
  Anticipo: $3000.0

💳 MÉTODO DE PAGO 2:
  ID Método: 3 (03 Transferencia Electrónica)
  Banco: "Santander"
  Cuenta: "555666777888"
  Dig: "34"
  Terminal: ""
  Anticipo: $5000.0
```

**✅ Verificar:**
- Ambos métodos tienen `banco`, `cuenta`, `dig` llenos
- Ambos `terminal1` y `terminal2` están vacíos

---

### ✅ ESCENARIO 5: Efectivo + Tarjeta

**Pasos:**
1. Ve a "Generar Pedido"
2. **Método 1:** Selecciona "01 Efectivo" + Cuenta + $7000
3. **Método 2:** Selecciona "04 Tarjeta de Crédito" + Terminal + $8000
4. Presiona "GUARDAR"

**Salida esperada en consola:**
```
💰 MÉTODO DE PAGO 1:
  ID Método: 1 (01 Efectivo)
  Banco: "Banorte"
  Cuenta: "999888777666"
  Dig: "78"
  Terminal: ""
  Anticipo: $7000.0

💳 MÉTODO DE PAGO 2:
  ID Método: 4 (04 Tarjeta de Crédito)
  Banco: "BBVA"
  Cuenta: "012345678901"
  Dig: "89"
  Terminal: "TERM-001"
  Anticipo: $8000.0
```

**✅ Verificar:**
- Método 1: `banco1`, `cuenta1`, `dig1` llenos, `terminal1` vacío
- Método 2: `banco2`, `cuenta2`, `dig2` llenos (del terminal), `terminal2` lleno

---

### ✅ ESCENARIO 6: Tres Métodos (Efectivo + Transferencia + Tarjeta)

**Pasos:**
1. Ve a "Generar Pedido"
2. **Método 1:** "01 Efectivo" + Cuenta + $8000
3. **Método 2:** "03 Transferencia" + Cuenta + $7000
4. **Método 3:** "04 Tarjeta de Crédito" + Terminal + $5000
5. Presiona "GUARDAR"

**Salida esperada en consola:**
```
💰 MÉTODO DE PAGO 1:
  ID Método: 1 (01 Efectivo)
  Banco: "HSBC"
  Cuenta: "123456789012"
  Dig: "90"
  Terminal: ""
  Anticipo: $8000.0

💳 MÉTODO DE PAGO 2:
  ID Método: 3 (03 Transferencia Electrónica)
  Banco: "Santander"
  Cuenta: "321098765432"
  Dig: "45"
  Terminal: ""
  Anticipo: $7000.0

💵 MÉTODO DE PAGO 3:
  ID Método: 4 (04 Tarjeta de Crédito)
  Banco: "Banamex"
  Cuenta: "555444333222"
  Dig: "67"
  Terminal: "TERM-002"
  Anticipo: $5000.0
```

**✅ Verificar:**
- Los 3 métodos tienen `banco`, `cuenta`, `dig` llenos
- Solo método 3 tiene `terminal3` lleno
- Métodos 1 y 2 tienen `terminal` vacío

---

## 🔍 QUÉ BUSCAR EN LOS LOGS

### 1. **Logs de Endpoints (al cargar la pantalla):**
```
═══════════════════════════════════════════════════════════
DEBUG /cuentas/ - Respuesta completa:
[...]
DEBUG /cuentas/ - Campos del primer elemento:
  banco: BBVA (String)
  cuenta: 012345678901 (String)
  dig: 89 (String)
═══════════════════════════════════════════════════════════

═══════════════════════════════════════════════════════════
DEBUG /terminales/ - Respuesta completa:
[...]
DEBUG /terminales/ - Campos del primer elemento:
  terminal: TERM-001 (String)
  banco: BBVA (String)
  cuenta: 012345678901 (String)
  dig: 89 (String)
═══════════════════════════════════════════════════════════
```

**✅ Verificar:**
- Los endpoints devuelven los campos esperados
- Los tipos de datos son correctos (String)

### 2. **Logs de Envío (al presionar GUARDAR):**
```
═══════════════════════════════════════════════════════════
🚀 ENVIANDO PEDIDO AL BACKEND
═══════════════════════════════════════════════════════════
[... datos del pedido ...]
📝 JSON COMPLETO:
{descripcio: ..., correo: ..., banco1: BBVA, cuenta1: 012345678901, ...}
═══════════════════════════════════════════════════════════
```

**✅ Verificar:**
- Todos los campos requeridos están presentes
- Los valores son correctos según lo seleccionado
- No hay valores `null` donde no deberían estar

---

## 📸 CÓMO COMPARTIR LOS RESULTADOS

1. **Copia los logs de la consola** después de cada escenario
2. **Pégalos en un archivo de texto** o directamente en el chat
3. **Indica qué escenario probaste**

Ejemplo:
```
ESCENARIO 3: Solo Tarjeta de Crédito
═══════════════════════════════════════════════════════════
🚀 ENVIANDO PEDIDO AL BACKEND
[... pega aquí el log completo ...]
═══════════════════════════════════════════════════════════
```

---

## ⚠️ PROBLEMAS COMUNES

### ❌ Si `banco1`, `cuenta1`, `dig1` están vacíos cuando NO deberían:
- **Causa:** El endpoint no está devolviendo los datos correctos
- **Solución:** Revisa los logs de `/cuentas/` o `/terminales/`

### ❌ Si `terminal1` tiene valor cuando debería estar vacío:
- **Causa:** Error en la lógica de selección
- **Solución:** Verifica que seleccionaste "Cuenta" y no "Terminal"

### ❌ Si aparece error al guardar:
- **Causa:** El backend rechazó el JSON
- **Solución:** Copia el JSON completo del log y compártelo

---

## 🎯 OBJETIVO

Confirmar que en **TODOS** los escenarios:
1. ✅ `banco`, `cuenta`, `dig` SIEMPRE tienen valor (de cuenta o terminal)
2. ✅ `terminal` solo tiene valor cuando el método es Tarjeta
3. ✅ Los valores coinciden con lo seleccionado en la UI
