import 'package:flutter/material.dart';
import 'package:hackathon_economy_app/app/models/user_model.dart';
import 'package:hackathon_economy_app/app/repository/auth_repository.dart';
import 'package:hackathon_economy_app/features/city_map/screens/city_map_screen.dart';

import '../../../app/sync/sync_service.dart';
import '../../../core/layout/app_view_size.dart';
import '../../building_types/repo/building_type_input_repository.dart';
import '../../building_types/repo/building_type_output_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _repo = AuthRepository();
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  bool _loading = false;

  final _userCtrl = TextEditingController(text: 'test');
  final _passCtrl = TextEditingController(text: 'test');
  final _cityCtrl = TextEditingController(text: 'MyCity');

  final _inRepo = BuildingTypeInputRepository();
  final _outRepo = BuildingTypeOutputRepository();

  Future<void> warmUp() async {
    // грузим параллельно; если один упадёт — не срываем авторизацию
    await Future.wait([
      _inRepo.syncFromServerAndCache(),
      _outRepo.syncFromServerAndCache(),
    ], eagerError: false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      UserModel user;
      if (_isLogin) {
        user = await _repo.signIn(_userCtrl.text.trim(), _passCtrl.text);
      } else {
        user = await _repo.signUp(
          _userCtrl.text.trim(),
          _passCtrl.text,
          _cityCtrl.text.trim(),
        );
      }

      await warmUp();

      //  ПЕРИОДИЧЕСКАЯ СИНХРОНИЗАЦИЮ
      // SyncService.I.start(userId: user.userId!);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => CityMapScreen(incomingUser: user)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vp = AppViewSize.of(context);
    final double targetW = vp.targetW;
    final double targetH = vp.targetH;

    final fields = <Widget>[
      TextFormField(
        controller: _userCtrl,
        decoration: const InputDecoration(labelText: 'Логин'),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Введите логин' : null,
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _passCtrl,
        decoration: const InputDecoration(labelText: 'Пароль'),
        obscureText: true,
        validator: (v) => (v == null || v.isEmpty) ? 'Введите пароль' : null,
      ),
      if (!_isLogin) ...[
        const SizedBox(height: 12),
        TextFormField(
          controller: _cityCtrl,
          decoration: const InputDecoration(labelText: 'Город'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Введите город' : null,
        ),
      ],
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _loading ? null : _submit,
          child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
        ),
      ),
      TextButton(
        onPressed: _loading ? null : () => setState(() => _isLogin = !_isLogin),
        child: Text(
          _isLogin ? 'Нет аккаунта? Регистрация' : 'У меня уже есть аккаунт',
        ),
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.tightFor(width: targetW, height: targetH),
        child: Scaffold(
          appBar: AppBar(title: const Text('Авторизация')),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_loading) const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      ...fields,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
