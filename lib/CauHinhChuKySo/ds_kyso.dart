import 'dart:async';
import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'dart:convert' show base64, jsonDecode, jsonEncode;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:english_words/english_words.dart';
import 'package:qlvbbotuphap/CauHinhChuKySo/CreateSignature.dart';
import 'package:qlvbbotuphap/data/moor_database.dart';

class DanhSachChuKy extends StatefulWidget {
  final int page;
  final int pageSize;

  DanhSachChuKy({
    required this.page,
    required this.pageSize,
  });

  @override
  _DanhSachChuKyState createState() =>
      _DanhSachChuKyState(page: page, pageSize: pageSize);
}

class _DanhSachChuKyState extends State<DanhSachChuKy> {
  final _imageSaver = ImageGallerySaver();

  bool _isLoading = false;
  bool _showResult = false;
  String _resultText = "";
  Color _resultColor = Colors.red;
  List lstItem = [];
  int page;
  final int pageSize;
  final PagingController<int, Tasks> _pagingController =
  PagingController(firstPageKey: 1);
  bool alreadySaved = false;

  _DanhSachChuKyState({
    required this.page,
    required this.pageSize,
  });

  @override
  void initState() {

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _pagingController.addStatusListener((status) {
      if (status == PagingStatus.firstPageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Có lỗi xảy ra trong quá trình lấy dữ liệu',
            ),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _pagingController.retryLastFailedRequest(),
            ),
          ),
        );
      }
    });

    Future.delayed(Duration.zero, () {
      this._fetchPage(page);
    });

    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
      final database = Provider.of<TaskDatabase>(context);
      List<Task> lstTaskTmp = await database.getPaged(
          this.pageSize, (this.pageSize * (this.page - 1)) + 1);
      setState(() {
        var json = jsonEncode(lstTaskTmp.map((e) => e.toJson()).toList());
        lstItem += jsonDecode(json);
//        _pagingController.appendLastPage(lstItem);
        page++;
      });
  }

  /// Fetches image from web and saves in gallery
  Future<void> saveNetworkImage() async {
    _startLoading();
    final url =
        "https://solarsystem.nasa.gov/system/downloadable_items/519_solsticeflare.jpg";
    final image = NetworkImage(url);
    final key = await image.obtainKey(ImageConfiguration());
    DecoderCallback decoderCallback;
    final load = image.load(key,"" as DecoderCallback);
    load.addListener(
      ImageStreamListener((listener, err) async {
        final byteData =
            await listener.image.toByteData(format: ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        final res = await ImageGallerySaver.saveImage(bytes

          // directoryName: "dir_name",
        );
        _stopLoading();
        _displayResult(res);
        print(res);
      }),
    );
  }

  /// Saves one of asset images to gallery
  Future<void> saveAssetImage() async {
    _startLoading();
    final urls = ["assets/CHUKY.PNG"];
    List<Uint8List> bytesList = [];
    for (final url in urls) {
      final bytes = await rootBundle.load(url);
      bytesList.add(bytes.buffer.asUint8List());
    }
    final res = await ImageGallerySaver.saveImage( bytesList as Uint8List);
    _stopLoading();
    _displayResult(res);
    print(res);
  }

  /*fetchData() async {
    final database = Provider.of<TaskDatabase>(context);
    List<Task> lstTaskTmp = await database.getPaged(
        this.pageSize, (this.pageSize * (this.page - 1)) + 1);
    setState(() {
      var json = jsonEncode(lstTaskTmp.map((e) => e.toJson()).toList());
      lstItem += jsonDecode(json);
      _pagingController.appendLastPage(lstItem);
      page++;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    /*return   RefreshIndicator(
      onRefresh: () => Future.sync(
            () => _pagingController.refresh(),
      ),
      child: PagedListView<int, Tasks>(
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<Tasks>(
          itemBuilder: (context, item, index) {
            return _buildSinhVien(lstItem[index]);
          },
        ),
      ),
    );
*/

    return Scaffold(
        appBar: AppBar(
          title: Text('Quản lý chữ ký test'),
          actions: [
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateSignature(),
                      ));
                }),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: lstItem.length > 0
                  ? ListView.builder(
                      padding: EdgeInsets.all(7.0),
                      itemBuilder: (context, index)
                      {
                        // if (index < lstItem.length)
                          return _buildSinhVien(lstItem[index]);
                      },
                    )
                  : Center(
                      child: Text('Không có dữ liệu'),
                    ),
            ),
          ],
        ));
  }
   doNothing(BuildContext context, item) {
    var itemID = item["id"];
    final database = Provider.of<TaskDatabase>(context);
    database.deleteTaskById(itemID);
    setState(() {
      lstItem.removeWhere((e) => e["id"] == itemID);
    });
  }
  Widget _buildSinhVien(item) {
    String _base64 = item['name'];



    if (_base64 == null) return new Container();
    Uint8List bytes = base64.decode(_base64);
    return Slidable(

        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          dismissible: DismissiblePane(onDismissed: () {}),

          children:  [
            SlidableAction(

              foregroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Delete',
              onPressed: doNothing(context ,item),

            ),
          ],
        ),



        child: Card(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.blueGrey)),
          elevation: 3,
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(top: 7, bottom: 7),
            //color: index %2 == 0 ? Colors.grey.shade200: Colors.transparent,
            child: Column(
              children: [
                Container(
                  child: new ListTile(
                    visualDensity:
                        VisualDensity(horizontal: 0.0, vertical: -4.0),
                    title: new Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width - 60,
                              child: RichText(
                                text: TextSpan(children: [
                                  WidgetSpan(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.memory(bytes,
                                            width: 140,
                                            height: 160,
                                            fit: BoxFit.fill),
                                        IconButton(
                                          iconSize: 25,
                                          icon: Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,),
                                          highlightColor: Colors.blueAccent,
                                          color: alreadySaved ? Colors.red : null,
                                          onPressed: (){
                                            setState(() {
                                              if (alreadySaved) {
                                                alreadySaved = false;
                                              } else {
                                                alreadySaved = true;
                                              }
                                            });
                                          } ,
                                        ),

                                        /*Container(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  190,
                                              child: RichText(
                                                text: TextSpan(children: [
                                                  TextSpan(
                                                    text: 'Họ tên: ',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.black54),
                                                  ),
                                                  TextSpan(
                                                    text: 'Trần Minh Ngọc',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.black),
                                                  ),
                                                ]),
                                              )),
                                        ],
                                      ),
                                    )*/
                                      ],
                                    ),
                                  ),
                                ]),

                              ),

                            ),

                          ],
                        )
                      ],
                    ),
                    onTap: () {

                    },
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget get _progressIndictaor {
    return _isLoading
        ? Container(
            child: Center(child: CircularProgressIndicator()),
            color: Color.fromRGBO(0, 0, 0, 0.3),
          )
        : Container();
  }

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void _displayResult(bool success) {
    _showResult = true;
    if (success) {
      _displaySuccessMessage();
    } else {
      _displayErrorMessage();
    }
    Timer(Duration(seconds: 2), () {
      _hideResult();
    });
  }

  void _displaySuccessMessage() {
    setState(() {
      _resultText = "Images saved successfullty";
      _resultColor = Colors.green;
    });
  }

  void _displayErrorMessage() {
    setState(() {
      _resultText = "An error occurred while saving images";
      _resultColor = Colors.red;
    });
  }

  void _hideResult() {
    setState(() {
      _showResult = false;
    });
  }
}
