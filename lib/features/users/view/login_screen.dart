import 'package:flutter/material.dart';
import 'package:tutor_student_client/repositories/users/user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pushNamed('/')),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Вход в аккаунт',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                          decoration: const InputDecoration(labelText: 'Почта'),
                          onSaved: (value) => _email = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Поле должно быть заполнено";
                            }
                            return null;
                          }),
                      TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Пароль'),
                          obscureText: true,
                          onSaved: (value) => _password = value ?? '',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Поле должно быть заполнено";
                            }
                            return null;
                          }),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Войти в аккаунт'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    } else {
      return;
    }
    try {
      final status = await UserRepository().login(_email, _password);
      if (mounted && status == 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Неверный логин или пароль'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.indigo,
          ),
        );
        return;
      }
      if (mounted) {
        Navigator.of(context).pushNamed('/main_screen');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
