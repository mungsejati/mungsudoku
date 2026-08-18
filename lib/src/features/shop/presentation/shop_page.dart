import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model for a pricing tier.
// ─────────────────────────────────────────────────────────────────────────────

class _TierData {
  final String title;
  final String price;
  final List<String> benefits;
  final bool isHighlighted;
  final String? badge;

  const _TierData({
    required this.title,
    required this.price,
    required this.benefits,
    this.isHighlighted = false,
    this.badge,
  });
}

const _tiers = [
  _TierData(
    title: 'Silver',
    price: 'Rp 159K',
    benefits: [
      'Pro Upgrade',
      'Silver Badge',
      'Wall of Founders',
    ],
  ),
  _TierData(
    title: 'Gold',
    price: 'Rp 299K',
    benefits: [
      'Semua Silver',
      'Unlimited Hints',
      'Gold Badge',
      'Discord Access',
      'Tema Gold Onyx',
    ],
    isHighlighted: true,
    badge: 'Best Value',
  ),
  _TierData(
    title: 'Diamond',
    price: 'Rp 799K',
    benefits: [
      'Semua Gold',
      'Diamond Badge',
      'Top Credits',
      'Early Access VIP',
      'Discord VIP Role',
    ],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────

class ShopPage extends ConsumerWidget {
  const ShopPage({super.key});

  void _handlePurchase(BuildContext context, String itemName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Berhasil mengklaim $itemName!'),
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
            colorFilter: const ColorFilter.mode(
              topBarTextColor,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Shop',
          style: TextStyle(color: topBarTextColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // ── Area A & B: 2-column compact row ─────────────────────────
          const _SectionTitle(title: "Today's Offers"),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _CompactProductCard(
                    title: 'Daily Focus',
                    price: 'FREE',
                    description: '+3 Hint gratis hari ini. Jaga streak-mu!',
                    buttonText: 'Claim',
                    isPrimary: false,
                    onTap: () =>
                        _handlePurchase(context, 'paket Daily Focus Allowance'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CompactProductCard(
                    title: 'Pro Upgrade',
                    price: 'Rp 79.000',
                    description: 'Ad-Free & Unlimited Fast Notes.',
                    buttonText: 'Upgrade',
                    isPrimary: true,
                    onTap: () =>
                        _handlePurchase(context, 'paket Pro Focus Upgrade'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Area C: The Founders ──────────────────────────────────────
          // Scarcity Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade700, width: 2),
            ),
            child: Column(
              children: [
                const Text(
                  'THE FOUNDERS EDITION',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.amber,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Global Founder Slots: 1,452 / 2,000 Tersisa',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.amber.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: 548 / 2000,
                  backgroundColor: Colors.white,
                  color: Colors.amber.shade700,
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── 3-Column Comparison Pricing Table ────────────────────────
          _PricingTable(
            tiers: _tiers,
            onSelect: (tier) =>
                _handlePurchase(context, 'paket ${tier.title} Investor'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.4,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Compact card used in the 2-column top row.
class _CompactProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String description;
  final String buttonText;
  final bool isPrimary;
  final VoidCallback onTap;

  const _CompactProductCard({
    required this.title,
    required this.price,
    required this.description,
    required this.buttonText,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final isBlackTheme = primaryColor == const Color(0xFF5A5A5A);
    final shadowColor = isBlackTheme
        ? const Color(0xFF3E3E3E)
        : Colors.black.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isPrimary ? primaryColor : Colors.grey.shade200,
                foregroundColor: isPrimary ? Colors.white : primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: onTap,
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 3-column pricing comparison table.
class _PricingTable extends StatelessWidget {
  final List<_TierData> tiers;
  final void Function(_TierData tier) onSelect;

  const _PricingTable({required this.tiers, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tiers.map((tier) {
        final isHighlighted = tier.isHighlighted;
        // Give the highlighted card extra vertical room so it "floats" above.
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: isHighlighted ? 0 : 12,
              left: tiers.indexOf(tier) == 0 ? 0 : 5,
              right: tiers.indexOf(tier) == tiers.length - 1 ? 0 : 5,
            ),
            child: _PricingTierCard(
              tier: tier,
              onSelect: () => onSelect(tier),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Individual pricing tier card — light for Silver/Diamond, dark for Gold.
class _PricingTierCard extends StatelessWidget {
  final _TierData tier;
  final VoidCallback onSelect;

  const _PricingTierCard({required this.tier, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final bool isDark = tier.isHighlighted;
    final Color cardBg = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final Color titleColor = isDark ? Colors.white : primaryColor;
    final Color priceColor = isDark ? Colors.amber.shade300 : Colors.black87;
    final Color benefitColor =
        isDark ? Colors.white70 : Colors.black.withValues(alpha: 0.65);
    final Color checkColor =
        isDark ? Colors.amber.shade400 : Colors.green.shade600;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 5),
            blurRadius: isDark ? 12 : 4,
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.25),
          width: isDark ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Badge (only on highlighted tier)
          if (tier.badge != null)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Text(
                tier.badge!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  tier.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                // Price
                Text(
                  tier.price,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),
                const SizedBox(height: 10),
                // Benefits list
                ...tier.benefits.map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, size: 11, color: checkColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            b,
                            style: TextStyle(
                              fontSize: 10,
                              color: benefitColor,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // CTA button
                isDark
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade500,
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: onSelect,
                        child: const Text(
                          'Pilih Paket',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: BorderSide(
                            color: primaryColor.withValues(alpha: 0.6),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: onSelect,
                        child: const Text(
                          'Pilih Paket',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
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
