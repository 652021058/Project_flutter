import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart'; // Assuming you already have customClipper
import 'package:flutter_mongo_lab1/controllers/transaction_controller.dart';
import 'package:flutter_mongo_lab1/models/transaction_model.dart';

class EditTransactionPage extends StatefulWidget {
  final TransactionModel transaction; // รับ transactionModel ที่จะทำการแก้ไข

  const EditTransactionPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _EditTransactionPageState createState() => _EditTransactionPageState();
}

class _EditTransactionPageState extends State<EditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String content;
  late String amount; // จำนวนเงินที่ทำธุรกรรม
  late String message;
  late DateTime date;

  @override
  void initState() {
    super.initState();
    title = widget.transaction.title;
    content = widget.transaction.content;
    amount = widget.transaction.amount;
    message = widget.transaction.message;
    date = widget.transaction.date;
  }

  Future<void> _updateTransaction(BuildContext context, String transactionId) async {
    final transactionController = TransactionController();
    try {
      await transactionController.updateTransaction(
        context,
        transactionId,
        title,
        content,
        amount,
        message,
        date,
      );
      Navigator.pushReplacementNamed(context, '/admin');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('แก้ไขบันทึกเรียบร้อยแล้ว')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการแก้ไขบันทึก: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: [
            // Background
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xffE9EFEC),
                          Color(0xffFABC3F),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'แก้ไข',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'บันทัก',
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
                            label: 'ชื่อ',
                            initialValue: title,
                            onSaved: (value) => title = value!,
                            validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อ' : null,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'เนื้อหา',
                            initialValue: content,
                            onSaved: (value) => content = value!,
                            validator: (value) => value!.isEmpty ? 'กรุณากรอกเนื้อหา' : null,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'จำนวนเงิน',
                            initialValue: amount.toString(),
                            keyboardType: TextInputType.number,
                            onSaved: (value) {
                              if (value != null && value.isNotEmpty) {
                                amount =value; // Handle conversion
                              }
                            },
                            validator: (value) => value!.isEmpty ? 'กรุณากรอกจำนวนเงิน' : null,
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'ข้อความ',
                            initialValue: message,
                            onSaved: (value) => message = value!,
                            validator: (value) => value!.isEmpty ? 'กรุณากรอกข้อความ' : null,
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    _updateTransaction(context, widget.transaction.id);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff821131),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'แก้ไข',
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

  // ฟังก์ชันสร้าง TextField สำหรับฟอร์มแก้ไขโพสต์
  Widget _buildTextField({
    required String label,
    required String initialValue,
    TextInputType? keyboardType,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2), // Shadow position
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
        initialValue: initialValue,
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }
}
