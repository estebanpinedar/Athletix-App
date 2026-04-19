# Escuela Deportiva Project

Sistema gestor de escuelas deportivas desarrollado en Flutter + Node.js + Turso.

## Notificaciones push

La integración base ya está hecha en app y backend. Para activarlas en un entorno real todavía debes completar estos secretos antes de desplegar:

1. Copia tu archivo de Firebase Android en `C:\escuela_deportiva_project\ade_deportiva\android\app\google-services.json`.
2. Verifica que el `package_name` de ese archivo coincida con `com.example.ade_deportiva` o actualiza `applicationId` y `namespace` en Android para que ambos sean iguales.
3. En el backend desplegado define `FIREBASE_SERVICE_ACCOUNT_JSON` con el JSON completo de la cuenta de servicio de Firebase Admin.

Hay ejemplos listos en:

- `C:\escuela_deportiva_project\ade_deportiva\android\app\google-services.json.example`
- `C:\escuela_deportiva_project\escuela_api\.env.example`

## Comandos pendientes en tu máquina

En este entorno no está instalado Flutter/Dart, así que no pude ejecutar estos pasos, pero el proyecto queda listo para correrlos:

```powershell
cd C:\escuela_deportiva_project\ade_deportiva
flutter pub get

cd C:\escuela_deportiva_project\escuela_api
npm install
```

Después de eso, vuelve a desplegar la app y la API con las credenciales reales de Firebase.
