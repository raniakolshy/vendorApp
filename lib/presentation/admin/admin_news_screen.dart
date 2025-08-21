import 'package:flutter/material.dart';

class AdminNewsScreen extends StatefulWidget {
  const AdminNewsScreen({super.key});

  @override
  State<AdminNewsScreen> createState() => _AdminNewsScreenState();
}

class _AdminNewsScreenState extends State<AdminNewsScreen> {
  // Liste de données d'exemple pour les actualités avec types
  final List<Map<String, dynamic>> _newsItems = [
    {
      'title': 'Issue Fixed',
      'content': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc vulputate libero et velit interdum, ac aliquet odio mattis.',
      'time': '2 m ago',
      'type': 'fix', // fix, feature, maintenance, delivery, payment, security
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'title': 'New Feature Added',
      'content': 'A new feature has been added to improve your experience. Check it out now!',
      'time': '10 m ago',
      'type': 'feature',
      'icon': Icons.new_releases,
      'color': Colors.blue,
    },
    {
      'title': 'Server Maintenance',
      'content': 'Scheduled server maintenance will occur on Thursday at 2 AM UTC.',
      'time': '1 h ago',
      'type': 'maintenance',
      'icon': Icons.build,
      'color': Colors.orange,
    },
    {
      'title': 'Delivery Issues',
      'content': 'Some delivery routes are experiencing delays due to weather conditions.',
      'time': '3 h ago',
      'type': 'delivery',
      'icon': Icons.local_shipping,
      'color': Colors.purple,
    },
    {
      'title': 'Payment System Update',
      'content': 'We have updated our payment processing system for better security.',
      'time': '5 h ago',
      'type': 'payment',
      'icon': Icons.payment,
      'color': Colors.teal,
    },
    {
      'title': 'Security Alert',
      'content': 'Important security update required. Please update your app immediately.',
      'time': '1 d ago',
      'type': 'security',
      'icon': Icons.security,
      'color': Colors.red,
    },
  ];

  void _refreshNews() {
    // Cette fonction simule un rafraîchissement de la liste d'actualités.
    setState(() {
      _newsItems.clear();
      _newsItems.addAll([
        {
          'title': 'Refreshed News 1',
          'content': 'This is a new news item fetched after a refresh.',
          'time': 'just now',
          'type': 'feature',
          'icon': Icons.new_releases,
          'color': Colors.blue,
        },
        {
          'title': 'Delivery System Improved',
          'content': 'We have optimized our delivery routes for faster shipping.',
          'time': '2 m ago',
          'type': 'delivery',
          'icon': Icons.local_shipping,
          'color': Colors.purple,
        },
        {
          'title': 'Payment Gateway Updated',
          'content': 'Added support for new payment methods including cryptocurrency.',
          'time': '5 m ago',
          'type': 'payment',
          'icon': Icons.payment,
          'color': Colors.teal,
        },
        {
          'title': 'Bug Fixes',
          'content': 'Fixed several minor bugs reported by users in the last update.',
          'time': '10 m ago',
          'type': 'fix',
          'icon': Icons.bug_report,
          'color': Colors.green,
        },
      ]);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('News list refreshed!'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
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
        content: const Text('News deleted successfully.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        action: SnackBarAction(
          label: 'Undo',
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
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Admin News',
                style: TextStyle(
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
                          const Text(
                            'Recent Updates',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.grey),
                            onPressed: _refreshNews,
                            tooltip: 'Refresh news',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _newsItems.isEmpty
                            ? const Center(
                          child: Text(
                            'No news updates available',
                            style: TextStyle(
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
                                title: newsItem['title']!,
                                content: newsItem['content']!,
                                time: newsItem['time']!,
                                icon: newsItem['icon']!,
                                color: newsItem['color']!,
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
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
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