import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'package:dio/dio.dart';

class AskAdminScreen extends StatefulWidget {
  const AskAdminScreen({super.key});

  @override
  State<AskAdminScreen> createState() => _AskAdminScreenState();
}

class _AskAdminScreenState extends State<AskAdminScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();
  bool _isSending = false;

  Future<void> _submitToMagento() async {
    if (_subjectController.text.trim().isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.enterSubject, Colors.red);
      return;
    }
    if (_queryController.text.trim().isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.enterQuery, Colors.red);
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final VendorProfile me = await VendorApiClient().getVendorProfile();
      // Use typed properties instead of map access
      final name = '${me.companyName ?? ''}'.trim();
      final email = '';
      final messageBody = '[${_subjectController.text.trim()}]\n\n${_queryController.text.trim()}';

      await VendorApiClient().sendContactMessage(
        name: name.isNotEmpty ? name : 'App User',
        email: email.isNotEmpty ? email : 'no-reply@kolshy.ae',
        telephone: '',
        comment: messageBody,
      );

      _showSnackBar(AppLocalizations.of(context)!.requestSent, Colors.green);
      _subjectController.clear();
      _queryController.clear();
    } on DioException catch (e) {
      _showSnackBar('Failed to send: ${e.response?.data['message'] ?? e.message}', Colors.red);
    } catch (e) {
      _showSnackBar('Failed to send: $e', Colors.red);
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.askQuestionTitle,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        loc.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Tooltip(
                        message: loc.subjectTooltip,
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: loc.inputHint,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    loc.yourQuery,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E5E5)),
                    ),
                    child: TextField(
                      controller: _queryController,
                      minLines: 10,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: loc.inputHint,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _submitToMagento,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDD1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSending
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        loc.send,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}