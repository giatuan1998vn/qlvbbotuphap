import 'dart:developer' as Dev;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qlvbbotuphap/data/moor_database.dart';



import 'viewPDF.dart';
import 'ThongTinVBDT.dart';
import 'NhatKyDuThao.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class ThongTinDuThaoWidget extends StatefulWidget {
  ThongTinDuThaoWidget({ required this.idDuThao,required this.trangthai,required this.fileName}) ;
  final String idDuThao;
  final int trangthai;
  final String fileName;
  @override
  State<StatefulWidget> createState() {
    return TabBarVBDuThao();
  }
}

class TabBarVBDuThao extends State<ThongTinDuThaoWidget> {
  bool isLoading = false;
//  String assetPDFPath = "";
  ValueNotifier<String> assetPDFPath = ValueNotifier<String>('');
  ValueNotifier<String> remotePDFpath = ValueNotifier<String>('');
  SharedPreferences? sharedStorage;
  var duThao = null;
  var urlFile = null;
  String? AuthToken;
  bool isLoadingPDF = true;
  var urlToSign = "";
   String encodedImages = "";
  double pdfWidth = 612;
  double pdfHeight = 792;
  @override
  void initState() {
    super.initState();
    this.fetchData();
    getFileFromAsset("assets/VanBanGoc.pdf").then((f) {
      setState(() {
        assetPDFPath = ValueNotifier(f.path);
        // print(assetPDFPath);
      });
    });


  }

  Future<File> createFileOfPdfUrl(String filePath) async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      // final url = "http://www.pdf995.com/samples/pdf.pdf";
      final url = 'http://qlvbapi.moj.gov.vn/' + filePath;
      urlToSign = url;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);

    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  getDecodedImage(BuildContext buildContext) async{
    final database = Provider.of<TaskDatabase>(buildContext);
    Task defaultSign = await database.getDefault();
    if (defaultSign != null){
      encodedImages = defaultSign.name!;
    }
    else
      encodedImages = "";
  }

//Get api
  fetchData() async {
    String url =
        "http://qlvbapi.moj.gov.vn/test/GetDuThaoByID/" + widget.idDuThao;
    sharedStorage = await SharedPreferences.getInstance();
    String? token = sharedStorage!.getString("token");
    AuthToken = token;
    var response = await http.get(Uri.parse(url), headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer ' + token!
    });
    if (response.statusCode == 200) {
      var items = jsonDecode(response.body)['OData'];
      setState(() {
        duThao = items;
        isLoading = false;
      });
    } else {
      duThao = null;
      isLoading = false;
    }

    if (duThao != null) {
      setState(() {
        isLoadingPDF = true;
      });
      List<dynamic> lstDuThao = duThao['listFileAttachField'];
      String urlField = duThao['listFileAttachField'][lstDuThao.length - 1]['urlField'];
      var fileD;
      if (widget.fileName != null)
        fileD = lstDuThao.singleWhere((element) => element["nameField"] == widget.fileName);

      if (fileD != null){
        urlField = fileD["urlField"];
      }
      if(lstDuThao.isNotEmpty){
        url = "http://qlvbapi.moj.gov.vn/test/GetUrlFile/" +
            widget.idDuThao! +
            "?urlfile=" +urlField;
        sharedStorage = await SharedPreferences.getInstance();
        String? token = sharedStorage!.getString("token");
        var responseDuThao = await http.get(
          Uri.parse(url),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': 'Bearer ' + token!
          },
        );

        if (responseDuThao.statusCode == 200) {
          var items = jsonDecode(responseDuThao.body)['OData'];
          if(items != null){
            urlFile = items["url"];
            setState(() {
              pdfWidth = items["Width"];
              pdfHeight = items["Height"];
            });
            Dev.log('urlFile: $urlFile');
            await createFileOfPdfUrl(urlFile).then((f) {
              setState(() {
                remotePDFpath = ValueNotifier(f.path);
              });
            });
          }
          setState(() {
            isLoading = false;
            isLoadingPDF = false;
          });
        } else {
          urlFile = null;
          isLoading = false;
          setState(() {
            isLoadingPDF = false;
          });
        }
      }
      else{
        isLoading = false;
        setState(() {
          isLoadingPDF = false;
        });
      }
    }
  }

  Future<File> getFileFromAsset(String asset) async {
    try {
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/VanBanGoc.pdf");

      File assetFile = await file.writeAsBytes(bytes);
      return assetFile;
    } catch (e) {
      throw Exception("Error opening asset file");
    }
  }

  List<bool> isSelected = [false, false, false];

  @override
  Widget build(BuildContext context) {
    getDecodedImage(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
       // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          ),
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Thông tin',
              ),
              Tab(
                text: 'Toàn văn',
              ),
              Tab(
                text: 'Gửi nhận',
              ),
            ],
          ),
          title: Text('Chi tiết văn bản dự thảo'),

        ),
        body: !isLoading ? TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            ThongTinVBDT(
              idDuThao: widget.idDuThao!,
            ),
            !isLoadingPDF
            ? (remotePDFpath.value != '' && remotePDFpath.value.toLowerCase().contains(".pdf"))?
            Container(
              child: PdfViewPage(path: remotePDFpath, idDuThao: widget.idDuThao!, token: AuthToken!, urlToSign: urlToSign, trangthai: widget.trangthai, encodedImage: encodedImages, left: 0, top: 0, pdfWidth: pdfWidth, pdfHeight: pdfHeight,),
              // child: PDFNativeScreen(path: remotePDFpath,),
            ): Container(
              child: Center(
                child: Text('Không có file PDF đính kèm'),
              ),
            )
            : Center(
              child: CircularProgressIndicator(),
            ),
            NhatKyDuThao(
              idDuThao: widget.idDuThao!,
            ),
          ],
        ) : Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  void _tapSign() {
    Dev.log('message');
  }
}
