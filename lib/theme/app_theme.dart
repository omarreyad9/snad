import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Static, theme-independent bits of the Muse design system.
class MuseTheme {
  static const String sans = 'DM Sans';
  static const String serif = 'Playfair Display';

  static const Color success = Color(0xFF9EAA86);

  static Color? get inkDark => null;
}

/// Semantic colour tokens + the text styles / decorations built from them.
///
/// There is one light and one dark instance. Read the active one anywhere
/// with `context.mc`.
class MuseColors extends ThemeExtension<MuseColors> {
  final Color frame; // screen background
  final Color surface; // search box, icon buttons
  final Color panel; // raised panels (filter sheet)
  final Color navBar;
  final Color hairline; // dividers
  final Color outline; // input / pill borders
  final Color inputFill;
  final Color placeholder; // image loading / error background

  final Color textStrong;
  final Color textMid;
  final Color textMuted;
  final Color textFaint;

  final Color brand;
  final Color brandLight;
  final Color brandSoft;
  final Color brandAccent;
  final Color accentText;

  final Color avatar;
  final Color membership;
  final Color toastBg;
  final Color error;

  const MuseColors({
    required this.frame,
    required this.surface,
    required this.panel,
    required this.navBar,
    required this.hairline,
    required this.outline,
    required this.inputFill,
    required this.placeholder,
    required this.textStrong,
    required this.textMid,
    required this.textMuted,
    required this.textFaint,
    required this.brand,
    required this.brandLight,
    required this.brandSoft,
    required this.brandAccent,
    required this.accentText,
    required this.avatar,
    required this.membership,
    required this.toastBg,
    required this.error,
  });

  static const light = MuseColors(
    frame: Color(0xFFFAF9F7),
    surface: Color(0xFFF2EFEB),
    panel: Color(0xFFFFFFFF),
    navBar: Color(0xCCFFFFFF),
    hairline: Color(0xFFEEEAE5),
    outline: Color(0xFFE5DED7),
    inputFill: Color(0xFFFDFCFB),
    placeholder: Color(0xFFEEE9E2),
    textStrong: Color(0xFF332B26),
    textMid: Color(0xFF766D66),
    textMuted: Color(0xFF9C9287),
    textFaint: Color(0xFFB4AAA2),
    brand: Color(0xFF76523D),
    brandLight: Color(0xFF9B7962),
    brandSoft: Color(0xFF9C775D),
    brandAccent: Color(0xFFA47D56),
    accentText: Color(0xFF80604D),
    avatar: Color(0xFFC9B8A7),
    membership: Color(0xFF73513E),
    toastBg: Color(0xFF3D3028),
    error: Color(0xFFA95D4C),
  );

  static const dark = MuseColors(
    frame: Color(0xFF161311),
    surface: Color(0xFF241F1B),
    panel: Color(0xFF2B2521),
    navBar: Color(0xCC161311),
    hairline: Color(0xFF302A25),
    outline: Color(0xFF42392F),
    inputFill: Color(0xFF1E1A17),
    placeholder: Color(0xFF2A2420),
    textStrong: Color(0xFFF3ECE5),
    textMid: Color(0xFFC2B7AC),
    textMuted: Color(0xFF9A8F85),
    textFaint: Color(0xFF6E655D),
    brand: Color(0xFFA9785A),
    brandLight: Color(0xFFC9A58C),
    brandSoft: Color(0xFFBE957A),
    brandAccent: Color(0xFFCDA377),
    accentText: Color(0xFFD3AE92),
    avatar: Color(0xFF6B5646),
    membership: Color(0xFF5A3F30),
    toastBg: Color(0xFF4B3F37),
    error: Color(0xFFD2806E),
  );

  // ── Text styles ────────────────────────────────────────────
  TextStyle get eyebrow => TextStyle(
        fontFamily: MuseTheme.sans,
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.44,
        color: textMuted,
      );

  TextStyle get heroTitle => TextStyle(
        fontFamily: MuseTheme.serif,
        fontSize: 50,
        fontWeight: FontWeight.w500,
        letterSpacing: -2.75,
        height: 1.02,
        color: textStrong,
      );

  TextStyle get sectionTitle => TextStyle(
        fontFamily: MuseTheme.serif,
        fontSize: 25,
        fontWeight: FontWeight.w500,
        letterSpacing: -1.0,
        color: textStrong,
      );

  TextStyle get body => TextStyle(
        fontFamily: MuseTheme.sans,
        fontSize: 13,
        height: 1.6,
        color: textMuted,
      );

  // ── Decorations ────────────────────────────────────────────
  BoxDecoration get card => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
      );

  BoxDecoration get primaryButton => BoxDecoration(
        color: brand,
        borderRadius: BorderRadius.circular(10),
      );

  BoxDecoration get pill => BoxDecoration(
        border: Border.all(color: outline),
        borderRadius: BorderRadius.circular(20),
      );

  BoxDecoration get pillActive => BoxDecoration(
        color: brand,
        borderRadius: BorderRadius.circular(20),
      );

  BoxDecoration get membershipCard => BoxDecoration(
        color: membership,
        borderRadius: BorderRadius.circular(15),
      );

  BoxDecoration get toast => BoxDecoration(
        color: toastBg,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF32241C).withOpacity(0.2),
            blurRadius: 25,
            offset: const Offset(0, 9),
          ),
        ],
      );

  @override
  MuseColors copyWith() => this;

  @override
  MuseColors lerp(ThemeExtension<MuseColors>? other, double t) {
    if (other is! MuseColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return MuseColors(
      frame: l(frame, other.frame),
      surface: l(surface, other.surface),
      panel: l(panel, other.panel),
      navBar: l(navBar, other.navBar),
      hairline: l(hairline, other.hairline),
      outline: l(outline, other.outline),
      inputFill: l(inputFill, other.inputFill),
      placeholder: l(placeholder, other.placeholder),
      textStrong: l(textStrong, other.textStrong),
      textMid: l(textMid, other.textMid),
      textMuted: l(textMuted, other.textMuted),
      textFaint: l(textFaint, other.textFaint),
      brand: l(brand, other.brand),
      brandLight: l(brandLight, other.brandLight),
      brandSoft: l(brandSoft, other.brandSoft),
      brandAccent: l(brandAccent, other.brandAccent),
      accentText: l(accentText, other.accentText),
      avatar: l(avatar, other.avatar),
      membership: l(membership, other.membership),
      toastBg: l(toastBg, other.toastBg),
      error: l(error, other.error),
    );
  }
}

extension MuseContext on BuildContext {
  /// The Muse colour tokens for the current (light / dark) theme.
  MuseColors get mc => Theme.of(this).extension<MuseColors>() ?? MuseColors.light;
}

/// Builds the Material [ThemeData] for a brightness.
ThemeData buildMuseTheme(Brightness brightness) {
  final colors = brightness == Brightness.dark ? MuseColors.dark : MuseColors.light;
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.frame,
    fontFamily: MuseTheme.sans,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.brand,
      brightness: brightness,
    ).copyWith(surface: colors.frame),
    textSelectionTheme: TextSelectionThemeData(cursorColor: colors.brand),
    extensions: [colors],
  );
}

/// Persists the chosen theme mode (system / light / dark).
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  static const _key = 'muse_theme_mode';

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      value = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
    } catch (_) {
      // Keep the default if storage is unavailable.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {}
  }
}
