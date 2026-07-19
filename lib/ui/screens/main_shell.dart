import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'products_screen.dart';
import 'suppliers_screen.dart';
import 'sales_screen.dart';
import 'clients_screen.dart';
import 'stock_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class MainShell extends StatefulWidget {
  final String userRole;
  const MainShell({super.key, required this.userRole});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  late final List<Widget> _screens = [
    DashboardScreen(userRole: widget.userRole),
    ProductsScreen(userRole: widget.userRole),
    SuppliersScreen(userRole: widget.userRole),
    SalesScreen(userRole: widget.userRole),
    ClientsScreen(userRole: widget.userRole),
    StockScreen(userRole: widget.userRole),
    ReportsScreen(userRole: widget.userRole),
    SettingsScreen(userRole: widget.userRole),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Tableau de bord')),
              NavigationRailDestination(icon: Icon(Icons.medication_rounded), label: Text('Médicaments')),
              NavigationRailDestination(icon: Icon(Icons.local_shipping_rounded), label: Text('Fournisseurs')),
              NavigationRailDestination(icon: Icon(Icons.point_of_sale_rounded), label: Text('Ventes')),
              NavigationRailDestination(icon: Icon(Icons.people_rounded), label: Text('Clients')),
              NavigationRailDestination(icon: Icon(Icons.inventory_2_rounded), label: Text('Stock')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart_rounded), label: Text('Rapports')),
              NavigationRailDestination(icon: Icon(Icons.settings_rounded), label: Text('Paramètres')),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                    },
                    icon: const Icon(Icons.logout_rounded),
                    tooltip: 'Déconnexion',
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _screens[_index]),
        ],
      ),
    );
  }
}
