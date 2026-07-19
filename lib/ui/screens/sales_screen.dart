import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../services/export_service.dart';

class SalesScreen extends StatefulWidget {
  final String userRole;
  const SalesScreen({super.key, required this.userRole});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _products = [];
  final List<Map<String, dynamic>> _cart = [];
  double _discount = 0;
  final double _taxRate = 16;
  double _subtotal = 0;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('products');
    if (!mounted) return;
    setState(() => _products.addAll(rows));
  }

  void _addToCart(Map<String, dynamic> product) {
    final existing = _cart.where((e) => e['id'] == product['id']).toList();
    if (existing.isNotEmpty) {
      existing.first['quantity'] += 1;
    } else {
      _cart.add({'id': product['id'], 'name': product['name'], 'salePrice': product['salePrice'], 'quantity': 1});
    }
    _recalculate();
  }

  void _recalculate() {
    _subtotal = 0;
    for (final item in _cart) {
      _subtotal += (item['salePrice'] as num).toDouble() * (item['quantity'] as int);
    }
    final tax = _subtotal * (_taxRate / 100);
    _total = _subtotal - _discount + tax;
    if (mounted) setState(() {});
  }

  Future<void> _checkout() async {
    if (_cart.isEmpty) return;
    final db = await DatabaseHelper().database;
    final invoiceNumber = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    final saleId = await db.insert('sales', {
      'invoiceNumber': invoiceNumber,
      'clientName': 'Client général',
      'total': _total,
      'discount': _discount,
      'tax': _taxRate,
      'createdAt': DateTime.now().toIso8601String(),
    });
    for (final item in _cart) {
      await db.insert('sale_items', {
        'saleId': saleId,
        'productId': item['id'],
        'productName': item['name'],
        'quantity': item['quantity'],
        'unitPrice': item['salePrice'],
        'total': (item['salePrice'] as num).toDouble() * (item['quantity'] as int),
      });
      await db.rawUpdate('UPDATE products SET quantity = quantity - ? WHERE id = ?', [item['quantity'], item['id']]);
    }
    if (!mounted) return;
    setState(() {
      _cart.clear();
      _discount = 0;
      _recalculate();
    });
    if (!mounted) return;
    final items = _cart.map((item) => {
      'productName': item['name'],
      'quantity': item['quantity'],
      'unitPrice': item['salePrice'],
    }).toList();
    await ExportService.exportInvoicePdf({
      'invoiceNumber': invoiceNumber,
      'clientName': 'Client général',
      'total': _total,
      'taxRate': _taxRate,
      'discount': _discount,
      'date': DateTime.now().toIso8601String(),
    }, items.cast<Map<String, dynamic>>());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vente enregistrée : $invoiceNumber')));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) => p['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Vente rapide')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recherche des médicaments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Rechercher'),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final p = filtered[i];
                            return ListTile(
                              title: Text(p['name'].toString()),
                              subtitle: Text('${p['salePrice']} CDF • stock ${p['quantity']}'),
                              trailing: IconButton(icon: const Icon(Icons.add_shopping_cart), onPressed: () => _addToCart(p)),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 360,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Panier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (_, i) {
                            final item = _cart[i];
                            return ListTile(title: Text(item['name'].toString()), subtitle: Text('${item['quantity']} x ${item['salePrice']} CDF'));
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Remise'),
                        onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0),
                      ),
                      const SizedBox(height: 12),
                      Text('Sous-total : ${_subtotal.toStringAsFixed(0)} CDF'),
                      Text('TVA : ${_taxRate.toStringAsFixed(0)}%'),
                      Text('Total : ${_total.toStringAsFixed(0)} CDF', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      FilledButton.icon(onPressed: _checkout, icon: const Icon(Icons.payment), label: const Text('Payer')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
