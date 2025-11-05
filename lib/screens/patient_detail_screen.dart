import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/patient_model.dart';
import '../models/appointment_model.dart';
import '../models/billing_model.dart';
import '../widgets/patient_timeline.dart';
import 'dental_chart_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<Appointment> appointments = [];
  List<Billing> billings = [];
  bool isLoading = true;
  double totalUnpaid = 0;

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  Future<void> _loadPatientData() async {
    setState(() => isLoading = true);

    try {
      final appointmentMaps = await DBHelper.instance.getPatientAppointments(
        widget.patient.id!,
      );
      final billingMaps = await DBHelper.instance.getPatientBilling(
        widget.patient.id!,
      );

      final loadedAppointments = appointmentMaps
          .map((map) => Appointment.fromMap(map))
          .toList();
      final loadedBillings = billingMaps
          .map((map) => Billing.fromMap(map))
          .toList();

      double unpaid = 0;
      for (var billing in loadedBillings) {
        unpaid += (billing.cost - billing.paid);
      }

      setState(() {
        appointments = loadedAppointments;
        billings = loadedBillings;
        totalUnpaid = unpaid;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading patient data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.medication),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DentalChartScreen(
                  patient: widget.patient,
                ),
              ),
            ),
            tooltip: 'Dental Chart',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientData,
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
                  // Patient Info Card
                  _buildPatientInfoCard(),
                  const SizedBox(height: 24),

                  // Quick Stats
                  _buildQuickStats(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 32),

                  // Visit Timeline
                  Row(
                    children: [
                      const Icon(Icons.timeline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Visit Timeline',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${appointments.length + billings.length} events',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  PatientTimeline(
                    appointments: appointments,
                    billings: billings,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientInfoCard() {
    final hasAllergies = widget.patient.allergies != null &&
        widget.patient.allergies!.isNotEmpty &&
        widget.patient.allergies!.toLowerCase() != 'none';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    widget.patient.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${widget.patient.patientId ?? "N/A"}',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasAllergies)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Icon(
                      Icons.warning,
                      color: Colors.red.shade700,
                      size: 32,
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            _buildInfoRow(Icons.phone, 'Phone', widget.patient.phone ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.credit_card, 'CNIC', widget.patient.cnic ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.cake, 'Age', widget.patient.age?.toString() ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.person, 'Gender', widget.patient.gender ?? 'N/A'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Address', widget.patient.address ?? 'N/A'),
            if (widget.patient.medicalHistory != null &&
                widget.patient.medicalHistory!.isNotEmpty) ...[
              const Divider(height: 24),
              _buildInfoRow(
                Icons.medical_information,
                'Medical History',
                widget.patient.medicalHistory!,
              ),
            ],
            if (hasAllergies) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ALLERGIES',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            widget.patient.allergies!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        SizedBox(
          width: 130,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    final completedAppointments = appointments
        .where((a) => a.status.toLowerCase() == 'completed')
        .length;
    final totalBilled = billings.fold<double>(
      0,
      (sum, b) => sum + b.cost,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Visits',
            completedAppointments.toString(),
            Icons.event_available,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Total Billed',
            'Rs. ${totalBilled.toStringAsFixed(0)}',
            Icons.receipt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Balance',
            'Rs. ${totalUnpaid.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
            totalUnpaid > 0 ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DentalChartScreen(
                  patient: widget.patient,
                ),
              ),
            ),
            icon: const Icon(Icons.medication),
            label: const Text('Dental Chart'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
