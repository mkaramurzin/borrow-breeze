import 'package:borrowbreeze/services/auth.dart';
import 'package:borrowbreeze/services/database.dart';
import 'package:flutter/material.dart';
import 'package:borrowbreeze/models/filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FilterDialog extends StatefulWidget {
  final LoanFilter currentFilter;

  FilterDialog({required this.currentFilter});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  List<FilterRow> filterRows = [FilterRow()];
  List<String> usedFilters = [];
  List<String> accountNames = [];
  List<String> borrowerNames = [];
  List<String> borrowerUsernames = [];
  String sortField = 'repay date';
  bool sortAscending = true;
  final AuthService _auth = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Database(uid: _auth.user!.uid).fetchAccountNames().then((names) {
      setState(() {
        accountNames = names.toSet().toList();
      });
    });
    Database(uid: _auth.user!.uid).fetchBorrowerNames().then((names) {
      setState(() {
        borrowerNames = names;
      });
    });
    Database(uid: _auth.user!.uid).fetchBorrowerUsernames().then((names) {
      setState(() {
        borrowerUsernames = names;
      });
    });
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

  _showCustomDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Create and Apply Filter'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: [
                      // filterRows.every((row) => row.type == 'status' || row.type == 'repayDate')
                      filterRows.every((row) => row.type == 'status')
                          ? Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: sortField,
                                    items: [
                                      'repay date',
                                    ].map((field) {
                                      return DropdownMenuItem(
                                        child: Text(field),
                                        value: field,
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          sortField = value;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Sort by',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: sortAscending == true
                                        ? 'Ascending'
                                        : 'Descending',
                                    items: [
                                      'Ascending',
                                      'Descending',
                                    ].map((field) {
                                      return DropdownMenuItem(
                                        child: Text(field),
                                        value: field,
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          value == 'Ascending'
                                              ? sortAscending = true
                                              : sortAscending = false;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 40,
                                ),
                              ],
                            )
                          : Center(
                              child: Text(
                                'Sorting only supported for Filter by Status',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 25,
                      ),
                      ...filterRows.map((filterRow) {
                        return Container(
                          margin: EdgeInsets.only(top: 10),
                          child: FilterRowWidget(
                            key: ValueKey(filterRow),
                            filterRow: filterRow,
                            usedFilters: usedFilters,
                            onTypeUsed: (type) {
                              setState(() {
                                if (!usedFilters.contains(type)) {
                                  usedFilters.add(type);
                                }
                              });
                            },
                            onDelete: () {
                              setState(() {
                                if (filterRow.type != 'status') {
                                  usedFilters.remove(filterRow.type);
                                }
                                filterRows.remove(filterRow);
                              });
                            },
                            onUpdate: (updatedRow) {
                              setState(() {
                                int index = filterRows.indexOf(filterRow);
                                if (index != -1) {
                                  filterRows[index] = updatedRow;
                                }
                              });
                            },
                            selectDate: _selectDate,
                            accountNames: accountNames,
                            borrowerNames: borrowerNames,
                            borrowerUsernames: borrowerUsernames,
                            availableTypes: getAvailableTypes(filterRows),
                          ),
                        );
                      }).toList(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                FilterRow newRow = FilterRow();
                                if (usedFilters.contains(newRow.type) &&
                                    newRow.type != 'status') {
                                  return;
                                }
                                filterRows.add(newRow);
                                if (newRow.type != 'status') {
                                  usedFilters.add(newRow.type);
                                }
                              });
                            },
                          ),
                          ElevatedButton(
                            child: Text("Apply"),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                LoanFilter result = LoanFilter();
                                bool applySort =
                                    true; // only allow sort on top of filter if sorting by just loan status
                                filterRows.forEach((row) {
                                  switch (row.type) {
                                    case 'status':
                                      result.status ??= [];
                                      result.status!.add(row.value);
                                      break;
                                    case 'lenderAccount':
                                      result.lenderAccount = row.value;
                                      applySort = false;
                                      break;
                                    case 'borrowerUsername':
                                      result.borrowerUsername = row.value;
                                      applySort = false;
                                      break;
                                    case 'borrowerName':
                                      result.borrowerName = row.value;
                                      applySort = false;
                                      break;
                                    case 'originationDate':
                                      result.originationDate =
                                          Timestamp.fromDate(row.value);
                                      applySort = false;
                                      break;
                                    case 'repayDate':
                                      result.repayDate =
                                          Timestamp.fromDate(row.value);
                                      applySort = false;
                                      break;
                                  }
                                });
                                if (applySort) {
                                  result.sortOption = SortOption(
                                      field: sortField,
                                      ascending: sortAscending);
                                }
                                Navigator.pop(context, result);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          child: Text(
            'Custom',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _showCustomDialog(context);
          },
        ),
      ],
      title: Text('Create and Apply Filter'),
      content: SingleChildScrollView(
          child: Center(
        child: DropdownButtonFormField(
          items: [
            'ongoing due today',
            'ongoing due today + overdue',
            'ongoing due this week',
            'ongoing due this week + overdue'
          ].map((preset) {
            return DropdownMenuItem(
              child: Text(preset),
              value: preset,
            );
          }).toList(),
          onChanged: (value) {
            LoanFilter result = LoanFilter();
            result.specialInstructions = value;
            result.sortOption =
                SortOption(field: 'repay date', ascending: true);
            Navigator.pop(context, result);
          },
          decoration: InputDecoration(
            labelText: 'Preset Filters',
            border: OutlineInputBorder(),
          ),
        ),
      )),
    );
  }

  List<String> getAvailableTypes(List<FilterRow> currentRows) {
    List<String> allTypes = [
      'status',
      'lenderAccount',
      'borrowerUsername',
      'borrowerName',
      'originationDate',
      'repayDate',
    ];

    for (var row in currentRows) {
      if (row.type != 'status') {
        allTypes.remove(row.type);
      }
    }

    return allTypes;
  }
}

class FilterRow {
  String type;
  dynamic value;
  String? selectedValue;

  FilterRow({this.type = 'status', this.value, this.selectedValue});
}

class FilterRowWidget extends StatefulWidget {
  final List<String> usedFilters;
  final Function(String) onTypeUsed;
  final List<String> accountNames;
  final List<String> borrowerNames;
  final List<String> borrowerUsernames;
  final FilterRow filterRow;
  final VoidCallback onDelete;
  final Function(FilterRow) onUpdate;
  final Function(BuildContext, DateTime?, Function(DateTime?)) selectDate;
  final List<String> availableTypes;

  FilterRowWidget({
    required Key key,
    required this.usedFilters,
    required this.onTypeUsed,
    required this.filterRow,
    required this.onDelete,
    required this.onUpdate,
    required this.selectDate,
    required this.accountNames,
    required this.borrowerNames,
    required this.borrowerUsernames,
    required this.availableTypes,
  }) : super(key: key);

  @override
  State<FilterRowWidget> createState() => _FilterRowWidgetState();
}

class _FilterRowWidgetState extends State<FilterRowWidget> {
  final AuthService _auth = AuthService();
  String? selectedUsername;
  String? selectedBorrowerName;

  @override
  void initState() {
    super.initState();
    selectedUsername = widget.filterRow.selectedValue;
    selectedBorrowerName = widget.filterRow.selectedValue;
  }

  Future<List<String>> fetchSuggestions(String type) async {
    if (type == 'borrowerUsername') {
      return await Database(uid: _auth.user!.uid).fetchBorrowerUsernames();
    } else if (type == 'borrowerName') {
      return await Database(uid: _auth.user!.uid).fetchBorrowerNames();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: widget.filterRow.type,
            onChanged: (newValue) {
              if (newValue != null) {
                widget.onTypeUsed(newValue);
                setState(() {
                  widget.filterRow.type = newValue;
                });
              }
            },
            onSaved: (newValue) {
              if (newValue != null) {
                setState(() {
                  if (widget.filterRow.type != 'status') {
                    widget.usedFilters.remove(widget.filterRow.type);
                  }
                  if (newValue != 'status' &&
                      !widget.usedFilters.contains(newValue)) {
                    widget.usedFilters.add(newValue);
                  }
                });
                widget.onUpdate(FilterRow(
                    type: newValue, value: defaultValueForType(newValue)));
                widget.onTypeUsed(newValue);
              }
            },
            items: [
              if (!widget.availableTypes.contains(widget.filterRow.type))
                DropdownMenuItem(
                    child: Text(typeLabel(widget.filterRow.type)),
                    value: widget.filterRow.type),
              ...widget.availableTypes
                  .where((type) =>
                      !widget.usedFilters.contains(type) || type == 'status')
                  .map((type) => DropdownMenuItem(
                      child: Text(typeLabel(type)), value: type))
            ].toList(),
            decoration: InputDecoration(
              labelText: 'Filter by',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        _filterWidget(context),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: widget.onDelete,
        ),
      ],
    );
  }

  String typeLabel(String type) {
    Map<String, String> labels = {
      'status': 'Status',
      'lenderAccount': 'Lender Account',
      'borrowerUsername': 'Borrower Username',
      'borrowerName': 'Borrower Name',
      'originationDate': 'Origination Date',
      'repayDate': 'Repay Date',
    };
    return labels[type] ?? '';
  }

  Widget _filterWidget(BuildContext context) {
    switch (widget.filterRow.type) {
      case 'status':
        return Expanded(
          child: DropdownButtonFormField<dynamic>(
            value: widget.filterRow.value,
            onChanged: (newValue) {
              if (newValue != null) {
                widget.onUpdate(
                    FilterRow(type: widget.filterRow.type, value: newValue));
              }
            },
            items: [
              'ongoing',
              'overdue',
              'paid',
              'defaulted',
              'partial',
              'disputed',
              'refunded'
            ].map((e) => DropdownMenuItem(child: Text(e), value: e)).toList(),
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please select a status';
              }
              return null;
            },
          ),
        );

      case 'lenderAccount':
        return Expanded(
          child: DropdownButtonFormField<String>(
            value: widget.accountNames.contains(widget.filterRow.value)
                ? widget.filterRow.value as String
                : null,
            onChanged: (newValue) {
              if (newValue != null) {
                widget.onUpdate(
                    FilterRow(type: widget.filterRow.type, value: newValue));
              }
            },
            items: widget.accountNames
                .map((account) =>
                    DropdownMenuItem(child: Text(account), value: account))
                .toList(),
            decoration: InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null) {
                return 'Please select an account';
              }
              return null;
            },
          ),
        );
      case 'borrowerUsername':
        if (selectedUsername == null) {
          return Expanded(
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable.empty();
                }
                return widget.borrowerUsernames.where(
                  (option) => option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()),
                );
              },
              onSelected: (selection) {
                setState(() {
                  selectedUsername = selection; // Save locally
                });
                FilterRow updatedRow = FilterRow(
                    type: widget.filterRow.type,
                    value: selection,
                    selectedValue: selection // Save the selected value
                    );
                widget.onUpdate(updatedRow); // Notify parent
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'User',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value == '' ||
                        selectedUsername == null) {
                      return "Username doesn't exist";
                    }
                    return null;
                  },
                );
              },
            ),
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(selectedUsername!)),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    selectedUsername = null;
                  });
                },
              )
            ],
          );
        }
      case 'borrowerName':
        if (selectedBorrowerName == null) {
          return Expanded(
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable.empty();
                }
                return widget.borrowerNames.where(
                  (option) => option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()),
                );
              },
              onSelected: (selection) {
                setState(() {
                  selectedBorrowerName = selection; // Save locally
                });
                FilterRow updatedRow = FilterRow(
                    type: widget.filterRow.type,
                    value: selection,
                    selectedValue: selection // Save the selected value
                    );
                widget.onUpdate(updatedRow); // Notify parent
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value == '') {
                      return "Name doesn't exist";
                    }
                    return null;
                  },
                );
              },
            ),
          );
        } else {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(selectedBorrowerName!)),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    selectedBorrowerName = null;
                  });
                },
              )
            ],
          );
        }
      case 'originationDate':
      case 'repayDate':
        return Expanded(
          child: TextFormField(
            controller: TextEditingController()
              ..text = widget.filterRow.value != null
                  ? formatDate(widget.filterRow.value)
                  : '',
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Date',
              border: OutlineInputBorder(),
            ),
            onTap: () async {
              widget.selectDate(context, widget.filterRow.value as DateTime?,
                  (selectedDate) {
                widget.onUpdate(FilterRow(
                    type: widget.filterRow.type, value: selectedDate));
                setState(() {});
              });
            },
            validator: (value) {
              if (value == null || value == '') {
                return 'Please enter a date';
              }
              return null;
            },
          ),
        );
      default:
        return SizedBox.shrink();
    }
  }

  String formatDate(DateTime date) {
    return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}-${date.year}";
  }

  dynamic defaultValueForType(String type) {
    switch (type) {
      case 'status':
        return 'ongoing';
      case 'borrowerUsername':
      case 'borrowerName':
      case 'lenderAccount':
        return '';
      case 'originationDate':
      case 'repayDate':
        return DateTime.now();
      default:
        return '';
    }
  }
}
