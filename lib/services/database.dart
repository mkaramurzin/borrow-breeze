import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/loan.dart';

class Database {
  final String uid;
  Database({required this.uid});

  // collection references
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('Users');

  Future<String> addLoan(Loan loan) async {
    final DocumentReference docRef =
        await userCollection.doc(uid).collection('Loans').add({
      'status': loan.status,
      'lender account': loan.lenderAccount,
      'financial platform': loan.financialPlatform,
      'borrower username': loan.borrowerUsername,
      'borrower name': loan.borrowerName,
      'amount': loan.amount,
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
    return docRef.id;
  }

  Future<List<Loan>> getLoans({
    String? status,
    String? borrowerUsername,
    DateTime? originationDate,
    DateTime? repayDate,
  }) async {
    CollectionReference loansCollection = userCollection.doc(uid).collection('Loans');
    Query loansQuery = loansCollection;
    
    if (status != null) {
      loansQuery = loansQuery.where('status', isEqualTo: status);
    }
    
    if (borrowerUsername != null) {
      loansQuery = loansQuery.where('borrower username', isEqualTo: borrowerUsername);
    }

    if (originationDate != null) {
      loansQuery = loansQuery.where('origination date', isEqualTo: originationDate);
    }

    if (repayDate != null) {
      loansQuery = loansQuery.where('repay date', isEqualTo: repayDate);
    }

    QuerySnapshot querySnapshot = await loansQuery.get();

    return querySnapshot.docs.map((doc) {
      return Loan(
          docID: doc.id,
          status: doc.get('status'),
          lenderAccount: doc.get('lender account'),
          financialPlatform: doc.get('financial platform'),
          borrowerUsername: doc.get('borrower username'),
          borrowerName: doc.get('borrower name'),
          amount: doc.get('amount'),
          repayAmount: doc.get('repay amount'),
          amountRepaid: doc.get('amount repaid'),
          originationDate: doc.get('origination date'),
          repayDate: doc.get('repay date'),
          requestLink: doc.get('request link'),
          notes: doc.get('notes'),
          verificationItems: doc.get('verification items'),
          reminders: doc.get('reminders'),
          changeLog: doc.get('changelog')
      );
    }).toList();
  }

}
