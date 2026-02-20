import requests
import json
import urllib3

# Deshabilitar warnings de SSL
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Configuración
BASE_URL = "https://tapetestufan.mx:6002"
USERNAME = 
PASSWORD = 

print("=" * 60)
print("PROBANDO ENDPOINTS DE CUENTAS Y TERMINALES")
print("=" * 60)

# 1. Login
print("\n1. Haciendo login...")
login_data = {
    'grant_type': '',
    'username': USERNAME,
    'password': PASSWORD,
    'scope': '',
    'client_id': '',
    'client_secret': ''
}

try:
    response = requests.post(
        f"{BASE_URL}/token",
        data=login_data,
        headers={
            'Content-Type': 'application/x-www-form-urlencoded',
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        },
        timeout=15,
        verify=False
    )
    response.raise_for_status()
    
    token_data = response.json()
    access_token = token_data.get('access_token')
    
    print(f"✓ Login exitoso!")
    print(f"Token: {access_token[:50]}..." if access_token else "No token")
    
except Exception as e:
    print(f"✗ Error en login: {e}")
    exit(1)

# Headers con el token
headers = {
    'Authorization': f'Bearer {access_token}',
    'Content-Type': 'application/json'
}

# 2. Obtener Cuentas
print("\n2. Obteniendo cuentas...")
try:
    response = requests.get(
        f"{BASE_URL}/cuentas/",
        headers=headers,
        timeout=10,
        verify=False
    )
    response.raise_for_status()
    
    cuentas = response.json()
    print(f"✓ Se obtuvieron {len(cuentas)} cuentas")
    print("\nESTRUCTURA DE CUENTAS:")
    print(json.dumps(cuentas[:3] if len(cuentas) > 3 else cuentas, indent=2, ensure_ascii=False))
    
except Exception as e:
    print(f"✗ Error obteniendo cuentas: {e}")

# 3. Obtener Terminales
print("\n3. Obteniendo terminales...")
try:
    response = requests.get(
        f"{BASE_URL}/terminales/",
        headers=headers,
        timeout=10,
        verify=False
    )
    response.raise_for_status()
    
    terminales = response.json()
    print(f"✓ Se obtuvieron {len(terminales)} terminales")
    print("\nESTRUCTURA DE TERMINALES:")
    print(json.dumps(terminales[:3] if len(terminales) > 3 else terminales, indent=2, ensure_ascii=False))
    
except Exception as e:
    print(f"✗ Error obteniendo terminales: {e}")

print("\n" + "=" * 60)
print("ANÁLISIS COMPLETADO")
print("=" * 60)
