import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:qlvbbotuphap/ChiTietVBDuThao.dart';
import 'package:qlvbbotuphap/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;


class DSachFile extends StatefulWidget {
  final String? idDuThao;
  final dynamic trangthai;
  DSachFile({this.idDuThao, this.trangthai});


  DSachFileState createState() => DSachFileState();
}

class DSachFileState extends State<DSachFile> {
  var duThao;
  bool isLoading = true;
  List<dynamic>? lstFile;
  fetchData() async {
    print('idDuThao: ${widget.idDuThao}');
    String url =
        "http://apivbdhbtp.ungdungtructuyen.vn/test/GetDuThaoByID/" + widget.idDuThao!;
    sharedStorage = await SharedPreferences.getInstance();
    String? token = sharedStorage!.getString("token");

    var response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ' + token!
    });
    if (response.statusCode == 200) {
      var item = jsonDecode(response.body)['OData'];
      setState(() {
        duThao = item;
        isLoading = false;
      });
    } else {
      duThao = null;
      isLoading = false;
    }
    if(duThao != null){
      lstFile = duThao['listFileAttachField'];

      if(lstFile!.length == 1){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThongTinDuThaoWidget(
              idDuThao: widget.idDuThao,
              trangthai: widget.trangthai,
              fileName: lstFile![0]["nameField"],
            ),
          ),
        );
      }
      else if (lstFile!.length == 0){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ThongTinDuThaoWidget(
              idDuThao: widget.idDuThao,
              trangthai: widget.trangthai,
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Widget getCard(item){
    return Card(
        elevation: 1.5,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ThongTinDuThaoWidget(
                  idDuThao: widget.idDuThao,
                  trangthai: widget.trangthai,
                  fileName: item["nameField"],
                ),
              ),
            );
          },
          child: Padding(
              padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 10),

              child: Container(
                height: 50,
                child: Text(item["nameField"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500
                  ),
                ),
              )
          ),
        )
    );
  }

  Widget getBody() {
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),));
    }
    return ListView.builder(
      // itemCount: duthaoList == null ? 0 : duthaoList.length ,
      itemCount: lstFile == null ? 0 : lstFile!.length,
      itemBuilder: (context, index) {
        return getCard(lstFile![index]);
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Material(
      child: SafeArea(
        top: false,
        child: Container(
          height: 300,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: getBody(),
          ),
        )
      ),
    );
  }

}