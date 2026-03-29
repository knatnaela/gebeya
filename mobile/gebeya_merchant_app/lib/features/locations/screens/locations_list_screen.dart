import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/theme/app_icons.dart';
import '../../../core/ui/widgets/app_empty_view.dart';
import '../../../core/ui/widgets/app_error_view.dart';
import '../../../core/ui/widgets/app_loading_skeleton.dart';
import '../../../core/ui/widgets/app_scaffold.dart';
import '../../../models/location.dart';
import '../locations_repository.dart';
import 'location_form_screen.dart';

class LocationsListScreen extends ConsumerStatefulWidget {
  const LocationsListScreen({super.key});

  static const routeLocation = '/app/locations';

  @override
  ConsumerState<LocationsListScreen> createState() =>
      _LocationsListScreenState();
}

class _LocationsListScreenState extends ConsumerState<LocationsListScreen> {
  List<Location> _locations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(locationsRepositoryProvider).fetchLocations();
      if (mounted) {
        setState(() {
          _locations = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _setDefault(Location loc) async {
    try {
      await ref.read(locationsRepositoryProvider).setDefaultLocation(loc.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default location updated')),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not set default: $e')));
      }
    }
  }

  Future<void> _confirmDeactivate(Location loc) async {
    final activeCount = _locations.where((l) => l.isActive).length;
    final cannotDeactivate = loc.isDefault && activeCount == 1;
    if (cannotDeactivate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot deactivate the only active location.'),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deactivate location?'),
        content: const Text(
          'This will hide the location from selection. You can reactivate it later from edit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(locationsRepositoryProvider).deleteLocation(loc.id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location deactivated')));
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Locations',
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_locations',
        onPressed: () async {
          final changed = await context.push<bool>(
            LocationFormScreen.routeLocation,
          );
          if (changed == true && mounted) await _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add location'),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const AppLoadingSkeletonList(rows: 8);
    if (_error != null) {
      return AppErrorView(
        title: 'Could not load locations',
        message: _error,
        onRetry: _load,
      );
    }
    if (_locations.isEmpty) {
      return AppEmptyView(
        icon: AppIcons.location,
        title: 'No locations yet',
        message: 'Add a shop or warehouse to use it in sales and stock.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: _locations.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final loc = _locations[i];
          final activeCount = _locations.where((l) => l.isActive).length;
          final canDeactivate =
              loc.isActive && !(loc.isDefault && activeCount == 1);
          return ListTile(
            leading: Icon(
              loc.isDefault ? Icons.star : AppIcons.location,
              color: loc.isDefault
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            title: Text(loc.name),
            subtitle: Text(
              [
                if (loc.address != null && loc.address!.isNotEmpty)
                  loc.address!,
                if (!loc.isActive) 'Inactive',
              ].where((s) => s.isNotEmpty).join(' · '),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  final changed = await context.push<bool>(
                    '${LocationFormScreen.routeLocation}?id=${loc.id}',
                  );
                  if (changed == true && mounted) await _load();
                } else if (v == 'default') {
                  await _setDefault(loc);
                } else if (v == 'deactivate') {
                  await _confirmDeactivate(loc);
                }
              },
              itemBuilder: (context) => [
                if (!loc.isDefault && loc.isActive)
                  const PopupMenuItem(
                    value: 'default',
                    child: Text('Set as default'),
                  ),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canDeactivate)
                  const PopupMenuItem(
                    value: 'deactivate',
                    child: Text('Deactivate'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
