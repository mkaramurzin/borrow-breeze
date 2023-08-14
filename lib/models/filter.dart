class LoanFilter {
  String? docID;
  String? filterName;
  String? status;
  String? borrowerUsername;
  String? lenderAccount;
  String? borrowerName;
  DateTime? originationDate;
  DateTime? repayDate;

  LoanFilter({
    this.docID,
    this.filterName,
    this.status,
    this.borrowerUsername,
    this.lenderAccount,
    this.borrowerName,
    this.originationDate,
    this.repayDate,
  });
}
