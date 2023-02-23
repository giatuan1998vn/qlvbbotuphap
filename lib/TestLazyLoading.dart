import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class LazyLoading extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoadingState();
  }
}

class LoadingState extends State<LazyLoading> {
  ScrollController _sc = new ScrollController();
  List duthaoList =[];
  bool isLoading = false;

  bool _hasMore = true;
  int page = 1;
  @override
  void initState() {
    super.initState();
    // this.getBody();
    this.fetchData(page);
    _hasMore = true;
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        fetchData(page);
      }
    });
  }
  //UI Dự thảo
  fetchData(int index) async {
    setState(() {
      isLoading = true;
    });
  print(index);
    String url = "http://attp.ungdungtructuyen.vn/api/TraCuu/TestPageApi?page="+index.toString()+"&pageSize=7";
    print(url);
    var response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        }
    );
    if (response.statusCode == 200) {
      var items = await json.decode(response.body);
    print(items);
      setState(() {
        duthaoList += items;
        isLoading = false;
        page++;
      });
      print(duthaoList.length);
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title:  Theme(
          data: Theme.of(context).copyWith(splashColor: Colors.transparent),
          child: TextField(
            autofocus: false,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.blueGrey, size: 22.0),
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

      body: Column(children: <Widget>[
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
     // resizeToAvoidBottomPadding: false,
    );
  }

//tạo list view
  Widget getBody() {
    if (duthaoList.contains(null) || duthaoList.length < 0 ) {
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
      itemCount: duthaoList == null ? 0 : duthaoList.length+1,
      // itemCount: _hasMore ? duthaoList.length + 1 : duthaoList.length,
      itemBuilder: (context, index) {
        if (index == duthaoList.length) {
          return _buildProgressIndicator();
        } else {
          return getCard(duthaoList[index],index);
        }
      },
      controller: _sc,
    );
  }
// các thẻ con trong list view
  Widget getCard(item, index){
    var vbdiTrichYeuField = item['TEN'];


    return Card(
        elevation: 1.5,
        child: InkWell(
          child: Padding(
            // padding: const EdgeInsets.all(10.0),
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
            child: ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          width: MediaQuery.of(context).size.width-160,
                          height: 42,
                          child: Text(vbdiTrichYeuField,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                      ),
                      SizedBox(height: 25,),
                      Text("$index",style: TextStyle(fontSize: 15,color: Colors.grey,),)
                    ],
                  ),

                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
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

