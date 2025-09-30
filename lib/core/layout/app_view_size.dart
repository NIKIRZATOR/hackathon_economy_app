import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// конфиг для размера экрана приложения
class AppViewSize extends InheritedWidget {
  final bool isMobile; // true = использовать реальный экран устройства
  final double targetW;
  final double targetH;

  const AppViewSize({
    super.key,
    required super.child,
    required this.isMobile,
    required this.targetW,
    required this.targetH,
  });

  static AppViewSize of(BuildContext context) {
    final v = context.dependOnInheritedWidgetOfExactType<AppViewSize>();
    assert(v != null, 'AppViewport not found in widget tree');
    return v!;
  }

  @override
  bool updateShouldNotify(covariant AppViewSize old) {
    return isMobile != old.isMobile ||
        targetW != old.targetW ||
        targetH != old.targetH;
  }

  static Widget decide({
    required BuildContext context,
    required Widget child,
    bool? usePhoneFrame,
    double phoneW = 414,
    double phoneH = 660,
  }) {
    final media = MediaQuery.of(context);
    // на мобильных - реальный экран
    // на web - рамка телефона
    final bool defaultUsePhoneFrame =
        kIsWeb || (media.size.shortestSide >= 600);
    final bool frame = usePhoneFrame ?? defaultUsePhoneFrame;

    final bool isMobile = !frame;
    final double targetW = isMobile ? media.size.width : phoneW;
    final double targetH = isMobile ? media.size.height : phoneH;

    return AppViewSize(
      isMobile: isMobile,
      targetW: targetW,
      targetH: targetH,
      child: child,
    );
  }
}
