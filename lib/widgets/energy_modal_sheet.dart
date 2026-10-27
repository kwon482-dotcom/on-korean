import 'package:flutter/material.dart';

import '../services/energy_service.dart';
import '../services/locale_service.dart';
import '../services/rewarded_ad_service.dart';

/// AI 에너지 충전 및 Pro 멤버십 안내 모달 바텀시트
class EnergyModalSheet extends StatefulWidget {
  const EnergyModalSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const EnergyModalSheet(),
    );
  }

  @override
  State<EnergyModalSheet> createState() => _EnergyModalSheetState();
}

class _EnergyModalSheetState extends State<EnergyModalSheet> {
  bool _isLoadingAd = false;
  bool _isLifetime = true; // 소장 패스 / 정기 구독 토글

  void _watchAdForReward() async {
    setState(() => _isLoadingAd = true);

    await RewardedAdService.showRewardedAd(
      onRewarded: () async {
        await EnergyService.addRewardEnergy();
        if (mounted) {
          setState(() => _isLoadingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.indigo.shade800,
              content: Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    LocaleService.tr('ad_reward_success'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        }
      },
      onDismissed: () {
        if (mounted) setState(() => _isLoadingAd = false);
      },
      onFailed: () {
        if (mounted) {
          setState(() => _isLoadingAd = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocaleService.tr('ad_load_failed')),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(16, 12, 16, 18 + bottomInset),
        child: ValueListenableBuilder<bool>(
          valueListenable: EnergyService.isPro,
          builder: (context, isPro, _) {
            return ValueListenableBuilder<int>(
              valueListenable: EnergyService.currentEnergy,
              builder: (context, energy, _) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 드래그 핸들 바
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF475569) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 헤더 타이틀
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF2C2208) : Colors.amber.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt, color: Colors.amber, size: 22),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  LocaleService.tr('ai_energy_modal_title'),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  LocaleService.tr('ai_energy_modal_desc'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: isDark ? const Color(0xFF94A3B8) : null,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 1. 현재 에너지 현황 카드 (여백 컴팩트화 및 오버플로우 방어)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPro
                                ? [Colors.indigo.shade800, Colors.deepPurple.shade700]
                                : (isDark
                                    ? [const Color(0xFF312E81), const Color(0xFF1E1B4B)]
                                    : [Colors.indigo.shade50, Colors.blue.shade50]),
                          ),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isPro
                                ? Colors.indigo
                                : (isDark ? const Color(0xFF4338CA) : Colors.indigo.shade100),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: (isPro ? Colors.amber : Colors.amber.shade700).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isPro ? Icons.workspace_premium : Icons.bolt,
                                color: isPro ? Colors.amber : Colors.amber.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isPro
                                        ? LocaleService.tr('pro_active_title')
                                        : LocaleService.tr('pro_energy_title'),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: isPro
                                          ? Colors.white70
                                          : (isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade900),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    isPro
                                        ? LocaleService.tr('pro_unlimited_status')
                                        : LocaleService.tr('pro_energy_count', [energy]),
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: isPro
                                          ? Colors.white
                                          : (isDark ? Colors.white : Colors.indigo.shade900),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (!isPro) ...[
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isLoadingAd ? null : _watchAdForReward,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade700,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoadingAd
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.play_circle_fill, size: 15),
                                          const SizedBox(width: 4),
                                          Text(
                                            LocaleService.tr('ad_reward_btn'),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 💡 에너지 차등 소모 규칙 안내 배너
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2208)
                              : Colors.amber.shade50.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF78350F) : Colors.amber.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 15,
                              color: isDark ? const Color(0xFFFBBF24) : Colors.amber.shade800,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                LocaleService.tr('ai_energy_rules'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? const Color(0xFFFDE68A) : Colors.brown.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 2. 멤버십 플랜 안내 헤더 & 토글
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                LocaleService.tr('pro_title'),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF312E81) : Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  LocaleService.tr('pro_coming_soon'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: _restorePurchases,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              Icons.restore,
                              size: 13,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                            ),
                            label: Text(
                              LocaleService.tr('pro_restore_purchases'),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 💡 [소장 패스] vs [정기 구독 (3일 무료)] 토글 세그먼트
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isLifetime = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _isLifetime ? Colors.indigo : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _isLifetime
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    LocaleService.tr('pro_lifetime_btn'),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: _isLifetime
                                          ? Colors.white
                                          : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _isLifetime = false),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: !_isLifetime ? Colors.indigo : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: !_isLifetime
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)]
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          LocaleService.tr('pro_monthly'),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: !_isLifetime
                                                ? Colors.white
                                                : (isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: !_isLifetime
                                              ? Colors.amber
                                              : (isDark ? const Color(0xFF064E3B) : Colors.green.shade100),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          LocaleService.tr('pro_monthly_trial'),
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.bold,
                                            color: !_isLifetime
                                                ? Colors.brown.shade900
                                                : (isDark ? const Color(0xFF6EE7B7) : Colors.green.shade800),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 💡 3단 요금 트리 카드 (플러스 / 프로 / 울트라) 나란히 배치
                      Row(
                        children: [
                          // 1. 플러스 (Plus: 단어 예문 집중)
                          Expanded(
                            child: _buildTierCard(
                              title: LocaleService.tr('pro_plus_title'),
                              badge: null,
                              subtitle: LocaleService.tr('pro_plus_desc'),
                              isHighlight: false,
                              cardColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                              borderColor: isDark ? const Color(0xFF334155) : Colors.grey.shade300,
                              onTap: _showPreparingSnackbar,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 6),

                          // 2. 프로 (Pro: 올인원 독해 - BEST 메인 주력)
                          Expanded(
                            child: _buildTierCard(
                              title: LocaleService.tr('pro_pro_title'),
                              badge: 'BEST',
                              badgeColor: Colors.amber.shade700,
                              subtitle: LocaleService.tr('pro_pro_desc'),
                              isHighlight: true,
                              cardColor: isDark
                                  ? const Color(0xFF1E1B4B)
                                  : Colors.indigo.shade50.withValues(alpha: 0.5),
                              borderColor: isDark ? const Color(0xFF6366F1) : Colors.indigo.shade400,
                              onTap: _showPreparingSnackbar,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 6),

                          // 3. 울트라 (Ultra: VIP 최신 AI)
                          Expanded(
                            child: _buildTierCard(
                              title: LocaleService.tr('pro_ultra_title'),
                              badge: 'VIP',
                              badgeColor: Colors.deepPurple,
                              subtitle: LocaleService.tr('pro_ultra_desc'),
                              isHighlight: false,
                              cardColor: isDark
                                  ? const Color(0xFF2E1065).withValues(alpha: 0.6)
                                  : Colors.purple.shade50.withValues(alpha: 0.4),
                              borderColor: isDark ? const Color(0xFF7C3AED) : Colors.purple.shade200,
                              onTap: _showPreparingSnackbar,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 공통 혜택 리스트 (컴팩트 카드)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: isDark ? Border.all(color: const Color(0xFF334155)) : null,
                        ),
                        child: Column(
                          children: [
                            _buildBenefitRow(Icons.block, LocaleService.tr('pro_benefit_1'), isDark),
                            const SizedBox(height: 5),
                            _buildBenefitRow(Icons.auto_awesome, LocaleService.tr('pro_benefit_2'), isDark),
                            const SizedBox(height: 5),
                            _buildBenefitRow(Icons.card_giftcard, LocaleService.tr('pro_benefit_3'), isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showPreparingSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleService.tr('pro_preparing_iap'))),
    );
  }

  void _restorePurchases() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleService.tr('pro_restore_result'))),
    );
  }

  Widget _buildTierCard({
    required String title,
    required String? badge,
    Color? badgeColor,
    required String subtitle,
    required bool isHighlight,
    required Color cardColor,
    required Color borderColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isHighlight ? 1.5 : 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isHighlight
                        ? (isDark ? const Color(0xFFA5B4FC) : Colors.indigo.shade900)
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.indigo,
                    borderRadius: BorderRadius.circular(3.5),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 25,
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade700,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isLifetime ? LocaleService.tr('pro_lifetime') : LocaleService.tr('pro_monthly'),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: isHighlight
                  ? (isDark ? const Color(0xFF818CF8) : Colors.indigo.shade700)
                  : (isDark ? const Color(0xFF64748B) : Colors.grey.shade600),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: isHighlight
                ? ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Text(
                      _isLifetime ? LocaleService.tr('btn_get_lifetime') : LocaleService.tr('btn_try_trial'),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : OutlinedButton(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                      side: BorderSide(
                        color: isDark ? const Color(0xFF475569) : Colors.grey.shade400,
                      ),
                      foregroundColor: isDark ? Colors.white : Colors.indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: Text(
                      _isLifetime ? LocaleService.tr('btn_get_lifetime') : LocaleService.tr('btn_try_trial'),
                      style: const TextStyle(fontSize: 10.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? const Color(0xFF818CF8) : Colors.indigo),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFCBD5E1) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
