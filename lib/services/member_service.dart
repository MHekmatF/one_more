// lib/services/member_service.dart
import 'package:flutter/material.dart';
import 'package:one_more/models/member.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../widgets/dialogs/register_member_dialog.dart';
import '../widgets/dialogs/renew_membership_dialog.dart'; // For generating UUIDs for new memberships


class MemberService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Member> _members = [];
  bool _isLoading = false;
  String? _errorMessage;
  Member? _selectedMember;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Member? get selectedMember => _selectedMember;
  // Add a BuildContext to the constructor or methods that need it for UI feedback
  final BuildContext _context; // Make it nullable if not always available
  // Constructor for optionally providing context
  MemberService(this._context) { // Constructor requires context
    fetchMembers();
  }
  void _showSnackBar(String message, {bool isError = false}) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(_context!).colorScheme.error : Theme.of(_context!).primaryColor,
          behavior: SnackBarBehavior.floating, // For desktop-like floating snackbar
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void selectMember(Member? member) {
    _selectedMember = member;
    notifyListeners();
  }

  Future<void> fetchMembers() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _supabase
          .from('members')
          .select('*, memberships(*)')
          .order('first_name', ascending: true);

      _members = (response as List).map((json) => Member.fromJson(json)).toList();
      _setLoading(false);
      // _showSnackBar('Members loaded successfully!', isError: false); // Optional: Success message
    } catch (e) {
      _setErrorMessage('Failed to load members: $e');
      _showSnackBar('Failed to load members.', isError: true);
      _setLoading(false);
    }
  }

  Future<void> registerMember({
    required String firstName,
    required String lastName,
    required String email,
    required String password, // Initial password for the member
    String? phoneNumber,
    String? address,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final AuthResponse res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user == null) {
        throw 'Supabase user creation failed.'; // This error will be caught below
      }
      await _supabase.from('members').insert({
        'id': res.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'address': address,
      });
      // Refresh the list of members
      await fetchMembers();
      _showSnackBar('Member registered successfully!', isError: false);
      _setLoading(false);



    } on AuthException catch (e) {
      _setErrorMessage('Registration failed: ${e.message}');      _showSnackBar('Registration failed: ${e.message}', isError: true);

      _setLoading(false);
      rethrow; // Re-throw to show error in UI
    } catch (e) {
      _setErrorMessage('An unexpected error occurred during registration: $e');      _showSnackBar('An unexpected error occurred: $e', isError: true);

      _setLoading(false);
      rethrow; // Re-throw to show error in UI
    }
  }

  Future<void> renewMembership({
    required String memberId,
    required DateTime startDate,
    required DateTime endDate,
    required double amountPaid,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final now = DateTime.now();
      await _supabase.from('memberships').insert({
        'id': const Uuid().v4(),
        'member_id': memberId,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'amount_paid': amountPaid,
        'renewal_date': now.toIso8601String(),
        'status': 'active',
      });

      // Refresh members and select the current one to update its history
      await fetchMembers();
      if (_selectedMember != null && _selectedMember!.id == memberId) {
        final updatedMember = _members.firstWhere((m) => m.id == memberId);
        selectMember(updatedMember);
      }
      _showSnackBar('Membership renewed successfully!', isError: false);
      _setLoading(false);
    } catch (e) {
      _setErrorMessage('Failed to renew membership: $e');
      _showSnackBar('Failed to renew membership: $e', isError: true);
      _setLoading(false);
      rethrow;
    }
  }


  // --- Dialog helpers ---
  void showRegisterMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext here
        return RegisterMemberDialog();
      },
    );
  }

  void showRenewMembershipDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext here
        return RenewMembershipDialog(member: member);
      },
    );
  }
}