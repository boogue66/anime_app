import 'package:anime_app/models/user_model.dart';
import 'package:anime_app/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController emailController = TextEditingController();

    final userState = ref.watch(userProvider);

    ref.listen<AsyncValue<User?>>(userProvider, (previous, next) {
      if (next.hasValue && next.value != null) {
        // Login successful, navigate to home
        context.go('/home');
      } else if (next.hasError) {
        // Show error message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),

            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: userState.isLoading
                  ? null
                  : () {
                      ref
                          .read(userProvider.notifier)
                          .login(emailController.text);
                    },
              child: userState.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: () {
                context.go('/register');
              },
              child: const Text("Don't have an account? Register here."),
            ),
          ],
        ),
      ),
    );
  }
}
