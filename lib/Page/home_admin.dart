import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/Page/EdittransactionPage.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';
import 'package:flutter_mongo_lab1/models/user_model.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:flutter_mongo_lab1/models/transaction_model.dart';
import 'package:flutter_mongo_lab1/controllers/transaction_controller.dart';
import 'package:provider/provider.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<TransactionModel> transactions = [];
  List<TransactionModel> filteredTransactions = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchtransaction();
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ออกจากระบบ'),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).onLogout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchtransaction() async {
    try {
      final transactionList = await TransactionController().getTransactions(context);
      setState(() {
        transactions = transactionList;
        filteredTransactions = transactionList; 
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching transactions: $error';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching transactions: $error')));
    }
  }

  void _filtertransactions(String query) {
    setState(() {
      searchQuery = query;
      filteredTransactions = transactions.where((transaction) {
        return transaction.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void updateTransaction(TransactionModel transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTransactionPage(transaction: transaction),
      ),
    );
  }

  Future<void> deletetransaction(TransactionModel transaction) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันบันทึก'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบบันทึกนี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await TransactionController().deleteTransaction(context, transaction.id);
        await _fetchtransaction();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ลบบันทึกสำเร็จ')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting transaction: $error')));
      }
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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'บันทึก',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'รายรับ-รายจ่าย',
                            style: TextStyle(color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // เพิ่ม TextField สำหรับการค้นหา
                    TextField(
                      onChanged: _filtertransactions,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาตามชื่อบันทึก...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_Transaction');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(
                        'เพิ่มบันทึก',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),

                    // แสดงผลโหลดข้อมูล
                    if (isLoading)
                      CircularProgressIndicator()
                    else if (errorMessage != null)
                      Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16))
                    else if (filteredTransactions.isEmpty)
                      Text('ไม่พบบันทึกที่ค้นหา', style: TextStyle(color: Colors.red, fontSize: 16)) // แสดงข้อความถ้าไม่มีบันทึก
                    else
                      _buildTranscationList(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50.0,
              right: 16.0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
                child: Icon(
                  Icons.logout,
                  color: Color(0xff821131),
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscationList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffC7253E)),
                      ),
                      SizedBox(height: 8),
                      Text('เนื้อหา: ${transaction.content}', style: TextStyle(fontSize: 14)),
                      Text('จำนวนเงิน: ${transaction.amount}', style: TextStyle(fontSize: 14)),
                      Text('ข้อความ: ${transaction.message}', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xffFABC3F)),
                  onPressed: () {
                    updateTransaction(transaction);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xff821131)),
                  onPressed: () {
                    deletetransaction(transaction);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
