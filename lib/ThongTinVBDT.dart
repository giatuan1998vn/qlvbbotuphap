
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ThongTinVBDT extends StatefulWidget {
  ThongTinVBDT({Key? key, this.idDuThao}) : super(key: key);
  final String? idDuThao;

  @override
  _ThongTinVBDT createState() => _ThongTinVBDT();
}

class _ThongTinVBDT extends State<ThongTinVBDT> {
  SharedPreferences? sharedStorage;

//  List duthaoList = [];
  var duThao = null;
  bool isLoading = false;
  List<dynamic>? yKienitems;
  List<Widget> lstYKien = [];
  @override
  void initState() {
    super.initState();
    this.fetchData();
  }

  //Get api
  fetchData() async {
    setState(() {
      isLoading = true;
      print(widget.idDuThao);
    });

    String url =
        "http://qlvbapi.moj.gov.vn/test/GetDuThaoByID/" + widget.idDuThao!;
    sharedStorage = await SharedPreferences.getInstance();
    String? token = sharedStorage!.getString("token");
    var response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ' + token!
    });

    if (response.statusCode == 200) {
      var items = jsonDecode(response.body)['OData'];

      String url =
          "http://qlvbapi.moj.gov.vn/test/GetYKienJsons/" + widget.idDuThao!;
      var responseYKien = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer ' + token
      });

      if (responseYKien.statusCode == 200){
        yKienitems = jsonDecode(responseYKien.body)['OData'];
        log('respp :${yKienitems.toString()}');
        for(var it in yKienitems!){
          lstYKien.add(
            new Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.25,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(GetDate(it["thoiGianThucTeField"].toString())),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(it["nguoiChoYkienField"].toString(),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text(it["noiDungYKienField"].toString() ,
                  ),
                ),
              ],
            )
          );
          lstYKien.add(new Divider());
        }
      }
      setState(() {
        duThao = items;
        isLoading = false;
      });
    } else {
      duThao = null;
      isLoading = false;
    }
  }
  //tạo list view
  Widget getBody() {
    var trichYeu = duThao['vbdiTrichYeuField']?? "";
    var soKyHieu = duThao['vbdiSoKyHieuField']?? "";
    var nguoiSoanThao = duThao['vbdiNguoiSoanField']['lookupValueField']??"";
    var lanhDao = duThao['vbdiNguoiKyField']['lookupValueField']??"";
    var trangThai = (duThao['vbdiTrangThaiVBField'] != null && duThao['vbdiTrangThaiVBField'] != "") ? ttDuthao(duThao['vbdiTrangThaiVBField']) : "";
    var donviSoanthao = duThao['vbdiDonViSoanThaoField']['lookupValueField']??"";
    var loaiVanban = duThao['vbdiLoaiVanBanField']['lookupValueField']??"";
    return ListView(
              children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:  <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: EdgeInsets.only(left: 22.0),
                            child: Text('Trích yếu',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            // padding: EdgeInsets.only(left: 22.0),
                            padding: EdgeInsets.fromLTRB(22.0,15, 0, 15),
                            child: Text(loaiVanban +" - "+trichYeu,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 22.0),
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text('Số trình ký',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: EdgeInsets.fromLTRB(22.0,15, 0, 15),
                            child: Text(soKyHieu,
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 22.0),
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Text('Trạng thái',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: EdgeInsets.fromLTRB(22.0,15, 0, 15),
                            child: Text(trangThai,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: EdgeInsets.only(left: 22.0),
                            child: Text('Đơn vị soạn/Người soạn',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: EdgeInsets.fromLTRB(22.0,15, 0, 15),
                            child: Text(donviSoanthao+"/"+nguoiSoanThao,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            padding: EdgeInsets.only(left: 22.0),
                            child: Text('Lãnh đạo ký văn bản',
                              style: TextStyle(
                                  fontSize: 14
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: EdgeInsets.fromLTRB(22.0,15, 0, 15),
                            child: Text(lanhDao,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Container(
                    padding: EdgeInsets.only(left: 18.0),
                    margin: EdgeInsets.only(bottom: 15.0, top: 15.0),
                    alignment: Alignment.center,
                    child: Text('Ý kiến',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      )
                      ,),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        padding: EdgeInsets.only(left: 20.0),
                        alignment: Alignment.center,
                        child: Text('Thời gian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          alignment: Alignment.center,
                          child: Text('Cán bộ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),)),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text('Nội dung',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                          ),)),
                    ],
                  ),
                  Divider(),
                  Container(
                    child: Column(
                      children: lstYKien,
                    ),
                  ),
              ]
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue))) :  getBody(),
    );
  }
}

String ttDuthao(id){
  String tt ;
  switch(id){
    case 0:
      tt = "Đã thu hồi";
      break;
    case 1:
      tt = "Đã chuyển phát hành";
      break;
    case 2:
      tt= "Đang soạn thảo/Xin ý kiến";
      break;
    case 3:
      tt = "Đã phê duyệt";
      break;
    case 4:
      tt = "Đang trình ký";
      break;
    case 5:
      tt = "Đã ký";
      break;
    case 6:
      tt = "Đang  làm lại";
      break;
    case 8:
      tt = "Chờ xác nhận thu hồi";
      break;
  }
  return "";
}
String GetDate(String strDt){
  var parsedDate = DateTime.parse(strDt);
  return ("${parsedDate.day}/${parsedDate.month}/${parsedDate.year}");
}
