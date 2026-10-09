import 'package:flutter/material.dart';

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'services/attachment_files.dart';

import 'app.dart';
import 'data/sqlite_medical_repository.dart';
import 'state/medical_store.dart';
import 'ui/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  MedicalStore? _store;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _failed = false);
    SqliteMedicalRepository? repository;
    try {
      repository = await SqliteMedicalRepository.open();
      final support = await getApplicationSupportDirectory();
      final store = MedicalStore(
        repository,
        files: AttachmentFiles(Directory(p.join(support.path, 'attachments'))),
      );
      await store.load();
      if (!mounted) {
        store.dispose();
        await repository.close();
        return;
      }
      setState(() => _store = store);
    } catch (_) {
      await repository?.close();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _store?.repository.close();
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_store != null) return MedicalApp(store: _store!);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: medicalTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _failed
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.storage_outlined,
                          size: 48,
                          color: journalTeal,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Could not open your records',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your stored data has not been reset. Check available device storage, then try again.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Try again'),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Opening your medical history…'),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
