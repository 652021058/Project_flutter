import 'dart:ffi';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart'; // สมมติว่าคุณมี Custom Clipper อยู่แล้ว
import 'package:flutter_mongo_lab1/controllers/transaction_controller.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TransactionController _transactionController = TransactionController();
  
  String title = '';
  String content = '';
  String message = '';
  String amount = ''; // ยังคงเป็น String

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _transactionController.insertTransaction(
        context,
        title,
        content,
        message, // ส่ง message เป็น String
        amount, // แปลง amount เป็น double ก่อนส่ง
        DateTime.now(),
      ).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เพิ่มบันทึกเรียบร้อยแล้ว')),
        );
        Navigator.pushReplacementNamed(context, '/admin');
      }).catchError((error) {
        if (error.toString().contains('401')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token หมดอายุแล้ว กรุณา login ใหม่')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffE9EFEC), Color(0xffFABC3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // รูปร่างพื้นหลัง
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: Transform.rotate(
                angle: -pi / 3.5,
                child: ClipPath(
                  clipper: ClipPainter(),
                  child: Container(
                    height: height * .5,
                    width: width,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            // เนื้อหาฟอร์ม
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'เพิ่ม',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'บันทึกใหม่',
                            style: TextStyle(color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _buildTextField(
                            label: 'ชื่อเรื่อง',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกชื่อเรื่อง';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              title = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'เนื้อหา',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกเนื้อหา';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              content = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'ข้อความ',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกข้อความ';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              message = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'จำนวน (amount)',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกจำนวน';
                              }
                              if (double.tryParse(value) == null) {
                                return 'กรุณากรอกจำนวนที่ถูกต้อง';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              amount = value!; // เก็บเป็น String
                            },
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _addTransaction,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xffC7253E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'บันทึก',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/admin');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(103, 103, 103, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType? keyboardType,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
