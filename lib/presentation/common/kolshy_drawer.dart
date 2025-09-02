import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../Translation/Language.dart';
import '../admin/admin_news_screen.dart';
import '../admin/ask_admin_screen.dart';
import '../analytics/customer_analytics_screen.dart';
import '../auth/login/welcome_screen.dart';
import '../pdf/print_pdf_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'nav_key.dart';


/// ---- theme constants (delete if you already have these) ----
const kIconGray = Color(0xFF8E9196);
const kTextGray = Color(0xFF2E2F32);
const kDividerGray = Color(0xFFE7E8EA);
const kDrawerActive = Color(0xFFF4F5F7);
const kMutedOrange = Color(0xFFFF8A00);
const kRedLogout = Color(0xFFE64949);
/// -----------------------------------------------------------

class KolshyDrawer extends StatefulWidget {
  final NavKey selected;
  final ValueChanged<NavKey> onSelect;

  const KolshyDrawer({
    super.key,
    required this.selected,
    required this.onSelect,
  });

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
              IconButton(
                icon: const Icon(Icons.close, color: kIconGray),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
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
                label: AppLocalizations.of(context)!.dashboard,
                active: widget.selected == NavKey.dashboard,
                onTap: () => widget.onSelect(NavKey.dashboard),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.orders]!,
                label: AppLocalizations.of(context)!.orders,
                active: widget.selected == NavKey.orders,
                onTap: () => widget.onSelect(NavKey.orders),
              ),
              _Expandable(
                label: AppLocalizations.of(context)!.product,
                base: 'product',
                open: _productOpen,
                onTap: () => setState(() => _productOpen = !_productOpen),
                children: [
                  _Child(
                    label: AppLocalizations.of(context)!.addProduct,
                    active: widget.selected == NavKey.productAdd,
                    onTap: () => widget.onSelect(NavKey.productAdd),
                  ),
                  _Child(
                    label: AppLocalizations.of(context)!.myProductList,
                    active: widget.selected == NavKey.productList,
                    onTap: () => widget.onSelect(NavKey.productList),
                  ),
                  _Child(
                    label: AppLocalizations.of(context)!.draftProduct,
                    active: widget.selected == NavKey.productDrafts,
                    onTap: () => widget.onSelect(NavKey.productDrafts),
                  ),
                ],
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.analytics]!,
                label: AppLocalizations.of(context)!.customerAnalytics,
                active: widget.selected == NavKey.analytics,
                onTap: () => widget.onSelect(NavKey.analytics),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.transactions]!,
                label: AppLocalizations.of(context)!.transactions,
                active: widget.selected == NavKey.transactions,
                onTap: () => widget.onSelect(NavKey.transactions),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.revenue]!,
                label: AppLocalizations.of(context)!.revenue,
                trailing: const _RevenueBadge(6),
                active: widget.selected == NavKey.revenue,
                onTap: () => widget.onSelect(NavKey.revenue),
              ),
              _DrawerItem.asset(
                base: _iconBase[NavKey.review]!,
                label: AppLocalizations.of(context)!.review,
                active: widget.selected == NavKey.review,
                onTap: () => widget.onSelect(NavKey.review),
              ),
              const SizedBox(height: 12),
              const Divider(color: kDividerGray, height: 24),

              // Profile row → opens figma-style popup
              _ProfileButton(onSelect: widget.onSelect),

              // Extra CTA
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.download_for_offline_outlined,
                          color: Colors.black45),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.installmainapplication,
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.w600),
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

// drawer icon uses "<name>_on.png" / "<name>_off.png"
class _AssetIcon extends StatelessWidget {
  final String base;
  final bool active;
  final double size;
  const _AssetIcon({
    required this.base,
    required this.active,
    this.size = 22,
  });
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
      _DrawerItem(
        base: base,
        label: label,
        active: active,
        onTap: onTap,
        trailing: trailing,
      );

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
                style: const TextStyle(
                  color: kTextGray,
                  fontWeight: FontWeight.w600,
                ),
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
    return Column(
      children: [
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
                const _AssetIcon(base: 'product', active: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: kTextGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: open ? .5 : 0,

                  duration: const Duration(milliseconds: 160),
                  child:
                  const Icon(Icons.expand_more_rounded, color: kIconGray),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          crossFadeState:
          open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 150),
          firstChild: const SizedBox.shrink(),
          secondChild: Column(children: children),
        ),
      ],
    );
  }
}

class _Child extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Child({
    required this.label,
    required this.active,
    required this.onTap,
  });
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
          child: Row(
            children: [
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
            ],
          ),
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
    decoration: BoxDecoration(
      color: kMutedOrange,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      '$count',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        height: 1,
      ),
    ),
  );
}

class _ProfileButton extends StatelessWidget {
  final ValueChanged<NavKey> onSelect;

  const _ProfileButton({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(.25),
        builder: (_) => _ProfileMenuDialog(onSelect: onSelect),
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
                  Text('Annette Black',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, color: kTextGray)),
                  SizedBox(height: 2),
                  Text('Kolshy Store',
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 12)),
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

class _ProfileMenuDialog extends StatelessWidget {
  final ValueChanged<NavKey> onSelect;

  const _ProfileMenuDialog({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 20,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuRow(
                icon: Icons.person_outline,
                label: AppLocalizations.of(context)!.profileSettings,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(NavKey.profileSettings);
                },
              ),

              const _DividerLine(),

              _MenuRow(
                icon: Icons.picture_as_pdf_outlined,
                label: AppLocalizations.of(context)!.printPDF,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(NavKey.printPdf);
                },
              ),
              _MenuRow(
                icon: Icons.article_outlined,
                label: AppLocalizations.of(context)!.adminNews,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(NavKey.adminNews);
                },
              ),
              _MenuRow(
                icon: Icons.translate_outlined,
                label: AppLocalizations.of(context)!.language,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(NavKey.language);
                },
              ),

              const _DividerLine(),
              _MenuRow(
                icon: Icons.support_agent_outlined,
                label: AppLocalizations.of(context)!.askForSupport,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(NavKey.askadmin);
                },
              ),

              // Destructive action
              // In your drawer file, update the logout section:
              InkWell(
                onTap: () async {
                  Navigator.pop(context);

                  // Show confirmation dialog
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.logout),
                        content: Text(AppLocalizations.of(context)!.confirmLogout),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(AppLocalizations.of(context)!.logout),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    try {
                      // Call the logout API
                      await ApiClient().logout();

                      // Navigate to welcome screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                            (route) => false,
                      );

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.logoutSuccessful),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${AppLocalizations.of(context)!.logoutFailed}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                  child: Text(
                    AppLocalizations.of(context)!.logout,
                    style: TextStyle(
                      color: kRedLogout,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.black45),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: kTextGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        thickness: 1,
        color: kDividerGray,
      ),
    );
  }
}