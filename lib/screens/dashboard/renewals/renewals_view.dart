// lib/screens/dashboard/renewals/renewals_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/member.dart';
import '../../../services/member_service.dart'; // For date formatting


class RenewalsView extends StatefulWidget {
  const RenewalsView({super.key});

  @override
  State<RenewalsView> createState() => _RenewalsViewState();
}

class _RenewalsViewState extends State<RenewalsView> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  String _searchQuery = '';
  MembershipStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final memberService = Provider.of<MemberService>(context);

    // Flatten all memberships from all members
    List<Membership> allMemberships = memberService.members.expand((member) => member.memberships.map((m) => m)).toList();

    // Sort by renewal date, most recent first
    allMemberships.sort((a, b) => b.renewalDate.compareTo(a.renewalDate));

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      allMemberships = allMemberships.where((membership) {
        final member = memberService.members.firstWhere((m) => m.id == membership.memberId, orElse: () => Member(id: '', firstName: '', lastName: '', email: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));
        return member.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            member.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply status filter
    if (_selectedStatusFilter != null) {
      allMemberships = allMemberships.where((membership) => membership.status == _selectedStatusFilter).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Renewals'),
        automaticallyImplyLeading: false, // Don't show back button on sub-view
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Renewals',
            onPressed: memberService.fetchMembers, // Re-fetch all members to update renewals
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by member name or email...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<MembershipStatus?>(
                  value: _selectedStatusFilter,
                  hint: const Text('Filter by Status'),
                  onChanged: (MembershipStatus? newValue) {
                    setState(() {
                      _selectedStatusFilter = newValue;
                    });
                  },
                  items: <MembershipStatus?>[null, ...MembershipStatus.values]
                      .map<DropdownMenuItem<MembershipStatus?>>((MembershipStatus? value) {
                    return DropdownMenuItem<MembershipStatus?>(
                      value: value,
                      child: Text(value == null ? 'All' : value.name.toUpperCase()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: memberService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : memberService.errorMessage != null
                ? Center(child: Text('Error: ${memberService.errorMessage}', style: TextStyle(color: Theme.of(context).colorScheme.error)))
                : allMemberships.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 80, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No membership renewals found!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Register new members or add renewals for existing ones.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // You could open the member registration dialog here or direct to members view
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Go to Members tab to add or renew.')),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Member / Renew'),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: allMemberships.length,
              itemBuilder: (context, index) {
                final membership = allMemberships[index];
                final member = memberService.members.firstWhere((m) => m.id == membership.memberId, orElse: () => Member(id: 'Unknown', firstName: 'Unknown', lastName: 'Member', email: '', createdAt: DateTime.now(), updatedAt: DateTime.now()));

                Color statusColor;
                switch (membership.status) {
                  case MembershipStatus.active:
                    statusColor = Colors.green;
                    break;
                  case MembershipStatus.expired:
                    statusColor = Colors.red;
                    break;
                  case MembershipStatus.pending:
                    statusColor = Colors.orange;
                    break;
                  case MembershipStatus.unknown:
                  default:
                    statusColor = Colors.grey;
                    break;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member: ${member.fullName}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(height: 15),
                        _buildInfoRow(context, Icons.calendar_today, 'Renewal Date:', _dateFormat.format(membership.renewalDate)),
                        _buildInfoRow(context, Icons.date_range, 'Membership Period:', '${_dateFormat.format(membership.startDate)} - ${_dateFormat.format(membership.endDate)}'),
                        _buildInfoRow(context, Icons.payments, 'Amount Paid:', _currencyFormat.format(membership.amountPaid)),
                        _buildInfoRow(
                          context,
                          Icons.info_outline,
                          'Status:',
                          membership.status.name.toUpperCase(),
                          valueColor: statusColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: valueColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}