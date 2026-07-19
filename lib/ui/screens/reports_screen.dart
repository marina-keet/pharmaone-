import 'package:flutter/material.dart';
import '../../services/export_service.dart';

class ReportsScreen extends StatelessWidget {
  final String userRole;
  const ReportsScreen({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapports PharmaOne')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, children: [
          _ReportCard(title: 'Journalier', subtitle: 'CA quotidien'),
          _ReportCard(title: 'Hebdomadaire', subtitle: 'Performance hebdo'),
          _ReportCard(title: 'Mensuel', subtitle: 'Synthèse mensuelle'),
          _ReportCard(title: 'Annuel', subtitle: 'Bilan annuel'),
        ]),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ReportCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final file = await ExportService.exportReportCsv([
                  {'title': title, 'subtitle': subtitle},
                ], title);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rapport exporté : $file')));
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Exporter'),
            ),
          ],
        ),
      ),
    );
  }
}
