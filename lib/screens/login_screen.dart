import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await AuthService.instance.signIn(
        _emailController.text,
        _passwordController.text,
      );
      
      if (success) {
        if (mounted) Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid credentials')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.jpg', height: 60),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicine Saver',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryAccent,
                            ),
                      ),
                      Text(
                        'Find affordable alternatives',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSubtle,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) => v!.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.key),
                ),
                validator: (v) => v!.length > 5 ? null : 'Min 6 chars',
              ),
              const SizedBox(height: 24),
              
              ListenableBuilder(
                listenable: AuthService.instance,
                builder: (context, _) {
                  return AuthService.instance.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primaryAccent,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Sign In'),
                          ),
                        );
                },
              ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {},
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
