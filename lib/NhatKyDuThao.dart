import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class NhatKyDuThao extends StatefulWidget {
  NhatKyDuThao({Key? key, this.idDuThao}) : super(key: key);
  final String? idDuThao;

  @override
  _NhatKyDuThao createState() => _NhatKyDuThao();
}

class _NhatKyDuThao extends State<NhatKyDuThao> {
  SharedPreferences? sharedStorage;
  List<Widget> listNhatKy = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.fetchData();
    this.getBody();
  }

  //Get api
  fetchData() async {
    setState(() {
      isLoading = true;
    });

    String url =
        "http://apivbdhbtp.ungdungtructuyen.vn/test/GetNhatKyJsons/" + widget.idDuThao!;
    sharedStorage = await SharedPreferences.getInstance();
    String? token = sharedStorage!.getString("token");
    var response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ' + token!
    });

    if (response.statusCode == 200) {
      var items = jsonDecode(response.body)['OData'];
      setState(() {
        // nhatKy = items;
        for(var element in items){
          listNhatKy.add(
              new Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 15,bottom: 15),
                    width: MediaQuery.of(context).size.width * 0.3,
                    alignment:Alignment.center,
                    child: Text( (element['thoiGianThucHienField'] != '') ? (DateFormat('dd/MM/yyyy').format( DateTime.parse(element['thoiGianThucHienField'])) ?? '') : '' ,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    alignment:Alignment.center,
                    padding: EdgeInsets.only(top: 15,bottom: 15),
                    child: Text(element['nguoiThucHienField']['titleField'],
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    padding: EdgeInsets.only(top: 15,bottom: 15),
                    alignment:Alignment.center,
                    child: Text(element['nguoiPTField'][0]['titleField']),
                  ),
                ],
              )
          );
          listNhatKy.add(new Divider());
          setState(() {
            isLoading = false;
          });
        }
      });
    } else {
      listNhatKy = [];
      isLoading = false;
    }
  }

  //tạo list view
  Widget getBody() {
    if (listNhatKy == null || listNhatKy.length == 0) {
      return Center(
          child: Text('Không có nhật ký gửi nhận!'));
    } else {
      return  ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    alignment:Alignment.center,
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                    child: Text('Thời gian',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),)),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  alignment:Alignment.center,
                  padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                  child: Text('Người gửi',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                    ),
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    alignment:Alignment.center,
                    padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
                    child: Text('Nơi nhận',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14
                      ),)),
              ],
            ),
            Container(
              child: Column(
                children: listNhatKy,
              ),
            ),
          ]
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue))) : getBody(),
    );
  }
}
