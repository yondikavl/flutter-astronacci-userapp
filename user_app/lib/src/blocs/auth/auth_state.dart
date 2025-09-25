part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final String token;
  Authenticated(this.token);
  @override
  List<Object?> get props => [token];
}

class Unauthenticated extends AuthState {}
