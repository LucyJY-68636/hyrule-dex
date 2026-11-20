# Hyrule Dex

Aplicación Flutter sencilla basada en la estructura de MiniPokedex, adaptada para consultar enemigos de **The Legend of Zelda: Tears of the Kingdom**.

## Funciones
- Inicio
- Catálogo de enemigos
- Búsqueda por nombre
- Detalle con descripción, ubicaciones y objetos que deja
- Favoritos (se conservan mientras la aplicación está abierta)
- Acerca de

## API
Hyrule Compendium API v3:
`https://api.hyrule-compendium.com/v3/compendium`

La lista consulta la categoría `monsters` con `game=2` (Tears of the Kingdom). El detalle también envía `game=2`.

## Ejecutar
Abre una terminal en la carpeta `hyrule_dex` y ejecuta:

```bash
flutter pub get
flutter run
```

## Antes de entregar
En `lib/main.dart`, reemplaza `Integrante 1` ... `Integrante 4` por los nombres reales del equipo.

## Nota
La API es un servicio externo. La disponibilidad y las imágenes dependen de que el servicio esté activo y de los datos publicados para cada entrada. Si una imagen no está disponible, la app muestra un icono de respaldo.
