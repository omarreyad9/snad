import 'package:flutter/material.dart';
import 'package:muse/theme/app_theme.dart';

enum AppTab { discover, profile }

/// Bottom navigation bar with 2 tabs — mirrors the web BottomNav.
class BottomNav extends StatelessWidget {
  final AppTab active;
  final ValueChanged<AppTab> onChange;

  const BottomNav({
    super.key,
    required this.active,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color: context.mc.navBar,
        border: Border(
          top: BorderSide(color: context.mc.hairline),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: AppTab.values.map((tab) {
            final isActive = active == tab;
            final icon = _iconFor(tab);
            return GestureDetector(
              onTap: () => onChange(tab),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 72,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            icon,
                            size: 19,
                            color: isActive
                                ? context.mc.brand
                                : context.mc.textFaint,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _labelFor(tab),
                      style: TextStyle(
                        fontFamily: MuseTheme.sans,
                        fontSize: 9,
                        color: isActive
                            ? context.mc.brand
                            : context.mc.textFaint,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _iconFor(AppTab tab) {
    return switch (tab) {
      AppTab.discover => Icons.home_outlined,
      AppTab.profile => Icons.person_outline,
    };
  }

  String _labelFor(AppTab tab) {
    return switch (tab) {
      AppTab.discover => 'Discover',
      AppTab.profile => 'Profile',
    };
  }
}
