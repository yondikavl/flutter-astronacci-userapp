import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'src/repositories/auth_repository.dart';
import 'src/repositories/user_repository.dart';
import 'src/blocs/auth/auth_bloc.dart';
import 'src/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authRepo = AuthRepository();
  final userRepo = UserRepository();

  runApp(MyApp(authRepository: authRepo, userRepository: userRepo));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final UserRepository userRepository;
  const MyApp(
      {required this.authRepository, required this.userRepository, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  AuthBloc(authRepository: authRepository)..add(AppStarted())),
        ],
        child: MaterialApp(
          title: 'User App',
          theme: ThemeData(primarySwatch: Colors.red),
          home: SplashScreen(),
        ),
      ),
    );
  }
}
