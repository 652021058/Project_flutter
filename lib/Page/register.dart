import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/Page/login_screen.dart';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      print('Username : ${usernameController.text}');
      print('Password : ${passwordController.text}');
      print('Name : ${nameController.text}');
      print('Role : ${roleController.text}');
      print('Email : ${emailController.text}');

      try {
        await AuthController().register(
          context,
          usernameController.text,
          passwordController.text,
          nameController.text,
          roleController.text,
          emailController.text,
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: Container(
                child: Transform.rotate(
                  angle: -pi / 3.5,
                  child: ClipPath(
                    clipper: ClipPainter(),
                    child: Container(
                      height: height * .4,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 72, 232, 136),
                            Color.fromARGB(255, 98, 119, 255),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
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
                          text: 'Register',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 0, 34, 255),
                          ),
                          children: [
                            TextSpan(
                              text: ' App',
                              style: TextStyle(
                                color: Color.fromARGB(255, 72, 66, 66),
                                fontSize: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                      _buildTextField(usernameController, 'Username'),
                      _buildTextField(passwordController, 'Password', obscureText: true),
                      _buildTextField(nameController, 'Name'),
                      _buildRoleDropdown(), // เปลี่ยนแปลงที่นี่
                      _buildTextField(emailController, 'Email address', keyboardType: TextInputType.emailAddress),
                      SizedBox(height: 20),
                      _buildRegisterButton(),
                      SizedBox(height: height * .02),
                      _buildLoginPrompt(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
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
                      Text('Back', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 10),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xff14279B), width: 2),
              ),
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

  Widget _buildRoleDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: roleController.text.isNotEmpty ? roleController.text : null,
            items: [
              DropdownMenuItem(
                value: 'admin',
                child: Text('admin'),
              ),
              DropdownMenuItem(
                value: 'user',
                child: Text('user'),
              ),
            ],
            onChanged: (value) {
              roleController.text = value ?? '';
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xff14279B), width: 2),
              ),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please select your role';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return GestureDetector(
      onTap: _register,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.shade200, offset: Offset(2, 4), blurRadius: 5, spreadRadius: 2)
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xff14279B), Color(0xff14279B)],
          ),
        ),
        child: Text('Register Now', style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Already have an account ?', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            SizedBox(width: 10),
            Text('Login', style: TextStyle(color: Color(0xff14279B), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  
}
