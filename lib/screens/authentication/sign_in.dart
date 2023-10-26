import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/screens/authentication/reset_password.dart';
import 'package:borrowbreeze/services/auth.dart';

class SignIn extends StatefulWidget {
  final toggle;
  SignIn({required this.toggle});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Sign In',
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
                margin: EdgeInsets.only(top: 150),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10)
                ),
                width: 500,
                height: 310,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          validator: (val) => val == '' ? 'Enter an email' : null,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            border: new OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            filled: true,
                          ),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          onFieldSubmitted: (val) async {
                            if(_formKey.currentState!.validate()) {
                              dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                              if(result is String) {
                                setState(() {
                                  error = result;
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          validator: (val) => val!.length < 1 ? 'Enter a password' : null,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            border: new OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            filled: true,
                          ),
                          obscureText: true,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                          onFieldSubmitted: (val) async {
                            if(_formKey.currentState!.validate()) {
                              dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                              if(result is String) {
                                setState(() {
                                  error = result;
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: RichText(text: TextSpan(
                                  text: 'Reset password',
                                  style: new TextStyle(color: Color.fromARGB(255, 255, 232, 22)),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        new MaterialPageRoute(
                                          builder: (BuildContext context) => ResetPassword()
                                        )
                                      );
                                    }
                              )),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: RichText(text: TextSpan(
                                  text: 'Register',
                                  style: new TextStyle(color: Color.fromARGB(255, 255, 232, 22)),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.toggle();
                                    }
                              )),
                            ),
                          ],
                        ),
                        SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(255, 255, 232, 22),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                    )
                                ),
                                child: Text(
                                  'Sign in',
                                  style: TextStyle(color: Colors.brown),
                                ),
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()) {
                                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                                    if(result is String) {
                                      setState(() {
                                        error = result;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          error,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        )
                      ]
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}
