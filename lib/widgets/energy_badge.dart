import 'package:flutter/material.dart';

import '../services/energy_service.dart';
import '../services/locale_service.dart';
import 'energy_modal_sheet.dart';

/// 상단 헤더에 들어가는 아담하고 직관적인 AI 잔여 에너지 배지
class EnergyBadge extends StatelessWidget {
  const EnergyBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.currentLocale,
      builder: (context, _, __) {
        return ValueListenableBuilder<bool>(
          valueListenable: EnergyService.isPro,
          builder: (context, isPro, _) {
            if (isPro) {
              return InkWell(
                onTap: () => EnergyModalSheet.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade600, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        LocaleService.tr('badge_pro_unlimited'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ValueListenableBuilder<int>(
              valueListenable: EnergyService.currentEnergy,
              builder: (context, energy, _) {
                final isLow = energy <= 2;
                final isZero = energy == 0;

                return InkWell(
                  onTap: () => EnergyModalSheet.show(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isZero
                          ? (isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50)
                          : isLow
                              ? (isDark ? Colors.orange.shade900.withValues(alpha: 0.3) : Colors.orange.shade50)
                              : (isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade50),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isZero
                            ? (isDark ? Colors.red.shade700 : Colors.red.shade300)
                            : isLow
                                ? (isDark ? Colors.orange.shade700 : Colors.orange.shade300)
                                : (isDark ? Colors.amber.shade700 : Colors.amber.shade400),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          color: isZero
                              ? Colors.red
                              : isLow
                                  ? Colors.deepOrange
                                  : (isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                          size: 14,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'AI $energy/${EnergyService.defaultDailyEnergy}',
                          style: TextStyle(
                            color: isZero
                                ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
                                : isLow
                                    ? (isDark ? Colors.orange.shade200 : Colors.deepOrange.shade900)
                                    : (isDark ? Colors.amber.shade200 : Colors.brown.shade800),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.add_circle,
                          size: 12,
                          color: isZero
                              ? Colors.red
                              : (isDark ? Colors.amber.shade300 : Colors.amber.shade800),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
