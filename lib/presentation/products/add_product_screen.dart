import 'package:app_vendor/presentation/products/drafts_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dropzone/flutter_dropzone.dart';

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
  final _tagInput = TextEditingController();

  // State
  String _category = 'Food';
  final _categories = const ['Food', 'Electronics', 'Apparel', 'Beauty', 'Home', 'Other'];
  String? _tag; // only one tag
  bool _hasSpecial = false;
  bool _taxes = true;
  String _stockAvail = 'In Stock';
  String _visibility = 'Invisible';
  bool _submitting = false;
  Uint8List? _coverBytes;
  String? _coverName;


  // ---------- styling helpers ----------
  BorderRadius get _radius => BorderRadius.circular(16);

  // Neutral input with optional $ prefix block
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
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
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
        borderSide: const BorderSide(color: Colors.black87, width: 1.5), // black focus
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
          // Wrap the label instead of overflowing
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
              triggerMode: TooltipTriggerMode.tap,   // 👈 tap to show on mobile
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
  void _setTag() {
    final t = _tagInput.text.trim();
    if (t.isNotEmpty) {
      setState(() => _tag = t); // only one tag kept
    }
  }

  void _removeTag() => setState(() => _tag = null);

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;
    await _submit(isDraft: true);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hasSpecial && _sp.text.trim().isNotEmpty) {
      final p = double.tryParse(_amount.text);
      final s = double.tryParse(_sp.text);
      if (p != null && s != null && s >= p) {
        _snack('Special price must be less than Amount', error: true);
        return;
      }
    }
    await _submit(isDraft: false);
  }

  Future<void> _submit({required bool isDraft}) async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600)); // TODO: call your API here
    _snack(isDraft ? 'Draft saved' : 'Product published');
    setState(() => _submitting = false);
  }

  void _delete() {
    // TODO: delete API call
    _snack('Product deleted');
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : Colors.black87),
    );
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    // Force black switches (no purple)
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
        child: Theme( // local theme override for switches
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
                        Text('Product', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
                              _sectionCard(title: 'Name & description', children: [
                                _label('Product title', help: 'Enter the full product name (e.g., Apple iPhone 14 Pro).'),
                                TextFormField(
                                  controller: _title,
                                  decoration: _dec(context, hint: 'Input your text'),
                                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                                ),
                                const SizedBox(height: 20),

                                _label('Category', help: 'Select the category that best fits your product.'),
                                DropdownButtonFormField<String>(
                                  value: _category,
                                  items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _category = v ?? _category),
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                _label('Tags', help: 'Add one keyword that describes your product.'),
                                _buildTagInput(),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: 'Description',
                                  help: 'Detailed description of features, materials, sizing, etc.',
                                  controller: _desc,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: 'Short Description',
                                  help: 'Short summary (1–2 sentences) for listings/search results.',
                                  controller: _shortDesc,
                                  minLines: 5,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                _label('SKU', help: 'Unique stock keeping unit (e.g., SKU-12345).'),
                                TextFormField(
                                  controller: _sku,
                                  decoration: _dec(context, hint: 'Ex: SKU-12345'),
                                ),
                              ]),

                              // Price
                              _sectionCard(title: 'Price', children: [
                                _label('Amount', help: 'Base selling price without discounts.'),
                                TextFormField(
                                  controller: _amount,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                  decoration: _dec(
                                    context,
                                    hint: '8',
                                    prefix: const Text('\$', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                  validator: (v) => (v == null || num.tryParse(v) == null) ? 'Enter a valid number' : null,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(child: _label('Special Price', help: 'Turn on to add a promotional/sale price.')),
                                    Switch(value: _hasSpecial, onChanged: (v) => setState(() => _hasSpecial = v)),
                                  ],
                                ),
                                const Divider(height: 24, color: Color(0xFFE5E5E5)),

                                if (_hasSpecial) ...[
                                  _label('Special price', help: 'Discounted price that overrides the regular amount.'),
                                  TextFormField(
                                    controller: _sp,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                                    decoration: _dec(
                                      context,
                                      hint: 'e.g., 24.99',
                                      prefix: const Text('\$', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                _label('Minimum amount', help: 'Minimum quantity a customer is allowed to purchase.'),
                                TextFormField(
                                  controller: _minQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(
                                    context,
                                    hint: '0',
                                    prefix: const Text('\$', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _label('Maximum amount', help: 'Maximum quantity a customer is allowed to purchase.'),
                                TextFormField(
                                  controller: _maxQty,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(
                                    context,
                                    hint: '0',
                                    prefix: const Text('\$', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black)),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(child: _label('Taxes', help: 'Apply taxes to this product at checkout.')),
                                    Switch(value: _taxes, onChanged: (v) => setState(() => _taxes = v)),
                                  ],
                                ),
                              ]),

                              // Stock & availability
                              _sectionCard(title: 'Stock & Availability', children: [
                                _label('Stock', help: 'Number of units available.'),
                                TextFormField(
                                  controller: _stock,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: 'e.g., 100'),
                                ),
                                const SizedBox(height: 20),

                                _label('Weight', help: 'Weight in kilograms (used for shipping).'),
                                TextFormField(
                                  controller: _weight,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}'))],
                                  decoration: _dec(context, hint: 'e.g., 0.50'),
                                ),
                                const SizedBox(height: 20),

                                _label('Allowed Quantity per Customer',
                                    help: 'Optional: maximum number of units a single customer can buy for this product.'
                                ),
                                TextFormField(
                                  controller: _maxQty, // or create its own controller, e.g. _perCustomerLimit
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: _dec(context, hint: 'e.g., 5'),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return null; // optional
                                    final n = int.tryParse(v);
                                    if (n == null || n < 0) return 'Enter a non-negative number';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                _label('Stock Availability', help: 'Choose current availability status.'),
                                DropdownButtonFormField<String>(
                                  value: _stockAvail,
                                  items: const ['In Stock', 'Out of Stock']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _stockAvail = v ?? _stockAvail),
                                  decoration: _dec(context),
                                ),
                                const SizedBox(height: 20),

                                _label('Visibility', help: 'Invisible products are hidden from the storefront.'),
                                DropdownButtonFormField<String>(
                                  value: _visibility,
                                  items: const ['Invisible', 'Visible']
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (v) => setState(() => _visibility = v ?? _visibility),
                                  decoration: _dec(context),
                                ),
                              ]),

                              // Meta
                              _sectionCard(title: 'Meta Infos', children: [
                                _label('Url Key', help: 'SEO-friendly slug used in the product URL.'),
                                TextFormField(
                                  controller: _url,
                                  decoration: _dec(context, hint: 'e.g., apple-iphone-14-pro'),
                                ),
                                const SizedBox(height: 20),

                                _label('Meta Title', help: 'Title shown in search engine results.'),
                                TextFormField(
                                  controller: _metaTitle,
                                  decoration: _dec(context, hint: 'e.g., Buy the iPhone 14 Pro'),
                                ),
                                const SizedBox(height: 20),
                                DescriptionMarkdownField(
                                  label: 'Meta Keywords',
                                  help: 'Optional: comma-separated keywords.',
                                  controller: _metaKeywords,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),

                                DescriptionMarkdownField(
                                  label: 'Meta Description',
                                  help: 'Short paragraph for search engines (150–160 chars).',
                                  controller: _metaDesc,
                                  minLines: 8,
                                  showPreview: true,
                                ),
                                const SizedBox(height: 20),


                                _label('Cover images', help: 'Upload a clear, high-resolution product image.'),
                                Container(
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
                                      // Preview
                                      if (_coverBytes != null)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: Image.memory(_coverBytes!, fit: BoxFit.cover),
                                        ),
                                      // Click target (always)
                                      Center(
                                        child: InkWell(
                                          onTap: _pickCover,
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
                                                  _coverName == null ? 'Click or drop image' : _coverName!,
                                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // (Optional) true drag & drop on web using flutter_dropzone
                                      if (kIsWeb)
                                        IgnorePointer(
                                          ignoring: false,
                                          child: LayoutBuilder(
                                            builder: (_, __) {
                                              return Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(16),
                                                  child: DropzoneView(
                                                    operation: DragOperation.copy,
                                                    mime: const ['image/png', 'image/jpeg', 'image/webp'],
                                                    onDrop: (ev) async {
                                                      final bytes = await ev.getFileData();
                                                      final name  = await ev.getFilename();
                                                      setState(() {
                                                        _coverBytes = bytes;
                                                        _coverName  = name;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),



                                // sticky footer
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
                            child: const Text('Save Draft'),
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
                                : const Text('Publish now'),
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
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                              ]),
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
      )
    );
  }
  // Tag input (single tag + black chip)
  Widget _buildTagInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Row(
        children: [
          if (_tag != null)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 2))],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_tag!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _removeTag,
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: TextField(
                controller: _tagInput,
                decoration: const InputDecoration.collapsed(hintText: 'Enter one tag and press Enter'),
                onSubmitted: (_) => _setTag(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image, // Only allow images
      withData: true, // Get the file's binary data
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _coverBytes = file.bytes;
        _coverName = file.name;
      });
    }
  }

}

class _IconRow extends StatelessWidget {
  const _IconRow(this.icons);
  final List<IconData> icons;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final i in icons) ...[
          Icon(i, size: 20, color: Colors.black87),
          const SizedBox(width: 14),
        ]
      ],
    );
  }
}
