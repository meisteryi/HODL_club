import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/hodl_provider.dart';
import '../utils/web_file_helper.dart';

class BackupModal extends StatefulWidget {
  const BackupModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BackupModal(),
    );
  }

  @override
  State<BackupModal> createState() => _BackupModalState();
}

class _BackupModalState extends State<BackupModal> {
  bool _isLoading = false;
  bool _showTextPasteField = false;
  final TextEditingController _pasteController = TextEditingController();

  @override
  void dispose() {
    _pasteController.dispose();
    super.dispose();
  }

  Future<void> _handleFileDownload(HodlProvider provider) async {
    setState(() => _isLoading = true);
    try {
      final jsonString = await provider.exportBackupData();
      final nowStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filename = 'hodl_club_backup_$nowStr.json';

      await downloadJsonFile(filename, jsonString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.cardSurface,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '📁 $filename 다운로드 완료!',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('파일 내보내기 실패: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCopyClipboard(HodlProvider provider) async {
    try {
      final jsonString = await provider.exportBackupData();
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.cardSurface,
            content: Row(
              children: [
                Icon(Icons.copy, color: AppColors.electricBlue, size: 20),
                SizedBox(width: 8),
                Text(
                  '📋 백업 데이터가 클립보드에 복사되었습니다.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                ),
              ],
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('복사 실패: $e');
    }
  }

  Future<void> _handleFilePickAndImport(HodlProvider provider) async {
    try {
      final jsonString = await pickJsonFile();
      if (jsonString == null || jsonString.trim().isEmpty) return;

      await _confirmAndRestore(provider, jsonString);
    } catch (e) {
      _showErrorSnackBar('파일을 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> _handleTextImport(HodlProvider provider) async {
    final text = _pasteController.text.trim();
    if (text.isEmpty) {
      _showErrorSnackBar('복원할 백업 텍스트를 입력해주세요.');
      return;
    }
    await _confirmAndRestore(provider, text);
  }

  Future<void> _confirmAndRestore(HodlProvider provider, String jsonString) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 24),
            SizedBox(width: 8),
            Text(
              '데이터 복원 확인',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          '현재 브라우저에 저장된 데이터가 백업 파일의 내용으로 완전히 교체됩니다.\n\n계속 진행하시겠습니까?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('덮어쓰기 복원', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await provider.importBackupData(jsonString);

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.cardSurface,
            content: Row(
              children: [
                Icon(Icons.celebration, color: AppColors.neonGreen, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 백업 데이터가 성공적으로 복원되었습니다!',
                    style: TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('데이터 복원 실패: 잘못된 형식이거나 손상된 파일입니다.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cardSurface,
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.electricRed, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: AppColors.electricRed, fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HodlProvider>();
    final ttalspiDays = provider.ttalspiElapsed.inDays;
    final yadongspiDays = provider.yadongspiElapsed.inDays;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1.2),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.gold, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'MTS 데이터 금고 (백업 & 복원)',
                        style: TextStyle(
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
              const Text(
                '브라우저(로컬스토리지)에 저장된 존버 기록을 파일로 안전하게 백업하고, 기기 변경 시 그대로 이어갈 수 있습니다.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),

              // Current Data Status Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 현재 보관 중인 내 데이터',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDataChip(
                            '🍆 딸스피',
                            '$ttalspiDays일차 (${provider.ttalspiPoints.toStringAsFixed(0)}P)',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDataChip(
                            '🔞 야동스피',
                            '$yadongspiDays일차 (${provider.yadongspiPoints.toStringAsFixed(0)}P)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDataChip(
                            '🏆 달성 업적',
                            '총 ${provider.unlockedCount}개',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDataChip(
                            '📉 청산 회고록',
                            '${provider.liquidationHistory.length}건',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SECTION 1: Export (내보내기)
              const Text(
                '1. 데이터 내보내기 (Backup Export)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : () => _handleFileDownload(provider),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text(
                        'JSON 파일 저장',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        backgroundColor: AppColors.cardSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : () => _handleCopyClipboard(provider),
                      icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.electricBlue),
                      label: const Text(
                        '텍스트 복사',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION 2: Import (가져오기)
              const Text(
                '2. 데이터 불러오기 (Backup Import)',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricBlue.withValues(alpha: 0.15),
                        foregroundColor: AppColors.electricBlue,
                        side: const BorderSide(color: AppColors.electricBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : () => _handleFilePickAndImport(provider),
                      icon: const Icon(Icons.file_upload_outlined, size: 18),
                      label: const Text(
                        '백업 파일 선택',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: _showTextPasteField ? AppColors.gold : AppColors.border,
                        ),
                        backgroundColor: AppColors.cardSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _showTextPasteField = !_showTextPasteField;
                        });
                      },
                      icon: Icon(
                        _showTextPasteField ? Icons.expand_less : Icons.edit_note,
                        size: 18,
                        color: _showTextPasteField ? AppColors.gold : AppColors.textMuted,
                      ),
                      label: const Text(
                        '텍스트 붙여넣기',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),

              // Expandable paste field
              if (_showTextPasteField) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _pasteController,
                        maxLines: 4,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        decoration: InputDecoration(
                          hintText: '복사해둔 백업 JSON 텍스트를 여기에 붙여넣으세요...',
                          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.all(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isLoading ? null : () => _handleTextImport(provider),
                        child: const Text(
                          '텍스트로 복원하기',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.textMuted, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '백업 파일은 순수 JSON 텍스트로 보관되며, 언제든 다른 PC, 사파리, 크롬, 새 휴대폰으로 이전할 수 있습니다.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
