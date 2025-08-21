import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key});

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  // Mock data to simulate fetching from an API
  final Map<String, dynamic> _vendorData = {
    'companyName': 'Gadgets & Gear Co.',
    'location': 'New York, USA',
    'bio': 'We are a leading provider of high-quality electronics and adventure gear. Our mission is to bring you the best products to enhance your daily life and outdoor experiences.',
    'logoUrl': 'assets/logo.jpg',
    'bannerUrl': 'assets/welcome_background.jpeg',
    'socialMedia': {
      'twitter': 'gadgets_gear',
      'instagram': 'gadgets_gear_official',
      'youtube': 'GadgetsAndGear',
    },
    'products': [
      {'name': 'Wireless Headphones', 'price': 'AED 129.99', 'category': 'Electronics', 'imageUrl': 'assets/img_square.jpg'},
      {'name': 'Smartwatch', 'price': 'AED 249.00', 'category': 'Electronics', 'imageUrl': 'assets/img_square.jpg'},
      {'name': 'Portable Power Bank', 'price': 'AED 45.50', 'category': 'Accessories', 'imageUrl': 'assets/img_square.jpg'},
      {'name': 'Action Camera', 'price': 'AED 399.99', 'category': 'Electronics', 'imageUrl': 'assets/img_square.jpg'},
      {'name': 'Bluetooth Speaker', 'price': 'AED 89.95', 'category': 'Electronics', 'imageUrl': 'assets/img_square.jpg'},
      {'name': 'Drone', 'price': 'AED 550.00', 'category': 'Electronics', 'imageUrl': 'assets/img_square.jpg'},
    ],
  };

  // Helper function to get the correct social media icon
  IconData _getSocialMediaIcon(String id) {
    switch (id) {
      case 'twitter':
        return FontAwesomeIcons.twitter;
      case 'facebook':
        return FontAwesomeIcons.facebook;
      case 'instagram':
        return FontAwesomeIcons.instagram;
      case 'youtube':
        return FontAwesomeIcons.youtube;
      case 'pinterest':
        return FontAwesomeIcons.pinterest;
      case 'tiktok':
        return FontAwesomeIcons.tiktok;
      default:
        return Icons.link;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image (Background Profile Picture)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E5E5),
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(_vendorData['bannerUrl']), // Using the new background image
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo (Updated to use new logo)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withOpacity(0.1)),
                          image: DecorationImage(
                            image: AssetImage(_vendorData['logoUrl']), // Using the new logo image
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Vendor Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _vendorData['companyName'],
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  _vendorData['location'],
                                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Social Media Links
                            Wrap(
                              spacing: 8.0,
                              children: _vendorData['socialMedia'].entries.map<Widget>((entry) {
                                return IconButton(
                                  onPressed: () {
                                    // Handle social media link tap
                                  },
                                  icon: FaIcon(_getSocialMediaIcon(entry.key), color: Colors.black87),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bio Section
                  _sectionCard(title: 'About Us', children: [
                    Text(_vendorData['bio']),
                  ]),

                  // Products Section
                  _sectionCard(title: 'Our Products', children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: _vendorData['products'].length,
                      itemBuilder: (context, index) {
                        final product = _vendorData['products'][index];
                        return _buildProductCard(product);
                      },
                    ),
                  ]),

                  // Back to Edit Profile Button (at the bottom)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Go back to the Edit Profile screen
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20, // Make the icon smaller for better balance
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,  // Increase the font size slightly
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,  // Replaced 'primary' with 'backgroundColor'
                        foregroundColor: Colors.white, // Replaced 'onPrimary' with 'foregroundColor'
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),  // More rounded corners
                        ),
                        elevation: 5, // Add shadow for depth
                        shadowColor: Colors.black.withOpacity(0.2), // Light shadow color
                      ),
                    ),
                  )



                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, String> product) {
    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              product['imageUrl']!,
              height: 120, // Reduced size to prevent overflow
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product['category']!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  product['price']!,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
