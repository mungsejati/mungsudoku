import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';


class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  void _handlePurchase(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pembelian $itemName berhasil ditambahkan ke akun (Mock)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const topBarTextColor = Colors.white;
    
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/arrow-left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(topBarTextColor, BlendMode.srcIn),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Shop',
          style: TextStyle(
            color: topBarTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _ProductCard(
            title: 'Remove Ads',
            price: 'Rp 15.000',
            icon: Icons.not_interested_rounded,
            onTap: () => _handlePurchase(context, 'Remove Ads'),
          ),
          const SizedBox(height: 16),
          _ProductCard(
            title: 'Skins / Themes',
            price: 'Rp 10.000',
            icon: Icons.palette_outlined,
            onTap: () => _handlePurchase(context, 'Skins / Themes'),
          ),
          const SizedBox(height: 16),
          _ProductCard(
            title: '+5 Hints',
            price: 'Rp 5.000',
            icon: Icons.lightbulb_outline_rounded,
            onTap: () => _handlePurchase(context, '+5 Hints'),
          ),
          const SizedBox(height: 16),
          _ProductCard(
            title: '+20 Hints',
            price: 'Rp 15.000',
            icon: Icons.lightbulb_outline_rounded,
            onTap: () => _handlePurchase(context, '+20 Hints'),
          ),
          const SizedBox(height: 16),
          _ProductCard(
            title: 'Fast Notes Pack',
            price: 'Rp 12.000',
            icon: Icons.edit_note_rounded,
            onTap: () => _handlePurchase(context, 'Fast Notes Pack'),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.title,
    required this.price,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String price;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 32),
          ],
        ),
      ),
    );
  }
}
