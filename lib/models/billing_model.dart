class Billing {
  final int? id;
  final int patientId;
  final String treatment;
  final double cost;
  final double paid;
  final String date;
  final String? patientName;

  Billing({
    this.id,
    required this.patientId,
    required this.treatment,
    required this.cost,
    required this.paid,
    required this.date,
    this.patientName,
  });

  double get balance => cost - paid;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'treatment': treatment,
      'cost': cost,
      'paid': paid,
      'date': date,
    };
  }

  factory Billing.fromMap(Map<String, dynamic> map) {
    return Billing(
      id: map['id'],
      patientId: map['patient_id'],
      treatment: map['treatment'],
      cost: (map['cost'] as num).toDouble(),
      paid: (map['paid'] as num).toDouble(),
      date: map['date'],
      patientName: map['patient_name'],
    );
  }
}
