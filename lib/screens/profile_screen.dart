import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import 'addresses_screen.dart';

/// Profile screen — avatar, membership card, settings links, sign out.
class ProfileScreen extends StatelessWidget {
  /// The signed-in Supabase user, or null when browsing as a guest.
  final User? user;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<String> onAction;
  final VoidCallback onSignOut;
  final VoidCallback onSignIn;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onAction,
    required this.onSignOut,
    required this.onSignIn,
  });

  /// Display name saved at sign-up, falling back to the email's local part.
  String get _name {
    final u = user;
    if (u == null) return 'Guest';
    final meta = u.userMetadata?['display_name']?.toString().trim() ?? '';
    if (meta.isNotEmpty) return meta;
    final email = u.email ?? '';
    return email.contains('@') ? email.split('@').first : 'Muse member';
  }

  String get _initials {
    final parts = _name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  static const _links = [
    ('Orders & returns', Icons.inventory_2_outlined, 'Your orders will appear here.'),
    ('Saved addresses', Icons.location_on_outlined, 'Address book is ready to connect.'),
    ('Payment methods', Icons.credit_card, 'Payment methods will be available at checkout.'),
    ('Preferences', Icons.settings_outlined, 'Preferences are saved for your next visit.'),
    ('Help center', Icons.help_outline, 'Help center is coming soon.'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero ──
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.mc.avatar,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: TextStyle(
                        fontFamily: MuseTheme.serif,
                        fontSize: 19,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user == null ? 'WELCOME' : 'WELCOME BACK', style: context.mc.eyebrow),
                      SizedBox(height: 4),
                      Text(
                        _name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MuseTheme.serif,
                          fontSize: 27,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -1.08,
                          color: context.mc.textStrong,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        user?.email ?? 'Sign in to see your account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: context.mc.textMuted),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: user == null
                      ? onSignIn
                      : () => onAction('Profile editing will be available soon.'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.mc.outline),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  ),
                  child: Text(user == null ? 'Sign in' : 'Edit', style: TextStyle(fontSize: 10, color: context.mc.accentText)),
                ),
              ],
            ),
          ),
          // ── Membership card ──
          Container(
            padding: EdgeInsets.all(22),
            decoration: context.mc.membershipCard,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MUSE MEMBER', style: TextStyle(fontSize: 9, letterSpacing: 1.44, color: Color(0xFFCDB9A9))),
                      SizedBox(height: 8),
                      Text(
                        'Quietly considered.',
                        style: TextStyle(
                          fontFamily: MuseTheme.serif,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 9),
                      Text(
                        "You're 2 orders away from a complimentary upgrade.",
                        style: TextStyle(fontSize: 10, height: 1.5, color: Color(0xFFD9C8BB)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '02',
                  style: TextStyle(
                    fontFamily: MuseTheme.serif,
                    fontSize: 44,
                    color: Color(0xFFBA9B84),
                  ),
                ),
              ],
            ),
          ),
          // ── Appearance ──
          SizedBox(height: 27),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('APPEARANCE', style: context.mc.eyebrow),
                SizedBox(height: 12),
                Row(
                  children: [
                    for (final option in [
                      (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
                      (ThemeMode.light, 'Light', Icons.light_mode_outlined),
                      (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                    ])
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: _ThemeChoice(
                          label: option.$2,
                          icon: option.$3,
                          selected: themeMode == option.$1,
                          onTap: () => onThemeChanged(option.$1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // ── Links ──
          SizedBox(height: 27),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.mc.hairline)),
            ),
            child: Column(
              children: _links.map((e) {
                final (label, icon, message) = e;
                return GestureDetector(
                  onTap: () {
                    if (label == 'Saved addresses') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AddressesScreen()),
                      );
                    } else {
                      onAction(message);
                    }
                  },
                  child: Container(
                    height: 58,
                    padding: EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: context.mc.hairline)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 18, color: context.mc.accentText),
                            SizedBox(width: 12),
                            Text(label, style: TextStyle(fontSize: 12, color: context.mc.textMid)),
                          ],
                        ),
                        Icon(Icons.chevron_right, size: 16, color: context.mc.textFaint),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // ── Sign out ──
          SizedBox(height: 28),
          GestureDetector(
            onTap: user == null ? onSignIn : onSignOut,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3),
              child: Text(user == null ? 'Sign in' : 'Sign out', style: TextStyle(fontSize: 11, color: context.mc.accentText)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.mc;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: selected ? c.pillActive : c.pill,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? Colors.white : c.textMid),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: selected ? Colors.white : c.textMid),
            ),
          ],
        ),
      ),
    );
  }
}