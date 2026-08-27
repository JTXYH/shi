# Shi

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

Shi es un asistente de limpieza del teclado y la pantalla para macOS. El modo de limpieza bloquea temporalmente el teclado y los clics del puntero, atenúa las pantallas y ofrece un atajo de salida claro para evitar acciones accidentales.

## Funciones

- Seis idiomas: chino simplificado, chino tradicional, inglés, japonés, coreano y español
- En el primer inicio usa el primer idioma preferido de macOS; la selección manual de Ajustes queda guardada
- Tres apariencias: Barrido, Blanco y Reloj nocturno
- Mantén pulsadas ambas teclas Shift, o Shift + Esc, para salir de forma segura
- Duración de pulsación, tiempo máximo de limpieza y bloqueo de clics configurables
- Actualizaciones firmadas mediante Sparkle 2
- Compilación Universal 2 para Apple Silicon e Intel Mac

## Requisitos

- macOS 14 o posterior
- El modo de limpieza requiere permiso en Ajustes del Sistema › Privacidad y seguridad › Accesibilidad

El permiso de Accesibilidad solo se usa para bloquear la entrada durante la limpieza. Shi no registra las teclas ni envía datos de uso. No realiza solicitudes de red, excepto la comprobación de actualizaciones mediante HTTPS.

## Descargar

[⬇️ Descargar la versión más reciente desde GitHub Releases](https://github.com/JTXYH/shi/releases/latest)

Extrae el ZIP y mueve `Shi.app` a la carpeta Aplicaciones.

### Si macOS bloquea el primer inicio

El paquete actual usa una firma ad-hoc y no está notarizado por Apple. Si macOS indica que no puede comprobar si la app contiene software malicioso o que no puede verificar al desarrollador, confirma primero que procede de los [GitHub Releases](https://github.com/JTXYH/shi/releases) de este repositorio y utiliza uno de estos métodos:

1. Abre Aplicaciones en Finder, haz Control-clic o clic derecho en `Shi.app`, elige Abrir y confirma Abrir otra vez.
2. O intenta iniciar la app una vez y después ve a Ajustes del Sistema › Privacidad y seguridad; en la sección Seguridad, elige Abrir igualmente.

No desactives Gatekeeper ni ejecutes comandos de Terminal de origen desconocido para omitir la protección. Si macOS detecta explícitamente software malicioso, elimina el archivo y vuelve a descargarlo desde el Release oficial.

Después de la primera autorización, Sparkle verifica e instala las actualizaciones mediante firmas Ed25519. Como las firmas ad-hoc no tienen un Team ID estable, macOS puede pedir que vuelvas a activar el permiso de Accesibilidad después de una actualización.

## Compilar desde el código fuente

Se necesita Xcode 16 o posterior. El proyecto fija Sparkle 2.9.2.

```sh
./scripts/build-app.sh debug
```

El resultado se genera en `dist/Shi.app`. De forma predeterminada se usa una firma ad-hoc y se vuelven a firmar la aplicación principal y todos los ejecutables de Sparkle incluidos.

## Publicación

El modelo de distribución actual coincide con Codex Meter: firma de código ad-hoc y firmas Sparkle Ed25519 para el archivo de actualización y el appcast. El script crea una aplicación Universal 2, verifica las firmas internas y genera el ZIP, SHA-256 y appcast.

```sh
./scripts/package-release.sh
```

Crea un GitHub Release `vX.Y.Z` y sube el ZIP, el archivo SHA-256 y `appcast.xml` generados. Si obtienes un Developer ID más adelante, el mismo script puede activar la firma oficial y la notarización de Apple.

Consulta [docs/releasing.md](docs/releasing.md) para ver el procedimiento completo.

## Diseño de seguridad

- Las compilaciones públicas actuales usan firma ad-hoc y no están notarizadas por Apple, por lo que Gatekeeper muestra un aviso en el primer inicio
- Actualizaciones Sparkle verificadas mediante HTTPS, appcast firmado y firmas Ed25519
- App Sandbox desactivado porque el bloqueo global de entrada necesita Accesibilidad fuera del sandbox
- Diagnósticos mediante macOS Unified Logging, sin archivos predecibles en `/tmp`
- Algunos Mac recurren a la interfaz privada DisplayServices, por lo que se requieren pruebas de regresión en las versiones de macOS de destino

Consulta [SECURITY.md](SECURITY.md) para informar de un problema de seguridad.

## Licencia

[MIT](LICENSE)
