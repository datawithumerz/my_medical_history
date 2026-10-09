import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:my_medical_history/services/attachment_files.dart';

final fixturePng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
);
final fixturePdf = utf8.encode('%PDF-1.4\nPersistence test fixture\n%%EOF');

Future<AttachmentFiles> testAttachmentFiles() async => AttachmentFiles(
  Directory(
    p.join((await getApplicationSupportDirectory()).path, 'verification_files'),
  ),
);
