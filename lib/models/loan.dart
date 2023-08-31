import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Loan {
  String docID;
  String status;
  String lenderAccount;
  String borrowerUsername;
  String financialPlatform;
  String borrowerName;
  double principal;
  double repayAmount;
  double amountRepaid;
  double interest;
  double roi;
  Timestamp originationDate;
  Timestamp repayDate;
  int duration;
  String requestLink;

  String notes;
  List<Map<String, dynamic>> verificationItems;
  int reminders;
  String changeLog;

  Loan({
    this.docID = '',
    required this.status,
    this.lenderAccount = 'independent',
    required this.financialPlatform,
    required this.borrowerUsername,
    required this.borrowerName,
    required this.principal,
    required this.repayAmount,
    required this.interest,
    required this.roi,
    this.amountRepaid = 0,
    required this.originationDate,
    required this.repayDate,
    required this.duration,
    this.requestLink = '',
    this.notes = '',
    this.verificationItems = const [],
    this.reminders = 0,
    this.changeLog = '',
  });
}
