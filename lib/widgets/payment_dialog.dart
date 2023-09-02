import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  const PaymentDialog({super.key});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  double amountRepaid = 0;
  late TextEditingController _controller;

  String error = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter Payment"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10,),
            Text(
              error,
              style: TextStyle(color: Colors.red, fontSize: 14),
            )
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: Text("Submit"),
          onPressed: () {
            double? enteredAmount = double.tryParse(_controller.text);
            if (enteredAmount != null && enteredAmount > 0) {
              amountRepaid = enteredAmount;
              Navigator.of(context).pop(amountRepaid);
            } else {
              error = 'Please enter a valid payment amount';
              setState(() {
                
              });
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
