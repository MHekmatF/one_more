// lib/screens/dashboard/members/members_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/member.dart';
import '../../../services/member_service.dart';



class MembersView extends StatelessWidget {
  const MembersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Member List (left panel)
        const SizedBox(
          width: 300, // Fixed width for the member list
          child: MembersListView(),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        // Member Details (right panel)
        Expanded(
          child: MemberDetailsView(),
        ),
      ],
    );
  }
}

// --- Member List Widget ---
class MembersListView extends StatelessWidget {
  const MembersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final memberService = Provider.of<MemberService>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search members...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
            onChanged: (query) {
              // TODO: Implement search/filter logic for members list
              print('Search query: $query');
            },
          ),
        ),
        Expanded(
          child: memberService.isLoading
              ? const Center(child: CircularProgressIndicator())
              : memberService.errorMessage != null
              ? Center(child: Text('Error: ${memberService.errorMessage}', style: TextStyle(color: Theme.of(context).colorScheme.error))) // Themed error text
              : memberService.members.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_alt_outlined, size: 80, color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'No members registered yet!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Click the "+" button to add your first member.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6)),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: memberService.members.length,
            itemBuilder: (context, index) {
              final member = memberService.members[index];
              final isSelected = memberService.selectedMember?.id == member.id;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: isSelected ? Colors.blue.shade50 : null,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(member.fullName),
                  subtitle: Text(member.email),
                  trailing: Icon(
                    member.overallStatus == MembershipStatus.active
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: member.overallStatus == MembershipStatus.active
                        ? Colors.green
                        : Colors.red,
                  ),
                  onTap: () {
                    memberService.selectMember(member);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- Member Details Widget ---
class MemberDetailsView extends StatelessWidget {
  MemberDetailsView({super.key});

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final memberService = Provider.of<MemberService>(context);
    final selectedMember = memberService.selectedMember;

    if (memberService.isLoading && selectedMember == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedMember == null) {
      return const Center(
        child: Text(
          'Select a member from the list to view their details.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedMember.fullName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  memberService.showRenewMembershipDialog(context, selectedMember);
                },
                icon: const Icon(Icons.add_task),
                label: const Text('Renew Membership'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailCard(
            context,
            'Contact Information',
            [
              _buildDetailRow(context, Icons.email, 'Email:', selectedMember.email),
              _buildDetailRow(context, Icons.phone, 'Phone:', selectedMember.phoneNumber ?? 'N/A'),
              _buildDetailRow(context, Icons.home, 'Address:', selectedMember.address ?? 'N/A'),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailCard(
            context,
            'Membership Status',
            [
              _buildDetailRow(context, Icons.calendar_today, 'Registered On:', _dateFormat.format(selectedMember.createdAt)),
              _buildDetailRow(
                context,
                selectedMember.overallStatus == MembershipStatus.active ? Icons.check_circle : Icons.warning,
                'Status:',
                selectedMember.overallStatus.name.toUpperCase(),
                valueColor: selectedMember.overallStatus == MembershipStatus.active ? Colors.green : Colors.red,
              ),
              if (selectedMember.currentMembership != null)
                _buildDetailRow(context, Icons.event, 'Expires On:', _dateFormat.format(selectedMember.currentMembership!.endDate)),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Membership History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          selectedMember.memberships.isEmpty
              ? const Text('No membership history available.')
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: selectedMember.memberships.length,
            itemBuilder: (context, index) {
              final membership = selectedMember.memberships[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Renewal ${_dateFormat.format(membership.renewalDate)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      _buildDetailRow(context, Icons.date_range, 'Period:', '${_dateFormat.format(membership.startDate)} - ${_dateFormat.format(membership.endDate)}'),
                      _buildDetailRow(context, Icons.money, 'Amount Paid:', _currencyFormat.format(membership.amountPaid)),
                      _buildDetailRow(
                        context,
                        Icons.info_outline,
                        'Status:',
                        membership.status.name.toUpperCase(),
                        valueColor: membership.status == MembershipStatus.active ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
// Continue from lib/screens/dashboard/members/members_view.dart inside MemberDetailsView class
  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          SizedBox(
            width: 120, // Adjust width as needed for labels
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDetailCard(BuildContext context, String title, List<Widget> children) {
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20, thickness: 1),
              ...children,
            ],
          ),
        ));}

} // End of MemberDetailsView class
