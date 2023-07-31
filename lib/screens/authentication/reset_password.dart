import 'package:flutter/material.dart';
import 'package:borrowbreeze/services/auth.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Reset Password',
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
              height: 310,
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          validator: (val) => val!.length < 1 ? 'Enter an email' : null,
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
                              dynamic result = await _auth.sendPasswordResetEmail(email: email);
                              if(result is String) {
                                setState(() {
                                  error = result;
                                });
                              } else if(result == null) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Success'),
                                        content: Text('Check your email'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                );
                              }
                            }
                          },
                        ),
                        SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    // backgroundColor: "#FFA611".toColor(),
                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)
                                    )
                                ),
                                child: Text(
                                  'Reset Password',
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()) {
                                    dynamic result = await _auth.sendPasswordResetEmail(email: email);
                                    if(result is String) {
                                      setState(() {
                                        error = result;
                                      });
                                    } else if(result == null) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Success'),
                                            content: Text('Check your email'),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                child: Text('Ok'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        }
                                      );
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
