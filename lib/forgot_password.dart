import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  bool _isLoading = false;

  // Brand Colors (Matches your App Theme)
  final Color _brandPurple = const Color(0xff7b3df0);
  final Color _brandBlue = const Color(0xff5fc3ff);

  Future<void> _sendResetLink() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // SENDING EMAIL REQUEST
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://google.com',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Check your Inbox"),
            content: Text(
              "If an account exists for $email, we have sent a password reset link.\n\n(Check your Spam folder too!)",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to Login
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Reset Password"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Header Icon ---
              Icon(Icons.mark_email_unread, size: 80, color: _brandPurple),

              const SizedBox(height: 20),

              // --- Title ---
              Text(
                "Forgot Password?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _brandPurple,
                ),
              ),

              const SizedBox(height: 10),

              // --- Subtitle ---
              const Text(
                "Enter your email and we will send you a reset link.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 30),

              // --- Input Field ---
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: Icon(Icons.email, color: _brandPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _brandPurple, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              const SizedBox(height: 24),

              // --- Gradient Button ---
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_brandPurple, _brandBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: _brandPurple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _isLoading ? null : _sendResetLink,
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Send Reset Email",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
