# Shi

[简体中文](README.md) | [繁體中文](README.zh-Hant.md) | [English](README.en.md) | [日本語](README.ja.md) | [한국어](README.ko.md) | [Español](README.es.md)

Shi es una herramienta gratuita y de código abierto para limpiar el teclado y la pantalla del Mac. El modo de limpieza bloquea temporalmente el teclado y, de forma predeterminada, los clics del trackpad y del ratón. También atenúa las pantallas para reducir las acciones accidentales mientras limpias. Al terminar, mantén pulsado el atajo de salida para volver a usar el Mac.

[Descargar la última versión](https://github.com/JTXYH/shi/releases/latest) · [Informar de un problema](https://github.com/JTXYH/shi/issues) · [Licencia MIT](LICENSE)

## Funciones

- **Pausa de la entrada durante la limpieza**: bloquea el teclado y permite elegir si también se bloquean los clics del trackpad y del ratón.
- **Tres apariencias**: Barrido, Blanco y Reloj nocturno, con una pantalla de limpieza en cada monitor.
- **Atenuación y restauración de la pantalla**: atenúa las pantallas durante la limpieza y las restaura al salir; el resultado depende del monitor y de la compatibilidad con macOS.
- **Atajos para empezar y salir**: con la app en ejecución, pulsa `Control + Option + Command + C` para empezar; mantén pulsadas ambas teclas `Shift` o `Shift + Esc` para salir.
- **Tiempos configurables**: ajusta la duración de la pulsación para salir y el tiempo de finalización automática de la limpieza.
- **Seis idiomas**: chino simplificado, chino tradicional, inglés, japonés, coreano y español.
- **Actualizaciones desde la app**: busca actualizaciones y verifica sus firmas con Sparkle.

## Capturas de pantalla

<p align="center">
  <img src="docs/images/screenshots/main-window.png" alt="Ventana principal de Shi" width="560">
</p>

<p align="center">
  <img src="docs/images/screenshots/cleaning-wipe.png" alt="Pantalla de limpieza Barrido" width="31%">
  <img src="docs/images/screenshots/cleaning-white.png" alt="Pantalla de limpieza Blanco" width="31%">
  <img src="docs/images/screenshots/cleaning-night-clock.png" alt="Pantalla de limpieza Reloj nocturno" width="31%">
</p>

<p align="center"><sub>Barrido · Blanco · Reloj nocturno</sub></p>

## Requisitos

- macOS 14 Sonoma o posterior.
- Un Mac con Apple Silicon o Intel. La compilación produce una app Universal 2.
- Permiso de Accesibilidad de macOS para el modo de limpieza.

## Instalación

1. Descarga el ZIP de la aplicación desde [GitHub Releases](https://github.com/JTXYH/shi/releases/latest).
2. Descomprímelo y mueve `Shi.app` a la carpeta Aplicaciones.
3. Abre la app y sigue los pasos de uso que aparecen a continuación.

La distribución predeterminada actual utiliza una firma ad-hoc y no está notarizada por Apple. Si al abrirla por primera vez macOS indica que no puede verificar al desarrollador o comprobar si contiene software malicioso, confirma que el archivo procede de este repositorio y no ha sido modificado. Después, sigue las [instrucciones de Apple para abrir la app](https://support.apple.com/en-us/102445). No ignores una detección explícita de malware.

## Uso

1. Abre Shi, elige una apariencia y pulsa **Empezar a limpiar**. También puedes usar `Control + Option + Command + C` mientras la app está en ejecución.
2. La primera vez, sigue las indicaciones para activar Shi en **Ajustes del Sistema › Privacidad y seguridad › Accesibilidad**. Si no aparece, añade `Shi.app` con el botón `+`. **La limpieza comienza automáticamente al conceder el permiso.**
3. Al terminar, mantén pulsadas las teclas `Shift` izquierda y derecha, o `Shift + Esc`. La duración predeterminada es de **1,5 segundos**; al salir se restauran la entrada y el brillo de las pantallas.

En Ajustes puedes cambiar estas opciones:

| Ajuste | Valor predeterminado | Opciones |
| --- | --- | --- |
| Duración de la pulsación para salir | 1,5 segundos | 1, 1,5 o 2 segundos |
| Tiempo máximo de limpieza | 10 minutos | 5 minutos, 10 minutos o sin finalización automática |
| Bloquear clics del trackpad y del ratón | Activado | Activado o desactivado |

En el primer inicio se utiliza el primer idioma preferido de macOS; si no es compatible, se usa el inglés. El idioma elegido manualmente se guarda en el Mac.

El botón de encendido y Touch ID no se pueden bloquear. Usa la pantalla de bloqueo de macOS cuando te ausentes.

## Permisos, privacidad y actualizaciones

- El permiso de Accesibilidad permite interceptar el teclado durante el modo de limpieza. Shi no registra las pulsaciones ni recopila estadísticas de uso; las preferencias se guardan en el Mac.
- La limpieza funciona sin conexión y no requiere una cuenta. Buscar y descargar actualizaciones requiere conexión a la red.
- Las compilaciones de distribución obtienen la información de actualización mediante HTTPS y verifican el appcast y el archivo de actualización con firmas Ed25519 de Sparkle. Puedes buscar actualizaciones desde Ajustes; esta función está desactivada en las compilaciones de depuración.
- Después de actualizar o recompilar una app con firma ad-hoc, macOS puede volver a pedir el permiso de Accesibilidad. Si la limpieza no empieza, vuelve a activar Shi en la lista de Accesibilidad.

Comunica las vulnerabilidades de forma privada siguiendo la [política de seguridad](SECURITY.md).

## Compilar desde el código fuente

Para desarrollar se necesita macOS y Xcode 16 o posterior, con las herramientas de línea de comandos configuradas para usar esa instalación de Xcode. El proyecto utiliza Swift, SwiftUI y AppKit, e incorpora [Sparkle](https://github.com/sparkle-project/Sparkle) mediante Swift Package Manager, actualmente fijado en la versión 2.9.2. La primera compilación necesita conexión a la red para descargar las dependencias.

```sh
git clone https://github.com/JTXYH/shi.git
cd shi
./scripts/build-app.sh debug
open dist/Shi.app
```

El script genera `dist/Shi.app` con las arquitecturas `arm64` y `x86_64`. Utiliza una firma ad-hoc de forma predeterminada, por lo que compilar localmente no requiere un certificado Developer ID. También puedes abrir `Shi.xcodeproj` en Xcode y seleccionar el esquema `Shi` para desarrollar y depurar.

Ejecuta las comprobaciones existentes de selección de idioma desde la raíz del repositorio:

```sh
./scripts/test-language-selection.sh
```

Estas comprobaciones cubren la detección del idioma del sistema y la prioridad del idioma guardado. La limpieza, los permisos y el comportamiento de las pantallas deben probarse en un Mac real.

## Contribuir

Puedes enviar informes de errores, mejoras y traducciones mediante [Issues](https://github.com/JTXYH/shi/issues) y [Pull Requests](https://github.com/JTXYH/shi/pulls).

- Al informar de un error, incluye la versión de la app, la versión de macOS, el modelo de Mac, los pasos para reproducirlo y el resultado esperado. Para problemas visuales, añade la configuración de los monitores.
- Explica el motivo del cambio y cómo lo has verificado. Adjunta capturas si modificas la interfaz y prueba en un Mac real los cambios relacionados con el bloqueo de entrada, la salida o el brillo.
- Mantén sincronizados los seis README al actualizar las funciones o las traducciones. Los textos de la app están en [Shi/Localization.swift](Shi/Localization.swift).

## Licencia

Proyecto mantenido por [JTXYH](https://github.com/JTXYH) y distribuido bajo la [licencia MIT](LICENSE). Las dependencias de terceros conservan sus respectivas licencias.
