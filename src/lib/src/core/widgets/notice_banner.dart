import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// [NoticeBanner] の表示トーン。
enum NoticeTone {
  /// 成功時（緑系の配色）。
  success,

  /// 失敗時（赤系の配色）。
  error,
}

/// 画面上部にお知らせ文を表示する共通UIコンポーネント。
///
/// 副作用（Side Effect）による1回限りの通知を、モーダルやスナックバーでは
/// なく画面上部の帯（バナー）として表示するために使用する。特定機能に依存
/// しないため`core/widgets/`に配置する。表示後は[duration]経過で自動的に
/// 消える。タップで閉じる場合は[onDismiss]を呼び出し元から渡す。
class NoticeBanner extends StatelessWidget {
  /// [NoticeBanner] を生成する。
  const NoticeBanner({
    required this.message,
    required this.tone,
    super.key,
    this.duration = const Duration(seconds: 4),
    this.onDismiss,
  });

  /// お知らせ文。
  final String message;

  /// 表示トーン。
  final NoticeTone tone;

  /// 表示時間。未指定時は既定値（4秒）で自動的に非表示にする。
  final Duration duration;

  /// タップで閉じる際のコールバック。
  final VoidCallback? onDismiss;

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('message', message))
      ..add(EnumProperty<NoticeTone>('tone', tone))
      ..add(DiagnosticsProperty<Duration>('duration', duration))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onDismiss', onDismiss));
  }

  @override
  Widget build(final BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isSuccess = tone == NoticeTone.success;
    final Color background =
        isSuccess ? colors.primaryContainer : colors.errorContainer;
    final Color foreground =
        isSuccess ? colors.onPrimaryContainer : colors.onErrorContainer;
    return Material(
      color: background,
      child: InkWell(
        onTap: onDismiss,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(message, style: TextStyle(color: foreground)),
              ),
              if (onDismiss != null)
                Icon(Icons.close, size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
