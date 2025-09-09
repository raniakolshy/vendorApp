import 'package:app_vendor/l10n/app_localizations.dart';
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
  final Widget child;

  const AppShell({
    super.key,
    required this.scaffoldKey,
    required this.selected,
    required this.onSelect,
    required this.bottomIndex,
    required this.onBottomTap,
    required this.unreadCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
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
                  name: loc.menu,
                  icon: 'menu',
                  active: bottomIndex == 0,
                  onTap: () {
                    onBottomTap(0);
                    scaffoldKey.currentState?.openDrawer();
                  },
                ),
                _TopBtn(
                  name: loc.home,
                  icon: 'home',
                  active: bottomIndex == 1,
                  onTap: () => onBottomTap(1),
                ),
                _TopBtn(
                  name: loc.chat,
                  icon: 'chat',
                  active: bottomIndex == 2,
                  onTap: () => onBottomTap(2),
                ),
                // Bell + popover
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _TopBtn(
                      name: loc.notifications,
                      icon: 'bell',
                      active: bottomIndex == 3,
                      onTap: () {
                        onBottomTap(3);
                        _showNotificationsPopover(context);
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

  // ---- Popover ----
  void _showNotificationsPopover(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: loc.notifications,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, __) {
        return Stack(
          children: [
            // tap outside to close
            Positioned.fill(
              child: GestureDetector(onTap: () => Navigator.pop(ctx)),
            ),
            Positioned(
              right: 12,
              top: 62,
              child: FadeTransition(
                opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.05),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: anim,
                    curve: Curves.easeOut,
                  )),
                  child: const _NotificationsCard(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ----------------- Top bar pieces -----------------

class _TopBtn extends StatelessWidget {
  final String name;
  final String icon;
  final bool active;
  final VoidCallback onTap;

  const _TopBtn({
    required this.name,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip( // <-- accessibilité multi-langue
      message: name,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
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
            'assets/icons/$icon.png',
            width: 18,
            height: 18,
          ),
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

// ----------------- Notifications popover -----------------

class _NotificationsCard extends StatefulWidget {
  const _NotificationsCard();

  @override
  State<_NotificationsCard> createState() => _NotificationsCardState();
}

class _NotificationsCardState extends State<_NotificationsCard> {
  final List<_NotifData> _items = [
    _NotifData(
      avatar: 'assets/avatar1.png',
      name: 'Kristin Watson',
      handleAndTime: 'alexandeun • 23m',
      line1: 'Rate ⭐ 5 for 3D soothing wallp…',
      unread: true,
    ),
    _NotifData(
      avatar: 'assets/avatar2.png',
      name: 'Leslie Alexander',
      handleAndTime: 'flores • Aug 15',
      line1: 'Likes 3D computer improved ve…',
      unread: true,
    ),
    _NotifData(
      avatar: 'assets/avatar3.png',
      name: 'Annette Black',
      handleAndTime: 'edwards • Apr 11',
      line1: 'Comment on Gray vintage 3D co…',
      unread: false,
    ),
    _NotifData(
      avatar: 'assets/avatar4.png',
      name: 'Brooklyn Simmons',
      handleAndTime: 'cooper • YD',
      line1: 'Purchased 3D dark mode wallp…',
      unread: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 310,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    loc.notifications,
                    style: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2F32),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black45),
                    splashRadius: 18,
                  ),
                ],
              ),
              // Scrollable list with swipe-to-remove
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final data = _items[index];
                    return Dismissible(
                      key: ValueKey('${data.name}_${data.line1}_$index'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        setState(() {
                          _items.removeAt(index);
                        });
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red.withOpacity(0.85),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: _NotifTile(
                        avatar: data.avatar,
                        name: data.name,
                        handleAndTime: data.handleAndTime,
                        line1: data.line1,
                        unread: data.unread,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Data model
class _NotifData {
  final String avatar, name, handleAndTime, line1;
  final bool unread;
  _NotifData({
    required this.avatar,
    required this.name,
    required this.handleAndTime,
    required this.line1,
    required this.unread,
  });
}

// A single notification row (with avatar, text, unread dot)
class _NotifTile extends StatelessWidget {
  final String avatar;
  final String name;
  final String handleAndTime;
  final String line1;
  final bool unread;

  const _NotifTile({
    required this.avatar,
    required this.name,
    required this.handleAndTime,
    required this.line1,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage(avatar),
            backgroundColor: const Color(0xFFEAECEE),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + meta
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E2F32),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      handleAndTime,
                      style: text.bodySmall?.copyWith(
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  line1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // blue unread dot
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: unread ? const Color(0xFF2F80ED) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}