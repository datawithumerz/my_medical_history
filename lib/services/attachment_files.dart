import 'dart:io';

import 'package:path/path.dart' as p;

class AttachmentException implements Exception {
  const AttachmentException(this.message);
  final String message;
  @override
  String toString() => message;
}

class StoredAttachment {
  const StoredAttachment(this.name, this.mimeType, this.size);
  final String name;
  final String mimeType;
  final int size;
}

/// Owns copies in a persistent app directory. Never deletes picker/source files.
class AttachmentFiles {
  AttachmentFiles(Directory directory) : directory = directory.absolute;
  final Directory directory;
  static const maxBytes = 25 * 1024 * 1024;
  File file(String storedName) {
    if (!RegExp(r'^[a-f0-9]{32}\.(pdf|png|jpg|webp)$').hasMatch(storedName)) {
      throw const AttachmentException(
        'This attachment has an invalid storage location.',
      );
    }
    return File(p.join(directory.path, storedName));
  }

  Future<File> resolve(String storedName) async {
    final result = file(storedName);
    if (!await result.exists()) {
      throw const AttachmentException(
        'File missing on this device. Add the original file again, or remove this attachment entry.',
      );
    }
    return result;
  }

  Future<StoredAttachment> import(String id, Stream<List<int>> content) async {
    if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(id)) {
      throw ArgumentError('Invalid attachment ID');
    }
    await directory.create(recursive: true);
    final pending = File(p.join(directory.path, '$id.part'));
    if (await pending.exists()) {
      throw const AttachmentException('Please try adding the file again.');
    }
    RandomAccessFile? output;
    var size = 0;
    try {
      output = await pending.open(mode: FileMode.writeOnly);
      await for (final chunk in content) {
        size += chunk.length;
        if (size > maxBytes) {
          throw const AttachmentException('Choose a file smaller than 25 MB.');
        }
        await output.writeFrom(chunk);
      }
      await output.flush();
      await output.close();
      output = null;
      final input = await pending.open();
      late List<int> header;
      try {
        header = await input.read(12);
      } finally {
        await input.close();
      }
      bool starts(List<int> signature) =>
          header.length >= signature.length &&
          List.generate(
            signature.length,
            (i) => header[i] == signature[i],
          ).every((v) => v);
      final (extension, mime) = switch (header) {
        _ when starts([37, 80, 68, 70, 45]) => ('pdf', 'application/pdf'),
        _ when starts([137, 80, 78, 71, 13, 10, 26, 10]) => (
          'png',
          'image/png',
        ),
        _ when starts([255, 216, 255]) => ('jpg', 'image/jpeg'),
        _
            when starts([82, 73, 70, 70]) &&
                header.length >= 12 &&
                String.fromCharCodes(header.sublist(8, 12)) == 'WEBP' =>
          ('webp', 'image/webp'),
        _ => throw const AttachmentException(
          'Choose a PDF, JPEG, PNG or WebP image. This file type could not be recognized.',
        ),
      };
      final name = '$id.$extension';
      final target = file(name);
      if (await target.exists()) {
        throw const AttachmentException('Please try adding the file again.');
      }
      await pending.rename(target.path);
      return StoredAttachment(name, mime, size);
    } finally {
      await output?.close();
      if (await pending.exists()) await pending.delete();
    }
  }

  Future<void> remove(String name) async {
    final target = file(name);
    if (await target.exists()) await target.delete();
  }
}
