import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:qlvbbotuphap/shared.dart';



class RegisterForm extends StatefulWidget {
  final String? itemid;
  final Function? data;
  const RegisterForm({Key? key, this.itemid, this.data}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _RegisterFormState();
  }
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final ngayKhaibao = TextEditingController();
  static ValueNotifier<DateTime> firstDate = ValueNotifier<DateTime>(DateTime(1900));
  static ValueNotifier<DateTime> lastDateCheck = ValueNotifier<DateTime>(DateTime(2100));
  int _radioValueDoiTuongKhaiBao = 1;
  int _radioValueNguonTin = 1;
  int _radioValueGioiTinh = 1;
  bool _group2 = false;
  bool isDonvi = false;
  TextEditingController _controllerNgayKhaiBao = TextEditingController();
  bool _isFirstLoading = true;

  // region TextController
  TextEditingController _HOTEN = TextEditingController();
  TextEditingController _SDT = TextEditingController();
  TextEditingController _EMAIL = TextEditingController();
  TextEditingController _USERNAME = TextEditingController();
  TextEditingController _PASS = TextEditingController();
  TextEditingController _CONFIRMPASS = TextEditingController();
  TextEditingController _DIACHI = TextEditingController();
  TextEditingController _NGAYSINH = TextEditingController();
  // endregion

  @override
  void initState() {
    firstDate = ValueNotifier<DateTime>(DateTime.now());
    ngayKhaibao.text =  DateFormat('dd/MM/yyyy').format(firstDate.value);
    super.initState();
  }

  void _onChangeGioiTinh(int? value) {
    setState(() {
      _radioValueGioiTinh = value!;
    });
  }

  var style1 = TextStyle(fontSize: 13,);
  var styleGroup = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 3.0);
  var styleTextField = TextStyle(fontSize: 13);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký tài khoản'),
      ),

      body: FormDangKy(),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget FormDangKy(){
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Yêu cầu nhập giá trị cho trường này';
                      }
                      return null;
                    },
                    controller: _USERNAME,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: styleTextField,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Tên đăng nhập'
                    ),
                  ),
                ),
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Yêu cầu nhập giá trị cho trường này';
                      }
                      return null;
                    },
                    controller: _PASS,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: styleTextField,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Mật khẩu'
                    ),
                  ),
                ),
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Yêu cầu nhập giá trị cho trường này';
                      }
                      return null;
                    },
                    controller: _CONFIRMPASS,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: styleTextField,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Xác nhận mật khẩu'
                    ),
                  ),
                ),
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    controller: _HOTEN,
                    style: styleTextField,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Họ và tên'
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 8,
                      ),
                      Text(
                        'Giới tính :',
                        style: style1,
                      ),
                      GestureDetector(
                        onTap: (){
                          _onChangeGioiTinh(1);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: 1,
                              groupValue: _radioValueGioiTinh,
                              onChanged: _onChangeGioiTinh,
                            ),
                            Text(
                              'Nam',
                              style: style1,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: (){
                          _onChangeGioiTinh(2);
                        },
                        child: Row(
                          children: [
                            Radio(
                              value: 2,
                              groupValue: _radioValueGioiTinh,
                              onChanged: _onChangeGioiTinh,
                            ),
                            Text(
                              'Nữ',
                              style: style1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Yêu cầu nhập giá trị cho trường này';
                      }
                      return null;
                    },
                    style: styleTextField,
                    controller: _NGAYSINH,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    focusNode: onUserInteractionDisabledFocusNode(),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Ngày sinh'
                    ),
                    onTap: (){
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true,
                          maxTime: DateTime.now(),
                          onConfirm: (date) {
                            setState(() {
                              _NGAYSINH.text = ConvertToDateTime(date);
                            });
                          },
                          // currentTime: DateTime.now(),
                          locale: LocaleType.vi
                      );
                    },
                  ),
                ),
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Yêu cầu nhập giá trị cho trường này';
                      }
                      return null;
                    },
                    controller: _SDT,
                    style: styleTextField,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Số điện thoại'
                    ),
                  ),
                ),
                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    controller: _EMAIL,
                    style: styleTextField,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Email'
                    ),
                  ),
                ),

                Container(
                  alignment :Alignment.center,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(7,5,7,0),
                  child: TextFormField(
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Yêu cầu nhập giá trị cho trường này';
                      }
                      return null;
                    },
                    controller: _DIACHI,
                    style: styleTextField,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.lightBlue)),
                        labelText: 'Địa chỉ'
                    ),
                  ),
                ),
                Container(
                  height: 20,
                )
              ],
            ),
          )
      ),
    );
  }
}

class onUserInteractionDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}