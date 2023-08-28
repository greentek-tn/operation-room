import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:untitled/common/auth_exception_handler.dart';
import 'package:untitled/common/auth_status.dart';
import 'package:untitled/common/customer_snackbar.dart';
import 'package:untitled/common/loader.dart';
import 'package:untitled/common/validator.dart';
import 'package:untitled/screens/signIn.dart';
import 'package:untitled/services/auth_service.dart';

import '../common/theme_helper.dart';

class forgatpassword extends StatefulWidget {
  const forgatpassword({Key? key}) : super(key: key);
  @override
  State<forgatpassword> createState() => _forgatpasswordState();
}

class _forgatpasswordState extends State<forgatpassword> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(preferredSize: Size.fromHeight(150),
          child: AppBar(
            flexibleSpace: ClipRRect(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/app1.jpg"),
                      fit: BoxFit.fill
                  ),),
              ),
            ),
            backgroundColor: Colors.orangeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50)),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              children: [
                SizedBox(height: 30.0),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 50, 25, 10),
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                        // textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Enter the email address associated with your account.',
                        style: TextStyle(
                            // fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                        // textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40.0),
                Form(
                  key: _key,
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: ThemeHelper().inputBoxDecorationShaddow(),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: ThemeHelper()
                              .textInputDecoration("Email", "Enter your email"),
                          validator: (value) =>
                              Validator.validateEmail(value ?? ""),
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(80.0),
                            color: Colors.green),
                        child: ElevatedButton(
                          style: ThemeHelper().buttonStyle(),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(40, 10, 40, 10),
                            child: Text(
                              "Send".toUpperCase(),
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
                              final _status = await _authService.resetPassword(
                                  email: _emailController.text.trim());
                              if (_status == AuthStatus.successful) {
                                LoaderX.hide();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => signIn()),
                                );
                              } else {
                                LoaderX.hide();
                                final error =
                                    AuthExceptionHandler.generateErrorMessage(
                                        _status);
                                CustomSnackBar.showErrorSnackBar(context,
                                    message: error);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: "Remember your password? "),
                            TextSpan(
                              text: 'Login',
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => signIn()),
                                  );
                                },
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
