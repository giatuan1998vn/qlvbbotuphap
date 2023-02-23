import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qlvbbotuphap/MenuRight.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'shared.dart';

class HomePage extends StatefulWidget {
  final returnData;

  const HomePage({Key? key, this.returnData}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return PageState();
  }
}

class PageState extends State<HomePage> {
  int dangsoanthao= 0 ,dangtrinhky = 0,danglamlai =0,choxacnhan = 0;
  @override
  void initState() {
    super.initState();
    countDT();
    getUserInfor();
  }
  String? hoten, chucvu;

  getUserInfor() async {
    String url = "http://apivbdhbtp.ungdungtructuyen.vn/test/GetThongTinUser";
    sharedStorage = await SharedPreferences.getInstance();
    String? token = await sharedStorage!.getString("token");
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
        hoten = items["Title"];
        chucvu = items["userChucVu"];
      });
      sharedStorage!.setString("hotenUser", hoten!);
      sharedStorage!.setString("chucvu", chucvu!);
      print('$hoten');
    }
  }

  countDT() async{
      if (!mounted) return;
      tt2 = await lengthDuthao(context, "/test/GetThaoJsonsByTrangThai?TrangThai=2");
      tt4 = await lengthDuthao(context, "/test/GetThaoJsonsByTrangThai?TrangThai=4");
      tt6 = await lengthDuthao(context, "/test/GetThaoJsonsByTrangThai?TrangThai=6");
      tt8 = await lengthDuthao(context, "/test/GetThaoJsonsByTrangThai?TrangThai=8");
      setState(() {
        dangsoanthao = tt2!;
        dangtrinhky = tt4!;
        danglamlai = tt6!;
        choxacnhan = tt8!;
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: new AppBar(
      automaticallyImplyLeading: false,
      title: Text('DỰ THẢO'),
      actions: <Widget>[
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.person_outline),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ],
    ),
    endDrawer: MenuRight(hoten: hoten,chucvu: chucvu,),
    body: new ListView(
      padding: const EdgeInsets.all(0.0),
      children: <Widget>[
        Card(
          child: ListTile(
            title: Text("Đang soạn thảo/Xin ý kiến"),
            leading: Icon(Icons.assignment , color: Colors.grey),
            trailing: Container(
              padding: const EdgeInsets.all(7.0),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
              ),
              child: new Text("$dangsoanthao", style: new TextStyle(color: Colors.white, fontSize: 21.0)),
            ),
            onTap: (){
              widget.returnData('/test/GetThaoJsonsByTrangThai?TrangThai=2',1,2);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Đang làm lại"),
            leading: Icon(Icons.cached, color: Colors.grey),
            trailing:  Container(
              padding: const EdgeInsets.all(7.0),
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent,
              ),
              child: new Text("$danglamlai", style: new TextStyle(color: Colors.white, fontSize: 21.0)),
            ),
            onTap: (){
              widget.returnData('/test/GetThaoJsonsByTrangThai?TrangThai=6',1,6);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Đang trình ký"),
            leading: Icon(Icons.dehaze, color: Colors.grey),
            trailing: InkWell(
              child: new Container(
                //width: 50.0,
                //height: 50.0,
                padding: const EdgeInsets.all(7.0),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: new Text("$dangtrinhky", style: new TextStyle(color: Colors.white, fontSize: 21.0)),
              ),
            ),
            onTap: (){
              widget.returnData('/test/GetThaoJsonsByTrangThai?TrangThai=4',1,4);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Đã chuyển phát hành"),
            leading: Icon(Icons.call_to_action, color: Colors.grey),
            onTap: (){
              widget.returnData('/test/GetThaoJsonsByTrangThai?TrangThai=1',1,1);
            },
          ),
        ),
        Card(
          child: ListTile(
            title: Text("Chờ xác nhận thu hồi"),
            leading: Icon(Icons.turned_in, color: Colors.grey),
            // trailing: Text("(8)", style: TextStyle(color: Colors.red), ),
            trailing:  Container(
                //width: 50.0,
                //height: 50.0,
                padding: const EdgeInsets.all(7.0),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent,
                ),
                child: new Text("$choxacnhan", style: new TextStyle(color: Colors.white, fontSize: 21.0)),
              ),
            onTap: (){
              widget.returnData('/test/GetThaoJsonsByTrangThai?TrangThai=8',1,8);
            },
            ),
          ),
      ],
    ),
  );

  }
}
