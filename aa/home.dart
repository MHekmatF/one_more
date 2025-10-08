import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _AuthPageState();
}

class _AuthPageState extends State<Home> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _supabase = Supabase.instance.client;


  insert() async {
    try {
      final response = await Supabase.instance.client.from('items').insert({
        "email": _emailController.text,
        "age": _ageController.text,
        "name": _nameController.text,
        "password": _passwordController.text,
      });

      if (response != null) {


        print('Task added successfully!');

        // getdata();
      } else {
        print('Error: ${response}');
      }
    } catch (e) {
      print("Unexpected error: $e");
    }
  }
  var data ;
  Future<void> getdata() async {
    try {
      final response =
      await Supabase.instance.client.from('items').select('name,email');

      if (response != null && response.isNotEmpty) {

        setState(() {data=response;

        });
        print("Data fetched successfully!");
        print(data);
      } else {
        print("No data found.");
      }
    } catch (error) {
      print("Error fetching data: $error");
    }
  }

//لاستخراج  id من اي مكان
// Supabase.instance.client.auth.currentUser;
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
            ),            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'العمر'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: insert,
              child: const Text('ارسال'),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: getdata,
              child: const Text('استقبال'),
            ),  Expanded(
              child: ListView.builder(itemBuilder: (context, index) {
                return Row(children: [Text(data[index]['name']??"d"),SizedBox(width: 50,),Text(data[index]["email"]??"sa")],);
              },itemCount: data.length,),
            ),
          ],
        ),
      ),
    );
  }
}
