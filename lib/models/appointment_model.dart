class Appointment {
  final int? id;
  final int patientId;
  final String date;
  final String time;
  final String? reason;
  final String status;
  final String? patientName;

  Appointment({
    this.id,
    required this.patientId,
    required this.date,
    required this.time,
    this.reason,
    this.status = 'Pending',
    this.patientName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'date': date,
      'time': time,
      'reason': reason,
      'status': status,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patient_id'],
      date: map['date'],
      time: map['time'],
      reason: map['reason'],
      status: map['status'] ?? 'Pending',
      patientName: map['patient_name'],
    );
  }
}
