
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
  //t???o list view
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
                            child: Text('Tr??ch y???u',
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
                            child: Text('S??? tr??nh k??',
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
                            child: Text('Tr???ng th??i',
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
                            child: Text('????n v??? so???n/Ng?????i so???n',
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
                            child: Text('L??nh ?????o k?? v??n b???n',
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
                    child: Text('?? ki???n',
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
                        child: Text('Th???i gian',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14
                          ),
                        ),
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          alignment: Alignment.center,
                          child: Text('C??n b???',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14
                            ),)),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(right: 20.0),
                        child: Text('N???i dung',
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
      tt = "???? thu h???i";
      break;
    case 1:
      tt = "???? chuy???n ph??t h??nh";
      break;
    case 2:
      tt= "??ang so???n th???o/Xin ?? ki???n";
      break;
    case 3:
      tt = "???? ph?? duy???t";
      break;
    case 4:
      tt = "??ang tr??nh k??";
      break;
    case 5:
      tt = "???? k??";
      break;
    case 6:
      tt = "??ang  l??m l???i";
      break;
    case 8:
      tt = "Ch??? x??c nh???n thu h???i";
      break;
  }
  return "";
}
String GetDate(String strDt){
  var parsedDate = DateTime.parse(strDt);
  return ("${parsedDate.day}/${parsedDate.month}/${parsedDate.year}");
}
