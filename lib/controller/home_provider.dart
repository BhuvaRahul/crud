import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/screens/authentication_screen.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomeProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  String updateImageUrl = '';

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  XFile? pickedImage = XFile("");
  final picker = ImagePicker();
  String _imagePath = '';

  String get imagePath => _imagePath;
  set imagePath(String value) {
    _imagePath = value;
    notifyListeners();
  }

  CroppedFile? croppedFile;

  Future getImage() async {
    await picker
        .pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
    )
        .then((value) async {
      if (value != null) {
        debugPrint("------->> ${value.name}");

        await ImageCropper().cropImage(
          sourcePath: value.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          uiSettings: [
            AndroidUiSettings(
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              aspectRatioLockEnabled: true,
            ),
          ],
        ).then((cropImage) async {
          if (cropImage != null) {
            debugPrint("-------|||${cropImage.path}");
            imagePath = cropImage.path;
            debugPrint("IMAGE PATH------->>>>>|$imagePath");
            await uploadImage(File(imagePath));
          }
        });
        // brokerLogoMasterController.text = value.name.split('-').last.split('.').first;
      }
    });
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future addData() async {
    String field1 = titleController.text;
    String field2 = descriptionController.text;
    isLoading = true;
    // File imageFile = await getImage();
    String imageUrl = await uploadImage(File(imagePath));
    debugPrint("😃😃😃😃---------😃😃😃😃😃 -->> $imageUrl");
    try {
      await FirebaseFirestore.instance.collection('data_collection').add({
        'field1': field1,
        'field2': field2,
        'imageUrl': imageUrl,
      }).then((value) {
        isLoading = false;
        titleController.clear();
        descriptionController.clear();
        imagePath = '';
      });
      notifyListeners();
      debugPrint("Data added successfully!");
    } catch (e) {
      isLoading = false;
      debugPrint("Error adding data: $e");
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference reference = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = reference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      debugPrint("🙂🙂🙂🙂🙂imageUrl ---->>>>> $imageUrl");
      notifyListeners();
      return imageUrl;
    } catch (e) {
      debugPrint("Error uploading image: $e");
      return '';
    }
  }

  Future<void> logOut(BuildContext context) async {
    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        FirebaseAuth.instance.signOut().then(
              (value) => {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthenticationScreen(),
                    ),
                    (route) => false),
              },
            );
      }
    } catch (e) {
      print(e); // TODO: show dialog with error
    }
  }
}
