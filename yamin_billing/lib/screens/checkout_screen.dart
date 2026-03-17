import 'package:flutter/material.dart';
import '../models/product.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final double tax;
  final double total;
  final VoidCallback onConfirm;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onConfirm,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'cash';
  bool _confirmed = false;

  void _confirm() {
    setState(() => _confirmed = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      widget.onConfirm();
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_confirmed) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    color: Colors.green.shade600, size: 60),
              ),
              const SizedBox(height: 24),
              Text('Payment Confirmed!',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                '\$${widget.total.toStringAsFixed(2)} received',
                style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('Order Summary',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  ...widget.cartItems.map((item) => ListTile(
                        leading: Text(item.product.imageEmoji,
                            style: const TextStyle(fontSize: 24)),
                        title: Text(item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('x${item.quantity} @ \$${item.product.price.toStringAsFixed(2)}'),
                        trailing: Text('\$${item.total.toStringAsFixed(2)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary)),
                        dense: true,
                      )),
                  const Divider(indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal', style: theme.textTheme.bodyMedium),
                        Text('\$${widget.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax (9%)',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                        Text('\$${widget.tax.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        Text('\$${widget.total.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text('Payment Method',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...[
              ('cash', Icons.payments_rounded, 'Cash'),
              ('card', Icons.credit_card_rounded, 'Card'),
              ('mobile', Icons.phone_android_rounded, 'Mobile Pay'),
            ].map((entry) {
              final (value, icon, label) = entry;
              final selected = _selectedPayment == value;
              return GestureDetector(
                onTap: () => setState(() => _selectedPayment = value),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon,
                          color: selected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 12),
                      Text(label,
                          style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                      const Spacer(),
                      if (selected)
                        Icon(Icons.check_circle_rounded,
                            color: theme.colorScheme.primary, size: 20),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _confirm,
            icon: const Icon(Icons.check_rounded),
            label: Text('Confirm Payment  ·  \$${widget.total.toStringAsFixed(2)}'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}