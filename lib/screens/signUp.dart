import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/auth_exception_handler.dart';
import 'package:untitled/common/auth_status.dart';
import 'package:untitled/common/customer_snackbar.dart';
import 'package:untitled/common/loader.dart';
import 'package:untitled/common/validator.dart';
import 'package:untitled/screens/signIn.dart';
import 'package:untitled/services/auth_service.dart';

import '../common/theme_helper.dart';

class signUp extends StatefulWidget {
  const signUp({Key? key}) : super(key: key);
  @override
  State<signUp> createState() => _signUpState();
}

class _signUpState extends State<signUp> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authService = AuthService();
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
                bottomLeft: Radius.circular(50)),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/app1.jpg"),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
                bottomLeft: Radius.circular(50)),
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
                    margin: EdgeInsets.fromLTRB(25, 50, 25, 10),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    alignment: Alignment.center,
                    child: Form(
                      key: _key,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            'Sign up',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: ThemeHelper().textInputDecoration(
                                  'First Name', 'Enter your first name'),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: ThemeHelper().textInputDecoration(
                                  'Last Name', 'Enter your last name'),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: ThemeHelper().textInputDecoration(
                                  "E-mail address", "Enter your email"),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                                  Validator.validateEmail(value ?? ""),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: ThemeHelper().textInputDecoration(
                                  "Mobile Number", "Enter your mobile number"),
                              keyboardType: TextInputType.phone,
                              validator: (val) {
                                if (!(val!.isEmpty) &&
                                    !RegExp(r"^(\d+)*$").hasMatch(val)) {
                                  return "Enter a valid phone number";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Container(
                            decoration:
                                ThemeHelper().inputBoxDecorationShaddow(),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: ThemeHelper().textInputDecoration(
                                  "Password*", "Enter your password"),
                              validator: (value) =>
                                  Validator.validatePassword(value ?? ""),
                            ),
                          ),
                          const SizedBox(height: 15.0),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(80.0),
                                color: Colors.green),
                            child: ElevatedButton(
                              style: ThemeHelper().buttonStyle(),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(40, 10, 40, 10),
                                child: Text(
                                  "Register".toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                if (_key.currentState!.validate()) {
                                  LoaderX.show(context);
                                  final _status =
                                      await _authService.createAccount(
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          displayName:
                                              _firstNameController.text +
                                                  _lastNameController.text,
                                          phone: _phoneController.text);
                                  if (_status == AuthStatus.successful) {
                                    LoaderX.hide();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => signIn()),
                                    );
                                    ;
                                  } else {
                                    LoaderX.hide();
                                    final error = AuthExceptionHandler
                                        .generateErrorMessage(_status);
                                    CustomSnackBar.showErrorSnackBar(
                                      context,
                                      message: error,
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
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
