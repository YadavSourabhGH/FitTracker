import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'permission_rationale_screen.dart';

/// Onboarding Screen to configure athlete profile and daily targets.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _stepGoalController = TextEditingController();
  String _selectedGender = 'male';

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _stepGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveAndContinue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name to personalize telemetry'),
          backgroundColor: AppColors.primaryCoral,
        ),
      );
      return;
    }

    final weight = double.tryParse(_weightController.text.trim()) ?? 70.0;
    final stepGoal = int.tryParse(_stepGoalController.text.trim()) ?? 10000;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    await prefs.setDouble('user_weight', weight);
    await prefs.setInt('user_step_goal', stepGoal);
    await prefs.setString('user_gender', _selectedGender);
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PermissionRationaleScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Welcome to', style: AppTypography.bodyLarge),
              Text('FitTrackr', style: AppTypography.displayLarge.copyWith(color: AppColors.primaryCoral)),
              const SizedBox(height: 8),
              Text(
                'Personalize your real-time fitness metrics and daily step goals.',
                style: AppTypography.bodyLarge,
              ),
              const SizedBox(height: 32),

              _inputLabel('Athlete Name'),
              _textField(_nameController, 'e.g. Alex Hunter'),
              const SizedBox(height: 20),

              _inputLabel('Body Weight (kg)'),
              _textField(_weightController, 'e.g. 70', isNumber: true),
              const SizedBox(height: 20),

              _inputLabel('Daily Step Goal'),
              _textField(_stepGoalController, 'e.g. 10000', isNumber: true),
              const SizedBox(height: 20),

              _inputLabel('Biological Sex (for metabolic BMR calculation)'),
              Row(
                children: [
                  _genderChoice('male', 'Male', Icons.male),
                  const SizedBox(width: 12),
                  _genderChoice('female', 'Female', Icons.female),
                ],
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: _saveAndContinue,
                child: const Text('Continue to Health Permissions'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: AppTypography.titleMedium),
    );
  }

  Widget _textField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: AppTypography.bodyLarge.copyWith(color: AppColors.textHeadline, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }

  Widget _genderChoice(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryCoralLight : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primaryCoral : AppColors.textBody,
              ),
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
