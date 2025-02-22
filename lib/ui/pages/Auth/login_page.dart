import 'package:face_recognition/ui/pages/dashboard_page.dart';
import 'package:flutter/material.dart';
import '../../../services/firebase_services.dart';
import '../../widgets/my_text_field.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final result = await AuthService().login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (mounted) {
        setState(() => loading = false); // Ensure loading stops

        if (result != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid email or password.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage("assets/logo_elkarooz.png"),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  buildTextField(emailController, "Email", false),
                  const SizedBox(height: 20),
                  buildTextField(passwordController, "Password", true),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        "Forgot your password?",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _login,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Login",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.red),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
