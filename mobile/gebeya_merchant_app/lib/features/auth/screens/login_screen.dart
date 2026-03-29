import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/phone/phone_api_payload.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import 'forgot_password_screen.dart';
import 'login_gateway_verify_screen.dart';
import 'merchant_signup_screen.dart';
import '../widgets/auth_shell.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const routeLocation = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _sendingCode = false;

  /// 0 = email + password, 1 = phone + Telegram code only
  int _mainTab = 0;

  String? _phoneE164;
  String _initialCountryCode = 'ET';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAuthConfig());
  }

  String _regionFromDeviceLocale() {
    final locale = Platform.localeName;
    final parts = locale.split(RegExp(r'[-_]'));
    if (parts.length >= 2) {
      return parts.last.toUpperCase();
    }
    return '';
  }

  Future<void> _loadAuthConfig() async {
    try {
      final codes = await ref.read(authRepositoryProvider).fetchAuthPublicConfig();
      if (!mounted) return;
      final region = _regionFromDeviceLocale();
      setState(() {
        if (region.length == 2 && codes.contains(region)) {
          _mainTab = 1;
          _initialCountryCode = region;
        } else if (codes.isNotEmpty) {
          _initialCountryCode = codes.first;
        }
      });
    } catch (_) {
      // keep defaults
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailPassword() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
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

  Future<void> _sendTelegramCode() async {
    final payload = PhoneApiPayload.merchantOrLocation(_phoneE164);
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid phone number')),
      );
      return;
    }
    setState(() => _sendingCode = true);
    try {
      final id = await ref.read(authControllerProvider.notifier).startGatewayLogin(
            phoneCountryIso: payload['phoneCountryIso']!,
            phoneNationalNumber: payload['phoneNationalNumber']!,
          );
      if (!mounted) return;
      if (id != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check Telegram for your verification code.')),
        );
        // Query `rid` is reliable across GoRouter versions; `extra` alone can fail for some builds.
        final uri = Uri(
          path: LoginGatewayVerifyScreen.routeLocation,
          queryParameters: {'rid': id},
        );
        context.push(uri.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('If an account exists for this number, a verification code was sent.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _sendingCode = false);
    }
  }

  void _onMainTabChanged(int tab) {
    setState(() {
      _mainTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthShell(
      title: 'Sign in',
      subtitle: _mainTab == 0
          ? 'Use your email and password.'
          : 'We’ll send a code to Telegram — you’ll enter it on the next screen.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Email')),
                ButtonSegment(value: 1, label: Text('Phone')),
              ],
              selected: {_mainTab},
              onSelectionChanged: (s) => _onMainTabChanged(s.first),
            ),
            const SizedBox(height: 16),
            if (_mainTab == 0) ...[
              AppTextField(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return 'Email is required';
                  if (!value.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (v) {
                  if ((v ?? '').isEmpty) return 'Password is required';
                  return null;
                },
                onFieldSubmitted: (_) => _submitEmailPassword(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Sign in',
                isLoading: _isLoading,
                onPressed: _submitEmailPassword,
              ),
            ] else ...[
              Text(
                'Enter the mobile number on your merchant account. After you tap Send code, you’ll enter the Telegram code on the next screen.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Phone number',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: _initialCountryCode,
                disableLengthCheck: true,
                onChanged: (phone) {
                  final c = phone.completeNumber.trim();
                  setState(() {
                    _phoneE164 = c.isEmpty ? null : (c.startsWith('+') ? c : '+$c');
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: _sendingCode ? null : _sendTelegramCode,
                  child: _sendingCode
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send code'),
                ),
              ),
            ],
            if (_mainTab == 0) ...[
              TextButton(
                onPressed: () => context.push(ForgotPasswordScreen.routeLocation),
                child: const Text('Forgot password?'),
              ),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go(MerchantSignupScreen.routeLocation),
              child: const Text('Register as Merchant'),
            ),
          ],
        ),
      ),
    );
  }
}
