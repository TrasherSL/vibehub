import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  /// Uploads an image file to Firebase Storage with progress reporting.
  Future<String> uploadImageWithProgress(
      File imageFile, String folder, Function(double) onProgress) async {
    try {
      // Generate a unique file name
      final String fileName = '${_uuid.v4()}.jpg';

      // Get a reference to the desired folder in Firebase Storage
      final Reference storageReference =
      _firebaseStorage.ref().child(folder).child(fileName);

      // Start the upload task
      final UploadTask uploadTask = storageReference.putFile(imageFile);

      // Listen to progress updates
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        onProgress(progress);
      });

      // Wait for the upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Retrieve the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
