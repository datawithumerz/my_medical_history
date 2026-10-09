import 'package:flutter/material.dart';

import '../../state/medical_store.dart';
import '../widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final MedicalStore store;
  @override
  Widget build(BuildContext context) => PageBody(
    children: [
      Text('Settings', style: Theme.of(context).textTheme.titleLarge),
      const SectionTitle('Storage & connections'),
      _row(
        Icons.phone_android,
        'On this device',
        '${counted(store.doctors.length, 'doctor')} · ${counted(store.visits.length, 'visit')} · ${counted(store.attachments.length, 'file')}',
        'Records and attached files are saved on this device. Uninstalling the app or clearing its storage removes local data.',
      ),
      _row(
        Icons.cloud_off_outlined,
        'Account sync',
        store.accountSync.isConnected ? 'Connected' : 'Not connected',
        'Sign-in and sync between your devices are not available yet. Your records are not being sent to an account.',
      ),
      _row(
        Icons.backup_outlined,
        'Google Drive backup',
        store.driveBackup.isConnected ? 'Connected' : 'Not connected',
        'Backup and restore are separate from account sync. Google Drive is not set up and no backup has been created.',
      ),
      const SectionTitle('About your journal'),
      const Text(
        'My Medical History',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 6),
      const Text(
        'Your recorded visits, clinical notes and documents. Medicines and results are shown as entered, without inferred health status.',
      ),
    ],
  );
  Widget _row(IconData icon, String title, String subtitle, String details) =>
      Column(
        children: [
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            children: [Text(details)],
          ),
          const Divider(),
        ],
      );
}
