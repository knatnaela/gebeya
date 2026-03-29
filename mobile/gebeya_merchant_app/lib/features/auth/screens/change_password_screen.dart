import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  static const routeLocation = '/change-password';

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .changePassword(oldPassword: _oldPasswordController.text, newPassword: _newPasswordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password changed. Please sign in again.')));
      context.go(LoginScreen.routeLocation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);

    return AppScaffold(
      title: 'Change password',
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'Enter your current password and choose a new password. You will need to sign in again.',
              style: hintStyle,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _oldPasswordController,
              label: 'Old password',
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) => (v ?? '').isEmpty ? 'Old password is required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _newPasswordController,
              label: 'New password',
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (v) {
                final value = v ?? '';
                if (value.isEmpty) return 'New password is required';
                if (value.length < 6) return 'Minimum 6 characters';
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: 'Update password', isLoading: _isLoading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
