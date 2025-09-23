class GameTask {
  final String id;
  final String title;
  bool done;

  GameTask({
    required this.id,
    required this.title,
    this.done = false,
  });
}