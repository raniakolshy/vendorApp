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

/// ---- theme constants ----
const kIconGray = Color(0xFF8E9196);
const kTextGray = Color(0xFF2E2F32);
const kDividerGray = Color(0xFFE7E8EA);
const kDrawerActive = Color(0xFFF4F5F7);
const kMutedOrange = Color(0xFFFF8A00);
const kRedLogout = Color(0xFFE64949);
/// -------------------------

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

  // vendor flag
  bool _isVendor = false;
  bool _loadingVendor = true;

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
  void initState() {
    super.initState();
    _productOpen = {
      NavKey.productAdd,
      NavKey.productList,
      NavKey.productDrafts,
    }.contains(widget.selected);
    _loadVendorFlag();
  }

  Future<void> _loadVendorFlag() async {
    try {
      final VendorProfile? me = await VendorApiClient().getVendorInfo();
      bool vendor = false;
      if (me != null) {
        // Check vendor status using the typed properties
        // You might need to add these properties to your VendorProfile model
        // or use a different approach to determine vendor status
        vendor = me.customerId != null && me.customerId! > 0;
        // If you have specific vendor flags in your model, use them instead:
        // vendor = me.isVendor == true || me.isSeller == true || (me.sellerId ?? 0) != 0;
      }
      if (!mounted) return;
      setState(() {
        _isVendor = vendor;
        _loadingVendor = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVendor = false;
        _loadingVendor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
                label: t?.dashboard ?? 'Dashboard',
                active: widget.selected == NavKey.dashboard,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onSelect(NavKey.dashboard);
                },
              ),

              if (!_loadingVendor && _isVendor)
                _DrawerItem.asset(
                  base: _iconBase[NavKey.orders]!,
                  label: t?.orders ?? 'Orders',
                  active: widget.selected == NavKey.orders,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelect(NavKey.orders);
                  },
                ),

              if (!_loadingVendor && _isVendor)
                _Expandable(
                  label: t?.product ?? 'Product',
                  base: 'product',
                  open: _productOpen,
                  onTap: () => setState(() => _productOpen = !_productOpen),
                  children: [
                    _Child(
                      label: t?.addProduct ?? 'Add Product',
                      active: widget.selected == NavKey.productAdd,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onSelect(NavKey.productAdd);
                      },
                    ),
                    _Child(
                      label: t?.myProductList ?? 'My Products',
                      active: widget.selected == NavKey.productList,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onSelect(NavKey.productList);
                      },
                    ),
                    _Child(
                      label: t?.draftProduct ?? 'Drafts',
                      active: widget.selected == NavKey.productDrafts,
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onSelect(NavKey.productDrafts);
                      },
                    ),
                  ],
                ),

              _DrawerItem.asset(
                base: _iconBase[NavKey.analytics]!,
                label: t?.customerAnalytics ?? 'Customer Analytics',
                active: widget.selected == NavKey.analytics,
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onSelect(NavKey.analytics);
                },
              ),

              if (!_loadingVendor && _isVendor)
                _DrawerItem.asset(
                  base: _iconBase[NavKey.transactions]!,
                  label: t?.transactions ?? 'Transactions',
                  active: widget.selected == NavKey.transactions,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelect(NavKey.transactions);
                  },
                ),

              if (!_loadingVendor && _isVendor)
                _DrawerItem.asset(
                  base: _iconBase[NavKey.revenue]!,
                  label: t?.revenue ?? 'Revenue',
                  trailing: const _RevenueBadge(6),
                  active: widget.selected == NavKey.revenue,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelect(NavKey.revenue);
                  },
                ),

              if (!_loadingVendor && _isVendor)
                _DrawerItem.asset(
                  base: _iconBase[NavKey.review]!,
                  label: t?.review ?? 'Review',
                  active: widget.selected == NavKey.review,
                  onTap: () {
                    Navigator.of(context).pop();
                    widget.onSelect(NavKey.review);
                  },
                ),

              const SizedBox(height: 12),
              const Divider(color: kDividerGray, height: 24),

              // Profile row → opens figma-style popup
              _ProfileButton(onSelect: widget.onSelect),

              // Extra CTA
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.download_for_offline_outlined,
                          color: Colors.black45),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Install main application',
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
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
                  child: const Icon(Icons.expand_more_rounded, color: kIconGray),
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

class _ProfileButton extends StatefulWidget {
  final ValueChanged<NavKey> onSelect;
  const _ProfileButton({required this.onSelect});

  @override
  State<_ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<_ProfileButton> {
  String? _displayName;     // e.g. "Jane Doe"
  String? _storeName;       // e.g. "Kolshy Store"
  String? _avatarUrl;       // optional, if you store a URL in custom_attributes
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final VendorProfile? me = await VendorApiClient().getVendorInfo();
      if (me != null) {
        // Use typed properties instead of map access
        final first = ''; // You'll need to add firstname/lastname to VendorProfile
        final last = '';  // or create a separate method to get user info
        final email = ''; // For now, using empty strings as placeholders

        // For now, using company name as display name
        final display = me.companyName ?? 'Vendor';
        final storeName = me.companyName ?? 'Vendor Store';

        if (!mounted) return;
        setState(() {
          _displayName = display;
          _storeName = storeName;
          _avatarUrl = null; // Set this if you have avatar URL in VendorProfile
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(.25),
        builder: (_) => _ProfileMenuDialog(onSelect: widget.onSelect),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: _avatarUrl != null
                  ? NetworkImage(_avatarUrl!)
                  : const AssetImage('assets/avatar_placeholder.jpg') as ImageProvider,
              backgroundColor: const Color(0xFFEDEDED),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _loading
                  ? const _NameSkeleton()
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName ?? '—',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: kTextGray,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _storeName ?? 'Vendor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: kIconGray),
          ],
        ),
      ),
    );
  }
}

class _NameSkeleton extends StatelessWidget {
  const _NameSkeleton();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 12, width: 120, color: Color(0xFFEDEDED)),
        const SizedBox(height: 6),
        Container(height: 10, width: 90, color: Color(0xFFF1F1F1)),
      ],
    );
  }
}

class _ProfileMenuDialog extends StatelessWidget {
  final ValueChanged<NavKey> onSelect;

  const _ProfileMenuDialog({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

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
                  label: t?.profileSettings ?? 'Profile Settings',
                  onTap: () {
                    Navigator.pop(context); // close dialog
                    onSelect(NavKey.profileSettings);
                  },
                ),

                const _DividerLine(),

                _MenuRow(
                  icon: Icons.picture_as_pdf_outlined,
                  label: t?.printPDF ?? 'Print PDF',
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(NavKey.printPdf);
                  },
                ),
                _MenuRow(
                  icon: Icons.article_outlined,
                  label: t?.adminNews ?? 'Admin News',
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(NavKey.adminNews);
                  },
                ),
                _MenuRow(
                  icon: Icons.translate_outlined,
                  label: t?.language ?? 'Language',
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(NavKey.language);
                  },
                ),

                const _DividerLine(),
                _MenuRow(
                  icon: Icons.support_agent_outlined,
                  label: t?.askForSupport ?? 'Ask for Support',
                  onTap: () {
                    Navigator.pop(context);
                    onSelect(NavKey.askadmin);
                  },
                ),
                InkWell(
                  onTap: () async {
                    final bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context2) {
                        return AlertDialog(
                          title: Text(t?.logout ?? 'Logout'),
                          content: Text(t?.confirmLogout ?? 'Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context2).pop(false),
                              child: Text(t?.cancel ?? 'Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context2).pop(true),
                              child: Text(t?.logout ?? 'Logout'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      try {
                        await VendorApiClient().logout();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                                (route) => false,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(t?.logoutSuccessful ?? 'Logged out successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${t?.logoutFailed ?? 'Logout failed'}: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    child: Text(
                      t?.logout ?? 'Logout',
                      style: const TextStyle(
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