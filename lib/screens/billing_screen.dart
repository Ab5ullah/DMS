import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/billing_model.dart';
import '../models/patient_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  List<Billing> _billings = [];
  bool _isLoading = true;
  String _filterType = 'All';
  double _totalUnpaid = 0.0;

  @override
  void initState() {
    super.initState();
    _loadBillings();
  }

  Future<void> _loadBillings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final billingsData = await DBHelper.instance.getAllBilling();
      final billings = billingsData.map((b) => Billing.fromMap(b)).toList();

      // Calculate total unpaid
      double unpaid = 0.0;
      for (var billing in billings) {
        unpaid += billing.balance;
      }

      setState(() {
        _billings = billings;
        _totalUnpaid = unpaid;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading billings: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteBilling(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this billing record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DBHelper.instance.deleteBilling(id);
        _loadBillings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Billing deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting billing: ${e.toString()}')),
          );
        }
      }
    }
  }

  List<Billing> get _filteredBillings {
    switch (_filterType) {
      case 'Paid':
        return _billings.where((b) => b.balance == 0).toList();
      case 'Unpaid':
        return _billings.where((b) => b.balance > 0).toList();
      default:
        return _billings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Outstanding Payments Summary Card
          if (_totalUnpaid > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outstanding Payments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total unpaid balance: \$${_totalUnpaid.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterType = 'Unpaid';
                      });
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter by Payment:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'All', label: Text('All')),
                    ButtonSegment(value: 'Paid', label: Text('Paid')),
                    ButtonSegment(value: 'Unpaid', label: Text('Unpaid')),
                  ],
                  selected: {_filterType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _filterType = newSelection.first;
                    });
                  },
                ),
                const Spacer(),
                CustomButton(
                  text: 'Add Billing',
                  icon: Icons.receipt_long,
                  onPressed: () => _showBillingDialog(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBillings.isEmpty
                    ? const Center(
                        child: Text(
                          'No billing records found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          elevation: 2,
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
                            columns: const [
                              DataColumn(label: Text('Patient', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Treatment', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Paid', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _filteredBillings.map((billing) {
                              return DataRow(cells: [
                                DataCell(Text(billing.patientName ?? 'Unknown')),
                                DataCell(Text(billing.treatment)),
                                DataCell(Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(billing.date)))),
                                DataCell(Text('\$${billing.cost.toStringAsFixed(2)}')),
                                DataCell(Text('\$${billing.paid.toStringAsFixed(2)}')),
                                DataCell(
                                  Text(
                                    '\$${billing.balance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: billing.balance > 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _showBillingDialog(billing: billing),
                                      tooltip: 'Edit',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteBilling(billing.id!),
                                      tooltip: 'Delete',
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showBillingDialog({Billing? billing}) async {
    final isEdit = billing != null;
    final treatmentController = TextEditingController(text: billing?.treatment);
    final costController = TextEditingController(text: billing?.cost.toString());
    final paidController = TextEditingController(text: billing?.paid.toString());
    DateTime selectedDate = billing != null ? DateTime.parse(billing.date) : DateTime.now();
    int? selectedPatientId = billing?.patientId;
    final formKey = GlobalKey<FormState>();

    // Load patients
    final patientsData = await DBHelper.instance.getAllPatients();
    final patients = patientsData.map((p) => Patient.fromMap(p)).toList();

    // If editing and patient doesn't exist in the list, reset selectedPatientId
    if (isEdit && selectedPatientId != null) {
      final patientExists = patients.any((p) => p.id == selectedPatientId);
      if (!patientExists) {
        selectedPatientId = null;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Billing' : 'Add Billing'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Patient',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: selectedPatientId,
                          decoration: InputDecoration(
                            hintText: 'Select patient',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: patients
                              .map((patient) => DropdownMenuItem(
                                    value: patient.id,
                                    child: Text(patient.name),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedPatientId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a patient';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: DBHelper.instance.getAllTreatmentTemplates(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Quick Select Template',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.tips_and_updates, size: 16, color: Colors.blue.shade700),
                                ],
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<Map<String, dynamic>>(
                                decoration: InputDecoration(
                                  hintText: 'Select a template (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                items: snapshot.data!
                                    .map((template) => DropdownMenuItem(
                                          value: template,
                                          child: Text('${template['name']} - \$${template['cost']}'),
                                        ))
                                    .toList(),
                                onChanged: (template) {
                                  if (template != null) {
                                    setDialogState(() {
                                      treatmentController.text = template['name'];
                                      costController.text = template['cost'].toString();
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    CustomTextField(
                      label: 'Treatment',
                      controller: treatmentController,
                      hintText: 'Enter treatment name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter treatment';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Cost',
                      controller: costController,
                      hintText: 'Enter cost',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cost';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Amount Paid',
                      controller: paidController,
                      hintText: 'Enter amount paid',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount paid';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Date',
                      controller: TextEditingController(text: DateFormat('MMM dd, yyyy').format(selectedDate)),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final billingData = Billing(
                    id: billing?.id,
                    patientId: selectedPatientId!,
                    treatment: treatmentController.text,
                    cost: double.parse(costController.text),
                    paid: double.parse(paidController.text),
                    date: selectedDate.toString().split(' ')[0],
                  );

                  try {
                    if (isEdit) {
                      await DBHelper.instance.updateBilling(billingData.toMap());
                    } else {
                      await DBHelper.instance.insertBilling(billingData.toMap());
                    }
                    _loadBillings();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Billing ${isEdit ? 'updated' : 'added'} successfully')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }
}
