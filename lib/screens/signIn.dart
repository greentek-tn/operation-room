import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/common/auth_exception_handler.dart';
import 'package:untitled/common/auth_status.dart';
import 'package:untitled/common/customer_snackbar.dart';
import 'package:untitled/common/loader.dart';
import 'dart:convert';
import 'package:untitled/screens/forgatpassword.dart';
import 'package:untitled/screens/Home.dart';
import 'package:untitled/screens/signUp.dart';
import 'package:untitled/services/auth_service.dart';

import '../common/theme_helper.dart';

class signIn extends StatefulWidget {
  const signIn({Key? key}) : super(key: key);
  @override
  State<signIn> createState() => _signInState();
}

class _signInState extends State<signIn> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  Future<void> _login() async {
    if (_key.currentState!.validate()) {
      LoaderX.show(context);
      final _status = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (_status == AuthStatus.successful) {
        // lahne wa9t tconnecti ysauvegardi andou li enti connectit bech maach yhezk ll login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);

        LoaderX.hide();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        LoaderX.hide();
        final error = AuthExceptionHandler.generateErrorMessage(_status);
        CustomSnackBar.showErrorSnackBar(context, message: error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          flexibleSpace: ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
              bottomLeft: Radius.circular(50),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/app1.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50),
              bottomLeft: Radius.circular(50),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(30, 50, 25, 20),
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        const Text(
                          'Sign in',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 30.0),
                        Form(
                          key: _key,
                          child: Column(
                            children: [
                              Container(
                                decoration: ThemeHelper()
                                    .inputBoxDecorationShaddow(),
                                child: TextField(
                                  controller: _emailController,
                                  decoration: ThemeHelper().textInputDecoration(
                                    'User email',
                                    'Enter your user email',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30.0),
                              Container(
                                decoration: ThemeHelper()
                                    .inputBoxDecorationShaddow(),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: ThemeHelper().textInputDecoration(
                                    'Password',
                                    'Enter your password',
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                    10, 10, 10, 30),
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            forgatpassword(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Forgot your password?",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.0),
                                  color: Colors.green,
                                ),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      5,
                                      20,
                                      5,
                                    ),
                                    child: Text(
                                      'Sign In'.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  onPressed: _login, // Call _login() method
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(10, 20, 10, 20),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Don't have an account? ",
                                      ),
                                      TextSpan(
                                        text: 'Sign up',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    signUp(),
                                              ),
                                            );
                                          },
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
