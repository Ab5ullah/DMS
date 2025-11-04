import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/appointment_model.dart';
import '../models/patient_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = true;
  String _filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointmentsData = await DBHelper.instance.getAllAppointments();
      final appointments = appointmentsData.map((a) => Appointment.fromMap(a)).toList();

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointments: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAppointment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this appointment?'),
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
        await DBHelper.instance.deleteAppointment(id);
        _loadAppointments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Appointment deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting appointment: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await DBHelper.instance.updateAppointment({'id': id, 'status': status});
      _loadAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: ${e.toString()}')),
        );
      }
    }
  }

  List<Appointment> get _filteredAppointments {
    if (_filterStatus == 'All') {
      return _appointments;
    }
    return _appointments.where((a) => a.status == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filter by Status:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'All', label: Text('All')),
                    ButtonSegment(value: 'Pending', label: Text('Pending')),
                    ButtonSegment(value: 'Completed', label: Text('Completed')),
                    ButtonSegment(value: 'Cancelled', label: Text('Cancelled')),
                  ],
                  selected: {_filterStatus},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _filterStatus = newSelection.first;
                    });
                  },
                ),
                const Spacer(),
                CustomButton(
                  text: 'Add Appointment',
                  icon: Icons.event_available,
                  onPressed: () => _showAppointmentDialog(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAppointments.isEmpty
                    ? const Center(
                        child: Text(
                          'No appointments found',
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
                              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Reason', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: _filteredAppointments.map((appointment) {
                              return DataRow(cells: [
                                DataCell(Text(appointment.patientName ?? 'Unknown')),
                                DataCell(Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(appointment.date)))),
                                DataCell(Text(appointment.time)),
                                DataCell(Text(appointment.reason ?? 'N/A')),
                                DataCell(_buildStatusChip(appointment.status)),
                                DataCell(Row(
                                  children: [
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showAppointmentDialog(appointment: appointment);
                                        } else if (value == 'delete') {
                                          _deleteAppointment(appointment.id!);
                                        } else {
                                          _updateStatus(appointment.id!, value);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18, color: Colors.blue),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Pending',
                                          child: Row(
                                            children: [
                                              Icon(Icons.pending, size: 18, color: Colors.orange),
                                              SizedBox(width: 8),
                                              Text('Mark as Pending'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Completed',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, size: 18, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('Mark as Completed'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Cancelled',
                                          child: Row(
                                            children: [
                                              Icon(Icons.cancel, size: 18, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Mark as Cancelled'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuDivider(),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, size: 18, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
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

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  void _showAppointmentDialog({Appointment? appointment}) async {
    final isEdit = appointment != null;
    final reasonController = TextEditingController(text: appointment?.reason);
    DateTime selectedDate = appointment != null ? DateTime.parse(appointment.date) : DateTime.now();
    TimeOfDay selectedTime = appointment != null
        ? TimeOfDay(
            hour: int.parse(appointment.time.split(':')[0]),
            minute: int.parse(appointment.time.split(':')[1]),
          )
        : TimeOfDay.now();
    int? selectedPatientId = appointment?.patientId;
    String selectedPatientName = appointment?.patientName ?? '';
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
          title: Text(isEdit ? 'Edit Appointment' : 'Add Appointment'),
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
                              selectedPatientName = patients.firstWhere((p) => p.id == value).name;
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
                    CustomTextField(
                      label: 'Date',
                      controller: TextEditingController(text: DateFormat('MMM dd, yyyy').format(selectedDate)),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Time',
                      controller: TextEditingController(text: selectedTime.format(context)),
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (time != null) {
                          setDialogState(() {
                            selectedTime = time;
                          });
                        }
                      },
                      suffixIcon: const Icon(Icons.access_time),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Reason',
                      controller: reasonController,
                      hintText: 'Enter reason for appointment',
                      maxLines: 3,
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
                  final appointmentData = Appointment(
                    id: appointment?.id,
                    patientId: selectedPatientId!,
                    date: selectedDate.toString().split(' ')[0],
                    time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    reason: reasonController.text.isEmpty ? null : reasonController.text,
                    status: appointment?.status ?? 'Pending',
                  );

                  try {
                    if (isEdit) {
                      await DBHelper.instance.updateAppointment(appointmentData.toMap());
                    } else {
                      await DBHelper.instance.insertAppointment(appointmentData.toMap());
                    }
                    _loadAppointments();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appointment ${isEdit ? 'updated' : 'added'} successfully')),
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
