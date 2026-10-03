import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/staff.dart';
import '../../domain/entities/staff_shift.dart';

/// 伝票入力画面右上の「スタッフ」欄（[StaffShift]、通常3件）を表示する
/// ウィジェット。
///
/// タイトルヘッダー（AppBar）と表のヘッダーの間に、成功状態の間は常時
/// 表示する。シフトごとに、氏名プルダウン・就業開始/終了時刻ボタン・
/// 「D」ラベル・ドリンクバック入力欄を横並びに配置する。
class VoucherStaffBar extends StatelessWidget {
  /// [VoucherStaffBar] を生成する。
  const VoucherStaffBar({
    required this.shifts,
    required this.staffRoster,
    required this.onNameChanged,
    required this.onTimeTap,
    required this.onTimeCommit,
    required this.onDrinkBackCommit,
    super.key,
    this.editingStaffShiftId,
    this.editingStaffShiftField,
  });

  /// シフト一覧。通常3件。
  final List<StaffShift> shifts;

  /// スタッフ選択肢一覧。氏名プルダウンの選択肢。
  final List<Staff> staffRoster;

  /// 編集中のシフトID。
  final String? editingStaffShiftId;

  /// 編集中のシフト項目。`'start'`または`'end'`。
  final String? editingStaffShiftField;

  /// 氏名選択時コールバック。
  final void Function(String shiftId, String? staffId) onNameChanged;

  /// 時刻ボタンタップ時コールバック。
  final void Function(String shiftId, String field) onTimeTap;

  /// 時刻確定時コールバック。
  final ValueChanged<String> onTimeCommit;

  /// ドリンクバック確定時コールバック。
  final void Function(String shiftId, String text) onDrinkBackCommit;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<StaffShift>('shifts', shifts))
      ..add(IterableProperty<Staff>('staffRoster', staffRoster))
      ..add(StringProperty('editingStaffShiftId', editingStaffShiftId))
      ..add(StringProperty('editingStaffShiftField', editingStaffShiftField))
      ..add(
        ObjectFlagProperty<void Function(String, String?)>.has(
          'onNameChanged',
          onNameChanged,
        ),
      )
      ..add(
        ObjectFlagProperty<void Function(String, String)>.has(
          'onTimeTap',
          onTimeTap,
        ),
      )
      ..add(
        ObjectFlagProperty<ValueChanged<String>>.has(
          'onTimeCommit',
          onTimeCommit,
        ),
      )
      ..add(
        ObjectFlagProperty<void Function(String, String)>.has(
          'onDrinkBackCommit',
          onDrinkBackCommit,
        ),
      );
  }

  @override
  Widget build(final BuildContext context) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child:
                    Text('スタッフ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...shifts.map(
                (final StaffShift shift) => _buildEntry(context, shift),
              ),
            ],
          ),
        ),
      );

  Widget _buildEntry(final BuildContext context, final StaffShift shift) =>
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: shift.staffId,
                    isDense: true,
                    hint: const Text('未定'),
                    items: <DropdownMenuItem<String?>>[
                      const DropdownMenuItem<String?>(child: Text('未定')),
                      ...staffRoster.map(
                        (final Staff staff) => DropdownMenuItem<String?>(
                          value: staff.staffId,
                          child: Text(staff.name),
                        ),
                      ),
                    ],
                    onChanged: (final String? value) =>
                        onNameChanged(shift.shiftId, value),
                  ),
                ),
                _timeButton(context, shift, 'start', shift.startTime),
                const Text('～'),
                _timeButton(context, shift, 'end', shift.endTime),
                const SizedBox(width: 4),
                const Text('D', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 96,
                  child: TextField(
                    controller: TextEditingController(
                      text: shift.drinkBack ?? '',
                    ),
                    decoration: const InputDecoration(isDense: true),
                    onSubmitted: (final String value) =>
                        onDrinkBackCommit(shift.shiftId, value),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _timeButton(
    final BuildContext context,
    final StaffShift shift,
    final String field,
    final String? value,
  ) {
    // 氏名（担当スタッフ）が未定のシフト枠は出退勤時刻を空白表示とし、
    // 編集不可とする。
    if (shift.staffId == null) {
      return const SizedBox(width: 72);
    }
    final bool isEditing =
        editingStaffShiftId == shift.shiftId && editingStaffShiftField == field;
    final String now = TimeOfDay.now().format(context);
    if (isEditing) {
      return SizedBox(
        width: 72,
        child: TextFormField(
          autofocus: true,
          initialValue: value ?? now,
          decoration: const InputDecoration(isDense: true),
          onFieldSubmitted: onTimeCommit,
        ),
      );
    }
    return TextButton(
      onPressed: () => onTimeTap(shift.shiftId, field),
      child: Text(value ?? now),
    );
  }
}

/// 角丸の点線枠を描画する[CustomPainter]。
///
/// [VoucherStaffBar]の各シフト枠（docs/ui/wireframeの
/// `.staffbar__entry`相当）を囲むために使用する（画面内でのみ使用する）。
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  /// 枠線の色。
  final Color color;

  static const double _dashWidth = 4;
  static const double _dashGap = 3;
  static const double _radius = 8;
  static const double _strokeWidth = 1;

  @override
  void paint(final Canvas canvas, final Size size) {
    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    final Path path = Path()..addRRect(rrect);
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = distance + _dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(final _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
