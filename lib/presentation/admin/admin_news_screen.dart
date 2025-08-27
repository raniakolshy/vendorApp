import 'package:app_vendor/l10n/app_localizations.dart';
import 'package:app_vendor/l10n/app_localizations_ar.dart';
import 'package:app_vendor/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  final List<Map<String, dynamic>> _newsItems = [
    {
      'title': 'issueFixed',
      'content': 'issueFixedContent',
      'time': 'time2mAgo',
      'type': 'fix',
    },
    {
      'title': 'newFeature',
      'content': 'newFeatureContent',
      'time': 'time10mAgo',
      'type': 'feature',
    },
    {
      'title': 'serverMaintenance',
      'content': 'serverMaintenanceContent',
      'time': 'time1hAgo',
      'type': 'maintenance',
    },
    {
      'title': 'deliveryIssues',
      'content': 'deliveryIssuesContent',
      'time': 'time3hAgo',
      'type': 'delivery',
    },
    {
      'title': 'paymentUpdate',
      'content': 'paymentUpdateContent',
      'time': 'time5hAgo',
      'type': 'payment',
    },
    {
      'title': 'securityAlert',
      'content': 'securityAlertContent',
      'time': 'time1dAgo',
      'type': 'security',
    },
  ];

  void _refreshNews() {
    setState(() {
      _newsItems.clear();
      _newsItems.addAll([
        {
          'title': 'refreshed1',
          'content': 'refreshed1Content',
          'time': 'timeJustNow',
          'type': 'feature',
        },
        {
          'title': 'deliveryImproved',
          'content': 'deliveryImprovedContent',
          'time': 'time2mAgo',
          'type': 'delivery',
        },
        {
          'title': 'paymentGatewayUpdated',
          'content': 'paymentGatewayUpdatedContent',
          'time': 'time5mAgo',
          'type': 'payment',
        },
        {
          'title': 'bugFixes',
          'content': 'bugFixesContent',
          'time': 'time10mAgo',
          'type': 'fix',
        },
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.newsRefreshed),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }

  void _deleteNewsItem(int index) {
    final deletedItem = _newsItems[index];
    setState(() {
      _newsItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.newsDeleted),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _newsItems.insert(index, deletedItem);
            });
          },
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'fix':
        return Icons.check_circle;
      case 'feature':
        return Icons.new_releases;
      case 'maintenance':
        return Icons.build;
      case 'delivery':
        return Icons.local_shipping;
      case 'payment':
        return Icons.payment;
      case 'security':
        return Icons.security;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'fix':
        return Colors.green;
      case 'feature':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'delivery':
        return Colors.purple;
      case 'payment':
        return Colors.teal;
      case 'security':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.adminNews,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.recentUpdates,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.grey),
                            onPressed: _refreshNews,
                            tooltip: loc.refreshNews,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _newsItems.isEmpty
                            ? Center(
                          child: Text(
                            loc.noNews,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: _newsItems.length,
                          itemBuilder: (context, index) {
                            final newsItem = _newsItems[index];
                            return Dismissible(
                              key: Key('news_${newsItem['title']}_$index'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              onDismissed: (direction) => _deleteNewsItem(index),
                              child: _buildNewsItem(
                                title: loc.getString(newsItem['title']),
                                content: loc.getString(newsItem['content']),
                                time: loc.getString(newsItem['time']),
                                icon: _getIconForType(newsItem['type']),
                                color: _getColorForType(newsItem['type']),
                              ),
                            );
                          },
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
  }

  Widget _buildNewsItem({
    required String title,
    required String content,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension LocalizationExtension on AppLocalizations {
  String getString(String key) {
    switch (key) {
      case 'issueFixed':
        return issueFixed;
      case 'issueFixedContent':
        return issueFixedContent;
      case 'newFeature':
        return newFeature;
      case 'newFeatureContent':
        return newFeatureContent;
      case 'serverMaintenance':
        return serverMaintenance;
      case 'serverMaintenanceContent':
        return serverMaintenanceContent;
      case 'deliveryIssues':
        return deliveryIssues;
      case 'deliveryIssuesContent':
        return deliveryIssuesContent;
      case 'paymentUpdate':
        return paymentUpdate;
      case 'paymentUpdateContent':
        return paymentUpdateContent;
      case 'securityAlert':
        return securityAlert;
      case 'securityAlertContent':
        return securityAlertContent;
      case 'refreshed1':
        return refreshed1;
      case 'refreshed1Content':
        return refreshed1Content;
      case 'deliveryImproved':
        return deliveryImproved;
      case 'deliveryImprovedContent':
        return deliveryImprovedContent;
      case 'paymentGatewayUpdated':
        return paymentGatewayUpdated;
      case 'paymentGatewayUpdatedContent':
        return paymentGatewayUpdatedContent;
      case 'bugFixes':
        return bugFixes;
      case 'bugFixesContent':
        return bugFixesContent;
      case 'time2mAgo':
        return time2mAgo;
      case 'time10mAgo':
        return time10mAgo;
      case 'time1hAgo':
        return time1hAgo;
      case 'time3hAgo':
        return time3hAgo;
      case 'time5hAgo':
        return time5hAgo;
      case 'time1dAgo':
        return time1dAgo;
      case 'timeJustNow':
        return timeJustNow;
      default:
        return key;
    }
  }
}