import 'package:flutter/material.dart';
import 'package:qlvbbotuphap/CauHinhChuKySo/ListKySo.dart';
import 'package:qlvbbotuphap/shared.dart';


class MenuRight extends StatelessWidget {
  String? hoten;
  String? chucvu;
  MenuRight({this.hoten, this.chucvu});
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 25.0, left: 5.0),
            color: Colors.blue,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(50.0)),
                  elevation: 10,
                  child: Padding(padding: EdgeInsets.all(9.0),
                    child: Image.asset("assets/default-avatar.png", height: 85, width: 85),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 20),
                  width: MediaQuery.of(context).size.width,
                  child: Text("$hoten",
                    style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).textScaleFactor == 2.0 ? MediaQuery.of(context).textScaleFactor * 4 : 20),),
                )
              ],
            ),
          ),
          ListTile(
            title: new Text('Chữ ký'),
            // trailing: new Icon(Icons.exit_to_app),
            trailing: new IconButton(
              icon: new Icon(Icons.create_outlined), onPressed: () {  },
            ),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuanLyChuKy(),
                  ));
            },
          ),
         /* new ListTile(
            title: new Text('Tạo chữ ký 2'),
            // trailing: new Icon(Icons.exit_to_app),
            trailing: new IconButton(
              icon: new Icon(Icons.create_outlined),
            ),
            onTap: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignaturePicker(title: 'Thêm chữ ký',),*//*   AddImage(title: "Ảnh chữ ký",),*//*
                  ));
            },
          ),*/
          ListTile(
            title: new Text('Đăng xuất'),
            trailing: new IconButton(
              icon: new Icon(Icons.exit_to_app), onPressed: () {  },
            ),
            onTap: (){
              logOut(context);
            },
          ),

        ],
      ),
    );
  }
}


