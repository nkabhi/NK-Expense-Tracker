import 'package:flutter/material.dart';

import 'theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/investments_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootNav(),
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});
  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AddTransactionScreen(),
    InvestmentsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'Transactions'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Add'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Invest'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
