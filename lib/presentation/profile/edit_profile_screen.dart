import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
  bool _twitterEnabled = false;
  bool _facebookEnabled = false;
  bool _instagramEnabled = false;
  bool _youtubeEnabled = false;
  bool _vimeoEnabled = false;
  bool _pinterestEnabled = false;
  bool _moleskineEnabled = false;
  bool _tiktokEnabled = false;

  final List<String> _countries = [
    'Tunisia', 'United States', 'Canada', 'United Kingdom', 'Germany', 'France',
    'Japan', 'Australia', 'Brazil', 'India', 'China'
  ];
  String _selectedCountry = 'Tunisia';

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
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
          border: const Border(right: BorderSide(color: Color(0xFFE5E5E5))),
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

  // ---------- File Picker Logic ----------
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

  // ---------- Save Function ----------
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    // Implement your API call to save the profile here
    // Example: _snack('Profile saved');
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : Colors.black87),
    );
  }

  // ---------- Build UI ----------
  @override
  Widget build(BuildContext context) {
    // Force black switches
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
                      children: const [
                        SizedBox(width: 4),
                        Text('Profile settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
                              _sectionCard(title: 'Profile Information', children: [
                                // Company Logo
                                _label('Company Logo', help: 'Upload your company logo'),
                                _buildLogoPicker(),
                                const SizedBox(height: 20),

                                // Company Banner
                                _label('Company Banner', help: 'Upload your company banner'),
                                _buildBannerPicker(),
                                const SizedBox(height: 20),

                                _label('Display name', help: 'The name that will be displayed on your vendor profile'),
                                TextFormField(
                                  controller: _companyName,
                                  decoration: _dec(context, hint: 'Company'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 20),

                                // Location Dropdown
                                _label('Location', help: 'The physical location of your business'),
                                DropdownButtonFormField<String>(
                                  value: _selectedCountry,
                                  items: _countries.map((country) {
                                    return DropdownMenuItem(
                                      value: country,
                                      child: Text(country),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedCountry = value!;
                                    });
                                  },
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                // Phone Number Field
                                _label('Phone Number', help: 'Your company\'s contact phone number'),
                                IntlPhoneField(
                                  controller: _phoneNumber,
                                  decoration: _dec(context, hint: 'Enter phone number'),
                                  initialCountryCode: _countryCodeMap[_selectedCountry] ?? 'TN', // Default to 'TN' (Tunisia)
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: 'Bio',
                                  help: 'A short description of your company.',
                                  controller: _bio,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label('Low Stock Quantity', help: 'Set the threshold for low stock warnings'),
                                TextFormField(
                                  controller: _lowStockQuantity,
                                  decoration: _dec(context, hint: '12'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                                const SizedBox(height: 20),

                                _label('Tax/VAT Number', help: 'Your official tax or VAT identification number'),
                                TextFormField(
                                  controller: _taxVatNumber,
                                  decoration: _dec(context, hint: '12'),
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: 'Payment Details',
                                  help: 'Details on how customers can pay for products.',
                                  controller: _paymentDetails,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label('Social Media IDs', help: 'Link your social media profiles'),
                                _buildSocialMediaField('Twitter ID', FontAwesomeIcons.twitter, _twitterId, _twitterEnabled, (value) => setState(() => _twitterEnabled = value)),
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Facebook ID', FontAwesomeIcons.facebook, _facebookId, _facebookEnabled, (value) => setState(() => _facebookEnabled = value)),
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Instagram ID', FontAwesomeIcons.instagram, _instagramId, _instagramEnabled, (value) => setState(() => _instagramEnabled = value)),
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Youtube ID', FontAwesomeIcons.youtube, _youtubeId, _youtubeEnabled, (value) => setState(() => _youtubeEnabled = value)),
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Vimeo ID', FontAwesomeIcons.vimeo, _vimeoId, _vimeoEnabled, (value) => setState(() => _vimeoEnabled = value)),
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Pinterest ID', FontAwesomeIcons.pinterest, _pinterestId, _pinterestEnabled, (value) => setState(() => _pinterestEnabled = value)),
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Moleskine ID', Icons.camera, _moleskineId, _moleskineEnabled, (value) => setState(() => _moleskineEnabled = value)), // Using a placeholder for Moleskine
                                const SizedBox(height: 20),
                                _buildSocialMediaField('Tiktok ID', FontAwesomeIcons.tiktok, _tiktokId, _tiktokEnabled, (value) => setState(() => _tiktokEnabled = value)),
                                const SizedBox(height: 20),
                              ]),

                              // Policies Section
                              _sectionCard(title: 'Company Policy', children: [
                                DescriptionMarkdownField(
                                  label: 'Return Policy',
                                  help: 'Describe your company’s return policy.',
                                  controller: _returnPolicy,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: 'Shipping Policy',
                                  help: 'Describe your company’s shipping policy.',
                                  controller: _shippingPolicy,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: 'Privacy Policy',
                                  help: 'Describe your company’s privacy policy.',
                                  controller: _privacyPolicy,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                              ]),

                              // Meta Information Section
                              _sectionCard(title: 'Meta Information', children: [
                                DescriptionMarkdownField(
                                  label: 'Meta Keywords',
                                  help: 'Add your company’s meta keywords.',
                                  controller: _metaKeywords,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: 'Meta Description',
                                  help: 'A short description of your company for search engines.',
                                  controller: _metaDescription,
                                  minLines: 4,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),
                                _label('Google Analytic ID', help: 'Your Google Analytics tracking ID'),
                                TextFormField(
                                  controller: _googleAnalyticId,
                                  decoration: _dec(context, hint: 'Input your text'),
                                ),
                                const SizedBox(height: 20),

                                // URL Paths
                                _label('Profile Page Target Url Path', help: 'This is the final URL of your profile page.'),
                                TextFormField(
                                  initialValue: 'marketplace/seller/profile/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label('Profile Page Request Url Path', help: 'Customize the URL of your profile page.'),
                                TextFormField(
                                  controller: _profilePageRequestUrlPath,
                                  decoration: _dec(context, hint: 'Input your text'),
                                ),
                                const SizedBox(height: 20),

                                _label('Collection Page Target Url Path', help: 'The final URL for your product collection page.'),
                                TextFormField(
                                  initialValue: 'marketplace/seller/collection/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label('Collection Page Request Url Path', help: 'Customize the URL of your collection page.'),
                                TextFormField(
                                  controller: _collectionPageRequestUrlPath,
                                  decoration: _dec(context, hint: 'Input your text'),
                                ),
                                const SizedBox(height: 20),

                                _label('Review Page Target Url Path', help: 'The final URL for your reviews page.'),
                                TextFormField(
                                  initialValue: 'marketplace/seller/feedback/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label('Review Page Request Url Path', help: 'Customize the URL for your reviews page.'),
                                TextFormField(
                                  controller: _reviewPageRequestUrlPath,
                                  decoration: _dec(context, hint: 'Input your text'),
                                ),
                                const SizedBox(height: 20),

                                _label('Location Page Target Url Path', help: 'The final URL for your location page.'),
                                TextFormField(
                                  initialValue: 'marketplace/seller/location/shop/comp',
                                  enabled: false,
                                  decoration: _dec(context, enabled: false),
                                ),
                                const SizedBox(height: 20),
                                _label('Location Page Request Url Path', help: 'Customize the URL for your location page.'),
                                TextFormField(
                                  controller: _locationPageRequestUrlPath,
                                  decoration: _dec(context, hint: 'Input your text'),
                                ),
                                const SizedBox(height: 20),

                                _label('Privacy Policy Page Request Url Path', help: 'Customize the URL for your privacy policy page.'),
                                TextFormField(
                                  controller: _privacyPolicyRequestUrlPath,
                                  decoration: _dec(context, hint: 'Input your text'),
                                ),
                                const SizedBox(height: 20),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Sticky footer with Save button
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
                                MaterialPageRoute(
                                  builder: (context) => const VendorProfileScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: const BorderSide(color: Colors.black87),
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('View Profile'),
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
                            child: const Text('Save'),
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

  Widget _buildLogoPicker() {
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
                  ) : null,
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
            label: const Text('Replace Logo', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerPicker() {
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
                      _bannerBytes == null ? 'Click or drop image' : 'Image selected',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (kIsWeb)
            IgnorePointer(
              ignoring: false,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: DropzoneView(
                    operation: DragOperation.copy,
                    mime: const ['image/png', 'image/jpeg', 'image/webp'],
                    onDrop: (ev) async {
                      final bytes = await ev.getFileData();
                      setState(() {
                        _bannerBytes = bytes;
                      });
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaField(String label, IconData icon, TextEditingController controller, bool enabled, ValueChanged<bool> onChanged) {
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
          decoration: _dec(context, hint: 'Input your text', enabled: enabled),
        ),
      ],
    );
  }

  final Map<String, String> _countryCodeMap = {
    'Tunisia': 'TN',
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