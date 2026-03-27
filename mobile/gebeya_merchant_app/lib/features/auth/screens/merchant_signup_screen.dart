import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../widgets/auth_shell.dart';
import 'login_screen.dart';

class MerchantSignupScreen extends ConsumerStatefulWidget {
  const MerchantSignupScreen({super.key});

  static const routeLocation = '/signup';

  @override
  ConsumerState<MerchantSignupScreen> createState() =>
      _MerchantSignupScreenState();
}

class _MerchantSignupScreenState extends ConsumerState<MerchantSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessAddressController = TextEditingController();

  final _adminFirstNameController = TextEditingController();
  final _adminLastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _businessAddressController.dispose();
    _adminFirstNameController.dispose();
    _adminLastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).merchantRegister(
            businessName: _businessNameController.text.trim(),
            businessEmail: _businessEmailController.text.trim(),
            businessPhone: _businessPhoneController.text.trim().isEmpty
                ? null
                : _businessPhoneController.text.trim(),
            businessAddress: _businessAddressController.text.trim().isEmpty
                ? null
                : _businessAddressController.text.trim(),
            adminFirstName: _adminFirstNameController.text.trim(),
            adminLastName: _adminLastNameController.text.trim().isEmpty
                ? null
                : _adminLastNameController.text.trim(),
            adminPassword: _passwordController.text,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted. Awaiting approval.'),
        ),
      );
      context.go(LoginScreen.routeLocation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Register as Merchant',
      subtitle: 'Submit your business details. You’ll be approved by an owner.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Business info',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _businessNameController,
              label: 'Business name',
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Business name is required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _businessEmailController,
              label: 'Business email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Business email is required';
                if (!value.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _businessPhoneController,
              label: 'Phone (optional)',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _businessAddressController,
              label: 'Address (optional)',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            Text(
              'Admin user',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            AppTextField(
              controller: _adminFirstNameController,
              label: 'First name',
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'First name is required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _adminLastNameController,
              label: 'Last name (optional)',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return 'Password is required';
                if (value.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'Confirm password',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return 'Confirm your password';
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Register',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(LoginScreen.routeLocation),
              child: const Text('Already have an account? Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

