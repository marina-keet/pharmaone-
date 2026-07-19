import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../models/pharmacy_models.dart';

class ProductsScreen extends StatefulWidget {
  final String userRole;
  const ProductsScreen({super.key, required this.userRole});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('products');
    setState(() {
      _products.clear();
      _products.addAll(rows.map((e) => Product.fromMap(e)).toList());
      _loading = false;
    });
  }

  Future<void> _showForm({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');
    final purchaseController = TextEditingController(text: product?.purchasePrice.toString() ?? '');
    final saleController = TextEditingController(text: product?.salePrice.toString() ?? '');
    final quantityController = TextEditingController(text: product?.quantity.toString() ?? '');
    final mfController = TextEditingController(text: product?.manufactureDate ?? '');
    final expController = TextEditingController(text: product?.expiryDate ?? '');
    final supplierController = TextEditingController(text: product?.supplier ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Nouveau médicament' : 'Modifier médicament'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Catégorie')),
            TextField(controller: barcodeController, decoration: const InputDecoration(labelText: 'Code-barres')),
            TextField(controller: purchaseController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix d\'achat')),
            TextField(controller: saleController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Prix de vente')),
            TextField(controller: quantityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantité')),
            TextField(controller: mfController, decoration: const InputDecoration(labelText: 'Date de fabrication')),
            TextField(controller: expController, decoration: const InputDecoration(labelText: 'Date de péremption')),
            TextField(controller: supplierController, decoration: const InputDecoration(labelText: 'Fournisseur')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () async {
            final db = await DatabaseHelper().database;
            final data = {
              'name': nameController.text,
              'category': categoryController.text,
              'barcode': barcodeController.text,
              'purchasePrice': double.tryParse(purchaseController.text) ?? 0.0,
              'salePrice': double.tryParse(saleController.text) ?? 0.0,
              'quantity': int.tryParse(quantityController.text) ?? 0,
              'manufactureDate': mfController.text,
              'expiryDate': expController.text,
              'supplier': supplierController.text,
            };
            if (product == null) {
              await db.insert('products', data);
            } else {
              await db.update('products', data, where: 'id = ?', whereArgs: [product.id]);
            }
            if (!context.mounted) return;
            Navigator.pop(context);
            _loadProducts();
          }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  Future<void> _delete(Product p) async {
    final db = await DatabaseHelper().database;
    await db.delete('products', where: 'id = ?', whereArgs: [p.id]);
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _products.where((p) => p.name.toLowerCase().contains(_searchController.text.toLowerCase()) || p.barcode.contains(_searchController.text)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des médicaments')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _searchController, onChanged: (_) => setState(() {}), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), labelText: 'Rechercher un médicament'))),
            const SizedBox(width: 12),
            if (widget.userRole != 'Caissier') FilledButton.icon(onPressed: () => _showForm(), icon: const Icon(Icons.add), label: const Text('Ajouter')),
          ]),
          const SizedBox(height: 16),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : DataTable(
                    columns: const [
                      DataColumn(label: Text('Nom')),
                      DataColumn(label: Text('Catégorie')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('Prix')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: filtered.map((p) => DataRow(cells: [
                      DataCell(Text(p.name)),
                      DataCell(Text(p.category)),
                      DataCell(Text('${p.quantity}')),
                      DataCell(Text('${p.salePrice.toStringAsFixed(0)} CDF')),
                      DataCell(Row(children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(product: p)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _delete(p)),
                      ])),
                    ])).toList(),
                  ),
          ),
        ]),
      ),
    );
  }
}
