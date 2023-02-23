import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qlvbbotuphap/data/moor_database.dart';
import 'package:qlvbbotuphap/shared.dart';



class CreateSignature extends StatefulWidget {


  @override
  _CreateSignatureState createState() => _CreateSignatureState();
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
//    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _WatermarkPaint && runtimeType == other.runtimeType && price == other.price && watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class _CreateSignatureState extends State<CreateSignature> {
  ByteData _img = ByteData(0);
  var color = Colors.black;
  var strokeWidth = 5.0;
  final _sign = GlobalKey<SignatureState>();
  final _imageSaver = ImageGallerySaver();
  TextEditingController hotenController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm chữ ký"),
      ),
      body: Column(
        children: <Widget>[
         /* new TextFormField(
            controller: hotenController,
            decoration: InputDecoration(
              icon: const Icon(Icons.person),
              hintText: 'Nhập họ và tên',
              labelText: 'Họ tên',
              suffixIcon: GestureDetector(
                  child: Image(
                    image: AssetImage('assets/default-avatar.png'),
                    fit: BoxFit.fill,
                    height: 2,
                  )),
            ),
          ),*/
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Signature(
                  color: color,
                  key: _sign,
                  onSign: () {
                    final sign = _sign.currentState;
                    debugPrint('${sign!.points.length} points in the signature');
                  },
                  backgroundPainter: _WatermarkPaint("2.0", "2.0"),
                  strokeWidth: strokeWidth,
                ),
              ),
              color: Colors.black12,
            ),
          ),
          _img.buffer.lengthInBytes == 0 ? Container() : LimitedBox(maxHeight: 200.0, child: Image.memory(_img.buffer.asUint8List())),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                      // color: Colors.blue,
                      onPressed: () async {
                        final sign = _sign.currentState;
                        //retrieve image data, do whatever you want with it (send to server, save locally...)
                        final image = await sign!.getData();
                        var data = await image.toByteData(format: ui.ImageByteFormat.png);
                        sign.clear();
                        final encoded = base64.encode(data!.buffer.asUint8List());
                        setState(() {
                          _img = data;
                        });
                        debugPrint("onPressed " + encoded);
                        _createFileFromString(encoded);

                        var name = hotenController.text;
                        final database = Provider.of<TaskDatabase>(context);
                        var defaultTask = await database.getDefault();
                        Task task;
                        if (defaultTask == null){
                          task = new Task(name: encoded, completed: true);
                        }else{
                          task = new Task(name: encoded);
                        }
                        showAlertDialog(context, "Lưu chữ ký thành công");
                        database.insertTask(task);
                        Navigator.of(context).pop();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.add_box_rounded, color: Colors.white),
                          Text("Lưu", style: TextStyle(
                            color: Colors.white,
                          ),)
                        ],
                      )
                  ),
                  TextButton(  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                      onPressed: () {
                        final sign = _sign.currentState;
                        sign!.clear();
                        setState(() {
                          _img = ByteData(0);
                        });
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever_outlined, color: Colors.white,),
                          Text("Xóa", style: TextStyle(
                            color: Colors.white,
                          ),)
                        ],
                      )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                      onPressed: () {
                        setState(() {
                          if(color == Colors.red)
                            color = Colors.blue;
                          else if(color == Colors.blue)
                            color = Colors.black;
                          else
                            color = Colors.red;
                        });
                      },
                      child: Text("Thay đổi màu sắc")),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          int min = 1;
                          int max = 10;
                          if (strokeWidth > max)
                            strokeWidth = min.toDouble();
                          else if (strokeWidth < min)
                            strokeWidth = max.toDouble();
                          else
                            strokeWidth = strokeWidth + 1;

                        });
                      },
                      child: Text("Thay đổi nét vẽ")),
                ],
              ),
              Container(
                height: 20,
              )
            ],
          )
        ],
      ),
    );
  }
  ///lưu ảnh vào bộ nhớ dạng png từ chuỗi string base64
  Future<String> _createFileFromString(encode) async {
    final encodedStr = encode;
    Uint8List bytes = base64.decode(encodedStr);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/abc.png';
    print("local file full path ${fullPath}");
    File file = File(fullPath);
    await file.writeAsBytes(bytes);
    print(file.path);

    List<Uint8List> bytesList = [];
    bytesList.add(bytes.buffer.asUint8List());
    final res = await ImageGallerySaver.saveImage( bytesList as Uint8List);
//    final result = await ImageGallerySaver.saveImage(bytes);
    print(res);

    return file.path;
  }
}