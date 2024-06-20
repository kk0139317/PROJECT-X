import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  File? _image;
  String? _prediction;
  double? _confidence;

  final String apiUrl = 'http://192.168.1.244:8001/api/upload/';

  Future<void> _uploadImage(File imageFile) async {
    var stream = new http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();

    var uri = Uri.parse(apiUrl);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile(
      'file',
      stream,
      length,
      filename: imageFile.path.split('/').last,
    );
    request.files.add(multipartFile);

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = utf8.decode(responseData);
      var data = jsonDecode(responseString);

      setState(() {
        _prediction = data['prediction'];
        _confidence = data['confidence'];
      });
    } else {
      print('Upload failed with status ${response.statusCode}');
    }
  }

  Future<void> _getImageFromGallery() async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _prediction = null;
        _confidence = null;
      });

      await _uploadImage(_image!);
    }
  }

  Future<void> _getImageFromCamera() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _prediction = null;
        _confidence = null;
      });

      await _uploadImage(_image!);
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromGallery();
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: _image == null ? Colors.grey[200] : null,
                ),
                child: _image == null
                    ? Icon(
                        Icons.image,
                        size: 100,
                        color: Colors.grey[400],
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              if (_prediction != null)
                Text(
                  'Prediction: $_prediction',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 10),
              if (_confidence != null)
                Text(
                  'Confidence: ${(_confidence!).toStringAsFixed(2)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: Icon(Icons.image),
                label: const Text(
                  'Upload Image',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                  shadowColor: Colors.blue.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
