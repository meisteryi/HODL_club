import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../models/liquidation_record.dart';

class RelapseCalendarWidget extends StatefulWidget {
  final List<LiquidationRecord> records;
  final Function(LiquidationRecord record)? onRecordTap;

  const RelapseCalendarWidget({
    super.key,
    required this.records,
    this.onRecordTap,
  });

  @override
  State<RelapseCalendarWidget> createState() => _RelapseCalendarWidgetState();
}

class _RelapseCalendarWidgetState extends State<RelapseCalendarWidget> {
  late DateTime _currentMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDate = null;
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _currentMonth = DateTime(now.year, now.month, 1);
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<LiquidationRecord> _getRecordsForDay(DateTime day) {
    return widget.records.where((r) => _isSameDay(r.timestamp, day)).toList();
  }

  String _formatDuration(Duration d) {
    if (d.inDays > 0) {
      final hours = d.inHours % 24;
      return hours > 0 ? '${d.inDays}일 $hours시간' : '${d.inDays}일';
    } else if (d.inHours > 0) {
      final mins = d.inMinutes % 60;
      return mins > 0 ? '${d.inHours}시간 $mins분' : '${d.inHours}시간';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}분';
    }
    return '${d.inSeconds}초';
  }

  String _buildDaySummaryBadgeText(List<LiquidationRecord> dayRecords) {
    final ttalCount = dayRecords.where((r) => r.tickerType != 'yadongspi').length;
    final yadongCount = dayRecords.where((r) => r.tickerType == 'yadongspi').length;
    if (ttalCount > 0 && yadongCount > 0) {
      return '총 ${dayRecords.length}회 리셋 (발사 $ttalCount · 시청 $yadongCount)';
    } else if (yadongCount > 0) {
      return '총 $yadongCount회 시청 🔞';
    } else {
      return '총 $ttalCount회 발사 🍆';
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // 1. Month statistics
    final monthRecords = widget.records.where((r) {
      return r.timestamp.year == _currentMonth.year &&
          r.timestamp.month == _currentMonth.month;
    }).toList();

    final ttalCount = monthRecords.where((r) => r.tickerType != 'yadongspi').length;
    final yadongCount = monthRecords.where((r) => r.tickerType == 'yadongspi').length;
    final totalLoss = monthRecords.fold<int>(0, (sum, r) => sum + r.simulatedLossAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Month Header & Navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 28),
                    onPressed: _prevMonth,
                    tooltip: '이전 달',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('yyyy년 M월').format(_currentMonth),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _goToToday,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                          ),
                          child: const Text(
                            '오늘',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary, size: 28),
                    onPressed: _nextMonth,
                    tooltip: '다음 달',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Month Stats Summary Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: monthRecords.isNotEmpty
                        ? AppColors.electricRed.withValues(alpha: 0.4)
                        : AppColors.neonGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('이달의 청산:', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(width: 6),
                        Text(
                          '🍆 $ttalCount회',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '🔞 $yadongCount회',
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      totalLoss > 0 ? '-${NumberFormat('#,###').format(totalLoss)} P 📉' : '0 P 🛡️',
                      style: TextStyle(
                        color: totalLoss > 0 ? AppColors.electricRed : AppColors.neonGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              // Legend
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🍆 딸스피', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  SizedBox(width: 10),
                  Text('🔞 야동스피', style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                  SizedBox(width: 10),
                  Text('💥 당일 다회 리셋 (겹침)', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Weekday Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Expanded(child: Center(child: Text('일', style: TextStyle(color: AppColors.electricRed, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('월', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('화', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('수', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('목', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('금', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)))),
              Expanded(child: Center(child: Text('토', style: TextStyle(color: AppColors.electricBlue, fontSize: 12, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // 3. Calendar Grid
        _buildCalendarGrid(now),
        const SizedBox(height: 16),

        // 4. Selected Date Detail List (or Month Recaps)
        _buildSelectedDateSection(),
      ],
    );
  }

  Widget _buildCalendarGrid(DateTime now) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // Sunday = 0
    final prevMonthDays = DateTime(year, month, 0).day;

    final totalGridCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalGridCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.82,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemBuilder: (context, index) {
        DateTime cellDate;
        bool isCurrentMonth = true;

        if (index < firstWeekday) {
          // Previous month trailing days
          final dayNum = prevMonthDays - firstWeekday + index + 1;
          cellDate = DateTime(year, month - 1, dayNum);
          isCurrentMonth = false;
        } else if (index >= firstWeekday + daysInMonth) {
          // Next month leading days
          final dayNum = index - (firstWeekday + daysInMonth) + 1;
          cellDate = DateTime(year, month + 1, dayNum);
          isCurrentMonth = false;
        } else {
          // Current month days
          final dayNum = index - firstWeekday + 1;
          cellDate = DateTime(year, month, dayNum);
        }

        final dayRecords = _getRecordsForDay(cellDate);
        final hasRecords = dayRecords.isNotEmpty;
        final isSelected = _selectedDate != null && _isSameDay(_selectedDate!, cellDate);
        final isToday = _isSameDay(now, cellDate);

        return _buildDayCell(
          cellDate: cellDate,
          isCurrentMonth: isCurrentMonth,
          dayRecords: dayRecords,
          hasRecords: hasRecords,
          isSelected: isSelected,
          isToday: isToday,
        );
      },
    );
  }

  Widget _buildDayCell({
    required DateTime cellDate,
    required bool isCurrentMonth,
    required List<LiquidationRecord> dayRecords,
    required bool hasRecords,
    required bool isSelected,
    required bool isToday,
  }) {
    Color textColor = AppColors.textPrimary;
    if (!isCurrentMonth) {
      textColor = AppColors.textMuted.withValues(alpha: 0.35);
    } else if (cellDate.weekday == DateTime.sunday) {
      textColor = AppColors.electricRed;
    } else if (cellDate.weekday == DateTime.saturday) {
      textColor = AppColors.electricBlue;
    }

    Color bgColor = AppColors.surface;
    Color borderColor = AppColors.border.withValues(alpha: 0.5);

    if (isSelected) {
      bgColor = AppColors.electricBlue.withValues(alpha: 0.25);
      borderColor = AppColors.neonGreen;
    } else if (hasRecords) {
      bgColor = AppColors.darkRed.withValues(alpha: 0.45);
      borderColor = AppColors.electricRed.withValues(alpha: 0.7);
    } else if (isToday) {
      bgColor = AppColors.cardSurface;
      borderColor = AppColors.gold.withValues(alpha: 0.6);
    }

    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedDate != null && _isSameDay(_selectedDate!, cellDate)) {
            _selectedDate = null; // Toggle unselect
          } else {
            _selectedDate = cellDate;
          }
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : (hasRecords ? 1.2 : 0.8),
          ),
          boxShadow: hasRecords
              ? [
                  BoxShadow(
                    color: AppColors.electricRed.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Day number & Today ring
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isToday) ...[
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Text(
                  cellDate.day.toString(),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: hasRecords || isToday || isSelected
                        ? FontWeight.w900
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),

            // Relapse Badges - Stacked/Overlapping if multiple
            if (hasRecords)
              _buildOverlappingBadge(dayRecords)
            else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  // "하루에 여러번은, 겹쳐서 ㅇㅇ"
  Widget _buildOverlappingBadge(List<LiquidationRecord> dayRecords) {
    final ttalCount = dayRecords.where((r) => r.tickerType != 'yadongspi').length;
    final yadongCount = dayRecords.where((r) => r.tickerType == 'yadongspi').length;
    final totalCount = dayRecords.length;

    if (totalCount == 1) {
      final isYadong = dayRecords.first.tickerType == 'yadongspi';
      return Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.electricRed.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        child: Text(isYadong ? '🔞' : '🍆', style: const TextStyle(fontSize: 10)),
      );
    }

    // 2회 이상일 때: 아이콘들을 겹쳐서(Stack) 배치하고 배수 뱃지(xN) 부착
    final icon1 = ttalCount > 0 ? '🍆' : '🔞';
    final icon2 = (yadongCount > 0 && ttalCount > 0)
        ? '🔞'
        : (ttalCount > 1 ? '🍆' : '🔞');

    return SizedBox(
      width: 38,
      height: 18,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // First icon (Left)
          Positioned(
            left: 0,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.electricRed, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 2),
                ],
              ),
              child: Text(icon1, style: const TextStyle(fontSize: 9)),
            ),
          ),
          // Second overlapping icon (Offset by 9px)
          Positioned(
            left: 9,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 1),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 2),
                ],
              ),
              child: Text(icon2, style: const TextStyle(fontSize: 9)),
            ),
          ),
          // Multiplier count pill (Stacked on top right)
          Positioned(
            left: 20,
            top: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0.5),
              decoration: BoxDecoration(
                color: AppColors.electricRed,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white, width: 0.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, blurRadius: 2),
                ],
              ),
              child: Text(
                'x$totalCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateSection() {
    if (_selectedDate == null) {
      // Month overview
      final monthRecords = widget.records.where((r) {
        return r.timestamp.year == _currentMonth.year &&
            r.timestamp.month == _currentMonth.month;
      }).toList();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app_outlined, color: AppColors.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${DateFormat('yyyy년 M월').format(_currentMonth)} 청산/리셋 기록 (${monthRecords.length}건)',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              '달력에서 날짜를 탭하면 그 날 한발 뺐거나(발사) 야동 본(시청) 상세 내역을 모아서 볼 수 있다 게이야!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            if (monthRecords.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              ...monthRecords.take(5).map((record) => _buildRecordItem(record)),
            ],
          ],
        ),
      );
    }

    // Specific Date Selected
    final dayRecords = _getRecordsForDay(_selectedDate!);
    const weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayName = weekdayNames[_selectedDate!.weekday - 1];
    final dateTitle = '${_selectedDate!.year}년 ${_selectedDate!.month}월 ${_selectedDate!.day}일 ($weekdayName)';
    final totalLoss = dayRecords.fold<int>(0, (sum, r) => sum + r.simulatedLossAmount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dayRecords.isNotEmpty
              ? AppColors.electricRed.withValues(alpha: 0.6)
              : AppColors.neonGreen.withValues(alpha: 0.5),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          dateTitle,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (dayRecords.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.electricRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.electricRed),
                            ),
                            child: Text(
                              _buildDaySummaryBadgeText(dayRecords),
                              style: const TextStyle(
                                color: AppColors.electricRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dayRecords.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '증발한 값: -${NumberFormat('#,###').format(totalLoss)} P 📉',
                        style: const TextStyle(
                          color: AppColors.electricRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = null;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  backgroundColor: AppColors.cardSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  '선택 해제',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          if (dayRecords.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: const Column(
                children: [
                  Text('💎', style: TextStyle(fontSize: 36)),
                  SizedBox(height: 8),
                  Text(
                    '이 날은 발사도 시청도 하지 않은 청정 구역입니다!',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '유혹을 전부 쳐내고 클린 존버 성공한 날 인정한다 이기 🔒',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            )
          else
            ...dayRecords.map((record) => _buildRecordItem(record)),
        ],
      ),
    );
  }

  Widget _buildRecordItem(LiquidationRecord record) {
    final isYadong = record.tickerType == 'yadongspi';
    final timeStr = DateFormat('HH:mm:ss').format(record.timestamp);
    final durationStr = _formatDuration(record.durationHeld);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (widget.onRecordTap != null) {
              widget.onRecordTap!(record);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isYadong ? '🔞 야동스피' : '🍆 딸스피',
                            style: const TextStyle(
                              color: AppColors.electricRed,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isYadong ? '$durationStr 존버 후 시청' : '$durationStr 존버 후 발사',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text('원인', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ),
                    Expanded(
                      child: Text(
                        record.reason,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(
                      width: 50,
                      child: Text('증발', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ),
                    Text(
                      '-${NumberFormat('#,###').format(record.simulatedLossAmount)} P',
                      style: const TextStyle(
                        color: AppColors.electricRed,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                if (record.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 50,
                        child: Text('메모', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ),
                      Expanded(
                        child: Text(
                          record.note,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '상세보기',
                        style: TextStyle(color: AppColors.electricBlue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.chevron_right, size: 14, color: AppColors.electricBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
