import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_mongo_lab1/Page/home_screen.dart';
import 'package:flutter_mongo_lab1/Page/register.dart';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mongo_lab1/models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserModel userModel = await AuthController()
            .login(context, _usernameController.text, _passwordController.text);

        if (!mounted) return;

        // ตรวจสอบ role ของผู้ใช้
        String role = userModel.user.role;
        print("role :$role");

        // อัปเดตสถานะการเข้าสู่ระบบของผู้ใช้
        Provider.of<UserProvider>(context, listen: false).onLogin(userModel);

        // นำทางไปยังหน้าตาม role ของผู้ใช้
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (role == 'user') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // กรณีที่ role ไม่ตรงกับที่คาดไว้
          print('Error: Unknown role');
        }
      } catch (e) {
        print(e);
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
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 255, 252, 195),
              Color.fromARGB(255, 255, 160, 72),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: Container(
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
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 255, 64, 0),
                          ),
                          children: [
                            TextSpan(
                              text: 'App',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 56, 53, 53),
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      _buildTextField(
                        controller: _usernameController,
                        label: "Email",
                      ),
                      SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: _login,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.grey.shade200,
                                offset: Offset(2, 4),
                                blurRadius: 5,
                                spreadRadius: 2,
                              )
                            ],
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xff14279B),
                                Color(0xff14279B),
                              ],
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password ?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: height * .055),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              fillColor: Color(0xfff3f3f4),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Don\'t have an account ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Register',
              style: TextStyle(
                color: Color(0xff14279B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: 40,
      left: 0,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              Icon(Icons.keyboard_arrow_left, color: Colors.black),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
