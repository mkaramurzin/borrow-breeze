import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  
  void setup() async {
    await Future.delayed(Duration.zero);
    Navigator.pushNamedAndRemoveUntil(context, '/loanlist', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: const Center(
        child: SpinKitSpinningLines(
          color: Colors.white,
          size: 50.0,
        ),
      ),
    );
  }
}
