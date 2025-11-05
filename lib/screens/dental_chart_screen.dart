import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/patient_model.dart';
import '../models/tooth_treatment_model.dart';
import '../widgets/dental_chart_widget.dart';

class DentalChartScreen extends StatefulWidget {
  final Patient patient;

  const DentalChartScreen({super.key, required this.patient});

  @override
  State<DentalChartScreen> createState() => _DentalChartScreenState();
}

class _DentalChartScreenState extends State<DentalChartScreen> {
  Map<int, ToothStatus> toothStatuses = {};
  List<ToothTreatment> treatments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadToothStatuses();
  }

  Future<void> _loadToothStatuses() async {
    setState(() => isLoading = true);

    try {
      // Get all tooth treatments for this patient
      final treatmentMaps = await DBHelper.instance.getPatientToothTreatments(
        widget.patient.id!,
      );
      treatments = treatmentMaps
          .map((map) => ToothTreatment.fromMap(map))
          .toList();

      // Build tooth status map (latest status for each tooth)
      final Map<int, ToothStatus> statusMap = {};

      // Initialize all teeth as healthy
      for (int quadrant = 1; quadrant <= 4; quadrant++) {
        for (int position = 1; position <= 8; position++) {
          final toothNumber = quadrant * 10 + position;
          statusMap[toothNumber] = ToothStatus.healthy;
        }
      }

      // Update with actual treatment data (latest treatment for each tooth)
      for (var treatment in treatments) {
        if (!statusMap.containsKey(treatment.toothNumber) ||
            _isMoreRecentStatus(
              treatment.status,
              statusMap[treatment.toothNumber]!,
            )) {
          statusMap[treatment.toothNumber] = treatment.status;
        }
      }

      setState(() {
        toothStatuses = statusMap;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tooth data: $e')));
      }
    }
  }

  bool _isMoreRecentStatus(ToothStatus newStatus, ToothStatus oldStatus) {
    // Simple logic: non-healthy statuses override healthy
    if (oldStatus == ToothStatus.healthy) return true;
    return false;
  }

  void _onToothTap(int toothNumber) {
    _showToothTreatmentDialog(toothNumber);
  }

  void _showLegendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text('Tooth Status Legend'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color codes represent tooth conditions:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...ToothStatus.values.map((status) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getColorFromHex(status.colorCode),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                status.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                _getStatusDescription(status),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Click any tooth to add or view treatment history',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getStatusDescription(ToothStatus status) {
    switch (status) {
      case ToothStatus.healthy:
        return 'No issues detected';
      case ToothStatus.decay:
        return 'Cavity or decay present';
      case ToothStatus.filled:
        return 'Filled with amalgam or composite';
      case ToothStatus.rct:
        return 'Root canal treatment completed';
      case ToothStatus.crown:
        return 'Crown or cap placed';
      case ToothStatus.bridge:
        return 'Part of a dental bridge';
      case ToothStatus.implant:
        return 'Dental implant';
      case ToothStatus.extracted:
        return 'Tooth has been removed';
      case ToothStatus.missing:
        return 'Tooth missing (not extracted)';
      case ToothStatus.planned:
        return 'Treatment planned';
    }
  }

  Future<void> _showToothTreatmentDialog(int toothNumber) async {
    // Get existing treatments for this tooth
    final toothTreatments = treatments
        .where((t) => t.toothNumber == toothNumber)
        .toList();

    await showDialog(
      context: context,
      builder: (context) => _ToothTreatmentDialog(
        patientId: widget.patient.id!,
        patientName: widget.patient.name,
        toothNumber: toothNumber,
        existingTreatments: toothTreatments,
        onSave: () async {
          await _loadToothStatuses();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dental Chart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showLegendDialog,
            tooltip: 'Show Legend',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadToothStatuses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.patient.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Patient ID: ${widget.patient.patientId ?? "N/A"} | '
                                  'Age: ${widget.patient.age ?? "N/A"} | '
                                  'Gender: ${widget.patient.gender ?? "N/A"}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Click on any tooth to add or view treatment history. Hover over teeth to see tooth type.',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dental chart
                  DentalChartWidget(
                    patientId: widget.patient.id!,
                    toothStatuses: toothStatuses,
                    onToothTap: _onToothTap,
                  ),

                  const SizedBox(height: 32),

                  // Recent treatments
                  if (treatments.isNotEmpty) ...[
                    const Text(
                      'Recent Treatments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentTreatmentsList(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRecentTreatmentsList() {
    final recentTreatments = treatments.take(10).toList();

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentTreatments.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final treatment = recentTreatments[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getColorFromHex(treatment.status.colorCode),
              child: Text(
                treatment.toothNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              '${treatment.procedure} - Tooth ${treatment.toothNumber}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${ToothTreatment.getQuadrantName(treatment.toothNumber)} - ${treatment.status.displayName}\n'
              '${DateFormat('MMM dd, yyyy').format(DateTime.parse(treatment.date))}',
            ),
            trailing: treatment.cost != null
                ? Text(
                    'Rs. ${treatment.cost!.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )
                : null,
            isThreeLine: true,
          );
        },
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}

class _ToothTreatmentDialog extends StatefulWidget {
  final int patientId;
  final String patientName;
  final int toothNumber;
  final List<ToothTreatment> existingTreatments;
  final VoidCallback onSave;

  const _ToothTreatmentDialog({
    required this.patientId,
    required this.patientName,
    required this.toothNumber,
    required this.existingTreatments,
    required this.onSave,
  });

  @override
  State<_ToothTreatmentDialog> createState() => _ToothTreatmentDialogState();
}

class _ToothTreatmentDialogState extends State<_ToothTreatmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _procedureController = TextEditingController();
  final _notesController = TextEditingController();
  final _costController = TextEditingController();
  ToothStatus _selectedStatus = ToothStatus.healthy;
  DateTime _selectedDate = DateTime.now();
  int _selectedTab = 0; // 0 = Add new, 1 = History

  @override
  void dispose() {
    _procedureController.dispose();
    _notesController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final treatment = ToothTreatment(
        patientId: widget.patientId,
        toothNumber: widget.toothNumber,
        procedure: _procedureController.text.trim(),
        status: _selectedStatus,
        date: _selectedDate.toString().split(' ')[0],
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        cost: _costController.text.isEmpty
            ? null
            : double.tryParse(_costController.text),
      );

      await DBHelper.instance.insertToothTreatment(treatment.toMap());

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSave();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving treatment: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tooth ${widget.toothNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${ToothTreatment.getQuadrantName(widget.toothNumber)} - ${ToothTreatment.getToothType(widget.toothNumber)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          widget.patientName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('Add Treatment', 0)),
                  Expanded(
                    child: _buildTab(
                      'History (${widget.existingTreatments.length})',
                      1,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildAddTreatmentTab()
                  : _buildHistoryTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue.shade700 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddTreatmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Procedure
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Procedure',
                border: OutlineInputBorder(),
              ),
              items: DentalProcedures.common.map((proc) {
                return DropdownMenuItem(value: proc, child: Text(proc));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _procedureController.text = value;
                }
              },
              validator: (value) => _procedureController.text.isEmpty
                  ? 'Please select or enter a procedure'
                  : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _procedureController,
              decoration: const InputDecoration(
                labelText: 'Or type custom procedure',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.trim().isEmpty ?? true
                  ? 'Please enter a procedure'
                  : null,
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<ToothStatus>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ToothStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _getColorFromHex(status.colorCode),
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(status.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedStatus = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade400),
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),

            // Cost
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Cost (Optional)',
                border: OutlineInputBorder(),
                prefixText: 'Rs. ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cost = double.tryParse(value);
                  if (cost == null) return 'Please enter a valid number';
                  if (cost < 0) return 'Cost cannot be negative';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton.icon(
              onPressed: _saveTreatment,
              icon: const Icon(Icons.save),
              label: const Text('Save Treatment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (widget.existingTreatments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No treatment history for this tooth',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: widget.existingTreatments.length,
      separatorBuilder: (context, index) => const Divider(height: 32),
      itemBuilder: (context, index) {
        final treatment = widget.existingTreatments[index];
        return _buildHistoryItem(treatment);
      },
    );
  }

  Widget _buildHistoryItem(ToothTreatment treatment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getColorFromHex(treatment.status.colorCode),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                treatment.status.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('MMM dd, yyyy').format(DateTime.parse(treatment.date)),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const Spacer(),
            if (treatment.cost != null)
              Text(
                'Rs. ${treatment.cost!.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          treatment.procedure,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (treatment.notes != null && treatment.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(treatment.notes!, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ],
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }
}
