import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'next_home_logo.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F1B2B), // Base dark theme color
      child: Column(
        children: [
          // City Skyline Silhouette
          SizedBox(
            width: double.infinity,
            height: 60, // Adjust height as necessary
            child: CustomPaint(
              painter: _SkylinePainter(color: const Color(0xFF1B365D)),
            ),
          ),
          
          // Main Footer Content Area
          Container(
            color: const Color(0xFF1B365D), // Lighter dark blue for contrast
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              children: [
                // 2-Column Grid Layout for Mobile
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: About Us
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('ABOUT US', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(height: 16),
                          Text(
                            'Next Home is a premium rental platform providing seamless experiences. Discover modern apartments, cozy single rooms, and luxurious villas tailored to your lifestyle.',
                            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Column 2: Address
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ADDRESS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          _buildContactRow(Icons.near_me, 'contact@nexthome.com'),
                          const SizedBox(height: 8),
                          _buildContactRow(Icons.phone, '+1 234 567 890'),
                          const SizedBox(height: 8),
                          _buildContactRow(Icons.location_on, '1234 Street Name,\nCity Name, United States'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 3: Company Links
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('COMPANY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          _buildFooterLink(context, 'Home', '/'),
                          _buildFooterLink(context, 'Profile', '/profile'),
                          _buildFooterLink(context, 'Map Search', '/map-search'),
                          _buildFooterLink(context, 'Contact', '#'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Column 4: Newsletter
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NEWSLETTER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 16),
                          const Text(
                            'Keep up on our always evolving product features. Subscribe to our newsletter.',
                            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: TextField(
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      hintStyle: TextStyle(color: Colors.white38),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF42898E), // Updated to match primary app theme
                                    borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.send, color: Colors.white, size: 16),
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Divider and Socials
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.facebook),
                    const SizedBox(width: 8),
                    _buildSocialIcon(Icons.flutter_dash), // Placeholder for Twitter
                    const SizedBox(width: 8),
                    _buildSocialIcon(Icons.rss_feed),
                    const SizedBox(width: 16),
                    Expanded(child: Divider(color: Colors.white.withOpacity(0.2))),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Logo & Copyright
                const SizedBox(
                  height: 50,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: NextHomeLogo(lightTheme: true, size: 200),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Copyright 2026 Next Home Inc. All Rights Reserved.',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          if (route != '#') {
            context.push(route);
          }
        },
        child: Row(
          children: [
            const Icon(Icons.chevron_right, color: Colors.white54, size: 14),
            const SizedBox(width: 4),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xFF42898E),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }
}

class _SkylinePainter extends CustomPainter {
  final Color color;

  _SkylinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    
    // Abstract building heights and widths
    final List<double> heights = [0.8, 0.4, 0.6, 0.3, 0.7, 0.2, 0.5, 0.9, 0.3, 0.6, 0.4, 0.8, 0.2, 0.5, 0.7];
    final double step = size.width / heights.length;
    
    double currentX = 0;
    
    for (int i = 0; i < heights.length; i++) {
      double h = size.height * heights[i];
      // Draw vertical line up to the roof
      path.lineTo(currentX, size.height - h);
      // Draw horizontal roof
      currentX += step;
      path.lineTo(currentX, size.height - h);
    }
    
    // Complete the path back to the bottom right
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SkylinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
