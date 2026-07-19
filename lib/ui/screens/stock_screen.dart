import 'package:flutter/material.dart';
import '../../data/database_helper.dart';

class StockScreen extends StatefulWidget {
  final String userRole;
  const StockScreen({super.key, required this.userRole});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('products');
    if (!mounted) return;
    setState(() => _items..clear()..addAll(rows));
  }

  Future<void> _updateStock(Map<String, dynamic> item, int delta, String kind) async {
    final db = await DatabaseHelper().database;
    await db.rawUpdate('UPDATE products SET quantity = quantity + ? WHERE id = ?', [delta, item['id']]);
    await db.insert('stock_movements', {
      'type': kind,
      'productId': item['id'],
      'quantity': delta.abs(),
      'note': '$kind de stock',
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion du stock')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final item = _items[index];
            return Card(
              child: ListTile(
                title: Text(item['name'].toString()),
                subtitle: Text('Péremption ${item['expiryDate']}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('${item['quantity']} en stock'),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _updateStock(item, 10, 'Entrée')),
                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _updateStock(item, -5, 'Sortie')),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
