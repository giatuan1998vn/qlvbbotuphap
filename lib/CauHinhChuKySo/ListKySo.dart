import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qlvbbotuphap/CauHinhChuKySo/CreateSignature.dart';
import 'package:qlvbbotuphap/data/moor_database.dart';
import 'package:qlvbbotuphap/shared.dart';


class QuanLyChuKy extends StatefulWidget {
  @override
  _QuanLyChuKyState createState() => _QuanLyChuKyState();
}

class _QuanLyChuKyState extends State<QuanLyChuKy> {
  late List tasks;
  GlobalKey keyColumn = new GlobalKey();

  late File _image;
  final picker = ImagePicker();
  final _imageSaver = ImageGallerySaver();
  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() async{
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        var data = _image.readAsBytesSync();
        final encoded = base64.encode(data.buffer.asUint8List());
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
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() async{
      if (pickedFile != null) {
        _image = File(pickedFile.path);

        var data = _image.readAsBytesSync();
        final encoded = base64.encode(data.buffer.asUint8List());
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
        if(encoded != null)
          print('endcode: $encoded');
      } else {
        print('No image selected.');
      }
    });
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
    final res = await ImageGallerySaver.saveImage(bytesList as Uint8List);
//    final result = await ImageGallerySaver.saveImage(bytes);
    print(res);

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quản lý chữ ký'),
          /*actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateSignature(),
                      ));
                }),
          ],*/
        ),
        body: Column(
          key: keyColumn,
          children: <Widget>[
            Expanded(
              child: _buildTaskList(context),

            ),
//            NewTaskInput(),
          ],
        ),
      floatingActionButton: Container(
        padding: EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.extended(
              heroTag: "btnAdd",
              icon: Icon(Icons.add),
              label: Text("Tạo"),
              backgroundColor: Colors.blue.shade800,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateSignature(),
                    ));
              },
            ),
            SizedBox(
              width: 10,
            ),
            FloatingActionButton.extended(
              heroTag: "btnGallery",
              icon: Icon(Icons.image),
              label: Text("Thư viện"),
              backgroundColor: Colors.blue.shade800,
              onPressed: () {
                getImageFromGallery();
              },
            ),
            /*FloatingActionButton.extended(
              heroTag: "btnPhoto",
              icon: Icon(Icons.camera_alt_outlined),
              label: Text("Chụp"),
              backgroundColor: Colors.blue.shade800,
              onPressed: () {
                getImageFromCamera();
              },
            )*/
          ],
        ),
      ),
    );
  }

  StreamBuilder<List<Task>> _buildTaskList(BuildContext context) {
    final database = Provider.of<TaskDatabase>(context);
    return StreamBuilder(
      stream: database.watchAllTasks(),
      builder: (context, AsyncSnapshot<List<Task>> snapshot) {
        tasks = snapshot.data ?? [] ;

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (_, index) {
            final itemTask = tasks[index];
            return _buildListItem(itemTask, database);
          },
        );
      },
    );
  }
  doNothing(BuildContext context, item, TaskDatabase database) {
    database.deleteTask(item);
  }
  Widget _buildListItem(Task itemTask, TaskDatabase database) {
    return Slidable(

        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          dismissible: DismissiblePane(onDismissed: () {}),

          children:  [
            SlidableAction(

              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Xóa',
              onPressed: doNothing(context,itemTask,database),

            ),
          ],
        ),

        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 1.0, color: Colors.black26),
            ),
          ),
          child: CheckboxListTile(

            title: Image.memory(base64.decode(itemTask!.name!),
                width: 150, height: 250, fit: BoxFit.fill),
//        subtitle: Text(itemTask.dueDate?.toString() ?? 'No date'),
            value: itemTask.completed,
            onChanged: (newValue) {
              tasks.forEach((element) {
                database.updateTask(element.copyWith(completed: false));
              });
            database.updateTask(itemTask.copyWith(completed: newValue!));
          },
          ),
        ));
  }
}
