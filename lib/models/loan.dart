import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Loan {
  String docID;
  String status;
  String lenderAccount;
  String borrowerUsername;
  String financialPlatform;
  String borrowerName;
  int amount;
  int repayAmount;
  int amountRepaid;
  Timestamp originationDate;
  Timestamp repayDate;
  String requestLink;

  String notes;
  List<String> verificationItems;
  int reminders;
  List<String> changeLog;

  Loan({
    this.docID = '',
    required this.status,
    this.lenderAccount = 'independent',
    required this.financialPlatform,
    required this.borrowerUsername,
    required this.borrowerName,
    required this.amount,
    required this.repayAmount,
    this.amountRepaid = 0,
    required this.originationDate,
    required this.repayDate,
    this.requestLink = '',
    this.notes = '',
    this.verificationItems = const [],
    this.reminders = 0,
    this.changeLog = const [],
  });
}
