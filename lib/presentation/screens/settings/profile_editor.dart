import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/user_settings.dart';

/// Shared profile/goal form used by onboarding and "Edit profile".
class ProfileEditor extends StatefulWidget {
  final UserSettings initial;
  final String submitLabel;
  final bool showGoals;
  final Future<void> Function(UserSettings) onSubmit;

  const ProfileEditor({
    super.key,
    required this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.showGoals = true,
  });

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _steps;
  late String _sex;
  late FitnessGoal _goal;
  late String _activity;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _name = TextEditingController(text: s.name == 'Athlete' ? '' : s.name);
    _age = TextEditingController(text: '${s.age}');
    _height = TextEditingController(text: s.heightCm.round().toString());
    _weight = TextEditingController(text: s.weightKg.toString().replaceAll(RegExp(r'\.0$'), ''));
    _steps = TextEditingController(text: '${s.stepGoal}');
    _sex = s.sex;
    _goal = s.goal;
    _activity = s.activityLevelId;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    _steps.dispose();
    super.dispose();
  }

  String? _range(String? v, num min, num max, String label) {
    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
    if (n == null) return 'Enter your $label';
    if (n < min || n > max) return '$label must be between $min and $max';
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final next = widget.initial.copyWith(
      name: _name.text.trim(),
      sex: _sex,
      age: int.parse(_age.text.trim()),
      heightCm: double.parse(_height.text.trim().replaceAll(',', '.')),
      weightKg: double.parse(_weight.text.trim().replaceAll(',', '.')),
      stepGoal: int.parse(_steps.text.trim()),
      goal: _goal,
      activityLevelId: _activity,
    );
    try {
      await widget.onSubmit(next);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    final decimal = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Name'),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'e.g. Alex Hunter'),
            validator: (v) => (v ?? '').trim().isEmpty ? 'Please enter your name' : null,
          ),
          const SizedBox(height: 16),
          _label('Sex (used for BMR)'),
          Row(
            children: [
              _choice('male', 'Male', Icons.male),
              const SizedBox(width: 12),
              _choice('female', 'Female', Icons.female),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Age'),
                    TextFormField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      decoration: const InputDecoration(suffixText: 'yrs'),
                      validator: (v) => _range(v, 13, 100, 'Age'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Height'),
                    TextFormField(
                      controller: _height,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: decimal,
                      decoration: const InputDecoration(suffixText: 'cm'),
                      validator: (v) => _range(v, 100, 250, 'Height'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Weight'),
                    TextFormField(
                      controller: _weight,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: decimal,
                      decoration: const InputDecoration(suffixText: 'kg'),
                      validator: (v) => _range(v, 25, 350, 'Weight'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.showGoals) ...[
            const SizedBox(height: 16),
            _label('Daily step goal'),
            TextFormField(
              controller: _steps,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              decoration: const InputDecoration(suffixText: 'steps'),
              validator: (v) => _range(v, 1000, 50000, 'Step goal'),
            ),
            const SizedBox(height: 16),
            _label('Primary goal'),
            Wrap(
              spacing: 8,
              children: FitnessGoal.values
                  .map((g) => ChoiceChip(
                        label: Text(g.label),
                        selected: _goal == g,
                        showCheckmark: false,
                        selectedColor: AppColors.primaryCoral,
                        labelStyle: AppTypography.titleMedium.copyWith(
                          fontSize: 12,
                          color: _goal == g ? Colors.white : AppColors.textHeadline,
                        ),
                        onSelected: (_) => setState(() => _goal = g),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            _label('Activity level'),
            ...ActivityLevel.all.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: _activity == a.id ? AppColors.primaryCoralLight : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _activity = a.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _activity == a.id ? AppColors.primaryCoral : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _activity == a.id ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 18,
                            color: _activity == a.id ? AppColors.primaryCoral : AppColors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.label, style: AppTypography.titleMedium.copyWith(fontSize: 13)),
                                Text(a.description, style: AppTypography.bodyMedium.copyWith(fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTypography.titleMedium),
      );

  Widget _choice(String value, String label, IconData icon) {
    final isSelected = _sex == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _sex = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryCoralLight : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? AppColors.primaryCoral : AppColors.textBody),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTypography.titleMedium.copyWith(
                  color: isSelected ? AppColors.primaryCoral : AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
