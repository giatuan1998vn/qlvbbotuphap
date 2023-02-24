import 'package:flutter/material.dart';
import 'package:qlvbbotuphap/MenuRight.dart';
import 'package:qlvbbotuphap/ui/modules/dsfiledinhkem/DanhSachFileDinhKem.dart';
import 'package:qlvbbotuphap/ui/modules/dsfiledinhkem/FloatingModal.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared.dart';


class DuThaoWidget extends StatefulWidget {
  final String? urlLoaiVB;
  final int trangthai;
  const DuThaoWidget({Key? key, this.urlLoaiVB, required this.trangthai}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return DuThaoState();
  }
}

class DuThaoState extends State<DuThaoWidget> {
  SharedPreferences? sharedStorage;
  List duthaoList = [];
  List duthaoDisplay = [];
  bool isLoading = false;
  int ttDuthaoKey= 4;

  String? hoten="", chucvu="";

  @override
  void initState() {
    super.initState();
    this.fetchData(widget.urlLoaiVB!);
    this.getBody();
    getUserInfor();
    if (widget.trangthai != null)
      ttDuthaoKey = widget.trangthai!;
  }


  getUserInfor() async{
    sharedStorage = await SharedPreferences.getInstance();
    if (!mounted) return; setState(() { });
    setState(() {
      hoten = sharedStorage!.getString("hotenUser");
      chucvu = sharedStorage!.getString("chucvu");
    });
  }

  fetchData(String path) async {
    if (!mounted) return; setState(() { });
    setState(() {
      isLoading = true;
    });
    var response;
    if(path == null || path == ""){
      response = await responseData("/test/GetThaoJsonsByTrangThai?TrangThai=2");
    }
    else{
      response = await responseData(path);
    }
    if (response.statusCode == 200) {
      var items = json.decode(response.body)['OData'];
      setState(() {
        duthaoList = items;
        duthaoDisplay = duthaoList;
        isLoading = false;
      });
    } else if(response.statusCode == 401){
      await showAlertDialog(context, "Phiên đăng nhập đã hết hạn \n Vui lòng thử lại");
      logOut(context);
    }
    else {
      setState(() {
        duthaoList = [];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Theme(
            data: Theme.of(context).copyWith(splashColor: Colors.transparent),
            child: TextField(
              autofocus: false,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.white, size: 22.0),
                filled: true,
                fillColor: Color(0x162e91),
                hintText: 'Tìm kiếm',
                contentPadding: EdgeInsets.only(left: 10.0, top: 15.0),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (text){
                text = text.toLowerCase().trim();
                setState(() {
                  duthaoDisplay = duthaoList.where((duthao) {
                    var trichyeuTitle = duthao["vbdiTrichYeuField"].toString().toLowerCase();
                    return trichyeuTitle.contains(text);
                  }).toList();
                });
              },
            ),
          ),
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

      body: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width *  0.1,
                  child: IconButton(
                    icon: Icon(const IconData(0xe164, fontFamily: 'MaterialIcons')),
                    tooltip: isSort == false ? 'Chiều giảm dần ' : 'Chiều tăng dần',
                    onPressed: () {
                      sort(duthaoList,sortType);
                    },
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.centerLeft,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        TextButton(
                            onPressed: (){
                              setState(() {
                                sortType = 0;
                                sort(duthaoList,sortType);
                              });
                            },
                            child: Text('Người soạn',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )
                            )
                        ),
                        TextButton(
                            onPressed: (){
                              setState(() {
                                sortType = 1;
                                sort(duthaoList,sortType);
                              });
                            },
                            child: Text('Ngày soạn',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )
                            )
                        ),
                        TextButton(
                            onPressed: (){
                              setState(() {
                                sortType = 2;
                                sort(duthaoList,sortType);
                              });
                            },
                            child: Text('Người ký',textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                )
                            )
                        ),
                      ],
                    )
                ),
              ],
            ),
            Container(
              height: 10,
            ),
            Expanded(
              child: Container(
                child: getBody(),
              ),
            ),
          ]
      ),
      endDrawer: MenuRight(hoten: hoten!,chucvu: chucvu!,),
      drawer: new Drawer(
        child: new ListView(
          children: <Widget>[
             Container(
               color: Colors.white12,
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height / 8,
                child: DrawerHeader(
                  child: Container(
                    child: Text("DỰ THẢO",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  )
                ),
            ),
            ListTile(
              title: Text('Đang soạn thảo/Xin ý kiến (' + (tt2 == null ? "0" : tt2.toString()) +')',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  ttDuthaoKey = 2;
                  fetchData("/test/GetThaoJsonsByTrangThai?TrangThai=2");
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Đang làm lại (' +(tt6 == null ? "0" : tt6.toString()) +')',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  ttDuthaoKey = 6;
                  fetchData("/test/GetThaoJsonsByTrangThai?TrangThai=6");
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Đang trình ký (' + (tt4 == null ? "0" : tt4.toString()) +')',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  ttDuthaoKey = 4;
                  fetchData("/test/GetThaoJsonsByTrangThai?TrangThai=4");
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Đã phê duyệt',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  ttDuthaoKey = 3;
                  fetchData("/test/GetThaoJsonsByTrangThai?TrangThai=3");
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Đã ký',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  ttDuthaoKey = 5;
                  fetchData("/test/GetThaoJsonsByTrangThai?TrangThai=5");
                  Navigator.pop(context);
                });
              },
            ),
            ListTile(
              title: Text('Chờ xác nhận thu hồi (' + (tt8 == null ? "0" : tt8.toString()) +')',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
              trailing: Icon(Icons.arrow_right),
              onTap: (){
                setState(() {
                  ttDuthaoKey = 8;
                  fetchData("/test/GetThaoJsonsByTrangThai?TrangThai=8");
                  Navigator.pop(context);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getBody() {
    print(duthaoList.length);
    if (duthaoList.contains(null) || duthaoList.length < 0 || isLoading) {
      return Center(
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blueAccent),));
    }
    else if(duthaoList.length == 0){
      return Center(
        child: Text("Không có bản ghi"),
      );
    }
    return ListView.builder(
      // itemCount: duthaoList == null ? 0 : duthaoList.length ,
      itemCount: duthaoDisplay == null ? 0 : duthaoDisplay.length,
      itemBuilder: (context, index) {
        return getCard(duthaoDisplay[index]);
      },
    );
  }
  Widget _getBodyPage(context, int index) {
    return Container( height: 200,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Material(

            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0)),
            child:  DSachFile(
                idDuThao:   index,trangthai:ttDuthaoKey
              // idDuThao: sMIDField.toString(),
            )
        ),
      ),
    );
  }
// các thẻ con trong list view
  Widget getCard(item){
    var vbdiNguoiSoanField = item['vbdiNguoiSoanField']['titleField'];
    var vbdiTrichYeuField = item['vbdiTrichYeuField'];
    var isyKienField = item['isyKienField'];
    int sMIDField = item['idField'];
    String trangthaiState = ttDuthao(item['vbdiTrangThaiVBField']);
    return Card(
        elevation: 1.5,
        child: InkWell(
          onTap: () {


            isyKienField == false
                ?
            // FloatingModal(
            //   child:  DSachFile(
            //       idDuThao:   sMIDField,trangthai:ttDuthaoKey
            //     // idDuThao: sMIDField.toString(),
            //   ),
            // )
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return _getBodyPage(context, sMIDField);
                }
                )


          // isyKienField == false
          //       ? Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //             builder: (context) => DSachFile(
          //               idDuThao: sMIDField,
          //               trangthai: ttDuthaoKey,
          //             ),
          //           ),
          //         )







            //     showFloatingModalBottomSheet(
            //     context: context,
            //     builder: (context) => DSachFile(
            //       idDuThao: sMIDField.toString(),
            //       trangthai: ttDuthaoKey,
            //     ),
            // )
                : print('tapped');
          },
          child: Padding(
            padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 10),
            /*child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.fromLTRB(5.0, 3, 0, 0),
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(vbdiTrichYeuField,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                    ),
                    SizedBox(height: 25,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(vbdiNguoiSoanField,
                        style: TextStyle(fontSize: 14,color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(' ',
                        style: TextStyle(fontSize: 14,color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 25,),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child :Text(trangthaiState,
                          style: new TextStyle(
                              fontSize: 13,
                              color: new Color(0xFF26C6DA)
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),*/
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                        padding: EdgeInsets.fromLTRB(5.0, 3, 0, 0),
                        width: MediaQuery.of(context).size.width * 0.9,
                        /*child: Text(vbdiTrichYeuField,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.justify
                        )*/
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: " "
                              ),
                              WidgetSpan(
                                child: Icon(Icons.assignment, color: Colors.blue,)
                              ),
                              TextSpan(
                                text: " "+ vbdiTrichYeuField,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black
                                ),
                              )
                            ]
                          ),
                          maxLines: 10,
                          textAlign: TextAlign.justify,
                        ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 5.0),
                      child: Text(vbdiNguoiSoanField,
                        style: TextStyle(fontSize: 15,color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 5.0),
                      child :Text(trangthaiState,
                          style: new TextStyle(
                              fontSize: 15,
                              color: new Color(0xFF26C6DA)
                          )
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
        )
    );
  }

  //Sắp xếp ds dự thảo
  bool isSort = false;
  int sortType = 0;
  void sort(List list, int type){
    print(type);

    switch(type){
      case 0:
        list.sort((a,b) => isSort ? Comparable.compare(b["vbdiNguoiSoanField"]["titleField"], a["vbdiNguoiSoanField"]["titleField"]) : Comparable.compare(a["vbdiNguoiSoanField"]["titleField"], b["vbdiNguoiSoanField"]["titleField"])) ;
        break;
      case 1:
        list.sort((a,b) => isSort ?
        Comparable.compare(b["createdField"], a["createdField"]) : Comparable.compare(a["createdField"], b["createdField"])) ;
        break;
      case 2:
        list.sort((a,b) => isSort ?
        Comparable.compare(b["vbdiNguoiKyField"]["idField"], a["vbdiNguoiKyField"]["idField"]) : Comparable.compare(a["vbdiNguoiKyField"]["idField"], b["vbdiNguoiKyField"]["idField"])) ;
        break;
    }
    // list.sort((a,b) => isSort ? Comparable.compare(b[type], a[type]) : Comparable.compare(a[type], b[type])) ;
    setState(() {
      isSort = !isSort;
    });
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
