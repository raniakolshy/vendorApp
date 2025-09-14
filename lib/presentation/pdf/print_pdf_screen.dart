import 'package:kolshy_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:dio/dio.dart';

class PrintPdfScreen extends StatefulWidget {
  const PrintPdfScreen({
    super.key,
    this.invoiceId,
    this.adminToken = '87igct1wbbphdok6dk1roju4i83kyub9',
  });

  final int? invoiceId;
  final String adminToken;

  @override
  State<PrintPdfScreen> createState() => _PrintPdfScreenState();
}

class _PrintPdfScreenState extends State<PrintPdfScreen> {
  final TextEditingController _infoController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  Map<String, dynamic>? _invoice;
  String? _lastComment;

  @override
  void initState() {
    super.initState();
    _loadInvoiceAndComments();
  }

  Future<void> _loadInvoiceAndComments() async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.invoiceId == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.invoiceDetailsSubtitle),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final inv = await VendorApiClient().getInvoiceById(
        invoiceId: widget.invoiceId!,
      );

      final comments = await VendorApiClient().getInvoiceComments(
        invoiceId: widget.invoiceId!,
      );

      String? latest;
      if (comments.isNotEmpty) {
        comments.sort((a, b) {
          final atA = DateTime.tryParse('${a['created_at'] ?? ''}') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final atB = DateTime.tryParse('${b['created_at'] ?? ''}') ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return atB.compareTo(atA);
        });
        latest = comments.first['comment']?.toString();
      }

      if (!mounted) return;
      setState(() {
        _invoice = inv;
        _lastComment = latest;
        if (latest != null && latest.trim().isNotEmpty) {
          _infoController.text = latest;
        }
      });
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToExport} ${e.response?.data['message'] ?? e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToExport} $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveComment() async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.invoiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.saveInfoEmpty),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
      return;
    }

    final text = _infoController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.saveInfoEmpty),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await VendorApiClient().addInvoiceComment(
        invoiceId: widget.invoiceId!,
        comment: text,
        isVisibleOnFront: true,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.saveInfoSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );

      await _loadInvoiceAndComments();
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToExport} ${e.response?.data['message'] ?? e.message}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.failedToExport} $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.printPdfTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 20),
            Container(
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
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.invoiceDetailsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.invoiceDetailsSubtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    if (_invoice != null) ...[
                      Text(
                        'Invoice #${_invoice!['increment_id'] ?? _invoice!['entity_id']} • '
                            'Order #${_invoice!['order_increment_id'] ?? ''}',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _infoController,
                        maxLines: 8,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: l10n.invoiceDetailsHint,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(fontSize: 15),
                        enabled: !_loading && !_saving && widget.invoiceId != null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_loading || _saving || widget.invoiceId == null)
                            ? null
                            : _saveComment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE31741),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _saving
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          l10n.saveInfoButton,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.invoiceId == null
                    ? 'No invoice selected.'
                    : l10n.invoiceDetailsFooter,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}