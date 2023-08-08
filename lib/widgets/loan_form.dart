import 'package:flutter/material.dart';

class LoanFormDialog extends StatefulWidget {
  @override
  _LoanFormDialogState createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends State<LoanFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? lenderAccount;
  String borrowerUsername = '';
  String? financialPlatform;
  String borrowerName = '';
  int? loanAmount;
  int? repayAmount;
  DateTime originationDate = DateTime.now();
  DateTime repayDate = DateTime.now().add(Duration(days: 21));
  String? loanRequestLink;
  List<Map<String, String>> verificationItems = [];

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
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
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) => borrowerUsername = value,
                        decoration: InputDecoration(
                          labelText: 'Borrower Username',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField(
                        value: financialPlatform,
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              financialPlatform = newValue;
                            });
                          }
                        },
                        items: ['PayPal', 'Venmo', 'Zelle'].map((platform) {
                          return DropdownMenuItem(
                            child: Text(platform),
                            value: platform,
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a financial platform';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) => borrowerName = value,
                        decoration: InputDecoration(
                          labelText: 'Borrower Name',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Loan Amount',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a loan amount';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 1) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          loanAmount = int.parse(value!);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Repay Amount',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a repay amount';
                          }
                          if (int.tryParse(value) == null ||
                              int.parse(value) < 1) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          repayAmount = int.parse(value!);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController()
                          ..text = formatDate(originationDate),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Origination Date',
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: originationDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(Duration(
                                days: 3650)), // 10 years into the future
                          );
                          if (pickedDate != null &&
                              pickedDate != originationDate) {
                            setState(() {
                              originationDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: TextEditingController()
                          ..text = formatDate(repayDate),
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Repay Date',
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: repayDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(Duration(
                                days: 3650)), // 10 years into the future
                          );
                          if (pickedDate != null && pickedDate != repayDate) {
                            setState(() {
                              repayDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onChanged: (value) => loanRequestLink = value,
                  decoration: InputDecoration(
                    labelText: 'Loan Request Link',
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
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
                Container(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        verificationItems.add({'label': '', 'url': ''});
                      });
                    },
                    child: Text("Add Verification Item"),
                  ),
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
