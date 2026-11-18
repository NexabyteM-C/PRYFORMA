import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';

class AdminNavItem {
  const AdminNavItem({
    required this.route,
    required this.label,
    required this.icon,
  });

  final String route;
  final String label;
  final Widget icon;
}

class AdminShell extends StatelessWidget {
  const AdminShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.organizationName,
    required this.onNavigate,
    required this.items,
  });

  final Widget child;
  final String currentRoute;
  final String organizationName;
  final ValueChanged<String> onNavigate;
  final List<AdminNavItem> items;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    // Wide screens: persistent sidebar.
    if (width >= 768) {
      return Material(
        color: FitColors.background,
        child: Row(
          children: [
            _Sidebar(
              width: 240,
              collapsed: false,
              organizationName: organizationName,
              currentRoute: currentRoute,
              onNavigate: onNavigate,
              items: items,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Mobile: app bar + drawer, content full width.
    final initial = organizationName.isNotEmpty ? organizationName[0] : '?';
    return Scaffold(
      backgroundColor: FitColors.background,
      appBar: AppBar(
        backgroundColor: FitColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: FitColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  fontFamily: 'Space Grotesk',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                organizationName,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        backgroundColor: FitColors.primaryDark,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                child: Text(
                  organizationName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'Panel de administración',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFFC9D8FF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: items
                      .map((item) => _NavTile(
                            item: item,
                            active: currentRoute == item.route,
                            onTap: () {
                              Navigator.of(context).pop();
                              onNavigate(item.route);
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.active, required this.onTap});
  final AdminNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : const Color(0xFFDCE6FF);
    final radius = BorderRadius.circular(FitRadii.lg);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: active ? FitColors.primary : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                IconTheme(data: IconThemeData(color: fg, size: 20), child: item.icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.width,
    required this.collapsed,
    required this.organizationName,
    required this.currentRoute,
    required this.onNavigate,
    required this.items,
  });

  final double width;
  final bool collapsed;
  final String organizationName;
  final String currentRoute;
  final ValueChanged<String> onNavigate;
  final List<AdminNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: FitColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          ...items.map(_buildNavItem),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final initial = organizationName.isNotEmpty ? organizationName[0] : '?';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: FitColors.primary,
              borderRadius: BorderRadius.circular(FitRadii.lg),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                fontFamily: 'Space Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizationName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Panel de coach',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Color(0xFFC9D8FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(AdminNavItem item) {
    final active = currentRoute == item.route;
    final bg = active ? FitColors.primary : Colors.transparent;
    final fg = active ? Colors.white : const Color(0xFFDCE6FF);
    final weight = active ? FontWeight.w600 : FontWeight.w500;
    final radius = BorderRadius.circular(FitRadii.lg);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          onTap: () => onNavigate(item.route),
          borderRadius: radius,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconTheme(
                  data: IconThemeData(color: fg, size: 18),
                  child: item.icon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: weight,
                      color: fg,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
