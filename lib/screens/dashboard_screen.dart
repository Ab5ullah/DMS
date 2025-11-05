import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../widgets/summary_card.dart';
import '../config/app_config.dart';
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
  double _totalIncome = 0.0;
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
      final totalIncome = await DBHelper.instance.getTotalIncomeAll();

      setState(() {
        _totalPatients = totalPatients;
        _todayAppointments = todayAppointments;
        _monthlyIncome = monthlyIncome;
        _totalIncome = totalIncome;
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
        backgroundColor: AppConfig.primaryColor,
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
            backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
            selectedIconTheme: IconThemeData(color: AppConfig.primaryColor),
            selectedLabelTextStyle: TextStyle(
              color: AppConfig.primaryColor,
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
              crossAxisCount: 4,
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
                  color: AppConfig.patientCardColor,
                ),
                SummaryCard(
                  title: "Today's Appointments",
                  value: _todayAppointments.toString(),
                  icon: Icons.calendar_today,
                  color: AppConfig.appointmentCardColor,
                ),
                SummaryCard(
                  title: 'Monthly Income',
                  value: '${AppConfig.currencySymbol} ${_monthlyIncome.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: AppConfig.monthlyIncomeCardColor,
                ),
                SummaryCard(
                  title: 'Total Income',
                  value: '${AppConfig.currencySymbol} ${_totalIncome.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: AppConfig.totalIncomeCardColor,
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
                          AppConfig.patientCardColor,
                          () => setState(() => _selectedIndex = 1),
                        ),
                        _buildQuickActionButton(
                          'New Appointment',
                          Icons.event_available,
                          AppConfig.appointmentCardColor,
                          () => setState(() => _selectedIndex = 2),
                        ),
                        _buildQuickActionButton(
                          'Add Billing',
                          Icons.receipt_long,
                          AppConfig.monthlyIncomeCardColor,
                          () => setState(() => _selectedIndex = 3),
                        ),
                        _buildQuickActionButton(
                          'View Reports',
                          Icons.bar_chart,
                          AppConfig.totalIncomeCardColor,
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

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  int _totalPatients = 0;
  int _todayAppointments = 0;
  double _monthlyIncome = 0.0;
  double _totalUnpaid = 0.0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _unpaidPatients = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final totalPatients = await DBHelper.instance.getTotalPatients();
      final todayAppointments = await DBHelper.instance.getTodayAppointments();
      final monthlyIncome = await DBHelper.instance.getMonthlyIncome();
      final totalUnpaid = await DBHelper.instance.getTotalUnpaid();

      // Get patients with unpaid balances
      final billingRecords = await DBHelper.instance.getAllBilling();
      final Map<int, double> patientBalances = {};
      final Map<int, String> patientNames = {};

      for (var billing in billingRecords) {
        final patientId = billing['patient_id'] as int;
        final cost = billing['cost'] as double;
        final paid = billing['paid'] as double;
        final balance = cost - paid;

        if (balance > 0) {
          patientBalances[patientId] =
              (patientBalances[patientId] ?? 0) + balance;
          if (!patientNames.containsKey(patientId)) {
            patientNames[patientId] = billing['patient_name'] as String;
          }
        }
      }

      final unpaid = patientBalances.entries
          .map((e) => {
                'patient_id': e.key,
                'patient_name': patientNames[e.key],
                'balance': e.value,
              })
          .toList()
        ..sort((a, b) => (b['balance'] as double)
            .compareTo(a['balance'] as double));

      setState(() {
        _totalPatients = totalPatients;
        _todayAppointments = todayAppointments;
        _monthlyIncome = monthlyIncome;
        _totalUnpaid = totalUnpaid;
        _unpaidPatients = unpaid.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConfig.primaryColor,
                  AppConfig.primaryColor.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.waving_hand, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to ${AppConfig.clinicName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Today: ${DateTime.now().toString().split(' ')[0]}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Summary cards
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Patients',
                  value: _totalPatients.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: "Today's Appointments",
                  value: _todayAppointments.toString(),
                  icon: Icons.event,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Monthly Income',
                  value:
                      '${AppConfig.currencySymbol} ${_monthlyIncome.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: 'Unpaid Balance',
                  value:
                      '${AppConfig.currencySymbol} ${_totalUnpaid.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet,
                  color: _totalUnpaid > 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Patient Balance Reminder
          if (_unpaidPatients.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Patients with Outstanding Balances',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _unpaidPatients.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final patient = _unpaidPatients[index];
                  final balance = patient['balance'] as double;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(
                        Icons.person,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    title: Text(
                      patient['patient_name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Outstanding balance',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      '${AppConfig.currencySymbol} ${balance.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Quick Actions
          Row(
            children: [
              const Icon(Icons.flash_on, color: Colors.blue),
              const SizedBox(width: 12),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildQuickActionCard(
                'View All Patients',
                Icons.people,
                Colors.blue,
                () {},
              ),
              _buildQuickActionCard(
                'Today\'s Schedule',
                Icons.calendar_today,
                Colors.green,
                () {},
              ),
              _buildQuickActionCard(
                'Add Billing',
                Icons.receipt,
                Colors.orange,
                () {},
              ),
              _buildQuickActionCard(
                'View Reports',
                Icons.bar_chart,
                Colors.purple,
                () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      width: 200,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
