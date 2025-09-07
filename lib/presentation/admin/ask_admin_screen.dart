import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import 'package:dio/dio.dart';

class AskAdminScreen extends StatelessWidget {
  const AskAdminScreen({super.key});

  Future<void> _submitToMagento(BuildContext context, {
    required String subject,
    required String message,
  }) async {
    try {
      final me = await ApiClient().getCustomerMe();
      final name = '${(me?['firstname'] ?? '').toString()} ${(me?['lastname'] ?? '').toString()}'.trim();
      final email = (me?['email'] ?? '').toString();
      final Map<String, dynamic> body = {
        'name': name.isNotEmpty ? name : 'App User',
        'email': email.isNotEmpty ? email : 'no-reply@kolshy.ae',
        'telephone': '',
        'comment': '[${subject.trim()}]\n\n${message.trim()}',
      };

      await ApiClient().dio.post(
        'contact',
        data: body,
        options: Options(headers: {'Authorization': null}),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.requestSent),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: ${ApiClient().parseMagentoError(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController queryController = TextEditingController();

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
              AppLocalizations.of(context)!.askQuestionTitle,
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
                        AppLocalizations.of(context)!.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Tooltip(
                        message: AppLocalizations.of(context)!.subjectTooltip,
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
                      controller: subjectController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.inputHint,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.yourQuery,
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
                      controller: queryController,
                      minLines: 10,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.inputHint,
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
                      onPressed: () async {
                        if (subjectController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.enterSubject),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (queryController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.enterQuery),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        await _submitToMagento(
                          context,
                          subject: subjectController.text,
                          message: queryController.text,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDD1E1E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.send,
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
