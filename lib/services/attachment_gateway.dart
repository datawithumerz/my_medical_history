import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

import 'attachment_files.dart';

class PickedAttachment {
  const PickedAttachment(this.name, this.read);
  final String name;
  final Stream<List<int>> Function() read;
}

abstract interface class AttachmentPicker {
  Future<PickedAttachment?> pick();
}

class NativeAttachmentPicker implements AttachmentPicker {
  const NativeAttachmentPicker();
  @override
  Future<PickedAttachment?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
    );
    return file == null
        ? null
        : PickedAttachment(file.name, file.readAsByteStream);
  }
}

abstract interface class AttachmentOpener {
  Future<void> open(String path, String mimeType);
}

class NativeAttachmentOpener implements AttachmentOpener {
  const NativeAttachmentOpener();
  @override
  Future<void> open(String path, String mimeType) async {
    final result = await OpenFilex.open(path, type: mimeType);
    if (result.type == ResultType.noAppToOpen) {
      throw const AttachmentException(
        'No app is available to open this file. Install a PDF or image viewer, then try again.',
      );
    }
    if (result.type != ResultType.done) {
      throw const AttachmentException(
        'The file could not be opened. Check your viewer app and try again.',
      );
    }
  }
}
