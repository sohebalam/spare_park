import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelector extends StatefulWidget {
  @override
  _ImageSelectorState createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  File? _image;
  final picker = ImagePicker();

  Future<void> _getImage() async {
    final action = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == null) return;

    final pickedFile = await picker.pickImage(source: action);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _submitImage() {
    if (_image != null) {
      print('Selected image: ${_image!.path}');
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _image == null
            ? Text('No image selected.')
            : Image.file(
                _image!,
                height: 200,
                width: 200,
              ),
        ElevatedButton(
          onPressed: _getImage,
          child: Text('Select Image'),
        ),
        ElevatedButton(
          onPressed: _submitImage,
          child: Text('Submit'),
        ),
      ],
    );
  }
}
