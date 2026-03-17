import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/product.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/product_card.dart';
import 'checkout_screen.dart';

enum ScanResult { none, found, notFound }

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();

  final List<CartItem> _cartItems = [];
  ScanResult _scanResult = ScanResult.none;
  Product? _foundProduct;
  String _lastScanned = '';

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + item.total);
  double get _tax => _subtotal * 0.09;
  double get _total => _subtotal + _tax;

  void _handleBarcodeSubmit(String barcode) {
    if (barcode.trim().isEmpty) return;

    final product = findProductByBarcode(barcode.trim());
    setState(() {
      _lastScanned = barcode.trim();
      if (product != null) {
        _foundProduct = product;
        _scanResult = ScanResult.found;
      } else {
        _foundProduct = null;
        _scanResult = ScanResult.notFound;
      }
    });
    _barcodeController.clear();
    HapticFeedback.lightImpact();
  }

  void _addToCart(Product product) {
    setState(() {
      final existing = _cartItems.where((i) => i.product.id == product.id);
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
      _scanResult = ScanResult.none;
      _foundProduct = null;
    });
    HapticFeedback.mediumImpact();
  }

  void _dismissScanResult() {
    setState(() {
      _scanResult = ScanResult.none;
      _foundProduct = null;
    });
  }

  void _incrementQty(CartItem item) {
    setState(() => item.quantity++);
  }

  void _decrementQty(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
    });
  }

  void _removeItem(CartItem item) {
    setState(() => _cartItems.remove(item));
    HapticFeedback.lightImpact();
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
      _scanResult = ScanResult.none;
    });
  }

  void _simulateScan() {
    final barcodes = mockProducts.map((p) => p.barcode).toList();
    final randomBarcode = barcodes[DateTime.now().millisecondsSinceEpoch % barcodes.length];
    _handleBarcodeSubmit(randomBarcode);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.point_of_sale_rounded,
                  color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'Quick Billing',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: _clearCart,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Clear'),
              style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Scan bar ──────────────────────────────────────────
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocus,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _handleBarcodeSubmit,
                    decoration: InputDecoration(
                      hintText: 'Scan or type barcode…',
                      prefixIcon: const Icon(Icons.qr_code_scanner_rounded),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.tonal(
                  onPressed: _simulateScan,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.document_scanner_rounded),
                ),
              ],
            ),
          ),

          // ── Scan result card ──────────────────────────────────
          if (_scanResult == ScanResult.found && _foundProduct != null)
            ProductFoundCard(
              product: _foundProduct!,
              onAddToCart: () => _addToCart(_foundProduct!),
              onDismiss: _dismissScanResult,
            ),

          if (_scanResult == ScanResult.notFound)
            ProductNotFoundCard(
              barcode: _lastScanned,
              onDismiss: _dismissScanResult,
            ),

          // ── Cart ─────────────────────────────────────────────
          Expanded(
            child: _cartItems.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 120),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return CartItemTile(
                        item: item,
                        onIncrement: () => _incrementQty(item),
                        onDecrement: () => _decrementQty(item),
                        onRemove: () => _removeItem(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomSheet: _cartItems.isEmpty ? null : _buildCheckoutPanel(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 72, color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Scan a barcode or press the scan button\nto add items',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutPanel(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: theme.textTheme.bodyMedium),
              Text('\$${_subtotal.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (9%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
              Text('\$${_tax.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900, color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(
                    cartItems: _cartItems,
                    subtotal: _subtotal,
                    tax: _tax,
                    total: _total,
                    onConfirm: _clearCart,
                  ),
                ),
              ),
              icon: const Icon(Icons.receipt_long_rounded),
              label: Text('Checkout  ·  ${_cartItems.length} items'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}