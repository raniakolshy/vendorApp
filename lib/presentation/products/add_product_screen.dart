import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/presentation/products/drafts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dropzone/flutter_dropzone.dart';

// L10n import généré par flutter gen_l10n

import '../common/description_markdown_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();

  // Controllers
  final _title = TextEditingController();
  final _sku = TextEditingController();
  final _desc = TextEditingController();
  final _shortDesc = TextEditingController();
  final _amount = TextEditingController(text: '8');
  final _sp = TextEditingController();
  final _minQty = TextEditingController(text: '0');
  final _maxQty = TextEditingController(text: '0');
  final _stock = TextEditingController();
  final _weight = TextEditingController();
  final _cities = TextEditingController();
  final _url = TextEditingController();
  final _metaTitle = TextEditingController();
  final _metaKeywords = TextEditingController();
  final _metaDesc = TextEditingController();

  // Tags (multi)
  final _tagInput = TextEditingController();
  List<String> _tags = [];

  // Product images (multi)
  List<Uint8List> _images = [];
  List<String> _imageNames = [];
  DropzoneViewController? _dzCtrl;

  // State
  String _category = 'Food';
  final _categories = const ['Food', 'Electronics', 'Apparel', 'Beauty', 'Home', 'Other'];
  bool _hasSpecial = false;
  bool _taxes = true;
  String _stockAvail = 'In Stock';
  String _visibility = 'Invisible';
  bool _submitting = false;

  // ---------- styling helpers ----------
  BorderRadius get _radius => BorderRadius.circular(16);

  InputDecoration _dec(BuildContext context, {String? hint, Widget? prefix}) {
    final divider = const Color(0xFFE5E5E5);
    return InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: prefix == null
          ? null
          : Container(
        width: 48,
        margin: const EdgeInsets.only(right: 8),
        decoration: const BoxDecoration(
          color: Color(0xFFF3F3F3),
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

  // ---------- actions ----------
  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    await _submit(isDraft: true);
  }

  Future<void> _publish() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_images.length < 3) {
      _snack(l10n.err_add_three_images, error: true);
      return;
    }

    if (_hasSpecial && _sp.text.trim().isNotEmpty) {
      final p = double.tryParse(_amount.text);
      final s = double.tryParse(_sp.text);
      if (p != null && s != null && s >= p) {
        _snack(l10n.err_special_lower_than_amount, error: true);
        return;
      }
    }
    await _submit(isDraft: false);
  }

  Future<void> _submit({required bool isDraft}) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    // TODO: call your API here (include _tags and _images)
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _snack(isDraft ? l10n.toast_draft_saved : l10n.toast_product_published);
    setState(() => _submitting = false);
  }

  void _delete() {
    final l10n = AppLocalizations.of(context)!;
    // TODO: delete API call
    _snack(l10n.toast_product_deleted);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : Colors.black87),
    );
  }

  // ---------- UI ----------
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
                        Text(l10n.product, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
                              // Name & description
                              _sectionCard(title: l10n.sec_name_description, children: [
                                _label(l10n.lbl_product_title, help: l10n.help_product_title),
                                TextFormField(
                                  controller: _title,
                                  decoration: _dec(context, hint: l10n.hint_input_text),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.v_required : null,
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_category, help: l10n.help_category),
                                DropdownButtonFormField<String>(
                                  value: _category,
                                  items: _categories
                                      .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(_localizeCategory(e, l10n)),
                                  ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _category = v ?? _category),
                                  decoration: _dec(context),
                                  dropdownColor: Colors.white,
                                  elevation: 8,
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_tags, help: l10n.help_tags),
                                _buildTagInput(l10n),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: l10n.lbl_description,
                                  help: l10n.help_description,
                                  controller: _desc,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: l10n.lbl_short_description,
                                  help: l10n.help_short_description,
                                  controller: _shortDesc,
                                  minLines: 5,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_sku, help: l10n.help_sku),
                                TextFormField(
                                  controller: _sku,
                                  decoration: _dec(context, hint: l10n.hint_sku),
                                ),
                              ]),

                              // Price
                              _sectionCard(title: l10n.sec_price, children: [
                                _label(l10n.lbl_amount, help: l10n.help_amount),
                                TextFormField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  decoration: _dec(
                                    context,
                                    hint: l10n.hint_amount_default,
                                    prefix: Text(l10n.curr_symbol, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                  validator: (v) => (v == null || num.tryParse(v) == null) ? l10n.v_number : null,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(child: _label(l10n.lbl_special_toggle, help: l10n.help_special_toggle)),
                                    Switch(value: _hasSpecial, onChanged: (v) => setState(() => _hasSpecial = v)),
                                  ],
                                ),
                                const Divider(height: 24, color: Color(0xFFE5E5E5)),

                                if (_hasSpecial) ...[
                                  _label(l10n.lbl_special_price, help: l10n.help_special_price),
                                  TextFormField(
                                    controller: _sp,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    decoration: _dec(
                                      context,
                                      hint: l10n.hint_price_example,
                                      prefix: Text(l10n.curr_symbol,
                                          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                _label(l10n.lbl_min_qty, help: l10n.help_min_qty),
                                TextFormField(
                                  controller: _minQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(
                                    context,
                                    hint: '0',
                                    prefix: Text(l10n.curr_symbol,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _label(l10n.lbl_max_qty, help: l10n.help_max_qty),
                                TextFormField(
                                  controller: _maxQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(
                                    context,
                                    hint: '0',
                                    prefix: Text(l10n.curr_symbol,
                                        style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(child: _label(l10n.lbl_taxes, help: l10n.help_taxes)),
                                    Switch(value: _taxes, onChanged: (v) => setState(() => _taxes = v)),
                                  ],
                                ),
                              ]),

                              // Stock & availability
                              _sectionCard(title: l10n.sec_stock_availability, children: [
                                _label(l10n.lbl_stock, help: l10n.help_stock),
                                TextFormField(
                                  controller: _stock,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: l10n.hint_stock),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_weight, help: l10n.help_weight),
                                TextFormField(
                                  controller: _weight,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))],
                                  decoration: _dec(context, hint: l10n.hint_weight),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_allowed_qty_per_customer, help: l10n.help_allowed_qty_per_customer),
                                TextFormField(
                                  controller: _maxQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: l10n.hint_allowed_qty),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return null;
                                    final n = int.tryParse(v);
                                    if (n == null || n < 0) return l10n.v_non_negative;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_stock_availability, help: l10n.help_stock_availability),
                                DropdownButtonFormField<String>(
                                  value: _stockAvail,
                                  items: ['In Stock', 'Out of Stock']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(_localizeStock(s, l10n))))
                                      .toList(),
                                  onChanged: (v) => setState(() => _stockAvail = v ?? _stockAvail),
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_visibility, help: l10n.help_visibility),
                                DropdownButtonFormField<String>(
                                  value: _visibility,
                                  items: ['Invisible', 'Visible']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(_localizeVisibility(s, l10n))))
                                      .toList(),
                                  onChanged: (v) => setState(() => _visibility = v ?? _visibility),
                                  decoration: _dec(context),
                                ),
                              ]),

                              // Meta + Images
                              _sectionCard(title: l10n.sec_meta_infos, children: [
                                _label(l10n.lbl_url_key, help: l10n.help_url_key),
                                TextFormField(
                                  controller: _url,
                                  decoration: _dec(context, hint: l10n.hint_url_key),
                                ),
                                const SizedBox(height: 20),

                                _label(l10n.lbl_meta_title, help: l10n.help_meta_title),
                                TextFormField(
                                  controller: _metaTitle,
                                  decoration: _dec(context, hint: l10n.hint_meta_title),
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: l10n.lbl_meta_keywords,
                                  help: l10n.help_meta_keywords,
                                  controller: _metaKeywords,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: l10n.lbl_meta_description,
                                  help: l10n.help_meta_description,
                                  controller: _metaDesc,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                // --- Product Images ---
                                _label(l10n.lbl_product_images, help: l10n.help_product_images),
                                Container(
                                  height: 210,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: const Color(0xFFE5E5E5)),
                                  ),
                                  child: Stack(
                                    children: [
                                      if (_images.isNotEmpty)
                                        GridView.builder(
                                          padding: const EdgeInsets.all(10),
                                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 10,
                                            crossAxisSpacing: 10,
                                          ),
                                          itemCount: _images.length,
                                          itemBuilder: (_, i) => Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Image.memory(
                                                  _images[i],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () => setState(() {
                                                    _images.removeAt(i);
                                                    _imageNames.removeAt(i);
                                                  }),
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                        color: Colors.black54, shape: BoxShape.circle),
                                                    padding: const EdgeInsets.all(4),
                                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      if (kIsWeb)
                                        DropzoneView(
                                          onCreated: (c) => _dzCtrl = c,
                                          operation: DragOperation.copy,
                                          mime: const ['image/png', 'image/jpeg', 'image/webp'],
                                          onDrop: (ev) async {
                                            final bytes = await _dzCtrl!.getFileData(ev);
                                            final name = await _dzCtrl!.getFilename(ev);
                                            setState(() {
                                              _images.add(bytes);
                                              _imageNames.add(name);
                                            });
                                          },
                                        ),

                                      Center(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.download_rounded),
                                          label: Text(l10n.btn_click_or_drop_image),
                                          onPressed: _pickImages,
                                          style: ElevatedButton.styleFrom(
                                            elevation: 3,
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black87,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_images.length < 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(l10n.warn_prefer_three_images,
                                        style: const TextStyle(color: Colors.red)),
                                  ),
                              ]),

                              // Linked products tabs
                              _sectionCard(
                                title: l10n.sec_linked_products,
                                children: [
                                  LinkedProductsTabs(height: 600, l10n: l10n),
                                ],
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
                                        onPressed: _submitting ? null : _saveDraft,
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          side: const BorderSide(color: Colors.black87),
                                          foregroundColor: Colors.black87,
                                        ),
                                        child: Text(l10n.btn_save_draft),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _submitting ? null : _publish,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          backgroundColor: Colors.black87,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: _submitting
                                            ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                            : Text(l10n.btn_publish_now),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    IconButton.outlined(
                                      onPressed: _submitting ? null : _delete,
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        side: const BorderSide(color: Color(0xFFE5E5E5)),
                                        foregroundColor: Colors.redAccent,
                                      ),
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: l10n.tt_delete,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- TAGS UI ----------
  Widget _buildTagInput(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (int i = 0; i < _tags.length; i++)
            Chip(
              label: Text(_tags[i], style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.black87,
              deleteIcon: const Icon(Icons.close, color: Colors.white, size: 16),
              onDeleted: () => setState(() => _tags.removeAt(i)),
            ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: _tagInput,
              decoration: InputDecoration.collapsed(hintText: l10n.hint_add_tag),
              onSubmitted: (v) {
                final t = v.trim();
                if (t.isNotEmpty && !_tags.contains(t)) {
                  setState(() => _tags.add(t));
                }
                _tagInput.clear();
              },
            ),
          )
        ],
      ),
    );
  }

  // ---------- images picking ----------
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        for (final f in result.files) {
          if (f.bytes != null) {
            _images.add(f.bytes!);
            _imageNames.add(f.name);
          }
        }
      });
    }
  }

  // Helpers to localize dropdown/item labels coming from constants:
  String _localizeCategory(String raw, AppLocalizations l10n) {
    switch (raw) {
      case 'Food':
        return l10n.cat_food;
      case 'Electronics':
        return l10n.cat_electronics;
      case 'Apparel':
        return l10n.cat_apparel;
      case 'Beauty':
        return l10n.cat_beauty;
      case 'Home':
        return l10n.cat_home;
      default:
        return l10n.cat_other;
    }
  }

  String _localizeStock(String raw, AppLocalizations l10n) {
    switch (raw) {
      case 'In Stock':
        return l10n.stock_in;
      case 'Out of Stock':
        return l10n.stock_out;
      default:
        return raw;
    }
  }

  String _localizeVisibility(String raw, AppLocalizations l10n) {
    switch (raw) {
      case 'Invisible':
        return l10n.visibility_invisible;
      case 'Visible':
        return l10n.visibility_visible;
      default:
        return raw;
    }
  }
}

class _CustomDropdownMenuItem extends StatelessWidget {
  const _CustomDropdownMenuItem({required this.value, required this.child});

  final String value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: DropdownMenuItem(
        value: value,
        child: child,
      ),
    );
  }
}

class LinkedProductsTabs extends StatefulWidget {
  const LinkedProductsTabs({super.key, this.height = 600, required this.l10n});
  final double height;
  final AppLocalizations l10n;

  @override
  State<LinkedProductsTabs> createState() => _LinkedProductsTabsState();
}

class _LinkedProductsTabsState extends State<LinkedProductsTabs> with SingleTickerProviderStateMixin {
  late final TabController _tc;
  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = widget.l10n;

    // Neutral palette
    const neutralPrimary = Colors.black;
    final bg = isDark ? const Color(0xFF101010) : Colors.white;
    final surface = isDark ? const Color(0xFF161616) : Colors.white;
    final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);
    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.white70 : Colors.black54;

    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: neutralPrimary,
          secondary: neutralPrimary,
        ),
      ),
      child: SizedBox(
        height: widget.height,
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.title_product_relationships,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  )),
              const SizedBox(height: 12),

              // Segmented tabs (neutral)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                padding: const EdgeInsets.all(6),
                child: TabBar(
                  controller: _tc,
                  indicator: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border),
                  ),
                  labelColor: neutralPrimary,
                  unselectedLabelColor: onSurfaceMuted,
                  tabs: [
                    Tab(icon: const Icon(Icons.link, size: 18), text: l10n.tab_related),
                    Tab(icon: const Icon(Icons.trending_up, size: 18), text: l10n.tab_upsell),
                    Tab(icon: const Icon(Icons.swap_horiz, size: 18), text: l10n.tab_crosssell),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: TabBarView(
                    controller: _tc,
                    children: [
                      ProductsTableShell(title: l10n.related_products, l10n: l10n),
                      ProductsTableShell(title: l10n.upsell_products, l10n: l10n),
                      ProductsTableShell(title: l10n.crosssell_products, l10n: l10n),
                    ],
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

/// The main widget that holds the product list logic and UI (single, deduplicated version)
class ProductsTableShell extends StatefulWidget {
  const ProductsTableShell({super.key, required this.title, required this.l10n});
  final String title;
  final AppLocalizations l10n;

  @override
  State<ProductsTableShell> createState() => _ProductsTableShellState();
}

class _ProductsTableShellState extends State<ProductsTableShell> {
  final _search = TextEditingController();

  // filter state
  bool _showEnabled = true;
  bool _showDisabled = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _filtersActive => !(_showEnabled && _showDisabled);

  void _openFilters() async {
    final l10n = widget.l10n;

    final result = await showModalBottomSheet<Map<String, bool>>(
      context: context,
      useSafeArea: true,
      isScrollControlled: false,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF161616)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        bool showEnabled = _showEnabled;
        bool showDisabled = _showDisabled;

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Row(
                children: [
                  Text(l10n.filters, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      showEnabled = true;
                      showDisabled = true;
                      Navigator.of(context).pop({'enabled': showEnabled, 'disabled': showDisabled});
                    },
                    child: Text(l10n.btn_reset),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.status_enabled),
                      value: showEnabled,
                      onChanged: (v) => showEnabled = v,
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text(l10n.status_disabled),
                      value: showDisabled,
                      onChanged: (v) => showDisabled = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop({'enabled': showEnabled, 'disabled': showDisabled}),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.btn_apply),
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _showEnabled = result['enabled'] ?? true;
        _showDisabled = result['disabled'] ?? true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);
    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.white70 : Colors.black54;

    final l10n = widget.l10n;

    // Demo dataset — enabled added and status kept
    final List<Map<String, dynamic>> products = [
      {
        'id': 'SKU-001',
        'name': l10n.demo_mouse_name,
        'type': l10n.cat_electronics,
        'price': 49.99,
        'status': l10n.inv_in_stock_label,
        'enabled': true,
      },
      {
        'id': 'SKU-002',
        'name': l10n.demo_tshirt_name,
        'type': l10n.cat_apparel,
        'price': 29.50,
        'status': l10n.inv_low_stock_label,
        'enabled': true,
      },
      {
        'id': 'SKU-003',
        'name': l10n.demo_espresso_name,
        'type': l10n.cat_home_appliances,
        'price': 199.99,
        'status': l10n.inv_out_stock_label,
        'enabled': false,
      },
    ];

    // Filter by search text
    final q = _search.text.trim().toLowerCase();

    // First: by Enabled/Disabled
    final filteredByToggle = products.where((p) {
      final isEnabled = (p['enabled'] as bool?) ?? true;
      if (isEnabled && !_showEnabled) return false;
      if (!isEnabled && !_showDisabled) return false;
      return true;
    });

    // Second: by search
    final filteredProducts = filteredByToggle.where((p) {
      if (q.isEmpty) return true;
      return p['name'].toString().toLowerCase().contains(q) ||
          p['id'].toString().toLowerCase().contains(q);
    }).toList();

    // Small helper: show an “active filters” chip
    Widget? activeFilterChip() {
      if (!_filtersActive) return null;
      String txt;
      if (_showEnabled && !_showDisabled) {
        txt = l10n.filters_showing_enabled_only;
      } else if (!_showEnabled && _showDisabled) {
        txt = l10n.filters_showing_disabled_only;
      } else {
        txt = l10n.filters_custom;
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_alt, size: 16),
            const SizedBox(width: 6),
            Text(txt, style: TextStyle(color: onSurface)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Toolbar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 640;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(widget.title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: onSurface)),
                  SizedBox(
                    width: narrow ? c.maxWidth : 260,
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.hint_search_name_sku,
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1F1F1F) : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openFilters,
                    icon: Icon(
                      Icons.filter_alt_outlined,
                      size: 18,
                      color: _filtersActive ? Theme.of(context).colorScheme.primary : onSurface,
                    ),
                    label: Text(_filtersActive ? l10n.btn_filters_on : l10n.btn_filters),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      side: BorderSide(color: border),
                      foregroundColor: onSurface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: _filtersActive
                          ? (isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF3F3F3))
                          : null,
                    ),
                  ),
                  if (activeFilterChip() != null) activeFilterChip()!,
                ],
              );
            },
          ),
        ),

        // List
        Expanded(
          child: filteredProducts.isEmpty
              ? EmptyModern(l10n: l10n)
              : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => ProductCard(product: filteredProducts[index], l10n: l10n),
          ),
        ),
      ],
    );
  }
}

// Empty state
class EmptyModern extends StatelessWidget {
  const EmptyModern({super.key, required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 56, color: isDark ? Colors.white54 : Colors.black26),
              const SizedBox(height: 14),
              Text(
                l10n.empty_no_linked_products,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.empty_no_linked_products_desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {/* TODO */},
                    icon: const Icon(Icons.add),
                    label: Text(l10n.btn_add_product),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () {/* TODO */},
                    icon: const Icon(Icons.filter_alt_outlined),
                    label: Text(l10n.btn_browse_catalog),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Card
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final AppLocalizations l10n;
  const ProductCard({super.key, required this.product, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final border = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE6E6E6);
    final onSurface = isDark ? Colors.white : Colors.black87;
    final onSurfaceMuted = isDark ? Colors.white70 : Colors.black54;

    final bool enabled = (product['enabled'] as bool?) ?? true;
    final statusLabel = enabled ? l10n.status_enabled : l10n.status_disabled;
    final statusColor = enabled ? Colors.green : Colors.orange;

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF161616) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: border),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.id_with_value(product['id'].toString()),
                  style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceMuted)),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, size: 20, color: onSurfaceMuted),
                onSelected: (_) {},
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'Edit', child: Text(l10n.btn_edit)),
                  PopupMenuItem(value: 'Delete', child: Text(l10n.btn_delete)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Main row
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F1F1F) : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.shopping_bag_outlined, color: isDark ? Colors.white30 : Colors.black38),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(product['name'],
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: onSurface)),
                const SizedBox(height: 4),
                Text(product['type'], style: theme.textTheme.bodyMedium?.copyWith(color: onSurfaceMuted)),
                if (product['status'] != null) ...[
                  const SizedBox(height: 2),
                  Text(l10n.inventory_with_value(product['status'].toString()),
                      style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceMuted)),
                ],
              ]),
            ),
          ]),
          const SizedBox(height: 16),

          // Footer row
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.lbl_price, style: theme.textTheme.bodySmall?.copyWith(color: onSurfaceMuted)),
              Text(l10n.price_with_currency(product['price'].toString()),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: onSurface)),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
            ),
          ]),
        ]),
      ),
    );
  }
}
