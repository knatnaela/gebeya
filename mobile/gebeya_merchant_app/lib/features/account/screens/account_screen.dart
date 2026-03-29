import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../models/current_user.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const routeLocation = '/app/account';

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _isLoading = false;
  bool _syncedFields = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _syncFromUser(CurrentUser u) {
    _firstNameController.text = u.firstName ?? '';
    _lastNameController.text = u.lastName ?? '';
  }

  Future<void> _save() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
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
    final auth = ref.watch(authControllerProvider);
    final CurrentUser? user = switch (auth) {
      AuthAuthenticated(:final user) => user,
      AuthRequiresPasswordChange(:final user) => user,
      _ => null,
    };

    if (user != null && !_syncedFields) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _syncedFields) return;
        final latest = ref.read(authControllerProvider);
        final CurrentUser? u = switch (latest) {
          AuthAuthenticated(:final user) => user,
          AuthRequiresPasswordChange(:final user) => user,
          _ => null,
        };
        if (u != null) {
          _syncFromUser(u);
          _syncedFields = true;
        }
      });
    }

    return AppScaffold(
      title: 'Account',
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Email',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email cannot be changed here.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    controller: _firstNameController,
                    label: 'First name',
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) return 'First name is required';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _lastNameController,
                    label: 'Last name',
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Save',
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}
