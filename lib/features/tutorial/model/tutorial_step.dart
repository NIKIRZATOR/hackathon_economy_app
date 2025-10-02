class TutorialStep {
  final String id;
  final String text;
  final String mishaAsset;
  final bool waitsUserTap; // если false — сразу ждём action
  final String? action;    // код внешнего действия (на будущее)

  const TutorialStep({
    required this.id,
    required this.text,
    required this.mishaAsset,
    this.waitsUserTap = true,
    this.action,
  });
}
