import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:flutter_mongo_lab1/varibles.dart';
import 'package:flutter_mongo_lab1/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthController {
  // Function to save tokens in SharedPreferences
  // Future<void> _saveTokens(String accessToken, String refreshToken) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('accessToken', accessToken);
  //   await prefs.setString('refreshToken', refreshToken);
  // }

  // // Function to get access token
  // Future<String?> getAccessToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('accessToken');
  // }

  // // Function to get refresh token
  // Future<String?> getRefreshToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('refreshToken');
  // }

  Future<UserModel> login(
      BuildContext context, String username, String password) async {
    print(apiURL);
    print(username);
    print(password);

    final response = await http.post(Uri.parse("$apiURL/api/auth/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            "email": username,
            "password": password,
          },
        ));
    print(response.statusCode);
    // Log response body to see what's coming from the server.
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('Response data: $data'); // Log the full response data
      UserModel userModel = UserModel.fromJson(data);

      // Check if all required fields are available in the response.

      // String? role = userModel.user.role;

      // Save tokens to SharedPreferences
      // await _saveTokens(accessToken, refreshToken);

      return userModel;
    } else {
      throw Exception('Error: Invalid response structure');
    }
  }

  Future<void> register(BuildContext context, String username, String password,
      String name, String role, String email) async {
    final Map<String, dynamic> registerData = {
      "username": username,
      "password": password,
      "name": name,
      "role": role,
      "email": email,
    };

    final response = await http.post(
      Uri.parse("$apiURL/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(registerData),
    );
    print(response.statusCode);

    if (response.statusCode == 201) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      print('Registration failed');
    }
  }

  Future<void> refreshToken(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final response = await http.post(
      Uri.parse("$apiURL/api/auth/refresh"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${userProvider.refreshToken}",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      final accessToken = data['accessToken'];
      userProvider.updateAccessToken(accessToken); // แก้ไขให้รับแค่ accessToken
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
