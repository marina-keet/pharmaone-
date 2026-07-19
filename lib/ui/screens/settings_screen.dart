import 'package:flutter/material.dart';
import '../../core/theme_controller.dart';
import '../../data/database_helper.dart';

class SettingsScreen extends StatefulWidget {
  final String userRole;
  const SettingsScreen({super.key, required this.userRole});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final nameController = TextEditingController(text: 'PharmaOne');
  final addressController = TextEditingController(text: 'Kinshasa, RDC');
  final phoneController = TextEditingController(text: '+243 999 000 000');
  final currencyController = TextEditingController(text: 'CDF');
  final taxController = TextEditingController(text: '16');

  Future<void> _saveSettings() async {
    final db = await DatabaseHelper().database;
    await db.update('pharmacy_settings', {
      'name': nameController.text,
      'address': addressController.text,
      'phone': phoneController.text,
      'currency': currencyController.text,
      'taxRate': double.tryParse(taxController.text) ?? 16.0,
    }, where: 'id = 1');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paramètres sauvegardés')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom de la pharmacie')),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Adresse')),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Téléphone')),
              const SizedBox(height: 12),
              TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'Devise')),
              const SizedBox(height: 12),
              TextField(controller: taxController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'TVA (%)')),
              const SizedBox(height: 24),
              Row(children: [
                FilledButton.icon(onPressed: _saveSettings, icon: const Icon(Icons.save), label: const Text('Enregistrer')),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: () async {
                  final db = await DatabaseHelper().database;
                  final path = '/tmp/pharmaone_backup.db';
                  await db.close();
                  await DatabaseHelper().backupDatabase(path);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sauvegarde créée')));
                }, icon: const Icon(Icons.backup_rounded), label: const Text('Sauvegarder')),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                const Text('Thème : '),
                const SizedBox(width: 8),
                DropdownButton<ThemeMode>(
                  value: AppThemeController.themeMode.value,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('Système')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Clair')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Sombre')),
                  ],
                  onChanged: (mode) {
                    if (mode != null) {
                      AppThemeController.setThemeMode(mode);
                    }
                  },
                ),
              ]),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final backupFile = '/tmp/pharmaone_backup.db';
                  await DatabaseHelper().restoreDatabase(backupFile);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Base restaurée')));
                },
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Restaurer la base'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
