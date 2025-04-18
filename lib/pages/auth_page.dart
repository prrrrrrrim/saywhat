import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(); // Add this if using password

  bool _isLoading = false;
  bool _isSignUp = true;

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;

      if (_isSignUp) {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
      } else {
        userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
      }

      // ✅ Show success pop-up
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Success 🎉"),
          content: Text(
            _isSignUp
                ? 'Account created for ${userCredential.user!.email}'
                : 'Welcome back, ${userCredential.user!.email}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // ❌ Show error pop-up
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Login Failed ❌"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Center(
                child: const Text(
                  'Say What',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Create an account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your email to sign up for this app',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle email auth or navigate to OTP/password
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue'),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('or'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Handle Google Sign In
                  },
                  icon: Image.asset(
                    'assets/google.png', // Make sure this image exists
                    height: 24,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'By clicking continue, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

