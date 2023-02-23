import 'package:flutter/material.dart';
import 'DuThao.dart';
import 'MenuRight.dart';
import 'HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'shared.dart';

class BottomNavigator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BottomNavigatorState();
  }
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _currentIndex = 0;
  String _title = 'DEMO VGCA';
  String urlttVB = '';
  int? trangthaiDT;
  String tenUser = "";
  String chucvu = "";

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  @override
  void initState() {
    super.initState();
    getUserInfor();
  }


  getUserInfor() async {
    String url = "http://qlvbapi.moj.gov.vn/test/GetThongTinUser";
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
      setState(() {
        tenUser = items["Title"];
        chucvu = items["userChucVu"];
      });
      sharedStorage!.setString("hotenUser", tenUser);
      sharedStorage!.setString("chucvu", chucvu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: body(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'Trang chủ',
            // title: new Text('Trang chủ'),
          ),
          new BottomNavigationBarItem(
            icon: new Icon(Icons.library_books),
            label: 'Dự thảo',
            // title: new Text('Dự thảo'),
          ),
        ],
      ),
      endDrawer: MenuRight(hoten: tenUser,chucvu: chucvu,),
    );
  }

  Widget? body() {
    switch (_currentIndex) {
      case 0:
        return HomePage(returnData: trangthaiVB);
        break;
      case 1:
        return DuThaoWidget(urlLoaiVB: urlttVB, trangthai: trangthaiDT!,);
        break;
    }
  }

  void trangthaiVB(String ttvb,  int index, int trangthai){
    setState(() {
      urlttVB = ttvb;
      _currentIndex = index;
      trangthaiDT = trangthai;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      if (index == 1)
        urlttVB = "";
      _currentIndex = index;
    });
  }
}
