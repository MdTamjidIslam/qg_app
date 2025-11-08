import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'home.dart';

class TopNavScaffold extends StatefulWidget {
  const TopNavScaffold({super.key});

  @override
  State<TopNavScaffold> createState() => _TopNavScaffoldState();
}

class _TopNavScaffoldState extends State<TopNavScaffold> {
  int _index = 0;
  final PageController _page = PageController();

  late final List<_TabMeta> _tabs = [
    _TabMeta(
      label: '首页',
      inactive: CupertinoIcons.house,
      active: CupertinoIcons.house_fill,
      page: HomePage(),
    ),
    _TabMeta(

      label: '视频',
      inactive: Icons.play_circle_outline,
      active: Icons.play_circle_filled_rounded,
      page:  _DemoPage(title: '青楼 · Favorites'),
    ),
    _TabMeta(
      label: '青楼',
      inactive: Icons.favorite_border,
      active: Icons.favorite,
      page: const _DemoPage(title: '青楼 · Favorites'),
    ),
    _TabMeta(
      label: '直播',
      inactive: Icons.live_tv_outlined,
      active: Icons.live_tv,
      page: const _DemoPage(title: '直播 · Live'),
    ),
    _TabMeta(
      label: '赚钱',
      inactiveWidget: const _TicketIcon(),
      activeWidget: const _TicketIcon(active: true),
      page: const _DemoPage(title: '赚钱 · Earn'),
    ),
  ];

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    setState(() => _index = i);
    _page.animateToPage(
      i,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Color(0xFFFF6DAF);
    const inactiveColor = Colors.grey;

    return Scaffold(
      // Main content with swipe
      body: PageView(
        controller: _page,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) => setState(() => _index = i),
        children: _tabs.map((t) => t.page).toList(),
      ),

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: _onTap,
        selectedItemColor: activeColor,
        unselectedItemColor: inactiveColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: List.generate(_tabs.length, (i) {
          final t = _tabs[i];
          return BottomNavigationBarItem(
            label: t.label,
            icon: t.iconWidget(
              size: 26,
              color: inactiveColor,
              selected: false,
            ),
            activeIcon: t.iconWidget(
              size: 26,
              color: activeColor,
              selected: true,
            ),
          );
        }),
      ),
    );
  }
}

class _TabMeta {
  final String label;
  final IconData? inactive;
  final IconData? active;
  final Widget? inactiveWidget;
  final Widget? activeWidget;
  final Widget page;

  const _TabMeta({
    required this.label,
    this.inactive,
    this.active,
    this.inactiveWidget,
    this.activeWidget,
    required this.page,
  }) : assert(
  // either icon pair OR widget pair
  ((inactive != null && active != null) && (inactiveWidget == null && activeWidget == null)) ||
      ((inactiveWidget != null && activeWidget != null) && (inactive == null && active == null)),
  'Provide either (inactive/active IconData) OR (inactive/active Widget).',
  );

  Widget iconWidget({required double size, required Color color, required bool selected}) {
    if (inactiveWidget != null || activeWidget != null) {
      return selected ? (activeWidget ?? inactiveWidget!) : (inactiveWidget ?? activeWidget!);
    }
    return Icon(selected ? active : inactive, size: size, color: color);
  }
}

/// Simple placeholder page for each tab
class _DemoPage extends StatelessWidget {
  final String title;
  const _DemoPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

/// Ticket icon with a ￥ mark (for “赚钱” tab)
class _TicketIcon extends StatelessWidget {
  final bool active;
  const _TicketIcon({this.active = false, super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = active ? Color(0xFFFF6DAF) : Colors.grey;
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 24, color: color),
          const Positioned(
            bottom: 6,
            child: Text('￥', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
