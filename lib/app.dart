
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/products.dart';
import 'screens/auth_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/brand_mark.dart';
import 'widgets/toast.dart';

enum _AppScreen { onboarding, welcome, auth, app }

/// Root widget — manages auth state, navigation, and shared app state.
class MuseApp extends StatefulWidget {
  const MuseApp({super.key});

  @override
  State<MuseApp> createState() => _MuseAppState();
}

class _MuseAppState extends State<MuseApp> {
  _AppScreen _screen = _AppScreen.onboarding;
  AppTab _activeTab = AppTab.discover;
  List<String> _savedIds = [];
  Product? _selectedProduct;
  List<Product> _products = [];
  bool _loadingProducts = true;
  String? _toast;
  Timer? _toastTimer;
  StreamSubscription? _authSub;
  final ThemeController _themeController = ThemeController();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _themeController.load();

    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    _user = supabase.auth.currentUser;
    if (session != null) {
      _screen = _AppScreen.app;
    }

    _authSub = supabase.auth.onAuthStateChange.listen((event) {
      if (!mounted) return;
      setState(() {
        // Always keep the signed-in user (email, name) in sync.
        _user = event.session?.user ?? supabase.auth.currentUser;
        if (event.session != null) _screen = _AppScreen.app;
      });
    });
  }

  Future<void> _loadProducts() async {
    final list = await fetchProducts();
    if (mounted) {
      setState(() {
        _products = list;
        _loadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _authSub?.cancel();
    _themeController.dispose();
    super.dispose();
  }

  void _toggleSaved(String id) {
    setState(() {
      if (_savedIds.contains(id)) {
        _savedIds = _savedIds.where((item) => item != id).toList();
      } else {
        _savedIds = [..._savedIds, id];
      }
    });
  }

  void _addToBag(Product product) {
    setState(() => _selectedProduct = null);
    _showToast('${product.name} added to your bag.');
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() => _toast = message);
    _toastTimer = Timer(Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      setState(() {
        _user = null;
        _screen = _AppScreen.welcome;
        _activeTab = AppTab.discover;
      });
      _showToast('You have been signed out.');
    } on AuthException catch (e) {
      if (mounted) _showToast(e.message);
    } catch (_) {
      if (mounted) _showToast('Unable to sign out. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeController,
      builder: (context, mode, _) => MaterialApp(
        title: 'muse',
        debugShowCheckedModeBanner: false,
        theme: buildMuseTheme(Brightness.light),
        darkTheme: buildMuseTheme(Brightness.dark),
        themeMode: mode,
        // Builder gives us a context that sits below MaterialApp's Theme.
        home: Builder(builder: _buildScreen),
      ),
    );
  }

  /// Flips between light and dark based on what is currently showing.
  void _toggleTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _themeController.setMode(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  Widget _buildScreen(BuildContext context) {
    switch (_screen) {
      case _AppScreen.onboarding:
        return OnboardingScreen(
          onCreateAccount: () {
            setState(() => _screen = _AppScreen.auth);
          },
          onExploreAsGuest: () {
            setState(() => _screen = _AppScreen.app);
          },
        );

      case _AppScreen.welcome:
        return WelcomeScreen(
          onStart: () => setState(() => _screen = _AppScreen.auth),
          onGuest: () => setState(() => _screen = _AppScreen.app),
        );

      case _AppScreen.auth:
        return AuthScreen(
          onBack: () => setState(() => _screen = _AppScreen.welcome),
          onSuccess: () => setState(() => _screen = _AppScreen.app),
        );

      case _AppScreen.app:
        return _buildMainApp(context);
    }
  }

  Widget _buildMainApp(BuildContext context) {
    Widget page;
    switch (_activeTab) {
      case AppTab.discover:
        page = _loadingProducts
            ? Center(child: CircularProgressIndicator())
            : DiscoverScreen(
                products: _products,
                savedIds: _savedIds,
                onToggleSaved: _toggleSaved,
                onOpen: (p) => setState(() => _selectedProduct = p),
              );
        break;
      case AppTab.profile:
        page = ProfileScreen(
          user: _user,
          themeMode: _themeController.value,
          onThemeChanged: _themeController.setMode,
          onAction: _showToast,
          onSignOut: _signOut,
          onSignIn: () => setState(() => _screen = _AppScreen.auth),
        );
        break;
    }

    return Scaffold(
      backgroundColor: context.mc.frame,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // ── Header ──
                Container(
                  height: 78,
                  padding: EdgeInsets.symmetric(horizontal: 28),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: context.mc.hairline),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BrandMark(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _showToast(
                              'Location is set to London, UK.',
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _StatusDot(),
                                SizedBox(width: 6),
                                Text(
                                  'London, UK',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.mc.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14),
                          GestureDetector(
                            onTap: () => _toggleTheme(context),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Theme.of(context).brightness == Brightness.dark
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                                size: 19,
                                color: context.mc.textMid,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ── Body ──
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Offstage(
                        offstage: _selectedProduct != null,
                        child: page,
                      ),
                      if (_selectedProduct != null)
                        ProductDetailScreen(
                          product: _selectedProduct!,
                          saved: _savedIds.contains(_selectedProduct!.id),
                          onBack: () =>
                              setState(() => _selectedProduct = null),
                          onToggleSaved: () =>
                              _toggleSaved(_selectedProduct!.id),
                          onAdd: () => _addToBag(_selectedProduct!),
                        ),
                    ],
                  ),
                ),
                // ── Bottom nav ──
                BottomNav(
                  active: _activeTab,
                  onChange: (tab) => setState(() => _activeTab = tab),
                ),
              ],
            ),
            if (_toast != null) Toast(message: _toast!),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: MuseTheme.success,
        shape: BoxShape.circle,
      ),
    );
  }
}
