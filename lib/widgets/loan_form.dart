import 'package:flutter/material.dart';

class LoanFormDialog extends StatefulWidget {
  @override
  _LoanFormDialogState createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends State<LoanFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? lenderAccount;
  String borrowerUsername = '';
  String borrowerName = '';
  int loanAmount = 0;
  int repayAmount = 0;
  DateTime originationDate = DateTime.now();
  DateTime repayDate = DateTime.now();
  List<Map<String, String>> verificationItems = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownButtonFormField(
                  value: lenderAccount,
                  onChanged: (newValue) {
                    if (newValue != null) {
                      setState(() {
                        lenderAccount = newValue;
                      });
                    }
                  },
                  items: ['Account 1', 'Account 2', 'Account 3']
                      .map((account) {
                    return DropdownMenuItem(
                      child: Text(account),
                      value: account,
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a lender account';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  onChanged: (value) => borrowerUsername = value,
                  decoration: InputDecoration(
                    labelText: 'Borrower Username',
                  ),
                ),
                // ... Repeat for all other fields ...
                ...verificationItems.map((item) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: item['label'],
                          decoration: InputDecoration(labelText: 'Label'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue: item['url'],
                          decoration: InputDecoration(labelText: 'URL'),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            verificationItems.remove(item);
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      verificationItems.add({'label': '', 'url': ''});
                    });
                  },
                ),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save and submit the form
                      _formKey.currentState!.save();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
