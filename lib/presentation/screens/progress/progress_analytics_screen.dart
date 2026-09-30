import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_theme.dart';

/// Progress Analytics Screen displaying volume load charts and estimated 1RM trends.
class ProgressAnalyticsScreen extends StatefulWidget {
  const ProgressAnalyticsScreen({super.key});

  @override
  State<ProgressAnalyticsScreen> createState() => _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState extends State<ProgressAnalyticsScreen> {
  String _selectedRange = '30D';
  final _ranges = ['7D', '30D', '90D', '1Y'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBase,
      appBar: AppBar(
        title: Text('Progress Analytics', style: AppTypography.headlineMedium),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Time Range Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _ranges.map((r) {
                final isSelected = _selectedRange == r;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRange = r),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryCoral : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primaryCoral : AppColors.cardBorder),
                    ),
                    child: Text(
                      r,
                      style: AppTypography.titleMedium.copyWith(
                        color: isSelected ? Colors.white : AppColors.textBody,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Volume Load Bar Chart Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly Volume Load (kg)', style: AppTypography.titleLarge),
                  const SizedBox(height: 4),
                  Text('Tonnage lifted across all compound sets', style: AppTypography.bodyMedium),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                const labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
                                if (v.toInt() < labels.length) {
                                  return Text(labels[v.toInt()], style: AppTypography.labelSmall);
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          _bar(0, 14200),
                          _bar(1, 16800),
                          _bar(2, 15400),
                          _bar(3, 18900),
                          _bar(4, 21500),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 1RM Bench Press Progression Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Estimated 1RM: Barbell Bench Press', style: AppTypography.titleLarge),
                  const SizedBox(height: 4),
                  Text('Calculated via Brzycki formula from top working sets', style: AppTypography.bodyMedium),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: AppColors.primaryCoral,
                            barWidth: 3.5,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryCoralLight.withValues(alpha: 0.5),
                            ),
                            spots: const [
                              FlSpot(0, 85),
                              FlSpot(1, 87.5),
                              FlSpot(2, 90),
                              FlSpot(3, 92.5),
                              FlSpot(4, 95),
                              FlSpot(5, 100),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primaryCoral,
          width: 22,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }
}
