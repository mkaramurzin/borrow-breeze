import 'package:borrowbreeze/models/filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:borrowbreeze/models/loan.dart';

class Database {
  final String uid;
  Database({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<void> setUserData() async {
    await userCollection
        .doc(uid)
        .collection('Accounts')
        .add({'name': 'Independent'});
  }

  Future<String> addLoan(Loan loan) async {
    final DocumentReference docRef =
        await userCollection.doc(uid).collection('Loans').add({
      'status': loan.status,
      'lender account': loan.lenderAccount,
      'financial platform': loan.financialPlatform,
      'borrower username': loan.borrowerUsername,
      'borrower name': loan.borrowerName,
      'amount': loan.principal,
      'repay amount': loan.repayAmount,
      'interest': loan.interest,
      'roi': loan.roi,
      'amount repaid': loan.amountRepaid,
      'origination date': loan.originationDate,
      'repay date': loan.repayDate,
      'duration': loan.duration,
      'request link': loan.requestLink,
      'notes': loan.notes,
      'verification items': loan.verificationItems,
      'reminders': loan.reminders,
      'changelog': loan.changeLog
    });
    _updateTotalMoneyLent(loan.principal);
    return docRef.id;
  }

  Future<List<Loan>> getLoans({LoanFilter? filter}) async {
    CollectionReference loansCollection =
        userCollection.doc(uid).collection('Loans');
    Query loansQuery = loansCollection;

    if (filter != null) {
      if (filter?.status != null && filter.status!.isNotEmpty) {
        loansQuery = loansQuery.where('status', whereIn: filter!.status);
      }

      if (filter?.borrowerUsername != null) {
        loansQuery = loansQuery.where('borrower username',
            isEqualTo: filter.borrowerUsername);
      }

      if (filter?.lenderAccount != null) {
        loansQuery =
            loansQuery.where('lender account', isEqualTo: filter.lenderAccount);
      }

      if (filter?.borrowerName != null) {
        loansQuery =
            loansQuery.where('borrower name', isEqualTo: filter.borrowerName);
      }

      if (filter?.originationDate != null) {
        DateTime date = filter.originationDate!.toDate();
        Timestamp startOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 23, 59, 59));
        loansQuery = loansQuery
            .where('origination date', isGreaterThanOrEqualTo: startOfDay)
            .where('origination date', isLessThanOrEqualTo: endOfDay);
      }

      if (filter?.repayDate != null) {
        DateTime date = filter.repayDate!.toDate();
        Timestamp startOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 0, 0, 0));
        Timestamp endOfDay = Timestamp.fromDate(
            DateTime(date.year, date.month, date.day, 23, 59, 59));
        loansQuery = loansQuery
            .where('repay date', isGreaterThanOrEqualTo: startOfDay)
            .where('repay date', isLessThanOrEqualTo: endOfDay);
      }
    }

    QuerySnapshot querySnapshot = await loansQuery.get();

    return querySnapshot.docs.map((doc) {
      return Loan(
          docID: doc.id,
          status: doc['status'] as String,
          lenderAccount: doc['lender account'] as String,
          financialPlatform: doc['financial platform'] as String,
          borrowerUsername: doc['borrower username'] as String,
          borrowerName: doc['borrower name'] as String,
          principal: doc['amount'] as double,
          repayAmount: doc['repay amount'] as double,
          interest: doc['interest'] as double,
          amountRepaid: doc['amount repaid'] as double,
          roi: doc['roi'] as double,
          originationDate: doc['origination date'] as Timestamp,
          repayDate: doc['repay date'] as Timestamp,
          duration: doc['duration'] as int,
          requestLink: doc['request link'] as String,
          notes: doc['notes'] as String,
          verificationItems: (doc['verification items'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
          reminders: doc['reminders'] as int,
          changeLog: doc['changelog'] as String);
    }).toList();
  }

  Future<void> updateLoan(Loan loan) async {
    await userCollection.doc(uid).collection('Loans').doc(loan.docID).update({
      'status': loan.status,
      'lender account': loan.lenderAccount,
      'financial platform': loan.financialPlatform,
      'borrower username': loan.borrowerUsername,
      'borrower name': loan.borrowerName,
      'amount': loan.principal,
      'repay amount': loan.repayAmount,
      'amount repaid': loan.amountRepaid,
      'origination date': loan.originationDate,
      'repay date': loan.repayDate,
      'request link': loan.requestLink,
      'notes': loan.notes,
      'verification items': loan.verificationItems,
      'reminders': loan.reminders,
      'changelog': loan.changeLog
    });
  }

  Future<List<String>> fetchAccountNames() async {
    // QuerySnapshot accountSnapshot =
    //     await FirebaseFirestore.instance.collection('Accounts').get();
    QuerySnapshot accountSnapshot =
        await userCollection.doc(uid).collection('Accounts').get();

    return accountSnapshot.docs
        .map((accountDoc) => accountDoc['name'] as String)
        .toList();
  }

  Future<List<String>> fetchBorrowerNames() async {
    CollectionReference loansCollection =
        userCollection.doc(uid).collection('Loans');
    QuerySnapshot querySnapshot = await loansCollection.get();

    Set<String> uniqueNames = {};

    for (var doc in querySnapshot.docs) {
      if (doc['borrower name'] != null) {
        uniqueNames.add(doc['borrower name'] as String);
      }
    }

    return uniqueNames.toList();
  }

  Future<List<String>> fetchBorrowerUsernames() async {
    CollectionReference loansCollection =
        userCollection.doc(uid).collection('Loans');
    QuerySnapshot querySnapshot = await loansCollection.get();

    Set<String> uniqueUsernames = {};

    for (var doc in querySnapshot.docs) {
      if (doc['borrower username'] != null) {
        uniqueUsernames.add(doc['borrower username'] as String);
      }
    }

    return uniqueUsernames.toList();
  }

  Future<void> saveFilter(LoanFilter filter, String filterName) async {
    await userCollection.doc(uid).collection('Filters').add({
      'filter name': filterName,
      'status': filter.status,
      'borrowerUsername': filter.borrowerUsername,
      'lenderAccount': filter.lenderAccount,
      'borrowerName': filter.borrowerName,
      'originationDates': filter.originationDate,
      'repayDates': filter.repayDate
    });
  }

  Future<List<LoanFilter>> getFilters() async {
    CollectionReference filtersCollection =
        userCollection.doc(uid).collection('Filters');
    QuerySnapshot querySnapshot = await filtersCollection.get();

    return querySnapshot.docs.map((doc) {
      return LoanFilter(
        docID: doc.id,
        filterName: doc['filter name'] as String,
        status: doc['status'] as List<String>,
        lenderAccount: doc['lender account'] as String?,
        borrowerUsername: doc['borrower username'] as String?,
        borrowerName: doc['borrower name'] as String?,
        originationDate: doc['origination date'] as Timestamp?,
        repayDate: doc['repay date'] as Timestamp?,
      );
    }).toList();
  }

  // Business logic related section below

  Future<void> handlePaidLoan(Loan loan) async {
    _updateTotalMoneyRepaid(loan.repayAmount - loan.amountRepaid);

    // undo defaulted loan changes
    if (loan.status == 'defaulted') {
      print(loan.amountRepaid);
      _updateTotalProfit(loan.principal);
      _updateTotalDefaulted(-loan.principal);
      _updateTotalInterest(-loan.amountRepaid);
      _updateTotalProfit(-loan.amountRepaid);
    }

    if (loan.amountRepaid > loan.principal) {
      _updateTotalInterest(
          loan.interest - (loan.amountRepaid - loan.principal));
      _updateTotalProfit(loan.interest - (loan.amountRepaid - loan.principal));
    } else {
      _updateTotalInterest(loan.interest);
      _updateTotalProfit(loan.interest);
    }
  }

  Future<void> handlePartialPayment(Loan loan, double amount) async {
    _updateTotalMoneyRepaid(amount);

    if (loan.amountRepaid >= loan.principal) {
      _updateTotalInterest(amount);
      _updateTotalProfit(amount);
    } else if (amount + loan.amountRepaid > loan.principal) {
      _updateTotalInterest((amount + loan.amountRepaid) - loan.principal);
      _updateTotalProfit((amount + loan.amountRepaid) - loan.principal);
    }
  }

  Future<void> handleDefaultedLoan(Loan loan) async {
    _updateTotalProfit(-loan.principal);
    _updateTotalDefaulted(loan.principal);
    _updateTotalInterest(loan.amountRepaid);
    _updateTotalProfit(loan.amountRepaid);
  }

  Future<void> _updateTotalMoneyLent(double amount) async {
    DocumentSnapshot userDoc = await userCollection.doc(uid).get();

    if (userDoc.exists) {
      // If the document exists, increment (or create) the value
      await userCollection
          .doc(uid)
          .update({'total money lent': FieldValue.increment(amount)});
    } else {
      // If the document doesn't exist, set the value
      await userCollection
          .doc(uid)
          .set({'total money lent': amount}, SetOptions(merge: true));
    }
  }

  Future<void> _updateTotalMoneyRepaid(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total money repaid': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalInterest(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total interest': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalProfit(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total profit': FieldValue.increment(amount)});
  }

  Future<void> _updateTotalDefaulted(double amount) async {
    await userCollection
        .doc(uid)
        .update({'total defaulted money': FieldValue.increment(amount)});
  }
}
