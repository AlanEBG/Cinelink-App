# Cinelink App 🎬

Aplicación de cine desarrollada en Flutter para gestión de películas, funciones y reserva de asientos.

## 📱 Características

- 🎥 Catálogo de películas con búsqueda y filtros
- 🎫 Visualización de horarios y funciones
- 💺 Selección de asientos virtual
- 📹 Reproductor de trailers de YouTube integrado
- 🎨 Diseño moderno inspirado en apps de cine premium
- ✨ Efecto blur cinematográfico de alta calidad con caché de imágenes

## 🚀 Instalación

```bash
# Clonar el repositorio
git clone <repository-url>

# Navegar al directorio
cd Cinelink-App

# Instalar dependencias
flutter pub get

# Ejecutar la app
flutter run
```

## ⚙️ Configuración del Backend

La app está configurada para conectarse a un backend NestJS:

```dart
// lib/app/constants.dart
static const String baseUrl = 'http://10.0.2.2:4000'; // Para emulador Android
```

### Para dispositivo físico:
Cambia la URL a tu IP local (ejemplo: `http://192.168.1.100:4000`)

## 📹 Reproducción de Trailers de YouTube

### ⚠️ IMPORTANTE: URL Válida Requerida

El campo `movieTrailer` en tu backend **DEBE** contener una URL válida de YouTube:

#### ✅ URLs Válidas:
```
https://www.youtube.com/watch?v=dQw4w9WgXcQ
https://youtu.be/dQw4w9WgXcQ
https://m.youtube.com/watch?v=dQw4w9WgXcQ
```

#### ❌ URLs Inválidas:
```
https://docs.flutter.dev/testing/errors
https://example.com/video.mp4
http://localhost/video
```

### 🔧 Ejemplo de configuración en Backend (NestJS):

```typescript
// Ejemplo de datos de película
const movie = {
  movieTitle: "Spider-Man: A Través del Spider-Verso",
  movieTrailer: "https://www.youtube.com/watch?v=shW9i6k8cB0", // URL real de YouTube
  movieImageUrl: "https://example.com/poster.jpg",
  movieDurationMinutes: 140,
  movieGenre: "ANIMACIÓN, ACCIÓN, AVENTURA",
  movieDescription: "Miles Morales viaja por múltiples universos...",
};
```

### 📝 Cómo obtener una URL de YouTube:

1. Ve a YouTube y busca el trailer de la película
2. Haz clic en el botón "Compartir"
3. Copia la URL (será algo como: `https://youtu.be/abc123`)
4. Guarda esta URL en el campo `movieTrailer` de tu base de datos

### 🐛 Solución de Problemas

#### El reproductor muestra un error:
- **Causa**: La URL no es de YouTube o es inválida
- **Solución**: Verifica que la URL sea de YouTube y esté en formato correcto

#### No se reproduce el video:
- Verifica conexión a Internet
- Asegúrate de que el video sea público (no privado ni eliminado)
- Comprueba que la URL funcione en un navegador

#### El video no está disponible:
- Algunos videos tienen restricciones regionales
- Videos con derechos de autor pueden no reproducirse en apps embebidas

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  dio: ^5.4.0
  provider: ^6.1.1
  google_fonts: ^6.1.0
  youtube_player_flutter: ^9.0.3  # Para reproducción de trailers
  cached_network_image: ^3.3.1    # Para caché y mejor rendimiento de imágenes
```

## 🎨 Características del Diseño

### Movie Detail Page:
- **Background con blur cinematográfico mejorado**:
  - Usa `ImageFiltered` con `ImageFilter.blur` (sigma 40x40)
  - `TileMode.decal` para bordes limpios sin repetición
  - Gradiente suave de 6 colores para transición perfecta
  - Caché de imágenes con `cached_network_image` para mejor rendimiento
- **Poster flotante con sombras múltiples**:
  - Sombra principal: blur 40, offset (0, 20), spread -5
  - Sombra secundaria: blur 20, offset (0, 10) para profundidad
- Badge de "Preventa" condicional
- Formatos de cine (4DX, IMAX, etc.)
- Botones de acción prominentes
- Reproductor de YouTube modal con bordes redondeados

### 🎨 Efecto Blur Mejorado

**Técnica utilizada:**
```dart
// ImageFiltered en lugar de BackdropFilter
ImageFiltered(
  imageFilter: ImageFilter.blur(
    sigmaX: 40,
    sigmaY: 40,
    tileMode: TileMode.decal, // Evita repetición en bordes
  ),
  child: CachedNetworkImage(...),
)
```

**Ventajas sobre BackdropFilter:**
- ✅ Blur más limpio y suave
- ✅ Sin artefactos en los bordes
- ✅ Mejor rendimiento con caché
- ✅ Menos pixelación
- ✅ Gradiente más natural (6 stops)

**Comparación:**
- **Antes**: BackdropFilter (sigma 30x30) con 4 stops
- **Después**: ImageFiltered (sigma 40x40, TileMode.decal) con 6 stops
- **Resultado**: Efecto cinematográfico premium similar a apps de Cinépolis/Cinemex

### Seat Selection:
- Sistema de asientos virtuales
- Generación basada en capacidad de sala
- Selección interactiva
- Validación en tiempo real

## 🔑 Permisos Requeridos

### Android (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Ya está configurado en el proyecto.

## 📱 Navegación de la App

```
MovieListPage
    ↓
MovieDetailPage (con reproductor de YouTube)
    ↓
ShowtimeListPage
    ↓
SeatSelectionPage
    ↓
Confirmación
```

## 🧪 Testing con Datos de Ejemplo

Para probar el reproductor de YouTube, asegúrate de que tu backend devuelva:

```json
{
  "movieId": 1,
  "movieTitle": "Película de Prueba",
  "movieTrailer": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "movieImageUrl": "https://image.tmdb.org/t/p/w500/poster.jpg",
  "movieDurationMinutes": 120,
  "movieGenre": "ACCIÓN",
  "movieDescription": "Descripción de prueba"
}
```

## 💡 Tips

1. **URLs de YouTube**: Siempre usa URLs completas de YouTube
2. **Testing**: Prueba las URLs en un navegador antes de usarlas
3. **Backend**: Asegúrate de que tu API esté corriendo antes de iniciar la app
4. **Emulador**: Usa `10.0.2.2` en lugar de `localhost`
5. **Dispositivo físico**: Usa tu IP local (ej: `192.168.1.100`)
6. **Imágenes**: Las imágenes se cachean automáticamente con `cached_network_image`
7. **Blur**: El efecto funciona mejor con imágenes de alta resolución (mínimo 1080p)

## 🛠️ Desarrollo

```bash
# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run

# Construir APK
flutter build apk --release

# Analizar código
flutter analyze
```

## 📚 Documentación Adicional

- Ver `IMPLEMENTACION.md` para detalles de implementación
- Revisar comentarios en el código para más información
- Consultar la documentación de Flutter: https://docs.flutter.dev/

## 🐛 Reporte de Errores

Si encuentras algún problema:
1. Verifica los logs de Flutter
2. Comprueba la conexión al backend
3. Revisa que las URLs de YouTube sean válidas
4. Asegúrate de tener permisos de Internet
5. Si las imágenes no cargan, limpia el caché: `flutter clean`

### Problemas comunes del blur:

**El blur se ve pixelado:**
- Solución: Asegúrate de usar imágenes de alta resolución
- La app ahora usa `ImageFiltered` con `TileMode.decal` para mejor calidad

**El fondo tiene bordes raros:**
- Ya está solucionado con `TileMode.decal` que evita repetición en bordes
- Si persiste, verifica que la imagen tenga buena resolución

## 📄 Licencia

Este proyecto es parte de un desarrollo académico/comercial.

---

**Desarrollado con ❤️ usando Flutter**
