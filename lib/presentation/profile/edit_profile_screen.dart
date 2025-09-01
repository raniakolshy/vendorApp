import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

// L10n

import '../common/description_markdown_field.dart';
import 'View_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();

  // Controllers
  final _companyName = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _bio = TextEditingController();
  final _lowStockQuantity = TextEditingController();
  final _taxVatNumber = TextEditingController();
  final _paymentDetails = TextEditingController();
  final _twitterId = TextEditingController();
  final _facebookId = TextEditingController();
  final _instagramId = TextEditingController();
  final _youtubeId = TextEditingController();
  final _vimeoId = TextEditingController();
  final _pinterestId = TextEditingController();
  final _moleskineId = TextEditingController();
  final _tiktokId = TextEditingController();
  final _metaKeywords = TextEditingController();
  final _metaDescription = TextEditingController();
  final _googleAnalyticId = TextEditingController();
  final _profilePageRequestUrlPath = TextEditingController();
  final _collectionPageRequestUrlPath = TextEditingController();
  final _reviewPageRequestUrlPath = TextEditingController();
  final _locationPageRequestUrlPath = TextEditingController();
  final _privacyPolicyRequestUrlPath = TextEditingController();
  final _returnPolicy = TextEditingController();
  final _shippingPolicy = TextEditingController();
  final _privacyPolicy = TextEditingController();

  // State
  Uint8List? _logoBytes;
  Uint8List? _bannerBytes;
  DropzoneViewController? _dzCtrl;

  bool _twitterEnabled = false;
  bool _facebookEnabled = false;
  bool _instagramEnabled = false;
  bool _youtubeEnabled = false;
  bool _vimeoEnabled = false;
  bool _pinterestEnabled = false;
  bool _moleskineEnabled = false;
  bool _tiktokEnabled = false;

  final List<String> _countries = const [
    'United Arab Emirates','Egypte', 'United States', 'Canada', 'United Kingdom', 'Germany', 'France',
    'Japan', 'Australia', 'Brazil', 'India', 'China'
  ];
  String _selectedCountry = 'United Arab Emirates';

  // ---------- styling helpers ----------
  BorderRadius get _radius => BorderRadius.circular(16);

  InputDecoration _dec(BuildContext context, {String? hint, Widget? prefix, bool enabled = true}) {
    final divider = const Color(0xFFE5E5E5);
    return InputDecoration(
      hintText: hint,
      isDense: true,
      enabled: enabled,
      filled: true,
      fillColor: enabled ? Colors.white : const Color(0xFFF3F3F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefix == null
          ? null
          : Container(
        width: 48,
        margin: const EdgeInsets.only(right: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFEFEFEF),
          borderRadius: BorderRadius.horizontal(left: Radius.circular(14)),
          border: Border(right: BorderSide(color: Color(0xFFE5E5E5))),
        ),
        alignment: Alignment.center,
        child: prefix,
      ),
      border: OutlineInputBorder(borderRadius: _radius, borderSide: BorderSide(color: divider)),
      enabledBorder: OutlineInputBorder(borderRadius: _radius, borderSide: BorderSide(color: divider)),
      focusedBorder: OutlineInputBorder(
        borderRadius: _radius,
        borderSide: const BorderSide(color: Colors.black87, width: 1.5),
      ),
    );
  }

  // ---------- Section Card ----------
  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  // ---------- File Picker ----------
  Future<void> _pickImage({required bool isLogo}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        if (isLogo) {
          _logoBytes = file.bytes;
        } else {
          _bannerBytes = file.bytes;
        }
      });
    }
  }

  // ---------- Save ----------
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    // TODO: call API to save profile
    _snack(AppLocalizations.of(context)!.toast_profile_saved);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : Colors.black87),
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final switchTheme = SwitchThemeData(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      thumbColor: MaterialStateProperty.resolveWith((s) => Colors.white),
      trackColor: MaterialStateProperty.resolveWith(
            (s) => s.contains(MaterialState.selected) ? Colors.black87 : const Color(0xFFD6D6D6),
      ),
      overlayColor: MaterialStateProperty.all(Colors.transparent),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Theme(
          data: Theme.of(context).copyWith(switchTheme: switchTheme),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Row(
                      children: [
                        const SizedBox(width: 4),
                        Text(l10n.profile_settings, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Scrollbar(
                        controller: _scroll,
                        child: SingleChildScrollView(
                          controller: _scroll,
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                          child: Column(
                            children: [
                              // Profile Information
                              _sectionCard(title: l10n.sec_profile_information, children: [
                                // Company Logo
                                _label(l10n.lbl_company_logo, help: l10n.help_company_logo),
                                _buildLogoPicker(l10n),
                                const SizedBox(height: 20),

                                // Company Banner
                                _label(l10n.lbl_company_banner, help: l10n.help_company_banner),
                                _buildBannerPicker(l10n),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_display_name, help: l10n.help_display_name),
                                TextFormField(
                                  controller: _companyName,
                                  decoration: _dec(context, hint: l10n.hint_company),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.v_required : null,
                                ),
                                const SizedBox(height: 20),

                                // Location Dropdown
                                _label(l10n.lbl_location, help: l10n.help_location),
                                DropdownButtonFormField<String>(
                                  value: _selectedCountry,
                                  items: _countries.map((country) {
                                    return DropdownMenuItem(
                                      value: country,
                                      child: Text(_localizeCountry(country, l10n)),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedCountry = value!),
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                // Phone Number Field
                                _label(l10n.lbl_phone_number, help: l10n.help_phone_number),
                                IntlPhoneField(
                                  controller: _phoneNumber,
                                  decoration: _dec(context, hint: l10n.hint_phone),
                                  initialCountryCode: _countryCodeMap[_selectedCountry] ?? 'TN',
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: l10n.lbl_bio,
                                  help: l10n.help_bio,
                                  controller: _bio,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_low_stock_qty, help: l10n.help_low_stock_qty),
                                TextFormField(
                                  controller: _lowStockQuantity,
                                  decoration: _dec(context, hint: '12'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_tax_vat, help: l10n.help_tax_vat),
                                TextFormField(
                                  controller: _taxVatNumber,
                                  decoration: _dec(context, hint: 'TN1234567'),
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: l10n.lbl_payment_details,
                                  help: l10n.help_payment_details,
                                  controller: _paymentDetails,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_social_ids, help: l10n.help_social_ids),
                                _buildSocialMediaField(l10n.sm_twitter, FontAwesomeIcons.twitter, _twitterId, _twitterEnabled, (v) => setState(() => _twitterEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_facebook, FontAwesomeIcons.facebook, _facebookId, _facebookEnabled, (v) => setState(() => _facebookEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_instagram, FontAwesomeIcons.instagram, _instagramId, _instagramEnabled, (v) => setState(() => _instagramEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_youtube, FontAwesomeIcons.youtube, _youtubeId, _youtubeEnabled, (v) => setState(() => _youtubeEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_vimeo, FontAwesomeIcons.vimeo, _vimeoId, _vimeoEnabled, (v) => setState(() => _vimeoEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_pinterest, FontAwesomeIcons.pinterest, _pinterestId, _pinterestEnabled, (v) => setState(() => _pinterestEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_moleskine, Icons.camera, _moleskineId, _moleskineEnabled, (v) => setState(() => _moleskineEnabled = v), l10n),
                                const SizedBox(height: 20),
                                _buildSocialMediaField(l10n.sm_tiktok, FontAwesomeIcons.tiktok, _tiktokId, _tiktokEnabled, (v) => setState(() => _tiktokEnabled = v), l10n),
                                const SizedBox(height: 20),
                              ]),

                              // Policies Section
                              _sectionCard(title: l10n.sec_company_policy, children: [
                                DescriptionMarkdownField(
                                  label: l10n.lbl_return_policy,
                                  help: l10n.help_return_policy,
                                  controller: _returnPolicy,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: l10n.lbl_shipping_policy,
                                  help: l10n.help_shipping_policy,
                                  controller: _shippingPolicy,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: l10n.lbl_privacy_policy,
                                  help: l10n.help_privacy_policy,
                                  controller: _privacyPolicy,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                              ]),

                              // Meta Information Section
                              _sectionCard(title: l10n.sec_meta_information, children: [
                                DescriptionMarkdownField(
                                  label: l10n.lbl_meta_keywords,
                                  help: l10n.help_meta_keywords_profile,
                                  controller: _metaKeywords,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: l10n.lbl_meta_description,
                                  help: l10n.help_meta_description_profile,
                                  controller: _metaDescription,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                _label(l10n.lbl_google_analytics, help: l10n.help_google_analytics),
                                TextFormField(
                                  controller: _googleAnalyticId,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                ),
                                const SizedBox(height: 20),

                                // URL Paths
                                _label(l10n.lbl_profile_target, help: l10n.help_profile_target),
                                TextFormField(
                                  initialValue: 'marketplace/seller/profile/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label(l10n.lbl_profile_request, help: l10n.help_profile_request),
                                TextFormField(
                                  controller: _profilePageRequestUrlPath,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_collection_target, help: l10n.help_collection_target),
                                TextFormField(
                                  initialValue: 'marketplace/seller/collection/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label(l10n.lbl_collection_request, help: l10n.help_collection_request),
                                TextFormField(
                                  controller: _collectionPageRequestUrlPath,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_review_target, help: l10n.help_review_target),
                                TextFormField(
                                  initialValue: 'marketplace/seller/feedback/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label(l10n.lbl_review_request, help: l10n.help_review_request),
                                TextFormField(
                                  controller: _reviewPageRequestUrlPath,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_location_target, help: l10n.help_location_target),
                                TextFormField(
                                  initialValue: 'marketplace/seller/location/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label(l10n.lbl_location_request, help: l10n.help_location_request),
                                TextFormField(
                                  controller: _locationPageRequestUrlPath,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_privacy_request, help: l10n.help_privacy_request),
                                TextFormField(
                                  controller: _privacyPolicyRequestUrlPath,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                ),
                                const SizedBox(height: 20),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sticky footer
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const VendorProfileScreen()),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.black87),
                              foregroundColor: Colors.black87,
                            ),
                            child: Text(l10n.btn_view_profile),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(l10n.btn_save),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {String help = ''}) {
    final hasHelp = help.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              softWrap: true,
            ),
          ),
          if (hasHelp) const SizedBox(width: 6),
          if (hasHelp)
            Tooltip(
              message: help,
              triggerMode: TooltipTriggerMode.tap,
              waitDuration: const Duration(milliseconds: 150),
              showDuration: const Duration(seconds: 4),
              preferBelow: false,
              child: const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.info_outline, size: 16, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogoPicker(AppLocalizations l10n) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  image: _logoBytes != null
                      ? DecorationImage(
                    image: MemoryImage(_logoBytes!),
                    fit: BoxFit.cover,
                  )
                      : null,
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                ),
                child: _logoBytes == null
                    ? const Center(child: Icon(Icons.business_rounded, size: 40, color: Colors.black38))
                    : null,
              ),
              if (_logoBytes != null)
                Positioned(
                  top: -8,
                  right: -8,
                  child: InkWell(
                    onTap: () => setState(() => _logoBytes = null),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.close, size: 16, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _pickImage(isLogo: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.add_circle_outline, size: 24),
            label: Text(l10n.btn_replace_logo, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPicker(AppLocalizations l10n) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      alignment: Alignment.center,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_bannerBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(_bannerBytes!, fit: BoxFit.cover),
            ),
          Center(
            child: InkWell(
              onTap: () => _pickImage(isLogo: false),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.download_rounded, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      _bannerBytes == null ? l10n.btn_click_or_drop_image : l10n.lbl_image_selected,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (kIsWeb)
            DropzoneView(
              onCreated: (c) => _dzCtrl = c,
              operation: DragOperation.copy,
              mime: const ['image/png', 'image/jpeg', 'image/webp'],
              onDrop: (ev) async {
                final bytes = await _dzCtrl!.getFileData(ev);
                setState(() => _bannerBytes = bytes);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaField(
      String label,
      IconData icon,
      TextEditingController controller,
      bool enabled,
      ValueChanged<bool> onChanged,
      AppLocalizations l10n,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _label(label)),
            Switch(value: enabled, onChanged: onChanged),
          ],
        ),
        TextFormField(
          controller: controller,
          decoration: _dec(context, hint: l10n.hint_input_text, enabled: enabled, prefix: Icon(icon, size: 18)),
        ),
      ],
    );
  }

  // Helpers
  String _localizeCountry(String raw, AppLocalizations l10n) {
    switch (raw) {
      case 'United Arab Emirates':
        return l10n.country_uae;
      case 'United States':
        return l10n.country_us;
      case 'Canada':
        return l10n.country_canada;
      case 'United Kingdom':
        return l10n.country_uk;
      case 'Germany':
        return l10n.country_germany;
      case 'France':
        return l10n.country_france;
      case 'Japan':
        return l10n.country_japan;
      case 'Australia':
        return l10n.country_australia;
      case 'Brazil':
        return l10n.country_brazil;
      case 'India':
        return l10n.country_india;
      case 'China':
        return l10n.country_china;
      default:
        return raw;
    }
  }

  final Map<String, String> _countryCodeMap = const {
    'United Arab Emirates': 'AE',
    'United States': 'US',
    'Canada': 'CA',
    'United Kingdom': 'GB',
    'Germany': 'DE',
    'France': 'FR',
    'Japan': 'JP',
    'Australia': 'AU',
    'Brazil': 'BR',
    'India': 'IN',
    'China': 'CN',
  };
}