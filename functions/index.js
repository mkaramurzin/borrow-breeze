const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.updateLoanStatus = functions.runWith({ timeoutSeconds: 540 })
  .pubsub.schedule('0 0 * * *').timeZone('America/Los_Angeles').onRun(async (context) => {
  const firestore = admin.firestore();
  const now = new Date();
  const usersSnapshot = await firestore.collection('Users').get();
  const updates = [];

  await Promise.all(usersSnapshot.docs.map(async userDoc => {
    const loansSnapshot = await userDoc.ref.collection('Loans').get();
    loansSnapshot.forEach(loanDoc => {
      const loan = loanDoc.data();
      const repayDate = loan['repay date'].toDate();
      if (loan.status === 'ongoing' && now > repayDate) {
        updates.push(
          loanDoc.ref.update({
            status: 'overdue'
          })
        );
      }
    });
  }));

  await Promise.all(updates);
  console.log('Loan status updated');
  return null;
});
