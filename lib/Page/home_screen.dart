import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/controllers/transaction_controller.dart';
import 'package:flutter_mongo_lab1/models/transaction_model.dart';
import 'package:flutter_mongo_lab1/Page/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TransactionModel> transactionss = [];
  List<TransactionModel> filteredTransactions = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTransaction();
  }

  Future<void> _fetchTransaction() async {
    try {
      final transactionList = await TransactionController().getTransactions(context);
      setState(() {
        transactionss = transactionList;
        filteredTransactions = transactionList;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching transaction: $error';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching transaction: $error')));
    }
  }

  void _filterTransactions(String query) {
    setState(() {
      searchQuery = query;
      filteredTransactions = transactionss.where((transaction) {
        return transaction.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }
//post
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกทั้งหมด'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlueAccent.withOpacity(0.8),
              Colors.blue.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              
              // เพิ่ม TextField สำหรับการค้นหา
              TextField(
                onChanged: _filterTransactions,
                decoration: InputDecoration(
                  hintText: 'ค้นหาตามชื่อบันทึก...',
                  border: OutlineInputBorder(),
                  filled: true, // เปิดใช้งานการเติมสี
                  fillColor: Colors.white, // กำหนดสีพื้นหลังเป็นสีขาว
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              
              SizedBox(height: 20),
              
              // แสดงข้อความโหลดหรือข้อความผิดพลาด
              if (isLoading)
                CircularProgressIndicator()
              else if (errorMessage != null)
                Text(errorMessage!)
              else
                _buildTransactionList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return Column(
      children: List.generate(filteredTransactions.length, (index) {
        final transaction = filteredTransactions[index];
        return Container(
          padding: EdgeInsets.all(8.0),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffC7253E)),
              ),
              SizedBox(height: 5),
              Text('เนื้อหา: ${transaction.content}', style: TextStyle(fontSize: 14)),
              Text('จำนวนเงิน: ${transaction.amount}', style: TextStyle(fontSize: 14)),
              Text('ข้อความ: ${transaction.message}', style: TextStyle(fontSize: 14)),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showLikedMessage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text('ถูกใจ'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showDislikedMessage(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text('ไม่ถูกใจ'),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      }),
    );
  }

  void _showLikedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ถูกใจแล้ว!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showDislikedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ไม่ถูกใจเลยนิ'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
