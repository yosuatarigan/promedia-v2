import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> downloadFileToDevice(
  Uint8List bytes,
  String fileName, {
  String mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
}) async {
  final ext = fileName.split('.').last;
  await FilePicker.platform.saveFile(
    dialogTitle: 'Simpan File',
    fileName: fileName,
    type: FileType.custom,
    allowedExtensions: [ext],
    bytes: bytes,
  );
}
