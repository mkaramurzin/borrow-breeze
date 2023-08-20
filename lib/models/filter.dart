import 'package:cloud_firestore/cloud_firestore.dart';

class LoanFilter {
  String? docID;
  String? filterName;
  List<String>? status;
  String? lenderAccount;
  String? borrowerUsername;
  String? borrowerName;
  Timestamp? originationDate;
  Timestamp? repayDate;

  LoanFilter({
    this.docID,
    this.filterName,
    this.status,
    this.lenderAccount,
    this.borrowerUsername,
    this.borrowerName,
    this.originationDate,
    this.repayDate,
  });
}
