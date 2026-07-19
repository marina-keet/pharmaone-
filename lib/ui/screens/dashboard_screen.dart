import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../data/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  final String userRole;
  const DashboardScreen({super.key, required this.userRole});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int salesCount = 0;
  double revenue = 0;
  int lowStock = 0;
  int totalProducts = 0;
  int expiringSoon = 0;
  int totalSales = 0;
  List<BarChartGroupData> _chartGroups = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final db = await DatabaseHelper().database;
    final sales = await db.rawQuery('SELECT COUNT(*) as c, COALESCE(SUM(total),0) as s FROM sales');
    final products = await db.query('products');
    final grouped = <String, int>{};
    for (final product in products) {
      final category = product['category']?.toString() ?? 'Autre';
      grouped[category] = (grouped[category] ?? 0) + (product['quantity'] as int);
    }
    final groups = grouped.entries.toList();
    final chartGroups = <BarChartGroupData>[];
    for (var i = 0; i < groups.length; i++) {
      chartGroups.add(BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: (groups[i].value).toDouble(), color: const Color(0xFF1E88E5), width: 18)],
      ));
    }
    final low = products.where((p) => (p['quantity'] as int) < 10).length;
    final exp = products.where((p) {
      final expiry = p['expiryDate'] as String?;
      if (expiry == null || expiry.isEmpty) return false;
      final date = DateTime.tryParse(expiry);
      if (date == null) return false;
      return date.difference(DateTime.now()).inDays <= 60;
    }).length;
    setState(() {
      salesCount = int.parse(sales.first['c'].toString());
      revenue = double.parse(sales.first['s'].toString());
      lowStock = low;
      totalProducts = products.length;
      expiringSoon = exp;
      totalSales = int.parse(sales.first['c'].toString());
      _chartGroups = chartGroups;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(title: 'CA du jour', value: '${revenue.toStringAsFixed(0)} CDF', icon: Icons.attach_money_rounded, color: const Color(0xFF1E88E5)),
      _StatCard(title: 'Ventes', value: '$totalSales', icon: Icons.receipt_long_rounded, color: const Color(0xFF2ECC71)),
      _StatCard(title: 'Produits', value: '$totalProducts', icon: Icons.medication_rounded, color: const Color(0xFF8E24AA)),
      _StatCard(title: 'Rupture', value: '$lowStock', icon: Icons.warning_amber_rounded, color: const Color(0xFFE53935)),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Tableau de bord PharmaOne')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Wrap(spacing: 16, runSpacing: 16, children: cards.map((c) => SizedBox(width: 260, child: c)).toList()),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Produits proches de péremption', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('$expiringSoon produits à surveiller'),
                const SizedBox(height: 8),
                Text('Rupture de stock : $lowStock produits'),
              ])))),
              const SizedBox(width: 16),
              Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Statistiques', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Rôle utilisateur : ${widget.userRole}'),
                const SizedBox(height: 8),
                Text('Mode hors ligne actif'),
                const SizedBox(height: 16),
                SizedBox(height: 220, child: BarChart(BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= _chartGroups.length) return const SizedBox();
                      final label = _chartGroups[index].x.toString();
                      return Text(label);
                    })),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _chartGroups,
                ))),
              ])))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]))
        ]),
      ),
    );
  }
}
