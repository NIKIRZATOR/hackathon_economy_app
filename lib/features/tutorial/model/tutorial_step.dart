class TutorialStep {
  final String id;
  final String text;
  final String mishaAsset;
  final bool waitsUserTap;
  final String? action;

  const TutorialStep({
    required this.id,
    required this.text,
    required this.mishaAsset,
    this.waitsUserTap = true,
    this.action,
  });
}
