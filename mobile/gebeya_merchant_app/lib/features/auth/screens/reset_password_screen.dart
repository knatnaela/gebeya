import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../widgets/auth_shell.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, this.initialToken});

  /// From deep link query `?token=` when supported.
  final String? initialToken;

  static const routeLocation = '/reset-password';

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset token is required')),
      );
      return;
    }

    final np = _newPasswordController.text;
    if (np.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    if (np != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).resetPassword(token: token, newPassword: np);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated. You can sign in now.')),
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
    final showTokenField = (widget.initialToken ?? '').isEmpty;

    return AuthShell(
      title: 'Set new password',
      subtitle: 'Choose a new password for your account.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTokenField) ...[
              AppTextField(
                controller: _tokenController,
                label: 'Reset token',
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Paste the token from your email' : null,
              ),
              const SizedBox(height: 12),
            ],
            AppTextField(
              controller: _newPasswordController,
              label: 'New password',
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return 'Password is required';
                if (value.length < 8) return 'At least 8 characters';
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
                if ((v ?? '').isEmpty) return 'Confirm your password';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Update password',
              isLoading: _isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(LoginScreen.routeLocation),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
