import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// PALETA DE COLORES GLOBAL - Extraída de movie_detail, seat_selection y showtime_list
// ============================================================================
class AppColors {
  // Colores principales
  static const Color primary = Color(0xFF4F7DF3); // Azul principal
  static const Color secondary = Color(0xFFFF3B6D); // Rosa/Rojo secundario
  static const Color textPrimary = Color(0xFF1E2A47); // Texto principal oscuro

  // Fondos
  static const Color background = Colors.white;
  static const Color cardBackground = Colors.white;

  // Grises
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Texto
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Estados
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Asientos (específico para seat_selection)
  static const Color seatAvailable = Colors.white;
  static const Color seatSelected = Colors.black;
  static const Color seatOccupied = Color(0xFFBDBDBD);
}

// ============================================================================
// DIMENSIONES Y ESPACIADO
// ============================================================================
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 50.0; // Para botones circulares
}

// ============================================================================
// TEMA PRINCIPAL DE LA APLICACIÓN
// ============================================================================
final ThemeData appTheme = ThemeData(
  // Colores base
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.cardBackground,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    onError: Colors.white,
  ),

  // Tipografía - Google Fonts Poppins
  textTheme: TextTheme(
    // Títulos grandes
    displayLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),

    // Títulos
    headlineLarge: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // Títulos secundarios
    titleLarge: GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),

    // Cuerpo de texto
    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: AppColors.textPrimary,
    ),
    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: AppColors.textSecondary,
    ),

    // Etiquetas
    labelLarge: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    ),
  ),

  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.white, size: 20),
  ),

  // Botones elevados (principales)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      shadowColor: AppColors.primary.withOpacity(0.3),
    ),
  ),

  // Botones con borde (secundarios)
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
      side: BorderSide(color: AppColors.grey300, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),

  // Botones de texto
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  ),

  // Input/TextField
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: AppColors.grey300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: BorderSide(color: AppColors.grey300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    hintStyle: GoogleFonts.poppins(color: AppColors.textTertiary, fontSize: 14),
  ),

  // Cards
  cardTheme: CardThemeData(
    color: AppColors.cardBackground,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    margin: const EdgeInsets.all(AppSpacing.sm),
  ),

  // Chips (para filtros)
  chipTheme: ChipThemeData(
    backgroundColor: Colors.white,
    selectedColor: AppColors.primary,
    disabledColor: AppColors.grey200,
    labelStyle: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    secondaryLabelStyle: GoogleFonts.poppins(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: AppColors.grey300, width: 2),
    ),
    elevation: 0,
    pressElevation: 0,
  ),

  // Dialogs
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    ),
    titleTextStyle: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: GoogleFonts.poppins(
      fontSize: 14,
      color: AppColors.textSecondary,
    ),
  ),

  // SnackBar
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.textPrimary,
    contentTextStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
    ),
    behavior: SnackBarBehavior.floating,
  ),

  // Bottom Sheet
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    elevation: 8,
  ),

  // Divider
  dividerTheme: DividerThemeData(
    color: AppColors.grey300,
    thickness: 1,
    space: 1,
  ),

  // Icon Theme
  iconTheme: IconThemeData(color: AppColors.grey600, size: 24),

  // Progress Indicator
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primary,
  ),
);

// ============================================================================
// DECORACIONES REUTILIZABLES
// ============================================================================
class AppDecorations {
  // Botón circular semi-transparente (usado en AppBars)
  static BoxDecoration circularBackButton = BoxDecoration(
    color: Colors.white.withOpacity(0.3),
    shape: BoxShape.circle,
  );

  // Botón circular con borde
  static BoxDecoration circularButtonWithBorder = BoxDecoration(
    color: Colors.grey.withOpacity(0.2),
    shape: BoxShape.circle,
    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Degradado de fondo blur (para fondos con imagen)
  static BoxDecoration blurredGradientBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.02),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.7),
        Colors.white.withOpacity(0.95),
        Colors.white,
      ],
      stops: const [0.0, 0.25, 0.45, 0.65, 0.85, 1.0],
    ),
  );

  // Sombra para cards
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // Sombra para posters
  static List<BoxShadow> posterShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 40,
      offset: const Offset(0, 20),
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  // Container de formato/badge
  static BoxDecoration formatBadge({required bool isAvailable}) {
    return BoxDecoration(
      color: isAvailable ? Colors.white : AppColors.grey200,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      border: Border.all(color: AppColors.grey300),
    );
  }

  // Container de precio
  static BoxDecoration priceContainer = BoxDecoration(
    color: AppColors.grey100,
    borderRadius: BorderRadius.circular(AppRadius.xxl),
  );

  // Container para iconos con fondo colorido
  static BoxDecoration iconContainer({required Color color}) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppRadius.sm),
    );
  }

  // Chip de filtro seleccionado (idioma)
  static BoxDecoration selectedLanguageChip = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.primary, width: 2),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Chip de filtro no seleccionado
  static BoxDecoration unselectedChip = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.grey300, width: 2),
  );

  // Chip de fecha seleccionado
  static BoxDecoration selectedDateChip = BoxDecoration(
    color: AppColors.secondary.withOpacity(0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.secondary, width: 2),
  );
}

// ============================================================================
// ESTILOS DE TEXTO PERSONALIZADOS
// ============================================================================
class AppTextStyles {
  // Títulos de película
  static TextStyle movieTitle = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Subtítulos con ícono
  static TextStyle infoText = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.grey700,
    fontWeight: FontWeight.w500,
  );

  // Género en mayúsculas
  static TextStyle genreText = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.grey700,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  // Etiquetas de formato
  static TextStyle formatLabel({required bool isAvailable}) {
    return GoogleFonts.poppins(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: isAvailable ? AppColors.textPrimary : AppColors.grey400,
    );
  }

  // Precio
  static TextStyle price = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Colors.black,
  );

  // Encabezado de sección
  static TextStyle sectionHeader = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Chip de filtro seleccionado
  static TextStyle selectedChipText = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Chip de filtro no seleccionado
  static TextStyle unselectedChipText = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );
}
