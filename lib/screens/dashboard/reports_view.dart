// lib/screens/dashboard/reports_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/member.dart';
import '../../services/member_service.dart';


class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final memberService = Provider.of<MemberService>(context);

    // Calculate some basic statistics for the report
    final totalMembers = memberService.members.length;
    final activeMembers = memberService.members.where((m) => m.overallStatus == MembershipStatus.active).length;
    final expiredMembers = totalMembers - activeMembers;

    final totalRevenue = memberService.members
        .expand((member) => member.memberships)
        .fold<double>(0.0, (sum, membership) => sum + membership.amountPaid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Report Data',
            onPressed: memberService.fetchMembers,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: memberService.isLoading
          ? const Center(child: CircularProgressIndicator())
          : memberService.errorMessage != null
          ? Center(child: Text('Error loading report data: ${memberService.errorMessage}'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Club Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 30, thickness: 1.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildReportCard(
                    context,
                    'Total Members',
                    totalMembers.toString(),
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildReportCard(
                    context,
                    'Active Members',
                    activeMembers.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildReportCard(
                    context,
                    'Expired Members',
                    expiredMembers.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildReportCard(
                    context,
                    'Total Revenue',
                    _currencyFormat.format(totalRevenue),
                    Icons.account_balance_wallet,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Membership Status Distribution',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Placeholder for a chart or more detailed table
            Center(
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    height: 200, // Placeholder height for a chart
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Chart Placeholder: Membership Status',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Recent Renewals',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Display a simplified list of recent renewals
            _buildRecentRenewalsTable(context, memberService.members),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRenewalsTable(BuildContext context, List<Member> members) {
    List<Membership> recentRenewals = members
        .expand((member) => member.memberships)
        .where((m) => m.renewalDate.isAfter(DateTime.now().subtract(const Duration(days: 90)))) // Last 3 months
        .toList();
    recentRenewals.sort((a, b) => b.renewalDate.compareTo(a.renewalDate)); // Most recent first

    if (recentRenewals.isEmpty) {
      return const Text('No recent renewals in the last 3 months.');
    }

    // Limit to top 5 for brevity in the report
    final displayRenewals = recentRenewals.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Member Name')),
                DataColumn(label: Text('Renewal Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: displayRenewals.map((membership) {
                final member = members.firstWhere((m) => m.id == membership.memberId, orElse: () => Member(id: 'Unknown', firstName: 'Unknown', lastName: 'Member', email: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));
                return DataRow(cells: [
                  DataCell(Text(member.fullName)),
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(membership.renewalDate))),
                  DataCell(Text(_currencyFormat.format(membership.amountPaid))),
                  DataCell(
                    Text(
                      membership.status.name.toUpperCase(),
                      style: TextStyle(
                        color: membership.status == MembershipStatus.active ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
            if (recentRenewals.length > 5)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    // Navigate to the RenewalsView or show more here
                    Provider.of<MemberService>(context, listen: false).fetchMembers(); // Simply refresh for now
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('More renewals available in the "Renewals" section.')),
                    );
                  },
                  child: const Text('View All Recent Renewals'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}