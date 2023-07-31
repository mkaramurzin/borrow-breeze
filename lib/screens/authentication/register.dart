import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/services/auth.dart';

class Register extends StatefulWidget {
  final toggle;
  Register({required this.toggle});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Register',
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
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(10)
                ),
                width: 500,
                height: 300,
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
                            border: new OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: (val) {
                            setState(() {
                              email = val;
                            });
                          },
                          onFieldSubmitted: (val) async {
                            if(_formKey.currentState!.validate()) {
                              dynamic result =
                              await _auth.registerWithEmailAndPassword(email, password);
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
                          validator: (val) => val!.length < 6 ? 'Password must be at least 6 characters' : null,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: new OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          obscureText: true,
                          onChanged: (val) {
                            setState(() {
                              password = val;
                            });
                          },
                          onFieldSubmitted: (val) async {
                            if(_formKey.currentState!.validate()) {
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(email, password);
                              if(result is String) {
                                setState(() {
                                  error = result;
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: RichText(text: TextSpan(
                                text: 'Sign in',
                                style: new TextStyle(color: Colors.blue),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () {
                                    widget.toggle();
                                  }
                              )),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  // backgroundColor: "#FFA611".toColor(),
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2)
                                  )
                              ),
                              child: Text(
                                'Register',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                if(_formKey.currentState!.validate()) {
                                  dynamic result =
                                  await _auth.registerWithEmailAndPassword(email, password);
                                  if(result is String) {
                                    setState(() {
                                      error = result;
                                    });
                                  }
                                }
                              },
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
