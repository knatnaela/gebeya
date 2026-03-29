import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../widgets/auth_shell.dart';
import 'login_screen.dart';

/// Telegram OTP step after [LoginScreen] phone flow (matches web `/login/verify-phone`).
class LoginGatewayVerifyScreen extends ConsumerStatefulWidget {
  const LoginGatewayVerifyScreen({super.key, this.requestId});

  static const routeLocation = '/login/verify-phone';

  /// Passed via [GoRouterState.extra] when opening from sign-in.
  final String? requestId;

  @override
  ConsumerState<LoginGatewayVerifyScreen> createState() => _LoginGatewayVerifyScreenState();
}

class _LoginGatewayVerifyScreenState extends ConsumerState<LoginGatewayVerifyScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final id = widget.requestId;
    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your sign-in session expired. Start again from sign in.')),
      );
      return;
    }
    final code = _otpController.text.trim();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the code from Telegram')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).gatewayLoginVerify(
            requestId: id,
            code: code,
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
    final id = widget.requestId;
    if (id == null || id.isEmpty) {
      return AuthShell(
        title: 'Verification',
        subtitle: 'No active phone sign-in session. Send a code from sign in first.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => context.go(LoginScreen.routeLocation),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      );
    }

    return AuthShell(
      title: 'Enter verification code',
      subtitle: 'Open Telegram and enter the code we sent for this number.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _otpController,
            label: 'Code from Telegram',
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _verify(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Continue',
            isLoading: _isLoading,
            onPressed: _verify,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => context.go(LoginScreen.routeLocation),
            child: const Text('Use a different number'),
          ),
        ],
      ),
    );
  }
}
