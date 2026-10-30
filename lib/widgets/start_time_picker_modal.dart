import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../models/ticker_type.dart';
import '../providers/hodl_provider.dart';

class StartTimePickerModal extends StatefulWidget {
  final TickerType ticker;

  const StartTimePickerModal({
    super.key,
    required this.ticker,
  });

  static Future<void> show(BuildContext context, TickerType ticker) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StartTimePickerModal(ticker: ticker),
    );
  }

  @override
  State<StartTimePickerModal> createState() => _StartTimePickerModalState();
}

class _StartTimePickerModalState extends State<StartTimePickerModal> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    final provider = context.read<HodlProvider>();
    final currentStart = widget.ticker == TickerType.ttalspi
        ? provider.ttalspiStartTime
        : provider.yadongspiStartTime;
    _selectedDateTime = currentStart ?? DateTime.now();
  }

  void _applyPreset(Duration offset) {
    setState(() {
      _selectedDateTime = DateTime.now().subtract(offset);
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime.isAfter(now) ? now : _selectedDateTime,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _selectedDateTime.hour,
        minute: _selectedDateTime.minute,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: Colors.black,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      final newCandidate = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (newCandidate.isAfter(now)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.cardSurface,
              content: Text(
                '미래 시각은 선택할 수 없습니다.',
                style: TextStyle(color: AppColors.electricRed),
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedDateTime = newCandidate;
      });
    }
  }

  void _save(HodlProvider provider) async {
    final now = DateTime.now();
    if (_selectedDateTime.isAfter(now)) {
      _selectedDateTime = now;
    }

    await provider.updateStartTime(widget.ticker, _selectedDateTime);

    if (mounted) {
      Navigator.pop(context);
      final elapsed = now.difference(_selectedDateTime);
      final days = elapsed.inDays;
      final hours = elapsed.inHours % 24;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardSurface,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.ticker.nameKo} 타이머가 $days일 $hours시간 전으로 재설정되었습니다!',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final ticker = widget.ticker;
    final now = DateTime.now();
    final calculatedDuration = now.difference(_selectedDateTime);
    final calculatedDays = calculatedDuration.inDays;
    final calculatedHours = calculatedDuration.inHours % 24;
    final calculatedMinutes = calculatedDuration.inMinutes % 60;

    final isTtal = ticker == TickerType.ttalspi;
    final actionLabel = isTtal ? '마지막 발사 시점' : '마지막 야동 시청 시점';

    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(ticker.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '${ticker.nameKo} $actionLabel 설정',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '실제 본인이 $actionLabel을 지정하면, 그 시점부터 계산되어 타이머와 포인트가 개별적으로 돌아갑니다.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Result Preview Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '선택한 $actionLabel',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      DateFormat('yyyy.MM.dd (E) HH:mm', 'ko').format(_selectedDateTime),
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '적용 시 존버 시간',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      '$calculatedDays일 $calculatedHours시간 $calculatedMinutes분 존버',
                      style: const TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Presets
          const Text(
            '빠른 선택 프리셋',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPresetChip('방금 전', const Duration(minutes: 0)),
              _buildPresetChip('오늘 자정 (0시)', Duration(
                hours: now.hour,
                minutes: now.minute,
                seconds: now.second,
              )),
              _buildPresetChip('1일 전', const Duration(days: 1)),
              _buildPresetChip('2일 전', const Duration(days: 2)),
              _buildPresetChip('3일 전', const Duration(days: 3)),
              _buildPresetChip('5일 전', const Duration(days: 5)),
              _buildPresetChip('7일 전 (1주)', const Duration(days: 7)),
              _buildPresetChip('14일 전 (2주)', const Duration(days: 14)),
              _buildPresetChip('30일 전 (1달)', const Duration(days: 30)),
            ],
          ),
          const SizedBox(height: 16),

          // Direct Date / Time Picker Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month, color: AppColors.gold, size: 18),
                  label: Text(DateFormat('yyyy.MM.dd').format(_selectedDateTime)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _pickTime,
                  icon: const Icon(Icons.access_time, color: AppColors.gold, size: 18),
                  label: Text(DateFormat('HH:mm').format(_selectedDateTime)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Submit Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _save(provider),
            child: Text(
              '${ticker.nameKo} 타이머에 적용하기',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, Duration offset) {
    return InkWell(
      onTap: () => _applyPreset(offset),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
