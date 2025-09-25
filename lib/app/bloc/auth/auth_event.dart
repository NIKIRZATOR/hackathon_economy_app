abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {
  final String username;
  final String password;
  SignInRequested(this.username, this.password);
}

class SignUpRequested extends AuthEvent {
  final String username;
  final String password;
  final String cityTitle;
  SignUpRequested(this.username, this.password, this.cityTitle);
}

class SignOutRequested extends AuthEvent {}
