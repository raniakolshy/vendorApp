import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/state_management/locale_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const Color _bgScaffold = Color(0xFFFAFAFA);
  static const Color _primary = Color(0xFFDD1E1E); // Updated to match your red color
  static const Color _stroke = Color(0xFFE5E5E5); // Updated border color

  late String selectedLanguage;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLanguage = 'english'; // Default value
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        final locale = localeProvider.locale;

        if (locale == null) {
          return Scaffold(
            backgroundColor: _bgScaffold,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Text(
                t.language,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final code = locale.languageCode;

        if (code == 'ar') {
          selectedLanguage = 'arabic';
        } else if (code == 'fr') {
          selectedLanguage = 'french';
        } else {
          selectedLanguage = 'english';
        }

        final all = <_LangItem>[
          _LangItem(
            label: t.english,
            value: 'english',
            flag: '🇬🇧',
            locale: const Locale('en'),
          ),
          _LangItem(
            label: t.arabic,
            value: 'arabic',
            flag: '🇸🇦',
            locale: const Locale('ar'),
          ),
        ];

        final q = _searchController.text.trim().toLowerCase();
        final filtered = all.where((e) {
          if (q.isEmpty) return true;
          return e.label.toLowerCase().contains(q) || e.value.contains(q);
        }).toList();

        return Scaffold(
          backgroundColor: _bgScaffold,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false, //
            title: Text(
              t.language,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SearchField(
                            controller: _searchController,
                            hintText: t.search,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Center(
                                child: Text(
                                  _noResultsText(context),
                                  style: const TextStyle(
                                    color: Color(0xFF999999),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (_, i) {
                                  final item = filtered[i];
                                  final isSelected = selectedLanguage == item.value;
                                  return _LanguageCard(
                                    item: item,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() => selectedLanguage = item.value);
                                      localeProvider.setLocale(item.locale);
                                    },
                                  );
                                },
                                separatorBuilder: (_, __) => const SizedBox(height: 12),
                                itemCount: filtered.length,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _noResultsText(BuildContext context) {
    switch (Localizations.localeOf(context).languageCode) {
      case 'ar':
        return 'لا توجد نتائج';
      case 'fr':
        return 'Aucun résultat';
      default:
        return 'No results found';
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  static const Color _stroke = Color(0xFFE5E5E5);
  static const Color _hint = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _stroke),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFF999999), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF333333),
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: _hint, fontSize: 16),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF999999), size: 20),
              onPressed: () {
                controller.clear();
                FocusScope.of(context).unfocus();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _LangItem item;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _primary = Color(0xFFDD1E1E);
  static const Color _stroke = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _primary : _stroke,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(item.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            _RadioPill(isOn: isSelected),
          ],
        ),
      ),
    );
  }
}

class _RadioPill extends StatelessWidget {
  const _RadioPill({required this.isOn});
  final bool isOn;

  static const Color _primary = Color(0xFFDD1E1E);
  static const Color _off = Color(0xFFE5E5E5);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isOn ? _primary : _off,
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isOn ? 12 : 0,
          height: isOn ? 12 : 0,
          decoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _LangItem {
  final String label;
  final String value;
  final String flag;
  final Locale locale;

  const _LangItem({
    required this.label,
    required this.value,
    required this.flag,
    required this.locale,
  });
}