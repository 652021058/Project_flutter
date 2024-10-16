import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:flutter_mongo_lab1/varibles.dart';
import 'package:flutter_mongo_lab1/models/transaction_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TransactionController {
  final _authController = AuthController();
  static int retryCount = 0; // นับจำนวนการพยายามรีเฟรช token

  Future<List<TransactionModel>> getTransactions(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$apiURL/api/transactions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken", // ใส่ accessToken ใน header
        },
      );

      if (response.statusCode == 200) {
        // Decode the response and map it to transcationModel objects
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((transcation) => TransactionModel.fromJson(transcation))
            .toList();
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Wrong Token. Please login again.');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        // Refresh token and retry
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;

        return await getTransactions(context);
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token expired. Please login again.');
      } else {
        throw Exception('Failed to load transcations with status code: ${response.statusCode}');
      }
    } catch (err) {
      throw Exception('Failed to load transcations: $err');
    }
  }

  Future<void> insertTransaction(BuildContext context, String title, String content,
      String amount, String message, DateTime date) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    final Map<String, dynamic> insertData = {
      "title": title,
      "content": content,
      "amount": amount,
      "message": message,
      "date": date.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse("$apiURL/api/transction"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(insertData),
      );

      if (response.statusCode == 201) {
        print("ธุรกรรมถูกเพิ่มเรียบร้อยแล้ว!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token ไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;
        return await insertTransaction(context, title, content, amount, message, date);
      } else {
        throw Exception('ไม่สามารถเพิ่มธุรกรรมได้ สถานะโค้ด: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดในการเพิ่มธุรกรรม: $error');
      throw Exception('ไม่สามารถเพิ่มธุรกรรมได้เนื่องจากข้อผิดพลาด: $error');
    }
  }

  Future<void> updateTransaction(BuildContext context, String transactionId,
      String title, String content, String amount, String message, DateTime date) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    final Map<String, dynamic> updateData = {
      "title": title,
      "content": content,
      "amount": amount,
      "message": message,
      "date": date.toIso8601String(),
    };

    try {
      final response = await http.put(
        Uri.parse("$apiURL/api/transactions/$transactionId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        print("ธุรกรรมถูกอัปเดตเรียบร้อยแล้ว!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token ไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;
        return await updateTransaction(context, transactionId, title, content, amount, message, date);
      } else {
        throw Exception('ไม่สามารถอัปเดตธุรกรรมได้ สถานะโค้ด: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดในการอัปเดตธุรกรรม: $error');
      throw Exception('ไม่สามารถอัปเดตธุรกรรมได้เนื่องจากข้อผิดพลาด: $error');
    }
  }

  Future<void> deleteTransaction(BuildContext context, String transactionId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    try {
      final response = await http.delete(
        Uri.parse("$apiURL/api/transactions/$transactionId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      if (response.statusCode == 200) {
        print("ธุรกรรมถูกลบเรียบร้อยแล้ว!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token ไม่ถูกต้อง กรุณาเข้าสู่ระบบอีกครั้ง');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;
        return await deleteTransaction(context, transactionId);
      } else {
        throw Exception('ไม่สามารถลบธุรกรรมได้ สถานะโค้ด: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดในการลบธุรกรรม: $error');
      throw Exception('ไม่สามารถลบธุรกรรมได้เนื่องจากข้อผิดพลาด: $error');
    }
  }
}
