// lib/models/member.dart
import 'package:uuid/uuid.dart'; // Make sure to add this dependency

enum MembershipStatus { active, expired, pending, unknown }

class Member {
  final String id; // This will link to Supabase auth.users.id
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Membership> memberships; // Aggregated membership history

  Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.createdAt,
    required this.updatedAt,
    this.memberships = const [],
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      memberships: (json['memberships'] as List<dynamic>?)
          ?.map((m) => Membership.fromJson(m as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  // Method to create a new member without an existing ID (for registration)
  factory Member.newMember({
    required String firstName,
    required String lastName,
    required String email,
    String? phoneNumber,
    String? address,
  }) {
    final now = DateTime.now();
    return Member(
      id: const Uuid().v4(), // Placeholder ID, will be replaced by Supabase Auth ID
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      createdAt: now,
      updatedAt: now,
    );
  }

  Member copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Membership>? memberships,
  }) {
    return Member(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberships: memberships ?? this.memberships,
    );
  }

  String get fullName => '$firstName $lastName';
  Membership? get currentMembership => memberships.isNotEmpty
      ? memberships.firstWhere(
          (m) => m.status == MembershipStatus.active && m.endDate.isAfter(DateTime.now()),
      orElse: () => memberships.reduce((a, b) => a.endDate.isAfter(b.endDate) ? a : b)
  ) // Get the latest valid or simply the latest
      : null;

  MembershipStatus get overallStatus {
    final latestMembership = currentMembership;
    if (latestMembership == null) return MembershipStatus.expired; // No memberships found

    if (latestMembership.endDate.isAfter(DateTime.now())) {
      return MembershipStatus.active;
    } else {
      return MembershipStatus.expired;
    }
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Membership {
  final String id;
  final String memberId;
  final DateTime startDate;
  final DateTime endDate;
  final double amountPaid;
  final DateTime renewalDate;
  final MembershipStatus status;

  Membership({
    required this.id,
    required this.memberId,
    required this.startDate,
    required this.endDate,
    required this.amountPaid,
    required this.renewalDate,
    this.status = MembershipStatus.active,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    MembershipStatus status;
    switch (json['status'] as String) {
      case 'active':
        status = MembershipStatus.active;
        break;
      case 'expired':
        status = MembershipStatus.expired;
        break;
      case 'pending':
        status = MembershipStatus.pending;
        break;
      default:
        status = MembershipStatus.unknown;
    }

    return Membership(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      renewalDate: DateTime.parse(json['renewal_date'] as String),
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'start_date': startDate.toIso8601String().split('T').first, // Only date part
      'end_date': endDate.toIso8601String().split('T').first,   // Only date part
      'amount_paid': amountPaid,
      'renewal_date': renewalDate.toIso8601String(),
      'status': status.name,
    };
  }
}