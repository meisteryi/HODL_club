import 'dart:convert';

class LiquidationRecord {
  final String id;
  final DateTime timestamp;
  final Duration durationHeld;
  final double returnRateAchieved;
  final int simulatedLossAmount;
  final String reason;
  final String note;
  final List<String> achievedBadges;
  final String tickerType; // 'ttalspi' or 'yadongspi'

  LiquidationRecord({
    required this.id,
    required this.timestamp,
    required this.durationHeld,
    required this.returnRateAchieved,
    required this.simulatedLossAmount,
    required this.reason,
    required this.note,
    this.achievedBadges = const [],
    this.tickerType = 'ttalspi',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationHeld.inSeconds,
      'returnRateAchieved': returnRateAchieved,
      'simulatedLossAmount': simulatedLossAmount,
      'reason': reason,
      'note': note,
      'achievedBadges': achievedBadges,
      'tickerType': tickerType,
    };
  }

  factory LiquidationRecord.fromMap(Map<String, dynamic> map) {
    return LiquidationRecord(
      id: map['id'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      durationHeld: Duration(seconds: map['durationSeconds'] ?? 0),
      returnRateAchieved: (map['returnRateAchieved'] as num).toDouble(),
      simulatedLossAmount: map['simulatedLossAmount'] ?? 0,
      reason: map['reason'] ?? '의지력 방전',
      note: map['note'] ?? '',
      achievedBadges: List<String>.from(map['achievedBadges'] ?? []),
      tickerType: map['tickerType'] ?? 'ttalspi',
    );
  }

  String toJson() => json.encode(toMap());

  factory LiquidationRecord.fromJson(String source) =>
      LiquidationRecord.fromMap(json.decode(source));
}
