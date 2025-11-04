import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../widgets/summary_card.dart';
import 'patient_screen.dart';
import 'appointment_screen.dart';
import 'billing_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _totalPatients = 0;
  int _todayAppointments = 0;
  double _monthlyIncome = 0.0;
  bool _isLoading = true;

  final List<Widget> _screens = [
    const DashboardHome(),
    const PatientScreen(),
    const AppointmentScreen(),
    const BillingScreen(),
    const ReportScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Patients',
    'Appointments',
    'Billing',
    'Reports',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final totalPatients = await DBHelper.instance.getTotalPatients();
      final todayAppointments = await DBHelper.instance.getTodayAppointments();
      final monthlyIncome = await DBHelper.instance.getMonthlyIncome();

      setState(() {
        _totalPatients = totalPatients;
        _todayAppointments = todayAppointments;
        _monthlyIncome = monthlyIncome;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_selectedIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadDashboardData,
              tooltip: 'Refresh',
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              if (index == 0) {
                _loadDashboardData();
              }
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.blue.shade50,
            selectedIconTheme: IconThemeData(color: Colors.blue.shade700),
            selectedLabelTextStyle: TextStyle(
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Patients'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Appointments'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.receipt_outlined),
                selectedIcon: Icon(Icons.receipt),
                label: Text('Billing'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment_outlined),
                selectedIcon: Icon(Icons.assessment),
                label: Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? _buildDashboardHome()
                : _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                SummaryCard(
                  title: 'Total Patients',
                  value: _totalPatients.toString(),
                  icon: Icons.people,
                  color: Colors.blue.shade600,
                ),
                SummaryCard(
                  title: "Today's Appointments",
                  value: _todayAppointments.toString(),
                  icon: Icons.calendar_today,
                  color: Colors.green.shade600,
                ),
                SummaryCard(
                  title: 'Monthly Income',
                  value: '\$${_monthlyIncome.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: Colors.orange.shade600,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildQuickActionButton(
                          'Add Patient',
                          Icons.person_add,
                          Colors.blue,
                          () => setState(() => _selectedIndex = 1),
                        ),
                        _buildQuickActionButton(
                          'New Appointment',
                          Icons.event_available,
                          Colors.green,
                          () => setState(() => _selectedIndex = 2),
                        ),
                        _buildQuickActionButton(
                          'Add Billing',
                          Icons.receipt_long,
                          Colors.orange,
                          () => setState(() => _selectedIndex = 3),
                        ),
                        _buildQuickActionButton(
                          'View Reports',
                          Icons.bar_chart,
                          Colors.purple,
                          () => setState(() => _selectedIndex = 4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Dashboard Home'),
    );
  }
}
