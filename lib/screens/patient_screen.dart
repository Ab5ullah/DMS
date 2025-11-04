import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/patient_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patientsData = await DBHelper.instance.getAllPatients();
      final patients = patientsData.map((p) => Patient.fromMap(p)).toList();

      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patients: ${e.toString()}')),
        );
      }
    }
  }

  void _searchPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPatients = _patients;
      } else {
        _filteredPatients = _patients.where((patient) {
          return patient.name.toLowerCase().contains(query.toLowerCase()) ||
              (patient.phone?.contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _deletePatient(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this patient?'),
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
        await DBHelper.instance.deletePatient(id);
        _loadPatients();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting patient: ${e.toString()}')),
          );
        }
      }
    }
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
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchPatients,
                    decoration: InputDecoration(
                      hintText: 'Search by name or phone...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                CustomButton(
                  text: 'Add Patient',
                  icon: Icons.person_add,
                  onPressed: () => _showPatientDialog(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                ? const Center(
                    child: Text(
                      'No patients found',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.blue.shade50,
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Phone',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Age',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Gender',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Address',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Medical History',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Allergies',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Actions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: _filteredPatients.map((patient) {
                            final hasAllergies =
                                patient.allergies != null &&
                                patient.allergies!.isNotEmpty &&
                                patient.allergies!.toLowerCase() != 'none';
                            return DataRow(
                              color: hasAllergies
                                  ? WidgetStateProperty.all(Colors.red.shade50)
                                  : null,
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      if (hasAllergies)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8,
                                          ),
                                          child: Icon(
                                            Icons.warning,
                                            color: Colors.red.shade700,
                                            size: 20,
                                          ),
                                        ),
                                      Expanded(child: Text(patient.name)),
                                    ],
                                  ),
                                ),
                                DataCell(Text(patient.phone ?? 'N/A')),
                                DataCell(
                                  Text(patient.age?.toString() ?? 'N/A'),
                                ),
                                DataCell(Text(patient.gender ?? 'N/A')),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      patient.address ?? 'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 200,
                                    ),
                                    child: Text(
                                      patient.medicalHistory ?? 'N/A',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  hasAllergies
                                      ? Container(
                                          constraints: const BoxConstraints(
                                            maxWidth: 200,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade100,
                                            border: Border.all(
                                              color: Colors.red.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.medical_information,
                                                color: Colors.red.shade700,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  patient.allergies!,
                                                  style: TextStyle(
                                                    color: Colors.red.shade900,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const Text('N/A'),
                                ),
                                DataCell(
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _showPatientDialog(
                                          patient: patient,
                                        ),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deletePatient(patient.id!),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showPatientDialog({Patient? patient}) {
    final isEdit = patient != null;
    final nameController = TextEditingController(text: patient?.name);
    final phoneController = TextEditingController(text: patient?.phone);
    final ageController = TextEditingController(text: patient?.age?.toString());
    final addressController = TextEditingController(text: patient?.address);
    final medicalHistoryController = TextEditingController(
      text: patient?.medicalHistory,
    );
    final allergiesController = TextEditingController(text: patient?.allergies);
    String? selectedGender = patient?.gender;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Patient' : 'Add Patient'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      label: 'Name',
                      controller: nameController,
                      hintText: 'Enter patient name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Phone',
                      controller: phoneController,
                      hintText: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Age',
                      controller: ageController,
                      hintText: 'Enter age',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            hintText: 'Select gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: ['Male', 'Female', 'Other']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedGender = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Address',
                      controller: addressController,
                      hintText: 'Enter address',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Medical History',
                      controller: medicalHistoryController,
                      hintText: 'Enter medical history',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Allergies',
                      controller: allergiesController,
                      hintText: 'Enter allergies',
                      maxLines: 2,
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
                  final patientData = Patient(
                    id: patient?.id,
                    name: nameController.text,
                    phone: phoneController.text.isEmpty
                        ? null
                        : phoneController.text,
                    age: ageController.text.isEmpty
                        ? null
                        : int.tryParse(ageController.text),
                    gender: selectedGender,
                    address: addressController.text.isEmpty
                        ? null
                        : addressController.text,
                    medicalHistory: medicalHistoryController.text.isEmpty
                        ? null
                        : medicalHistoryController.text,
                    allergies: allergiesController.text.isEmpty
                        ? null
                        : allergiesController.text,
                  );

                  try {
                    if (isEdit) {
                      await DBHelper.instance.updatePatient(
                        patientData.toMap(),
                      );
                    } else {
                      await DBHelper.instance.insertPatient(
                        patientData.toMap(),
                      );
                    }
                    _loadPatients();
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Patient ${isEdit ? 'updated' : 'added'} successfully',
                          ),
                        ),
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
