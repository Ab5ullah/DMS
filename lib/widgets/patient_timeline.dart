import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../models/billing_model.dart';

enum TimelineEventType { appointment, billing }

class TimelineEvent {
  final DateTime date;
  final TimelineEventType type;
  final String title;
  final String? subtitle;
  final String? status;
  final double? amount;
  final IconData icon;
  final Color color;

  TimelineEvent({
    required this.date,
    required this.type,
    required this.title,
    this.subtitle,
    this.status,
    this.amount,
    required this.icon,
    required this.color,
  });

  factory TimelineEvent.fromAppointment(Appointment appointment) {
    Color statusColor;
    switch (appointment.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return TimelineEvent(
      date: DateTime.parse(appointment.date),
      type: TimelineEventType.appointment,
      title: 'Appointment: ${appointment.reason}',
      subtitle: 'Time: ${appointment.time}',
      status: appointment.status,
      icon: Icons.event,
      color: statusColor,
    );
  }

  factory TimelineEvent.fromBilling(Billing billing) {
    final isPaid = billing.paid >= billing.cost;
    return TimelineEvent(
      date: DateTime.parse(billing.date),
      type: TimelineEventType.billing,
      title: 'Treatment: ${billing.treatment}',
      subtitle: 'Rs. ${billing.cost.toStringAsFixed(0)} (Paid: Rs. ${billing.paid.toStringAsFixed(0)})',
      status: isPaid ? 'PAID' : 'UNPAID',
      amount: billing.cost - billing.paid,
      icon: Icons.receipt_long,
      color: isPaid ? Colors.green : Colors.orange,
    );
  }
}

class PatientTimeline extends StatelessWidget {
  final List<Appointment> appointments;
  final List<Billing> billings;

  const PatientTimeline({
    super.key,
    required this.appointments,
    required this.billings,
  });

  List<TimelineEvent> _buildTimelineEvents() {
    final events = <TimelineEvent>[];

    // Convert appointments to timeline events
    for (var appointment in appointments) {
      events.add(TimelineEvent.fromAppointment(appointment));
    }

    // Convert billings to timeline events
    for (var billing in billings) {
      events.add(TimelineEvent.fromBilling(billing));
    }

    // Sort by date descending (most recent first)
    events.sort((a, b) => b.date.compareTo(a.date));

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final events = _buildTimelineEvents();

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timeline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No visit history yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return _TimelineItem(
          event: event,
          isLast: isLast,
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;

  const _TimelineItem({
    required this.event,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: event.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  event.icon,
                  size: 20,
                  color: event.color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Event content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (event.status != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: event.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: event.color),
                              ),
                              child: Text(
                                event.status!,
                                style: TextStyle(
                                  color: event.color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (event.subtitle != null)
                        Text(
                          event.subtitle!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(event.date),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (event.amount != null && event.amount! > 0) ...[
                            const SizedBox(width: 16),
                            Icon(
                              Icons.warning,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Balance: Rs. ${event.amount!.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
