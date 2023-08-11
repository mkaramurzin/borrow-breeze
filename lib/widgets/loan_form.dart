import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/auth.dart';

class LoanFormDialog extends StatefulWidget {
  final Loan? loan;

  LoanFormDialog({this.loan});

  @override
  _LoanFormDialogState createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends State<LoanFormDialog> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List accountNames = [];

  String? lenderAccount;
  String borrowerUsername = '';
  String? financialPlatform;
  String borrowerName = '';
  double? loanAmount;
  double? repayAmount;
  DateTime originationDate = DateTime.now();
  DateTime repayDate = DateTime.now().add(Duration(days: 21));
  String loanRequestLink = '';
  String notes = '';
  List<Map<String, String>> verificationItems = [];

  @override
  void initState() {
    super.initState();
    Database(uid: _auth.user!.uid).fetchAccountNames().then((names) {
      setState(() {
        accountNames = names;
      });
    });
    if (widget.loan != null) {
      lenderAccount = widget.loan!.lenderAccount;
      borrowerUsername = widget.loan!.borrowerUsername;
      financialPlatform = widget.loan!.financialPlatform;
      borrowerName = widget.loan!.borrowerName;
      loanAmount = widget.loan!.amount;
      repayAmount = widget.loan!.repayAmount;
      originationDate = widget.loan!.originationDate.toDate();
      repayDate = widget.loan!.repayDate.toDate();
      loanRequestLink = widget.loan!.requestLink;
      notes = widget.loan!.notes;
      verificationItems = (widget.loan!.verificationItems as List)
          .map((item) => {
                'label': item['label'] as String,
                'url': item['url'] as String,
              })
          .toList();
    }
  }

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
                              lenderAccount = newValue as String;
                            });
                          }
                        },
                        items: accountNames.map((account) {
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
                        decoration: InputDecoration(
                          labelText: 'Lender Account',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: borrowerUsername,
                        onChanged: (value) => borrowerUsername = value,
                        decoration: InputDecoration(
                          labelText: 'Borrower Username',
                          border: OutlineInputBorder(),
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
                        decoration: InputDecoration(
                          labelText: 'Financial Platform',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: borrowerName,
                        onChanged: (value) => borrowerName = value,
                        decoration: InputDecoration(
                          labelText: 'Borrower Name',
                          border: OutlineInputBorder(),
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
                        initialValue:
                            widget.loan != null ? loanAmount.toString() : '',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Loan Amount',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a loan amount';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 1) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          loanAmount = double.parse(value);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue:
                            widget.loan != null ? repayAmount.toString() : '',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Repay Amount',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a repay amount';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) < 1) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          repayAmount = double.parse(value);
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
                          border: OutlineInputBorder(),
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
                          border: OutlineInputBorder(),
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
                  initialValue: loanRequestLink,
                  onChanged: (value) => loanRequestLink = value,
                  decoration: InputDecoration(
                    labelText: 'Loan Request Link',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  initialValue: notes,
                  onChanged: (value) {
                    notes = value;
                  },
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ...verificationItems.map((item) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item['label'],
                            decoration: InputDecoration(
                              labelText: 'Label',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: item['url'],
                            decoration: InputDecoration(
                              labelText: 'URL',
                              border: OutlineInputBorder(),
                            ),
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
                    ),
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
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (widget.loan != null) {
                        List<String> changes = [];
                        changes.add(formatDate(DateTime.now()));
                        if (widget.loan!.lenderAccount != lenderAccount) {
                          changes.add(
                              'LENDER ACCOUNT    ${widget.loan!.lenderAccount} -> $lenderAccount');
                          widget.loan!.lenderAccount = lenderAccount!;
                        }
                        if (widget.loan!.borrowerUsername != borrowerUsername) {
                          changes.add(
                              'BORROWER USERNAME    ${widget.loan!.borrowerUsername} -> $borrowerUsername');
                          widget.loan!.borrowerUsername = borrowerUsername;
                        }
                        if (widget.loan!.financialPlatform !=
                            financialPlatform) {
                          changes.add(
                              'FINANCIAL PLATFORM    ${widget.loan!.financialPlatform} -> $financialPlatform');
                          widget.loan!.financialPlatform = financialPlatform!;
                        }
                        if (widget.loan!.borrowerName != borrowerName) {
                          changes.add(
                              'BORROWER NAME    ${widget.loan!.borrowerName} -> $borrowerName');
                          widget.loan!.borrowerName = borrowerName;
                        }
                        if (widget.loan!.amount != loanAmount) {
                          changes.add(
                              'LOAN AMOUNT    ${widget.loan!.amount} - > $loanAmount');
                          widget.loan!.amount = loanAmount!;
                        }
                        if (widget.loan!.repayAmount != repayAmount) {
                          changes.add(
                              'REPAY AMOUNT    ${widget.loan!.repayAmount} -> $repayAmount');
                          widget.loan!.repayAmount = repayAmount!;
                        }
                        if (widget.loan!.originationDate !=
                            Timestamp.fromDate(originationDate)) {
                          changes.add(
                              'ORIGINATION DATE    ${formatDate(widget.loan!.originationDate.toDate())} -> ${formatDate(originationDate)}');
                          widget.loan!.originationDate =
                              Timestamp.fromDate(originationDate);
                        }
                        if (widget.loan!.repayDate !=
                            Timestamp.fromDate(repayDate)) {
                          changes.add(
                              'REPAY DATE    ${formatDate(widget.loan!.repayDate.toDate())} -> ${formatDate(repayDate)}');
                          widget.loan!.repayDate =
                              Timestamp.fromDate(repayDate);
                        }
                        if (widget.loan!.requestLink != loanRequestLink) {
                          changes.add(
                              'LOAN REQUEST LINK    ${widget.loan!.requestLink} -> $loanRequestLink');
                          widget.loan!.requestLink = loanRequestLink;
                        }
                        if (widget.loan!.verificationItems.length >
                            verificationItems.length) {
                          changes.add('VERIFICATION ITEMS    titem removed');
                          widget.loan!.verificationItems = verificationItems;
                        }
                        if (widget.loan!.verificationItems.length <
                            verificationItems.length) {
                          changes.add('VERIFICATION ITEMS    item added');
                          widget.loan!.verificationItems = verificationItems;
                        }

                        String changelogEntry = "${changes.join('\n')}\n\n";
                        widget.loan!.changeLog += changelogEntry;
                        await Database(uid: _auth.user!.uid)
                            .updateLoan(widget.loan!);
                      } else {
                        await Database(uid: _auth.user!.uid).addLoan(Loan(
                            status: 'ongoing',
                            lenderAccount: lenderAccount!,
                            financialPlatform: financialPlatform!,
                            borrowerUsername: borrowerUsername,
                            borrowerName: borrowerName,
                            amount: loanAmount!,
                            repayAmount: repayAmount!,
                            originationDate:
                                Timestamp.fromDate(originationDate),
                            repayDate: Timestamp.fromDate(repayDate),
                            requestLink: loanRequestLink,
                            notes: notes,
                            verificationItems: verificationItems,
                            changeLog:
                                '${formatDate(DateTime.now())}\nLoan Item Created\nLoan Amount: $loanAmount\nRepay Amount: $repayAmount\nRepay Date: $repayDate\n\n'));
                      }
                      Navigator.pop(context);
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
