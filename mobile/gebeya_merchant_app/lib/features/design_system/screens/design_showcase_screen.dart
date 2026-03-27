import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gebeya_merchant_app/core/ui/theme/app_colors.dart';
import 'package:gebeya_merchant_app/core/ui/theme/app_icons.dart';
import 'package:gebeya_merchant_app/core/ui/theme/app_theme.dart';
import 'package:gebeya_merchant_app/core/utils/app_formatters.dart';

class DesignShowcaseScreen extends StatelessWidget {
  static const String routeLocation = '/design-showcase';

  const DesignShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Typography (Outfit + Inter)'),
            const SizedBox(height: 16),
            Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
            Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
            Text('Title Large (Header)', style: Theme.of(context).textTheme.titleLarge),
            Text('Body Medium (Standard text for the app)', style: Theme.of(context).textTheme.bodyMedium),
            Text('Body Small (Muted text)', style: Theme.of(context).textTheme.bodySmall),

            const SizedBox(height: 32),
            _sectionHeader('Buttons'),
            const SizedBox(height: 16),
            Wrap(
              runSpacing: 16,
              spacing: 16,
              children: [
                FilledButton(onPressed: () {}, child: const Text('Filled Button')),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('With Icon'),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined Button')),
                TextButton(onPressed: () {}, child: const Text('Text Button')),
              ],
            ),
            const SizedBox(height: 16),
            // Gradient Button Mockup
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPurple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                ),
                child: const Center(
                  child: Text(
                    'Premium Gradient Button',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
            _sectionHeader('Inputs'),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: Icon(Icons.visibility_off_outlined),
              ),
              obscureText: true,
            ),

            const SizedBox(height: 32),
            _sectionHeader('Cards'),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.cardTintPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.analytics, color: AppColors.brandPurple),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Total Revenue', style: Theme.of(context).textTheme.bodySmall),
                            Text('ETB 12,450.00', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '+15% from last month',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.brandBlue),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad).fadeIn(),

            const SizedBox(height: 16),
            // Gradient Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandPurple.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Premium features unlocked',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Upgrade your plan to get more insights.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 32),
            _sectionHeader('Number Formatting'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _formatItem('Currency', 12345.67.toCurrency('ETB')),
                _formatItem('Number', 1234567.toFormattedInt()),
                _formatItem('Compact', 1500000.toCompact()),
                _formatItem('Compact Currency', 2500000.toCompactCurrency('ETB')),
              ],
            ),

            const SizedBox(height: 32),
            _sectionHeader('App Icons (Lucide)'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _iconItem('Dashboard', AppIcons.dashboard),
                _iconItem('Products', AppIcons.products),
                _iconItem('Inventory', AppIcons.inventory),
                _iconItem('Sales', AppIcons.sales),
                _iconItem('Settings', AppIcons.settings),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _iconItem(String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.brandPurple),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText)),
      ],
    );
  }

  Widget _formatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightMutedText)),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.lightMutedText),
        ),
        const Divider(),
      ],
    );
  }
}
