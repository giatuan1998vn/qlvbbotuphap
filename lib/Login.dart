import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'btnavigator_widget.dart';
import 'shared.dart';


class LoginWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginWidget> {
  SharedPreferences? sharedStorage;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    rememberAccount();
  }

  rememberAccount() async {
    sharedStorage = await SharedPreferences.getInstance();
    if (sharedStorage!.containsKey("username")) {
      String? username = sharedStorage!.getString("username");
      bool? rememberAccount = sharedStorage!.getBool("rememberme");
      usernameController.text = username!;
      setState(() {
        rememberMe = rememberAccount!;
      });
    }
  }

  updateTokenFirebase(String tokenUser) async{
    var url = "http://qlvbapi.moj.gov.vn/test/UpdateTokenFirebase?tokenfirebase=" + tokenfirebase!;
    var response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ' + tokenUser
        }
    );
    if(response.statusCode == 200){
      var mess = json.decode(response.body)['Message'];
      print(mess);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: isLoading
                  ? Center(
                  child: CircularProgressIndicator(
                    valueColor:
                    new AlwaysStoppedAnimation<Color>(Color(0xff4f359b)),
                  ))
                  : ListView(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(10),
                      child: Image(
                        image: AssetImage('assets/btp-logo.png'),
                      )
                  ),
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: new Theme(
                        data: new ThemeData(
                          primaryColor: Colors.white,
                        ),
                        child: new TextField(
                          controller: usernameController,
                          cursorColor: Colors.white38,
                          style: TextStyle(color: Colors.white),
                          decoration: new InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.white)),
                            labelText: 'Tài khoản',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            prefixText: ' ',
                          ),
                        ),
                      )),
                  Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child:
                      new Theme(
                        data: new ThemeData(
                          primaryColor: Colors.white,
                        ),
                        child: new TextField(
                          obscureText: true,
                          controller: passwordController,
                          cursorColor: Colors.white38,
                          style: TextStyle(color: Colors.white),
                          decoration: new InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.white)
                            ),

                            labelText: 'Mật khẩu',
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )),
                  Container(
                    child:
                    Theme(
                        data: ThemeData(unselectedWidgetColor: Colors.white),
                        child: CheckboxListTile(
                          title: Text("Nhớ tên đăng nhập", style: TextStyle(color: Colors.white),),
                          value: rememberMe ,
                          checkColor: Colors.white,
                          onChanged:(newValue) {
                            setState(() {
                              rememberMe = newValue!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        )
                    ),
                  ),
                  Container(
//                   color: Colors.white,
                      height: 50,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff3064D0), // background (button) color// foreground (text) color
                          shape:  RoundedRectangleBorder(
                              side:new  BorderSide(color: Colors.blue,), //the outline color
                              borderRadius: new BorderRadius.all(new Radius.circular(10))),
                        ),
                        //the outline color

                        child: Text('Đăng nhập',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              // color: Colors.white,
                            )),
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          login(usernameController.text.trim(), passwordController.text);
                        },
                      )),
                ],
              )),
        )
    );
  }
  Future<void> login(String username, String password) async{
    if(usernameController.text.isNotEmpty && passwordController.text.isNotEmpty){
//      var url = "http://apivbdhbtp.vn/token";
      var url = "http://qlvbapi.moj.gov.vn/token";
      var details = {
        'username': username,
        'password': password,
        'grant_type': 'password'
      };
      var parts  = [];
      details.forEach((key, value) {
        parts.add('${Uri.encodeQueryComponent(key)}='
            '${Uri.encodeQueryComponent(value)}');
      });
      var formData = parts.join('&');
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData,
      );

      var getToken, expires_in;
      SharedPreferences sharedToken = await SharedPreferences.getInstance();
      DateTime now = DateTime.now();
      if (response.statusCode == 200){
        getToken =  json.decode(response.body)['access_token'];
        expires_in = json.decode(response.body)['expires_in'];
        await sharedToken.setString("token", getToken);
        var expiresOut = now.add(new Duration(seconds: expires_in));
        print(expiresOut.toString());
        sharedToken.setBool("rememberme", rememberMe);
        if(rememberMe){
          sharedToken.setString("username", username);
          sharedToken.setString("password", password);
        }
        sharedToken.setString("expires_in", expiresOut.toString());
        await updateTokenFirebase(getToken);

        setState(() {
          isLoading = false;
        });
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => BottomNavigator()), (Route<dynamic> route) => false);
      }
      else{
        setState(() {
          isLoading = false;
        });
        showAlertDialog(context, "Tài khoản hoặc mật khẩu không đúng");
      }
    }
    else{
      setState(() {
        isLoading = false;
      });
      showAlertDialog(context, "Tài khoản và mật khẩu không được trống");
    }
  }


}