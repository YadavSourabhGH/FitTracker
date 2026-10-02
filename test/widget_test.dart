import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fittrackr/main.dart';
import 'package:fittrackr/data/models/user_settings.dart';
import 'package:fittrackr/presentation/screens/diet/widgets/diet_suggestions_view.dart';
import 'package:fittrackr/presentation/screens/insights/widgets/coach_insight_banner.dart';
import 'package:fittrackr/presentation/screens/insights/widgets/goal_progress_card.dart';
import 'package:fittrackr/presentation/screens/insights/widgets/weekly_distribution_bars.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('first launch shows onboarding profile form', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FitTrackrApp(initialOnboardingDone: false)));
    await tester.pump();
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Primary goal'), findsOneWidget);
  });

  testWidgets('onboarding validates the name field', (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: FitTrackrApp(initialOnboardingDone: false)));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);
  });

  testWidgets('weekly distribution renders one label per day', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WeeklyDistributionBars(
          values: [1000, 12000, 0, 8000, 9000, 3000, 500],
          labels: ['A', 'B', 'C', 'D', 'E', 'F', 'G'],
          goal: 8000,
        ),
      ),
    ));
    for (final l in ['A', 'B', 'C', 'D', 'E', 'F', 'G']) {
      expect(find.text(l), findsOneWidget);
    }
  });

  testWidgets('goal progress card shows remaining steps and edit action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: GoalProgressCard(
            currentSteps: 2500,
            targetSteps: 8000,
            percentage: 31.25,
            streakDays: 3,
            weekValues: const [0, 0, 0, 0, 0, 0, 2500],
            weekLabels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            onEditGoal: () => tapped = true,
          ),
        ),
      ),
    ));
    expect(find.text('5,500 steps left'), findsOneWidget);
    expect(find.text('3 day streak'), findsOneWidget);
    await tester.tap(find.text('Edit goal'));
    expect(tapped, isTrue);
  });

  testWidgets('diet suggestions filter by category', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: DietSuggestionsView(goal: FitnessGoal.gain)),
      ),
    ));
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Post-Workout Protein'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Fat Loss'));
    await tester.pump();
    expect(find.text('Post-Workout Protein'), findsNothing);
    expect(find.text('High-Volume Calorie Deficit'), findsOneWidget);
  });

  test('coach insight prioritises a scheduled workout', () {
    final insight = CoachInsight.from(
      steps: 1000,
      stepGoal: 8000,
      water: 4,
      waterGoal: 8,
      kcalEaten: 500,
      kcalTarget: 2200,
      workedOutToday: false,
      restDay: false,
      hour: 10,
    );
    expect(insight.targetTab, 1);
  });
}
