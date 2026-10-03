import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/time_format.dart';
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
                _timeButton(shift, 'start', shift.startTime),
                const Text('～'),
                _timeButton(shift, 'end', shift.endTime),
                const SizedBox(width: 4),
                const Text('D', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 96,
                  child: _DrinkBackField(
                    key: ValueKey<String>(shift.shiftId),
                    savedValue: shift.drinkBack ?? '',
                    onCommit: (final String value) =>
                        onDrinkBackCommit(shift.shiftId, value),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _timeButton(
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
    final String now = formatHHmm(DateTime.now());
    if (isEditing) {
      return SizedBox(
        width: 72,
        child: _StaffTimeField(
          initialValue: value ?? now,
          onCommit: onTimeCommit,
        ),
      );
    }
    return TextButton(
      onPressed: () => onTimeTap(shift.shiftId, field),
      child: Text(value ?? now),
    );
  }
}

/// 就業時刻の入力欄（[VoucherStaffBar]の画面内でのみ使用する）。
///
/// Enter（キーボードの完了）に加え、欄の外のタップやフォーカス喪失でも
/// 入力値を確定する（docs/ui/wireframeの`change`・`blur`での確定に相当）。
/// 確定は1回のみ行う。
class _StaffTimeField extends StatefulWidget {
  const _StaffTimeField({
    required this.initialValue,
    required this.onCommit,
  });

  /// 入力欄の初期値（`HH:mm`形式）。
  final String initialValue;

  /// 入力確定時コールバック。
  final ValueChanged<String> onCommit;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('initialValue', initialValue))
      ..add(ObjectFlagProperty<ValueChanged<String>>.has('onCommit', onCommit));
  }

  @override
  State<_StaffTimeField> createState() => _StaffTimeFieldState();
}

class _StaffTimeFieldState extends State<_StaffTimeField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isCommitted = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    if (_isCommitted) {
      return;
    }
    _isCommitted = true;
    widget.onCommit(_controller.text);
  }

  @override
  Widget build(final BuildContext context) => TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        keyboardType: TextInputType.datetime,
        decoration: const InputDecoration(isDense: true),
        onSubmitted: (final String _) => _commit(),
        onTapOutside: (final PointerDownEvent _) => _focusNode.unfocus(),
      );
}

/// ドリンクバック（「D」欄）の入力欄（[VoucherStaffBar]の画面内でのみ使用
/// する）。
///
/// 自由記述（string型）として入力値をそのまま扱う。常時表示の欄のため、
/// Enter（キーボードの完了）・欄の外のタップ・フォーカス喪失のいずれかで、
/// 保存済みの値から変更がある場合のみ確定する。
class _DrinkBackField extends StatefulWidget {
  const _DrinkBackField({
    required this.savedValue,
    required this.onCommit,
    super.key,
  });

  /// 保存済みのドリンクバック（未入力の場合は空文字列）。
  final String savedValue;

  /// 入力確定時コールバック。
  final ValueChanged<String> onCommit;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('savedValue', savedValue))
      ..add(ObjectFlagProperty<ValueChanged<String>>.has('onCommit', onCommit));
  }

  @override
  State<_DrinkBackField> createState() => _DrinkBackFieldState();
}

class _DrinkBackFieldState extends State<_DrinkBackField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.savedValue);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(final _DrinkBackField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 入力中でなければ、保存済みの値の変化（再読込など）を入力欄に反映する。
    if (!_focusNode.hasFocus && widget.savedValue != oldWidget.savedValue) {
      _controller.text = widget.savedValue;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    if (_controller.text == widget.savedValue) {
      return;
    }
    widget.onCommit(_controller.text);
  }

  @override
  Widget build(final BuildContext context) => TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: const InputDecoration(isDense: true),
        onSubmitted: (final String _) => _focusNode.unfocus(),
        onTapOutside: (final PointerDownEvent _) => _focusNode.unfocus(),
      );
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
