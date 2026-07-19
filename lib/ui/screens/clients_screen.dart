import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../models/pharmacy_models.dart';

class ClientsScreen extends StatefulWidget {
  final String userRole;
  const ClientsScreen({super.key, required this.userRole});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query('clients');
    setState(() => _clients.addAll(rows.map((e) => Client.fromMap(e)).toList()));
  }

  Future<void> _showForm({Client? client}) async {
    final name = TextEditingController(text: client?.name ?? '');
    final phone = TextEditingController(text: client?.phone ?? '');
    final address = TextEditingController(text: client?.address ?? '');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(client == null ? 'Nouveau client' : 'Modifier client'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: name, decoration: const InputDecoration(labelText: 'Nom')),
          TextField(controller: phone, decoration: const InputDecoration(labelText: 'Téléphone')),
          TextField(controller: address, decoration: const InputDecoration(labelText: 'Adresse')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          FilledButton(onPressed: () async {
            final db = await DatabaseHelper().database;
            final data = {'name': name.text, 'phone': phone.text, 'address': address.text};
            if (client == null) {
              await db.insert('clients', data);
            } else {
              await db.update('clients', data, where: 'id = ?', whereArgs: [client.id]);
            }
            if (!context.mounted) return;
            Navigator.pop(context);
            setState(() => _clients.clear());
            _load();
          }, child: const Text('Enregistrer')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des clients')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Text('Historique des achats et informations clients', style: Theme.of(context).textTheme.titleMedium)),
            FilledButton.icon(onPressed: () => _showForm(), icon: const Icon(Icons.add), label: const Text('Ajouter')),
          ]),
          const SizedBox(height: 16),
          Expanded(child: ListView.builder(itemCount: _clients.length, itemBuilder: (_, index) {
            final c = _clients[index];
            return Card(child: ListTile(title: Text(c.name), subtitle: Text('${c.phone} • ${c.address}'), trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(client: c))));
          })),
        ]),
      ),
    );
  }
}
