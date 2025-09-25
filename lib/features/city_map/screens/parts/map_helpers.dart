part of '../city_map_screen.dart';

extension _CityMapStateHelpers on _CityMapScreenState {
  // перевод точки viewport -> scene
  Offset _toScene(Offset viewportPoint) => _tc.toScene(viewportPoint);

  // перевод точки scene -> viewport (обратно)
  Offset _sceneToViewport(Offset scenePoint) {
    final m = _tc.value;
    final v = v_math.Vector3(scenePoint.dx, scenePoint.dy, 0);
    final r = m.transform3(v);
    return Offset(r.x, r.y);
  }
}
// круглая кнопка с галочкой
class _ConfirmBtn extends StatelessWidget {
  const _ConfirmBtn({required this.onTap, this.size = 30});
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(blurRadius: 6, offset: Offset(0, 2), color: Colors.black26)],
        ),
        child: const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
