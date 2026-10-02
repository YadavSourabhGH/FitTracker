import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_keys.dart';
import '../../common_widgets/ui_kit.dart';
import '../../providers/app_providers.dart';
import '../../providers/nutrition_providers.dart';
import 'profile_editor.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: ProfileEditor(
            initial: settings,
            submitLabel: 'Save changes',
            onSubmit: (next) async {
              if ((next.weightKg - settings.weightKg).abs() > 0.01) {
                await ref.read(hydrationRepositoryProvider).logWeight(DateKeys.today(), next.weightKg);
                ref.invalidate(weightHistoryProvider);
              }
              await ref.read(settingsProvider.notifier).save(next);
              if (context.mounted) {
                showAppSnack(context, 'Profile updated');
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
