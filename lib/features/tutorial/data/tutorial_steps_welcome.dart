import '../model/tutorial_step.dart';

/// Приветственный сценарий для экрана авторизации.
/// Меняем эмоции Миши по шагам (см. assets/images/Misha).
final List<TutorialStep> kWelcomeSteps = [
  TutorialStep(
    id: 'hello',
    text:
    'Привет! Я Миша. Добро пожаловать в нашу игру!',
    mishaAsset: 'assets/images/Misha/Misha_happy.png',
  ),
  TutorialStep(
    id: 'question',
    text:
    'Ты здесь впервые? Если да — можно быстро зарегистрироваться.\nИли войди, если аккаунт уже есть.',
    mishaAsset: 'assets/images/Misha/Misha_like.png',
  ),
  TutorialStep(
    id: 'hint',
    text:
    'Заполни поля ниже и нажми кнопку. Удачи! Встретимся в твоём городе',
    mishaAsset: 'assets/images/Misha/Misha_smile.png',
  ),
];
