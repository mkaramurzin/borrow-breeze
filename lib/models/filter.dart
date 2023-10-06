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
  SortOption? sortOption;

  LoanFilter({
    this.docID,
    this.filterName,
    this.status,
    this.lenderAccount,
    this.borrowerUsername,
    this.borrowerName,
    this.originationDate,
    this.repayDate,
    this.sortOption,
  });
}

class SortOption {
  final String field;
  final bool ascending;

  const SortOption({required this.field, required this.ascending});
}