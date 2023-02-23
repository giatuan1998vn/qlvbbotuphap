import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class SignWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SignState();
  }
}

class SignState extends State<SignWidget> {
  static const platform = const MethodChannel('com.simax.si_vgca/sign');

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';
  String _signMessage = 'Unknown';

  double width = 50.0, height = 50.0;
  Offset? position;

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getSignMessage() async {
    String message;
    try {
      final String result =
          await platform.invokeMethod('signPDF', {"filePath": 'C:/flutter'});
      message = result;
      log(result);
    } on PlatformException catch (e) {
      message = 'Unknown';
    }
    setState(() {
      _signMessage = message;
    });
  }

  @override
  void initState() {
    super.initState();
    position = Offset(10.0, height + 40);
  }

  @override
  Widget build(BuildContext context) {
    final Completer<PDFViewController> _controller =
        Completer<PDFViewController>();

    double _x = 50;
    double _y = 50;
    // TODO: implement build
    /*return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              child: Text('Get Battery Level'),
              onPressed: _getBatteryLevel,
            ),
            Text(_batteryLevel),
            RaisedButton(
              child: Text('Sign'),
              onPressed: _getSignMessage,
            ),
            Text(_signMessage),
          ],

        ),

      )
    );*/
    return Scaffold(
      appBar: new AppBar(
        title: Text('Trang chủ'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.black54,
          ),
          Positioned(
              left: position!.dx,
              top: position!.dy - height - 30,
              child: Visibility(
                visible: true,
                child: Draggable(
                  child: Container(
                    width: width,
                    height: height,
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        "Drag",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                  ),
                  feedback: Container(
                    child: Center(
                      child: Text(
                        "Drag",
                        style: Theme.of(context).textTheme.headline1,
                      ),
                    ),
                    color: Colors.red[800],
                    width: width,
                    height: height,
                  ),
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
    );
  }

  void signPDF() {
    log('abc123');
  }
}
