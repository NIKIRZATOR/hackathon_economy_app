import 'package:bloc/bloc.dart';
import '../../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repo;

  AuthBloc(this.repo) : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<SignInRequested>(_onSignIn);
    on<SignUpRequested>(_onSignUp);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final saved = await repo.getSavedUser();
    if (saved != null) {
      emit(Authenticated(saved));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repo.signIn(event.username, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError('Ошибка входа: $e'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignUp(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await repo.signUp(event.username, event.password, event.cityTitle);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError('Ошибка регистрации: $e'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
    final s = state;
    if (s is Authenticated) {
      await repo.signOut(s.user);
    } else {
      await repo.signOutActive();
    }
    emit(Unauthenticated());
  }
}
