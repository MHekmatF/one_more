import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'home.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;

  Future<void> signUp() async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        print('✅ التسجيل ناجح!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم التسجيل بنجاح!')),
        );
        print(response);
        print("sss");
        print(response.session);
        print("sss");
print(response.session?.user);
        print("sss");
        print(response.session?.accessToken);
        print("sss");
        print(response.user);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));
      }
    } catch (error) {
      print('❌ خطأ في التسجيل: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء التسجيل: $error')),
      );
    }
  }

  Future<void> signIn() async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.session != null) {
        print('✅ تم تسجيل الدخول بنجاح!');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تسجيل الدخول بنجاح!')),
        );
        print(response);
        print("sss");
        print(response.session);
        print("sss");
        print(response.session?.user);
        print("sss");
        print(response.session?.accessToken);
        print("sss");
        print(response.user);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home(),));

      }
    } catch (error) {
      print('❌ خطأ في تسجيل الدخول: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التسجيل وتسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'الإيميل'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('تسجيل'),
            ),
            ElevatedButton(
              onPressed: signIn,
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}
