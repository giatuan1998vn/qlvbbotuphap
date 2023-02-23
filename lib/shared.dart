import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:qlvbbotuphap/Login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

int? tt2;
int? tt4;
int? tt6;
int? tt8;
bool? isLogin;

FirebaseMessaging? firebaseMessaging ;
String? tokenfirebase;
SharedPreferences? sharedStorage;
const String DOMAIN = "http://apivbdhbtp.ungdungtructuyen.vn";

void logOut(BuildContext context) async {
  sharedStorage = await SharedPreferences.getInstance();
  if(!sharedStorage!.getBool("rememberme")!){
    sharedStorage!.clear();
  }else{
    sharedStorage!.remove("expires_in");
    sharedStorage!.remove("token");
  }
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (BuildContext context) => LoginWidget()), (Route<dynamic> route) => false);
}
/// hiện thông báo
Future<void> showAlertDialog(BuildContext context, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Thông báo'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

responseData(String path) async {
  // String url = "http://apivbdhbtp.ungdungtructuyen.vn/test/GetThaoJsons";
  String url = DOMAIN + path;
  sharedStorage = await SharedPreferences.getInstance();
  String? token = sharedStorage!.getString("token");
  var response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ' + token!
      }
  );
  return response;
}

lengthDuthao(BuildContext context, String path)async{
  String url = DOMAIN + path;
  List duthaoList = [];
  sharedStorage = await SharedPreferences.getInstance();
  String? token = sharedStorage!.getString("token");
  var response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ' + token!
      }
  );
  if (response.statusCode == 200) {
    var items = json.decode(response.body)['OData'];
    duthaoList = items;
  } else if(response.statusCode == 401){
    await showAlertDialog(context, "Phiên đăng nhập đã hết hạn \n Vui lòng thử lại");
    logOut(context);
  }
  return duthaoList.length;
}

double autoTextSize(double textSize, double textScaleFactor) {
  return textScaleFactor != 1.0 ? textSize / textScaleFactor : textSize;
}

String ConvertToDateTime(DateTime _value){
  if(_value == null)
    return "";
  final f = new DateFormat('dd/MM/yyyy').format(_value);
  return f.toString();
}