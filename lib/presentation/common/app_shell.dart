import 'package:flutter/material.dart';
import 'kolshy_drawer.dart';
import 'nav_key.dart';

class AppShell extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final NavKey selected;
  final ValueChanged<NavKey> onSelect;

  final int bottomIndex;
  final ValueChanged<int> onBottomTap;

  final int unreadCount;
  final Future<void> Function() onOpenNotifications;
  final Widget child;

  const AppShell({
    super.key,
    required this.scaffoldKey,
    required this.selected,
    required this.onSelect,
    required this.bottomIndex,
    required this.onBottomTap,
    required this.unreadCount,
    required this.onOpenNotifications,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // removes the default menu icon
        toolbarHeight: 0, // hides the main AppBar height entirely
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: const BoxDecoration(color: Colors.black87),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TopBtn(
                  name: 'menu',
                  active: bottomIndex == 0,
                  onTap: () {
                    onBottomTap(0);
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
                _TopBtn(
                  name: 'home',
                  active: bottomIndex == 1,
                  onTap: () => onBottomTap(1),
                ),
                _TopBtn(
                  name: 'chat',
                  active: bottomIndex == 2,
                  onTap: () => onBottomTap(2),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _TopBtn(
                      name: 'bell',
                      active: bottomIndex == 3,
                      onTap: () async {
                        onBottomTap(3);
                        await onOpenNotifications();
                      },
                    ),
                    if (unreadCount > 0)
                      const Positioned(
                        right: 0,
                        top: 2,
                        child: _RedDot(),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        width: 320,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        backgroundColor: Colors.white,
        child: SafeArea(
          child: KolshyDrawer(selected: selected, onSelect: onSelect),
        ),
      ),
      body: child,
    );
  }
}

class _TopBtn extends StatelessWidget {
  final String name;
  final bool active;
  final VoidCallback onTap;

  const _TopBtn({
    required this.name,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(6), // smaller padding
        decoration: BoxDecoration(
          color: active ? Colors.white10 : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: active
              ? const [
            BoxShadow(
              blurRadius: 8,
              spreadRadius: 0.5,
              color: Colors.white24,
            ),
          ]
              : null,
        ),
        child: Image.asset(
          'assets/icons/$name.png',
          width: 20, // smaller icon size
          height: 20,
        ),
      ),
    );
  }
}

class _RedDot extends StatelessWidget {
  const _RedDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
    );
  }
}
