import 'dart:io';

import 'package:LIVE365/utils/file_utils.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class Service {
  Future<String> uploadImage(Reference ref, File file) async {
    String ext = FileUtils.getFileExtension(file);
    Reference storageReference = ref.child("${uuid.v4()}.$ext");
    UploadTask uploadTask = storageReference.putFile(file);
    await uploadTask.whenComplete(() => null);
    String fileUrl = await storageReference.getDownloadURL();
    return fileUrl;
  }
}
