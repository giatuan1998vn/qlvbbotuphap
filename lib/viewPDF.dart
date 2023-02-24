import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qlvbbotuphap/shared.dart';
import 'bottomsheet_widget.dart';
import 'dart:io' show Platform;

class PdfViewPage extends StatefulWidget {
  ValueNotifier<String> path = ValueNotifier<String>('');
  final String idDuThao;
  final String token;
  final String urlToSign;
  final int trangthai;
  final String? encodedImage ;
  final double pdfWidth;
  final double pdfHeight;
  final double top;
  final double left;
  PdfViewPage({Key? key, required this.path,required this.idDuThao,required this.token,required this.urlToSign,required this.trangthai,  this.encodedImage,required this.top,required this.left,required this.pdfWidth,required this.pdfHeight}) : super(key: key);

  @override
  _PdfViewPageState createState() => _PdfViewPageState(path: path!, idDuThao: idDuThao!, token: token!, urlToSign: urlToSign!, trangthai: trangthai, encodedImage: encodedImage!);
}

class _PdfViewPageState extends State<PdfViewPage> {
  static const platform = const MethodChannel('com.simax.si_vgca/sign');
  int _totalPages = 0;
  int _currentPage = 0;
  bool pdfReady = false;

  var pinController = TextEditingController();

  PDFViewController? _pdfViewController;
  double pdfWidth = 612;
  double pdfHeight = 792;
  Completer<PDFViewController> pdfController = Completer<PDFViewController>();
  bool pdfReload = false;

  double width = 100.0, height = 70.0;
  Offset? position;
  bool _visibleSign = false;
  bool _enableSwipe = true;
  String _signMessage = 'Unknown';
  List<Widget> listButton = [];
//  String path;
  final String idDuThao;
  final String token;
  final String urlToSign;
  final dynamic trangthai;
  final String encodedImage;

  ValueNotifier<String>? path = ValueNotifier<String>('');


  GlobalKey stickyKey = GlobalKey();
  final stickyKeyPositioned = GlobalKey();
  GlobalKey stickyKeyPdf = GlobalKey();
  double? top, left;
  double? xOff, yOff;
  _PdfViewPageState({
    @required this.path, required this.idDuThao,required this.token,required this.urlToSign, this.trangthai,required this.encodedImage
  });

  Future<void> _getSignMessage(BuildContext buildContext) async {

    String message;
    try {
      /*print("page = $_currentPage");
      print("x = ${position.dx.toInt()}");
      print("y = ${position.dy.toInt()}");

      double screenWidth = MediaQuery.of(context).size.width;
      double screenHeight = MediaQuery.of(context).size.height;
      // height without SafeArea
      var padding = MediaQuery.of(context).padding;
      double height1 = screenHeight - padding.top - padding.bottom;
      double screenPDFHeight = height1 - 100 - height;
      log('screenPDFHeight: $screenPDFHeight');
      log('Width = $screenWidth');
      log('Height = $screenHeight');
      log('x = ${position.dx}');
      log('y = ${height1 - position.dy}');
      double scaleX = position.dx/screenWidth;
      double scaleY = (((height1 - position.dy - (position.dy * 0.2))/screenHeight)).abs();
      int dx = (scaleX * pdfWidth).toInt();
      // int dy = (height1 - (scaleY * pdfHeight)).toInt().abs();
      int dy;
      print('scaleY :$scaleY');
      // dy = 180;
      double scaleScreen = pdfWidth/screenWidth;
      double scaleScreenHeight = pdfHeight/screenHeight;
      dy = (pdfHeight*scaleY).toInt();*/
      /*log('dy: ${dy}');
      print('dx: $dx');
      print('dy: $dy');*/
      final keyContext = stickyKeyPdf.currentContext;
      final box = keyContext!.findRenderObject() as RenderBox;
      final pos = box.localToGlobal(Offset.zero);
      double ratioW = pdfWidth/(box.size.width);
      double ratio = (box.size.width)/pdfWidth;
      final boxWidth = box.size.width;
      print('BOX WIDTH: ${boxWidth}');
      print('ratioW: ${ratioW}');
      final boxHeight = pdfHeight * ratio;
      print('BOX HEIGHT CAL: ${boxHeight}');
      // log('offset: ${drag.offset.toString()}');

      print('BOX HEIGHT: ${box.size.height}');

      print('x: ${left.toString()}, y: ${top.toString()}');
      print('dx1: ${left}, dy1: ${(box.size.height - top! - height - ((box.size.height - boxHeight)/2))}');
      int dy = (box.size.height - top! - height - ((box.size.height - boxHeight)/2)).toInt();
      double ratioH = pdfHeight/(boxHeight);

      print('dx: ${left! * ratioW}, dy: ${dy * ratioH}');
      int dx = (left! * ratioW).toInt();
      dy = (dy * ratioH).toInt();
      print('final dx: ${dx}, dy: ${dy}');
      print('final width: ${width * ratioW}, height: ${height * ratioH}');
      print('urlToSign: $urlToSign');
      if (Platform.isIOS){
        print("ImageSign: $encodedImage");
        message = await platform.invokeMethod('signPDF', {"url": urlToSign, "itemid": idDuThao, "token": token, "currentPage": _currentPage, "dx": dx, "dy": dy, "width": (width * ratioW).toInt(), "height": (height * ratioH).toInt(), "encodedImage": encodedImage});
      }else{
        message = await platform.invokeMethod('signPDF', {"filePath": widget.path!.value, "itemid": idDuThao, "token": token, "currentPage": _currentPage, "dx": dx, "dy": dy, "width": (width * ratioW).toInt(), "height": (height * ratioW).toInt()});
        // print("MinhNH: $encodedImage");
      }

      // message = await platform.invokeMethod('signPDF', {"pinCode": "12"});
    } on PlatformException catch (e) {
      message = e.toString();
    }
    setState(() {
      _signMessage = message;
      print('message: $_signMessage');
      _visibleSign = !_visibleSign;
      _enableSwipe = !_enableSwipe;
    });

  }

  showLogInDialog(BuildContext buildContext) async{

    await showDialog(
      context: buildContext,
      builder: (BuildContext newContext) => AlertDialog(
        title: new Text('Đăng nhập'),
        content: new Row(
          children: [
            new Expanded(
                child: new TextField(
                  controller: pinController,
                  autofocus: true,
                  decoration: new InputDecoration(
                      labelText: 'Mã PIN:', hintText: 'eg. 123456'
                  ),
                  onSubmitted: (value){
                    logInSmartCard(value);
                    Navigator.of(newContext).pop();
                  },
                )
            )
          ],
        ),
        actions: [
          new TextButton(
              onPressed: (){
                Navigator.of(newContext).pop();
              },
              child: const Text('Hủy')
          ),
          new TextButton(
              onPressed: (){
                Navigator.of(newContext).pop();
                logInSmartCard(pinController.text);
              },
              child: const Text('Đăng nhập')
          ),
        ],
      ),
    );
  }
  Future<void> logInSmartCard(String pinCode) async{

    if (Platform.isAndroid){
      setState(() {
        _visibleSign = !_visibleSign;
        _enableSwipe = !_enableSwipe;
      });
    }else {
      String message = await platform.invokeMethod('loginSmartCard', {"pinCode": pinCode});

      print(message);
      if (message == "Success"){
        setState(() {
          _visibleSign = !_visibleSign;
          _enableSwipe = !_enableSwipe;
        });
      }else{
        showAlertDialog(context, message);
      }
    }
  }

  Future<File> getFileFromAsset(String asset) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/VanBanGoc123.pdf");

      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    } catch (e) {
      throw Exception("Error opening asset file");
    }
  }

  List<Widget> getListButton(){
    List<Widget> lst = [];

    if (trangthai >=3 && trangthai <=5){
      lst.add(FloatingActionButton.extended(
        icon: Icon(Icons.question_answer),
        label: Text("Xử lý"),
        backgroundColor: Colors.blue.shade800,
        onPressed: () {
          var sheetController = showBottomSheet(
              context: context,
              builder: (context) => BottomSheetWidget(idDuThao: widget.idDuThao,));
          sheetController.closed.then((value) {
            print('press');
          });
        },
      ));
    }
    if(trangthai == 4){
    // if(true){
      lst.add(FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: Text("Ký"),
        backgroundColor: Colors.blue.shade800,
        onPressed: () {
          if (Platform.isIOS)
            showLogInDialog(context);
          else{
            setState(() {
              _visibleSign = !_visibleSign;
              _enableSwipe = !_enableSwipe;
            });
          }
          // setState(() {
          //   _visibleSign = !_visibleSign;
          //   _enableSwipe = !_enableSwipe;
          // });
        },
      ));
    }
    return lst;
  }
  @override
  void initState() {
    super.initState();
    pdfWidth = widget.pdfWidth!;
    pdfHeight = widget.pdfHeight!;
    print("pdfWidth: $pdfWidth");
    print("pdfHeight: $pdfHeight");
    print("trangthai: $trangthai");
    position = Offset(0, 0);
    top = widget.top;
    left = widget.left;
    listButton = getListButton();
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _getRenderOffsets() {
    // final RenderObject renderBoxWidget = stickyKeyPositioned!.currentContext!.findRenderObject()!;
    // final offset = renderBoxWidget.localToGlobal(Offset.zero!);
    final keyContext = stickyKeyPositioned.currentContext;
    final box = keyContext!.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    yOff = offset.dy - this.top!;
    xOff = offset.dx - this.left!;
  }

  void _afterLayout(_) {
    _getRenderOffsets();
  }

  @override
  void didChangeMetrics() {
    if (Platform.isAndroid) {
      // for rotations on Android
      pdfController = Completer<PDFViewController>();
      pdfReload = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pdfReload) {
      // for rotations on Android
      Timer(Duration(milliseconds: 300), () {
        setState(() {
          pdfReload = false;
        });
      });
    }

    return Scaffold(
     // resizeToAvoidBottomPadding: false,
      body: Stack(
        key: stickyKey,
        children: <Widget>[
          ValueListenableBuilder(
            builder: (BuildContext context, String value, Widget? child)
            {
              return  pdfReload ? Container() : PDFView(
                key: stickyKeyPdf,

                filePath: '$value',
                autoSpacing: true,
                enableSwipe: _enableSwipe,
                pageSnap: true,
                swipeHorizontal: true,
                nightMode: false,
                fitPolicy: FitPolicy.BOTH,
                onError: (e) {
                  print(e);
                },
                onRender: (_pages) {
                  setState(() {
                    _totalPages = _pages!;
                    pdfReady = true;
                    pdfReload = false;
                  });
                },
                /*onViewCreated: (PDFViewController vc) {
                  _pdfViewController = vc;
                },*/
                onViewCreated: (PDFViewController pdfViewController) {
                  pdfController.complete(pdfViewController);
                },
                onPageChanged: (int? page, int? total) {
                  setState(() {
                    _currentPage = page!;
                  });
                },
                onPageError: (page, e) {},
              );
            },
            valueListenable: path!,
          ),
          !pdfReady
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Offstage(),
          Positioned(
              key: stickyKeyPositioned,
              left: left,
              top: top,

              child: Visibility(
                visible: _visibleSign,
                child: Draggable(
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.transparent,
                    child: Center(
                      child: (encodedImage != null && encodedImage != "")
                        ? Image.memory(base64.decode(encodedImage!), width: width, height: height, )
                        : Image(
                          image: AssetImage('assets/signature.png'),
                          width: width,
                          height: height,
                        )
                    ),
                  ),
                  feedback: Center(
                      child: (encodedImage != null && encodedImage != "")
                          ? Image.memory(base64.decode(encodedImage!), width: width, height: height,)
                          : Image(
                              image: AssetImage('assets/signature.png'),
                              width: width,
                              height: height,

                            )
                  ),
                  childWhenDragging: Container(),
                  onDragEnd: (drag){
                    final keyContext = stickyKeyPdf.currentContext;
                    final box = keyContext!.findRenderObject() as RenderBox;
                    final pos = box.localToGlobal(Offset.zero);
                    double ratioW = pdfWidth/(box.size.width);
                    double ratio = (box.size.width)/pdfWidth;
                    final boxWidth = box.size.width;
                    print('BOX WIDTH: ${boxWidth}');
                    print('ratioW: ${ratioW}');
                    final boxHeight = pdfHeight * ratio;
                    print('BOX HEIGHT CAL: ${boxHeight}');
                    // log('offset: ${drag.offset.toString()}');

                    print('BOX HEIGHT: ${box.size.height}');

                    setState(() {
                      top = drag.offset.dy - (box.size.height * 0.2);
                      left = drag.offset.dx;
                    });
                    print('x: ${left.toString()}, y: ${top.toString()}');
                    print('dx1: ${left}, dy1: ${(box.size.height - top! - height - ((box.size.height - boxHeight)/2))}');
                    int dy = (box.size.height - top! - height - ((box.size.height - boxHeight)/2)).toInt();
                    double ratioH = pdfHeight/(boxHeight);

                    print('dx: ${left! * ratioW}, dy: ${dy * ratioH}');
                  },
                  /*onDraggableCanceled: (Velocity velocity, Offset offset) {
                    final keyContext = stickyKey.currentContext;
                    final box = keyContext.findRenderObject() as RenderBox;
                    final pos = box.localToGlobal(Offset.zero);

                    log('offset: ${offset.toString()}');
                    log('BOX WIDTH: ${box.size.width}');
                    log('BOX HEIGHT: ${box.size.height}');

                    final keyContextvisi = stickyKeyvisi.currentContext;
                    final boxvisi = keyContextvisi.findRenderObject() as RenderBox;
                    final posvisi = boxvisi.localToGlobal(Offset.zero);

                    log('POS: ${posvisi.toString()}');

                    setState(() {

                      top = drag.offset.dy - yOff;
                      left = drag.offset.dx - xOff;

                      *//*double screenWidth = MediaQuery.of(context).size.width;
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

                      if (_y > height1 - height - 70)
                        _y = height1 - height - 70;
                      else if (_y < 130) _y = 130;

                      offset = new Offset(_x, _y - (screenHeight * 8 / 100));*//*
                      offset = new Offset(offset.dx, offset.dy);
                      position = offset;
                    });
                  },*/
                ),
              )),
        ],
      ),
      floatingActionButton: _visibleSign
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "btnCancel",
                  child: const Icon(Icons.cancel),
                  backgroundColor: Colors.blue.shade800,
                  onPressed: () {
                    setState(() {
                      _visibleSign = !_visibleSign;
                      _enableSwipe = !_enableSwipe;
                    });
                  },
                ),
                FloatingActionButton(
                  heroTag: "btnSign",
                  child: const Icon(Icons.done),
                  backgroundColor: Colors.blue.shade800,
                  onPressed: () {
                    if (_visibleSign) {
                      _getSignMessage(context);
                    }
                  },
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: listButton,
            ),
    );
  }
}
class _SystemPadding extends StatelessWidget{
  final Widget? child;
  _SystemPadding({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context){
    var mediaQuery = MediaQuery.of(context);
    return new AnimatedContainer(
      padding: mediaQuery.viewInsets,
      duration: const Duration(microseconds: 300),
      child: child,
    );
  }
}
