import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'bottomsheet_widget.dart';
import 'shared.dart';
import 'dart:developer';
import 'package:flutter/services.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';



class MyHomePage extends StatefulWidget {
  final String? path;
  const MyHomePage({Key? key, this.path}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('com.simax.si_vgca/sign');
  String urlPDFPath = "";
  bool exists = true;
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;
  PDFViewController? _pdfViewController;
  bool loaded = false;

  double width = 100.0, height = 70.0;
  Offset? position;
  bool _visibleSign = false;
  bool _enableSwipe = true;
  String _signMessage = 'Unknown';
  int progress = 0;
  ReceivePort _receivePort = ReceivePort();


  final fileUrl = "http://apivbdhbtp.ungdungtructuyen.vn/Uploads/70e15eba-45b1-4b03-8446-4f49cc73a9d9.pdf";

  static downloadingCallback(id, status, progress) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");
    sendPort!.send([id, status, progress]);
  }
  Directory? _downloadsDirectory;
  Future<File> getFileFromUrl(String url, {name}) async {
    var fileName = 'testonline';
    if (name != null) {
      fileName = name;
    }
    try {
      var data = await http.get(Uri.parse(url));
      var bytes = data.bodyBytes;
      // var dir = await getApplicationDocumentsDirectory();
      File file = File("${_downloadsDirectory!.path}/" + fileName + ".pdf");
      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      throw Exception("Error opening url file");
    }
  }

  Future<void> initDownloadsDirectoryState() async {
    Directory? downloadsDirectory;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // downloadsDirectory = await DownloadsPathProvider.downloadsDirectory;
    } on PlatformException {
      print('Could not get the downloads directory');
    }

    if (!mounted) return;

    setState(() {
      _downloadsDirectory = downloadsDirectory;
    });
  }




  Future<void> _getSignMessage() async {
    String message;
    try {
      final String result =
      await platform.invokeMethod('signPDF', {"filePath": fileUrl,"currentPage": _currentPage, "x": position!.dx, "y": position!.dy});
      message = result;
      log(result);
    } on PlatformException catch (e) {
      message = 'Unknown';
      print(e);
    }
    setState(() {
      _signMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    position = Offset(10.0, height + 100);
    initDownloadsDirectoryState();

    getFileFromUrl("http://apivbdhbtp.ungdungtructuyen.vn/Uploads/70e15eba-45b1-4b03-8446-4f49cc73a9d9.pdf").then((value) => {
        setState(() {
          if (value != null) {
            urlPDFPath = value.path;
            loaded = true;
            exists = true;
          } else {
            exists = false;
          }
        })
      },
    );
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, "downloading");
    ///Listening for the data is comming other isolataes
    _receivePort.listen((message) {
      setState(() {
        progress = message[2];
      });

      print(progress);
    });
    // FlutterDownloader.registerCallback(downloadingCallback);
  }

  @override
  Widget build(BuildContext context) {
    if (loaded) {
      return Scaffold(
        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: urlPDFPath,
              autoSpacing: true,
              enableSwipe: true,
              pageSnap: true,
              swipeHorizontal: true,
              nightMode: false,
              onError: (e) {
                print(e);
              },
              onRender: (_pages) {
                setState(() {
                  _totalPages = _pages!;
                  pdfReady = true;
                });
              },
              onViewCreated: (PDFViewController vc) {
                setState(() {
                  _pdfViewController = vc;
                });
              },
              onPageChanged: (int? page, int? total) {
                setState(() {
                  _currentPage = page!;
                });
              },
              onPageError: (page, e) {},
            ),
            !pdfReady
                ? Center(
              child: CircularProgressIndicator(),
            )
                : Offstage(),
            Positioned(
                left: position!.dx,
                top: position!.dy - height - 57,
                child: Visibility(
                  visible: _visibleSign,
                  child: Draggable(
                    child: Container(
                      width: width,
                      height: height,
                      color: Colors.transparent,
                      child: Center(
                          child: Image(
                            image: AssetImage('assets/signature.png'),
                            width: width,
                            height: height,
                          )),
                    ),
                    feedback: Center(
                        child: Image(
                          image: AssetImage('assets/signature.png'),
                          width: width,
                          height: height,
                        )),
                    childWhenDragging: Container(),
                    onDraggableCanceled: (Velocity velocity, Offset offset) {
                      setState(() {
                        double screenWidth = MediaQuery.of(context).size.width;
                        double _x = offset.dx;
                        double _y = offset.dy;

                        if (_x > screenWidth - width - 10) {
                          _x = screenWidth - width - 10;
                        } else if (_x < 10) {
                          _x = 10;
                        }

                        double screenHeight = MediaQuery.of(context).size.height;
                        // height without SafeArea
                        var padding = MediaQuery.of(context).padding;
                        double height1 =
                            screenHeight - padding.top - padding.bottom;

                        if (_y > height1 - 100)
                          _y = height1 - 100;
                        else if (_y < 100) _y = 100;

                        offset = new Offset(_x, _y);
                        position = offset;
                      });
                    },
                  ),
                )),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              child: const Icon(Icons.question_answer),
              backgroundColor: Colors.blue.shade800,
              onPressed: () {
                var sheetController = showBottomSheet(
                    context: context, builder: (context) => BottomSheetWidget());
                sheetController.closed.then((value) {
                  print('press');
                });
              },
            ),
            FloatingActionButton(
              child: const Icon(Icons.edit),
              backgroundColor: Colors.blue.shade800,
              onPressed: () {
                setState(() {
                  _visibleSign = !_visibleSign;
                  _enableSwipe = !_enableSwipe;
                  if (!_visibleSign){
                    _getSignMessage();
                    print('$_signMessage');
                  }
                });
              },
            ),
            FloatingActionButton(
              child: const Icon(Icons.file_download),
              backgroundColor: Colors.blue.shade800,
              onPressed: () async {
                final status = await Permission.storage.request();
                if (status.isGranted) {
                  // final externalDir = await getExternalStorageDirectory();
                  print(_downloadsDirectory!.path);
                  // print(externalDir.path);
                  /*await FlutterDownloader.enqueue(
                    url:
                    "http://apivbdhbtp.ungdungtructuyen.vn/Uploads/70e15eba-45b1-4b03-8446-4f49cc73a9d9.pdf",
                    headers: {"auth": "test_for_sql_encoding"},
                    savedDir: _downloadsDirectory.path,
                    fileName: "simaxpdf1.pdf",
                    showNotification: true,
                    openFileFromNotification: true,
                  );*/
                } else {
                  print("Permission deined");
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.chevron_left),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_currentPage > 0) {
                    _currentPage--;
                    _pdfViewController!.setPage(_currentPage);
                  }
                });
              },
            ),
            Text(
              "${_currentPage + 1}/$_totalPages",
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              iconSize: 50,
              color: Colors.black,
              onPressed: () {
                setState(() {
                  if (_currentPage < _totalPages - 1) {
                    _currentPage++;
                    _pdfViewController!.setPage(_currentPage);
                  }
                });
              },
            ),
          ],
        ),

      );
    } else {
      if (exists) {
        //Replace with your loading UI
        return Scaffold(
          appBar: AppBar(
            title: Text("Demo"),
          ),
          body: Text(
            "Loading..",
            style: TextStyle(fontSize: 20),
          ),
        );
      } else {
        //Replace Error UI
        return Scaffold(
          appBar: AppBar(
            title: Text("Demo"),
          ),
          body: Text(
            "PDF Not Available",
            style: TextStyle(fontSize: 20),
          ),
        );
      }
    }
  }
}

// downloadPDF(String url, Directory downloadsDirectory) async{
//   final status = await Permission.storage.request();
//   if (status.isGranted) {
//     print(downloadsDirectory.path);
//     await FlutterDownloader.enqueue(
//       url:"http://apivbdhbtp.ungdungtructuyen.vn/Uploads/70e15eba-45b1-4b03-8446-4f49cc73a9d9.pdf",
//       // url: url,
//       // headers: {"auth": "test_for_sql_encoding"},
//       savedDir: downloadsDirectory.path,
//       fileName: "simaxpdf1.pdf",
//       showNotification: true,
//       openFileFromNotification: true,
//     );
//
//
//   } else {
//     print("Permission deined");
//   }
// }