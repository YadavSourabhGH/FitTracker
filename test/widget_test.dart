import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:fittrackr/main.dart';
import 'package:fittrackr/presentation/screens/insights/widgets/health_overview_row.dart';
import 'package:fittrackr/presentation/screens/profile/widgets/goal_overview_card.dart';
import 'package:fittrackr/presentation/screens/diet/food_search_modal.dart';
import 'package:fittrackr/presentation/screens/diet/diet_screen.dart';
import 'package:fittrackr/presentation/screens/diet/widgets/diet_suggestions_view.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('FitTrackr app initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FitTrackrApp(initialOnboardingDone: true),
      ),
    );
    expect(find.byType(FitTrackrApp), findsOneWidget);
  });

  testWidgets('HealthOverviewRow shows dash for unmeasured sensor values', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HealthOverviewRow()),
      ),
    );
    expect(find.text('-'), findsNWidgets(4));
    expect(find.text('Heart Rate'), findsOneWidget);
    expect(find.textContaining('Sleep'), findsOneWidget);
    expect(find.text('Hydration'), findsOneWidget);
    expect(find.textContaining('SpO2'), findsOneWidget);
  });

  testWidgets('GoalOverviewCard displays streak and weekday dots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GoalOverviewCard(
            streakDays: 1,
            weekDots: [false, false, false, false, false, false, false],
            movePct: 0.2,
            exercisePct: 0.1,
            hydrationPct: 0.0,
          ),
        ),
      ),
    );
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Day Streak'), findsOneWidget);
    expect(find.text('W'), findsOneWidget);
  });

  testWidgets('FoodSearchModal renders popular healthy choices by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FoodSearchModal(onFoodSelected: (_) {}),
        ),
      ),
    );
    expect(find.text('Popular Nutritious Choices'), findsOneWidget);
    expect(find.text('Rolled Oats (100g)'), findsOneWidget);
    expect(find.text('Grilled Chicken Breast (150g)'), findsOneWidget);
    expect(find.text('Greek Yogurt 0% (200g)'), findsOneWidget);
  });

  testWidgets('DietSuggestionsView renders category filters and recommendation cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: DietSuggestionsView()),
        ),
      ),
    );
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Muscle Gain'), findsOneWidget);
    expect(find.text('Fat Loss'), findsOneWidget);
    expect(find.text('Post-Workout Anabolic Window'), findsOneWidget);
  });

  testWidgets('DietScreen switches between Track Meals and Diet Suggestions tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DietScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Track Meals'), findsOneWidget);
    expect(find.text('Diet Suggestions'), findsOneWidget);
    expect(find.text('Daily Calories'), findsOneWidget);

    await tester.tap(find.text('Diet Suggestions'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DietSuggestionsView), findsOneWidget);
    expect(find.text('Post-Workout Anabolic Window'), findsOneWidget);
  });
}
