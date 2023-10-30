import 'package:flutter/material.dart';

class PaymentDialog extends StatefulWidget {
  final double remainingDebt;
  const PaymentDialog({super.key, required this.remainingDebt});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  double amountRepaid = 0;
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
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
            Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: _controller,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter Amount',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  double? enteredAmount = double.tryParse(value ?? '');
                  if (enteredAmount != null && enteredAmount >= widget.remainingDebt) {
                    return "Payment exceeds borrower's debt";
                  }
                  return null;
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
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
            if (_formKey.currentState?.validate() ?? false) {
              double? enteredAmount = double.tryParse(_controller.text);
              if (enteredAmount != null && enteredAmount > 0) {
                amountRepaid = enteredAmount;
                Navigator.of(context).pop(amountRepaid);
              }
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
