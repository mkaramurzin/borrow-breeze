import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/filter.dart';

class FilterDialog extends StatefulWidget {
  final LoanFilter currentFilter;

  FilterDialog({required this.currentFilter});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late LoanFilter filter;
  List accountNames = [];
  final AuthService _auth = AuthService();
  bool saveFilterChecked = false;
  TextEditingController filterNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filter = widget.currentFilter;
    Database(uid: _auth.user!.uid).fetchAccountNames().then((names) {
      setState(() {
        accountNames = names;
      });
    });
  }

  @override
  void dispose() {
    filterNameController.dispose();
    super.dispose();
  }

  String? formatDate(DateTime? date) {
    if (date != null) {
      return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}";
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime?) onDateSelected) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      onDateSelected(selectedDate);
    }
  }

  void clearDate(String dateField) {
    setState(() {
      if (dateField == 'origination') {
        filter.originationDate = null;
      } else if (dateField == 'repay') {
        filter.repayDate = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Apply Filter'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              hint: Text('Status'),
              value: filter.status,
              items: [
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'ongoing', child: Text('Ongoing')),
                DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                DropdownMenuItem(value: 'defaulted', child: Text('Defaulted')),
                DropdownMenuItem(value: 'disputed', child: Text('Disputed')),
                DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
              ],
              onChanged: (value) {
                setState(() {
                  filter.status = value as String?;
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            DropdownButtonFormField(
              hint: Text('Lender Account'),
              value: filter.lenderAccount,
              items: accountNames.map((account) {
                return DropdownMenuItem(
                  child: Text(account),
                  value: account,
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  filter.lenderAccount = value as String?;
                });
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: filter.borrowerUsername,
              onChanged: (value) => filter.borrowerUsername = value,
              decoration: InputDecoration(
                labelText: 'Borrower Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              initialValue: filter.borrowerName,
              onChanged: (value) => filter.borrowerName = value,
              decoration: InputDecoration(
                labelText: 'Borrower Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                        'Origination Date: ${formatDate(filter.originationDate) ?? 'Not set'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => clearDate('origination'),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                    onTap: () {
                      _selectDate(context, filter.originationDate,
                          (selectedDate) {
                        setState(() {
                          filter.originationDate = selectedDate;
                        });
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                        'Repay Date: ${formatDate(filter.repayDate) ?? 'Not set'}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () => clearDate('repay'),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                    onTap: () {
                      _selectDate(context, filter.repayDate, (selectedDate) {
                        setState(() {
                          filter.repayDate = selectedDate;
                        });
                      });
                    },
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title: Text("Save Filter?"),
              value: saveFilterChecked,
              onChanged: (newValue) {
                setState(() {
                  saveFilterChecked = newValue!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (saveFilterChecked)
              TextFormField(
                controller: filterNameController,
                decoration: InputDecoration(
                  labelText: 'Filter Name',
                  hintText: 'Enter a name for this filter',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (saveFilterChecked &&
                filterNameController.text.trim().isNotEmpty) {
              await Database(uid: _auth.user!.uid)
                  .saveFilter(filter, filterNameController.text.trim());
              Navigator.of(context).pop(filter);
            } else if (!saveFilterChecked) {
              Navigator.of(context).pop(filter);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter a name for the filter so you can use it later')),
              );
            }
          },
          child: Text('Apply'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
