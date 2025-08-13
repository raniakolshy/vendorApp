import 'package:flutter/material.dart';
import 'nav_key.dart';

class KolshyDrawer extends StatefulWidget {
  final NavKey selected;
  final ValueChanged<NavKey> onSelect;
  const KolshyDrawer({super.key, required this.selected, required this.onSelect});

  @override
  State<KolshyDrawer> createState() => _KolshyDrawerState();
}

class _KolshyDrawerState extends State<KolshyDrawer> {
  bool _productOpen = false;

  static const _iconBase = <NavKey, String>{
    NavKey.dashboard: 'dashboard',
    NavKey.orders: 'orders',
    NavKey.productAdd: 'product',
    NavKey.productList: 'product',
    NavKey.productDrafts: 'product',
    NavKey.analytics: 'analytics',
    NavKey.transactions: 'transactions',
    NavKey.revenue: 'revenue',
    NavKey.review: 'review',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
          child: Row(
            children: [
              // you said you didn't bring an X icon; use Material close icon
              IconButton(
                icon: const Icon(Icons.close, color: kIconGray),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              // use your GIF logo here too
              Image.asset(
                'assets/kolshy_logo_noir.gif',
                height: 30,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              _DrawerItem.asset(
                base: _iconBase[NavKey.dashboard]!,
                label: 'Dashboard',
                active: widget.selected == NavKey.dashboard,
                onTap: () => widget.onSelect(NavKey.dashboard),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.orders]!,
                label: 'Orders',
                active: widget.selected == NavKey.orders,
                onTap: () => widget.onSelect(NavKey.orders),
              ),
              _Expandable(
                label: 'Product',
                base: 'product',
                open: _productOpen,
                onTap: () => setState(() => _productOpen = !_productOpen),
                children: [
                  _Child(
                    label: 'Add product',
                    active: widget.selected == NavKey.productAdd,
                    onTap: () => widget.onSelect(NavKey.productAdd),
                  ),
                  _Child(
                    label: 'My product list',
                    active: widget.selected == NavKey.productList,
                    onTap: () => widget.onSelect(NavKey.productList),
                  ),
                  _Child(
                    label: 'Draft Product',
                    active: widget.selected == NavKey.productDrafts,
                    onTap: () => widget.onSelect(NavKey.productDrafts),
                  ),
                ],
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.analytics]!,
                label: 'Customer Analytics',
                active: widget.selected == NavKey.analytics,
                onTap: () => widget.onSelect(NavKey.analytics),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.transactions]!,
                label: 'Transactions',
                active: widget.selected == NavKey.transactions,
                onTap: () => widget.onSelect(NavKey.transactions),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.revenue]!,
                label: 'Revenue',
                trailing: const _RevenueBadge(6),
                active: widget.selected == NavKey.revenue,
                onTap: () => widget.onSelect(NavKey.revenue),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.review]!,
                label: 'Review',
                active: widget.selected == NavKey.review,
                onTap: () => widget.onSelect(NavKey.review),
              ),
              const SizedBox(height: 12),
              const Divider(color: kDividerGray, height: 24),
              const _ProfileButton(),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.download_for_offline_outlined, color: Colors.black45),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Install main application',
                          style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}

// drawer icon uses your "<name>_on.png" / "<name>_off.png"
class _AssetIcon extends StatelessWidget {
  final String base;
  final bool active;
  final double size;
  const _AssetIcon({required this.base, required this.active, this.size = 22});
  @override
  Widget build(BuildContext context) {
    final path = 'assets/icons/${base}_${active ? 'on' : 'off'}.png';
    return Image.asset(path, width: size, height: size);
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Widget? trailing;
  final String base;
  const _DrawerItem({
    required this.base,
    required this.label,
    required this.active,
    required this.onTap,
    this.trailing,
  });

  factory _DrawerItem.asset({
    required String base,
    required String label,
    required bool active,
    required VoidCallback onTap,
    Widget? trailing,
  }) =>
      _DrawerItem(base: base, label: label, active: active, onTap: onTap, trailing: trailing);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: active ? kDrawerActive : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _AssetIcon(base: base, active: active),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(color: kTextGray, fontWeight: FontWeight.w600),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Expandable extends StatelessWidget {
  final String label, base;
  final bool open;
  final VoidCallback onTap;
  final List<Widget> children;
  const _Expandable({
    required this.label,
    required this.base,
    required this.open,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: open ? kDrawerActive : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // you didn’t bring a dropdown icon – use Material chevron here
              const _AssetIcon(base: 'product', active: true),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: kTextGray, fontWeight: FontWeight.w600),
                ),
              ),
              AnimatedRotation(
                turns: open ? .5 : 0,
                duration: const Duration(milliseconds: 160),
                child: const Icon(Icons.expand_more_rounded, color: kIconGray),
              ),
            ],
          ),
        ),
      ),
      AnimatedCrossFade(
        crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 150),
        firstChild: const SizedBox.shrink(),
        secondChild: Column(children: children),
      ),
    ]);
  }
}

class _Child extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Child({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 38),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: active ? kDrawerActive : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(children: [
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: kTextGray,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _RevenueBadge extends StatelessWidget {
  final int count;
  const _RevenueBadge(this.count);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: kMutedOrange, borderRadius: BorderRadius.circular(10)),
    child: Text(
      '$count',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, height: 1),
    ),
  );
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showDialog(
        context: context,
        builder: (c) => SimpleDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          children: const [
            _PM('Profile Settings'),
            _PM('Print PDF'),
            _PM('Customer Dashboard'),
            _PM('Admin News'),
            _PM('Language'),
            Divider(),
            _PM('Ask for support'),
            Divider(),
            _PM('Log out', color: kRedLogout),
          ],
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/avatar_placeholder.jpg'),
              backgroundColor: Color(0xFFEDEDED),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Annette Black', style: TextStyle(fontWeight: FontWeight.w700, color: kTextGray)),
                  SizedBox(height: 2),
                  Text('Kolshy Store', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: kIconGray),
          ],
        ),
      ),
    );
  }
}

class _PM extends StatelessWidget {
  final String text;
  final Color color;
  const _PM(this.text, {this.color = kTextGray});
  @override
  Widget build(BuildContext context) => SimpleDialogOption(
    onPressed: () => Navigator.pop(context),
    child: Text(
      text,
      style: TextStyle(color: color, fontWeight: color == kRedLogout ? FontWeight.w700 : FontWeight.w500),
    ),
  );
}
