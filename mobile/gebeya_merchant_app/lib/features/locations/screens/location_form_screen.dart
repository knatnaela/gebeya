import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../../core/phone/phone_api_payload.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../locations_repository.dart';

class LocationFormScreen extends ConsumerStatefulWidget {
  const LocationFormScreen({super.key, this.locationId});

  static const routeLocation = '/app/locations/new';

  final String? locationId;

  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isActive = true;
  String? _phoneE164;
  String _phoneInitialCountry = 'ET';
  String _phoneInitialNational = '';
  bool _loading = false;
  bool _loadExisting = false;
  String? _loadError;

  bool get _isEdit =>
      widget.locationId != null && widget.locationId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loadExisting = true;
      _load();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final loc = await ref
          .read(locationsRepositoryProvider)
          .fetchLocation(widget.locationId!);
      if (!mounted) return;
      _phoneInitialCountry = 'ET';
      _phoneInitialNational = '';
      _phoneE164 = null;
      final raw = loc.phone;
      if (raw != null && raw.trim().isNotEmpty) {
        try {
          final normalized = raw.trim().startsWith('+') ? raw.trim() : '+${raw.trim()}';
          final p = PhoneNumber.parse(normalized);
          if (p.isValid()) {
            _phoneInitialCountry = p.isoCode.name;
            _phoneInitialNational = p.nsn;
            _phoneE164 = '+${p.countryCode}${p.nsn}';
          }
        } catch (_) {}
      }
      setState(() {
        _nameController.text = loc.name;
        _addressController.text = loc.address ?? '';
        _isActive = loc.isActive;
        _loadExisting = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e.toString();
          _loadExisting = false;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final repo = ref.read(locationsRepositoryProvider);
      final p = PhoneApiPayload.merchantOrLocation(_phoneE164);
      if (_isEdit) {
        await repo.updateLocation(
          widget.locationId!,
          name: _nameController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phoneCountryIso: p?['phoneCountryIso'] ?? '',
          phoneNationalNumber: p?['phoneNationalNumber'] ?? '',
          phone: p?['phone'] ?? '',
          isActive: _isActive,
        );
      } else {
        await repo.createLocation(
          name: _nameController.text.trim(),
          address: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          phoneCountryIso: p?['phoneCountryIso'],
          phoneNationalNumber: p?['phoneNationalNumber'],
          phone: p?['phone'],
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEdit ? 'Location updated' : 'Location created'),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadExisting) {
      return AppScaffold(
        title: _isEdit ? 'Edit location' : 'New location',
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_loadError != null) {
      return AppScaffold(
        title: 'Location',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_loadError!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return AppScaffold(
      title: _isEdit ? 'Edit location' : 'New location',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Name',
              hintText: 'Shop or warehouse name',
              outlined: true,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            IntlPhoneField(
              key: ValueKey(
                '${widget.locationId ?? 'new'}_$_phoneInitialCountry$_phoneInitialNational',
              ),
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Optional',
                border: OutlineInputBorder(),
              ),
              initialCountryCode: _phoneInitialCountry,
              initialValue: _phoneInitialNational,
              disableLengthCheck: true,
              onChanged: (phone) {
                final c = phone.completeNumber.trim();
                setState(() {
                  _phoneE164 = c.isEmpty ? null : (c.startsWith('+') ? c : '+$c');
                });
              },
            ),
            if (_isEdit) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                subtitle: const Text(
                  'Inactive locations are hidden from selection',
                ),
                value: _isActive,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _isActive = v),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _isEdit ? 'Save' : 'Create',
              isLoading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
