import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignaturePicker extends StatefulWidget {
  SignaturePicker({ this.title}) ;

  final String? title;

  @override
  _SignaturePickerState createState() => _SignaturePickerState();
}

class _SignaturePickerState extends State<SignaturePicker> {
  File? _image;
  String? _imagepath;
  final ImagePicker _picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    LoadImage();
  }

  //region Lấy ảnh từ camera và lưu ảnh vào thiết bị
  Future getImage() async {
    final image = await _picker.pickImage(source: ImageSource.camera);

    /// lấy đường dẫn thư mục để lưu
    Directory appDocDir = await getApplicationDocumentsDirectory();
    final String path = appDocDir.path;

    /// copy file đến đường dẫn mới
    // final File? newImage = await image.copy('$path/image123.png');

    setState(() {
      _image = image as File?;
    });
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: InkWell(
                onTap: () => print("ciao"),
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                      child: _image == null
                          ? (_imagepath != null
                              ? Image.file(
                                  File(_imagepath!),
                                  width: 300,
                                  height: 400,
                                )
                              : Text("Image is not loaded"))
//                        Text("Image is not loaded")
                          : Image.file(
                              _image!,
                              width: 300,
                              height: 400,
                            ),
                    ),
                    /* ListTile(
                      title: Text('Ảnh'),
                      subtitle:
                      Text('16 Cốm vòng, Dịch Vọng Hậu, Cầu Giấy, Hà Nội'),
                    ),*/
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 10,
            child: ElevatedButton(
              onPressed: () {
                SaveImage(_image!.path);
              },
              child: Text('Lưu'),
            ),
          )
        ],
      ),
      /*Center(
          child: _image == null ? Text("Image is not loaded") : Image.file(_image)
      ),*/
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void SaveImage(path) async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    saveimage.setString("imagepath", path);
  }

  void LoadImage() async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    setState(() {
      _imagepath = saveimage.getString("imagepath");
    });
  }
}
