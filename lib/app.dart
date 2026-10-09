import 'package:flutter/material.dart';

import 'state/medical_store.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/doctors_screen.dart';
import 'ui/screens/history_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/theme.dart';

class MedicalApp extends StatelessWidget {
  const MedicalApp({super.key, required this.store});
  final MedicalStore store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'My Medical History',
    debugShowCheckedModeBanner: false,
    theme: medicalTheme(),
    home: MedicalShell(store: store),
  );
}

class MedicalShell extends StatefulWidget {
  const MedicalShell({super.key, required this.store});
  final MedicalStore store;
  @override
  State<MedicalShell> createState() => _MedicalShellState();
}

class _MedicalShellState extends State<MedicalShell> {
  int _tab = 0;
  void _select(int tab) {
    FocusScope.of(context).unfocus();
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: journalTeal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.medical_information_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        title: const Text('My Medical History'),
        actions: [
          IconButton(
            tooltip: 'Storage and account settings',
            onPressed: () => _select(4),
            icon: const Icon(Icons.account_circle_outlined, color: journalTeal),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            HomeScreen(store: widget.store, onTab: _select),
            DoctorsScreen(store: widget.store),
            HistoryScreen(store: widget.store),
            ReportsScreen(store: widget.store),
            SettingsScreen(store: widget.store),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            key: Key('navHome'),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            key: Key('navDoctors'),
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Doctors',
          ),
          NavigationDestination(
            key: Key('navHistory'),
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            key: Key('navReports'),
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Reports',
          ),
          NavigationDestination(
            key: Key('navSettings'),
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    ),
  );
}
