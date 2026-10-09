// Executed by a separate Dart process to prove persistence outside app memory.
import 'dart:convert';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

Future<void> main(List<String> arguments) async {
  sqfliteFfiInit();
  final database = await databaseFactoryFfi.openDatabase(
    arguments.first,
    options: OpenDatabaseOptions(readOnly: true),
  );
  final doctors = await database.query('doctors', orderBy: 'id');
  final visits = await database.query('visits', orderBy: 'id');
  final attachments = await database.query('attachments', orderBy: 'id');
  final fileBytes = <String, String>{};
  if (arguments.length > 1) {
    for (final row in attachments) {
      final name = row['stored_name'] as String;
      if (!RegExp(r'^[a-f0-9]{32}\.(pdf|png|jpg|webp)$').hasMatch(name)) {
        throw StateError('Invalid stored filename');
      }
      fileBytes[name] = base64Encode(
        await File(p.join(arguments[1], name)).readAsBytes(),
      );
    }
  }
  await database.close();
  stdout.writeln(
    jsonEncode({
      'doctors': doctors,
      'visits': visits,
      'attachments': attachments,
      'fileBytes': fileBytes,
    }),
  );
}
