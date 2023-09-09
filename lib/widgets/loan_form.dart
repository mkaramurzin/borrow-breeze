import 'package:borrowbreeze/widgets/payment_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/loan.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/services/loan_logic.dart';
import 'package:borrowbreeze/widgets/metrics_row.dart';

class LoanFormDialog extends StatefulWidget {
  final Loan? loan;
  final Function() onFormSubmit;

  LoanFormDialog({this.loan, required this.onFormSubmit});

  @override
  _LoanFormDialogState createState() => _LoanFormDialogState();
}

class _LoanFormDialogState extends State<LoanFormDialog> {
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List accountNames = [];
  bool showPartialPaymentField = false;
  TextEditingController principalAmountController = TextEditingController();
  bool showCalcFee = false;

  String status = 'ongoing';
  String lenderAccount = 'Independent';
  String borrowerUsername = '';
  String financialPlatform = 'PayPal';
  String borrowerName = '';
  double? principalAmount;
  double? repayAmount;
  double? interest;
  double amountRepaid = 0;
  double? roi;
  DateTime originationDate = DateTime.now();
  DateTime repayDate = DateTime.now().add(Duration(days: 1));
  int duration = 1;
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
      status = widget.loan!.status;
      lenderAccount = widget.loan!.lenderAccount;
      borrowerUsername = widget.loan!.borrowerUsername;
      financialPlatform = widget.loan!.financialPlatform;
      borrowerName = widget.loan!.borrowerName;
      principalAmount = widget.loan!.principal;
      repayAmount = widget.loan!.repayAmount;
      interest = widget.loan!.interest;
      amountRepaid = widget.loan!.amountRepaid;
      roi = widget.loan!.roi;
      originationDate = widget.loan!.originationDate.toDate();
      repayDate = widget.loan!.repayDate.toDate();
      duration = widget.loan!.duration;
      loanRequestLink = widget.loan!.requestLink;
      notes = widget.loan!.notes;
      verificationItems = (widget.loan!.verificationItems as List)
          .map((item) => {
                'label': item['label'] as String,
                'url': item['url'] as String,
              })
          .toList();
    }
    if (widget.loan != null) {
      principalAmountController.text = principalAmount.toString();
    }
  }

  void updateMetrics() {
    if (principalAmount != null && repayAmount != null) {
      interest = repayAmount! - principalAmount!;
      roi = LoanLogic.calculateRoiSingle(principalAmount!, repayAmount!);
    }
    if (originationDate != null && repayDate != null) {
      duration = LoanLogic.calculateDuration(originationDate, repayDate);
    }
    setState(() {});
  }

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  bool containsItem(
      List<Map<String, dynamic>> list, Map<String, dynamic> item) {
    for (var listItem in list) {
      if (listItem['label'] == item['label'] &&
          listItem['url'] == item['url']) {
        return true;
      }
    }
    return false;
  }

  List<Widget> _buildButtonsBasedOnStatus() {
    ElevatedButton paidBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 130, 206, 133)),
      onPressed: () async {
        status = 'paid';
        amountRepaid = widget.loan!.repayAmount;
        Database(uid: _auth.user!.uid).handlePaidLoan(widget.loan!);
        onSubmit();
      },
      child: Text('Paid'),
    );
    ElevatedButton partialBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 255, 214, 125)),
      onPressed: () async {
        double? enteredAmount = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return PaymentDialog();
          },
        );
        if (enteredAmount != null) {
          if (status != 'extended') {
            status = 'partial';
          }
          Database(uid: _auth.user!.uid)
              .handlePartialPayment(widget.loan!, enteredAmount);
          amountRepaid += enteredAmount;
          onSubmit();
        }
      },
      child: Text('Partial Payment'),
    );
    ElevatedButton defaultBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 231, 15, 0)),
      onPressed: () {
        Database(uid: _auth.user!.uid).handleDefaultedLoan(widget.loan!);
        status = 'defaulted';
        onSubmit();
      },
      child: Text('Default'),
    );
    ElevatedButton disputeBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
      onPressed: () {
        Database(uid: _auth.user!.uid).handleDispute(widget.loan!);
        status = 'disputed';
        onSubmit();
      },
      child: Text('Disputed'),
    );
    ElevatedButton refundBtn = ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
      onPressed: () async {
        status = 'refunded';
        await Database(uid: _auth.user!.uid).handleRefundedLoan(widget.loan!);
        amountRepaid += widget.loan!.principal;
        onSubmit();
      },
      child: Text('refunded'),
    );

    switch (widget.loan!.status) {
      case 'ongoing':
      case 'partial':
      case 'extended':
        return [paidBtn, partialBtn, defaultBtn];
      case 'defaulted':
        return [paidBtn, disputeBtn];
      case 'disputed':
        return [refundBtn, defaultBtn];
      case 'paid':
        return [disputeBtn];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double dialogWidth;
    if (screenWidth < 600) {
      // Mobile
      dialogWidth = screenWidth * 0.9;
    } else {
      // Desktop
      dialogWidth = screenWidth * 0.5;
    }
    return AlertDialog(
      title: widget.loan == null
          ? Center(child: Text('Add Loan'))
          : Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Edit Loan'),
                widget.loan!.status == 'ongoing'
                    ? IconButton(
                        onPressed: () async {
                          await Database(uid: _auth.user!.uid)
                              .deleteLoan(widget.loan!);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Delete in progress")),
                          );
                        },
                        icon: Icon(Icons.delete),
                      )
                    : SizedBox()
              ],
            )),
      content: Container(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  widget.loan != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _buildButtonsBasedOnStatus())
                      : MetricsRow(
                          roi: roi, interest: interest, duration: duration),
                  SizedBox(
                    height: 20,
                  ),
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
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
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
                          readOnly: widget.loan != null,
                          controller: principalAmountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Principal Amount',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) < 1) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            principalAmount = double.tryParse(value);
                            updateMetrics();
                            showCalcFee = true;
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
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) < 1) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            repayAmount = double.tryParse(value);
                            updateMetrics();
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  showCalcFee
                      ? Row(
                          children: [
                            Text('Calculate Fee'),
                            IconButton(
                              onPressed: () {
                                principalAmount =
                                    LoanLogic.calculatePaymentProtectionFee(
                                        financialPlatform, principalAmount);
                                principalAmountController.text =
                                    principalAmount.toString();
                                updateMetrics();
                                showCalcFee = false;
                              },
                              icon: Icon(Icons.autorenew),
                            )
                          ],
                        )
                      : SizedBox(),
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
                              originationDate = pickedDate;
                              updateMetrics();
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
                              repayDate = pickedDate;
                              updateMetrics();
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
                  ...verificationItems.asMap().entries.map((entry) {
                    int idx = entry.key;
                    Map<String, String> item = entry.value;
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
                              onChanged: (value) {
                                setState(() {
                                  verificationItems[idx]['label'] = value;
                                });
                              },
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
                              onChanged: (value) {
                                setState(() {
                                  verificationItems[idx]['url'] = value;
                                });
                              },
                            ),
                          ),
                          Visibility(
                            child: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  verificationItems.removeAt(idx);
                                });
                              },
                            ),
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
                        onSubmit();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onSubmit() async {
    if (widget.loan != null) {
      List<String> changes = [];
      changes.add(formatDate(DateTime.now()));
      if (widget.loan!.status != status &&
          widget.loan!.status != 'paid' &&
          widget.loan!.status != 'refunded') {
        changes.add('STATUS    ${widget.loan!.status} -> $status');
        widget.loan!.status = status;
      }
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
      if (widget.loan!.financialPlatform != financialPlatform) {
        changes.add(
            'FINANCIAL PLATFORM    ${widget.loan!.financialPlatform} -> $financialPlatform');
        widget.loan!.financialPlatform = financialPlatform!;
      }
      if (widget.loan!.borrowerName != borrowerName) {
        changes.add(
            'BORROWER NAME    ${widget.loan!.borrowerName} -> $borrowerName');
        widget.loan!.borrowerName = borrowerName;
      }
      if (widget.loan!.repayAmount != repayAmount) {
        changes
            .add('REPAY AMOUNT    ${widget.loan!.repayAmount} -> $repayAmount');
        widget.loan!.repayAmount = repayAmount!;
      }
      if (widget.loan!.amountRepaid != amountRepaid) {
        changes.add(
            'AMOUNT REPAID    ${widget.loan!.amountRepaid} -> $amountRepaid');
        widget.loan!.amountRepaid = amountRepaid;
      }
      if (widget.loan!.originationDate != Timestamp.fromDate(originationDate)) {
        changes.add(
            'ORIGINATION DATE    ${formatDate(widget.loan!.originationDate.toDate())} -> ${formatDate(originationDate)}');
        widget.loan!.originationDate = Timestamp.fromDate(originationDate);
      }
      if (widget.loan!.repayDate != Timestamp.fromDate(repayDate)) {
        if (widget.loan!.status != 'defaulted' &&
            repayDate.isAfter(widget.loan!.repayDate.toDate())) {
          widget.loan!.status = 'extended';
        }
        changes.add(
            'REPAY DATE    ${formatDate(widget.loan!.repayDate.toDate())} -> ${formatDate(repayDate)}');
        widget.loan!.repayDate = Timestamp.fromDate(repayDate);
      }
      if (widget.loan!.requestLink != loanRequestLink) {
        changes.add(
            'LOAN REQUEST LINK    ${widget.loan!.requestLink} -> $loanRequestLink');
        widget.loan!.requestLink = loanRequestLink;
      }
      for (var item in widget.loan!.verificationItems) {
        if (!containsItem(verificationItems, item)) {
          changes.add(
              'VERIFICATION ITEM REMOVED:\nLabel: ${item['label']} URL: ${item['url']}');
        }
      }
      for (var item in verificationItems) {
        if (!containsItem(
            widget.loan!.verificationItems as List<Map<String, dynamic>>,
            item)) {
          changes.add(
              'VERIFICATION ITEM ADDED:\nLabel: ${item['label']} URL: ${item['url']}');
        }
      }
      widget.loan!.verificationItems = verificationItems;

      String changelogEntry = "${changes.join('\n')}\n\n";
      widget.loan!.changeLog += changelogEntry;
      await Database(uid: _auth.user!.uid).updateLoan(widget.loan!);
    } else {
      Loan newLoan = Loan(
          status: 'ongoing',
          lenderAccount: lenderAccount!,
          financialPlatform: financialPlatform!,
          borrowerUsername: borrowerUsername,
          borrowerName: borrowerName,
          principal: principalAmount!,
          repayAmount: repayAmount!,
          interest: interest!,
          roi: roi!,
          originationDate: Timestamp.fromDate(originationDate),
          repayDate: Timestamp.fromDate(repayDate),
          duration: duration!,
          requestLink: loanRequestLink,
          notes: notes,
          verificationItems: verificationItems,
          changeLog:
              '${DateTime.now()}\nLoan Item Created\nLoan Amount: $principalAmount\nRepay Amount: $repayAmount\nRepay Date: ${formatDate(repayDate)}\n\n');
      await Database(uid: _auth.user!.uid).addLoan(newLoan);
    }
    widget.onFormSubmit();
    Navigator.pop(context);
  }
}
