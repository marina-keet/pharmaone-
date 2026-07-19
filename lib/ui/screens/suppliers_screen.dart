import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../models/pharmacy_models.dart';

class SuppliersScreen extends StatefulWidget {
  final String userRole;
  const SuppliersScreen({super.key, required this.userRole});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final List<Supplier> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('suppliers');
    setState(() => _suppliers.addAll(rows.map((e) => Supplier.fromMap(e)).toList()));
  }

  Future<void> _showForm({Supplier? supplier}) async {
    final name = TextEditingController(text: supplier?.name ?? '');
    final phone = TextEditingController(text: supplier?.phone ?? '');
    final address = TextEditingController(text: supplier?.address ?? '');
    final note = TextEditingController(text: supplier?.note ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier == null ? 'Nouveau fournisseur' : 'Modifier fournisseur'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse')),
          TextField(controller: note, decoration: const InputDecoration(labelText: 'Note')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () async {
            final db = await DatabaseHelper().database;
            final data = {'name': name.text, 'phone': phone.text, 'address': address.text, 'note': note.text};
            if (supplier == null) {
              await db.insert('suppliers', data);
            } else {
              await db.update('suppliers', data, where: 'id = ?', whereArgs: [supplier.id]);
            }
            if (!context.mounted) return;
            Navigator.pop(context);
            setState(() => _suppliers.clear());
            _load();
          }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des fournisseurs')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text('Historique des achats et fournisseurs', style: Theme.of(context).textTheme.titleMedium)),
            if (widget.userRole != 'Caissier') FilledButton.icon(onPressed: () => _showForm(), icon: const Icon(Icons.add), label: const Text('Ajouter')),
          ]),
          const SizedBox(height: 16),
          Expanded(child: ListView.builder(itemCount: _suppliers.length, itemBuilder: (_, index) {
            final s = _suppliers[index];
            return Card(child: ListTile(title: Text(s.name), subtitle: Text('${s.phone} • ${s.address}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(supplier: s)), IconButton(icon: const Icon(Icons.delete), onPressed: () async { final db = await DatabaseHelper().database; await db.delete('suppliers', where: 'id = ?', whereArgs: [s.id]); setState(() => _suppliers.removeAt(index)); })])));
          })),
        ]),
      ),
    );
  }
}
