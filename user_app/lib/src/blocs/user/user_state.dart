part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoadInProgress extends UserState {}

class UserLoadMore extends UserState {}

class UserLoadSuccess extends UserState {
  final List<UserModel> users;
  final int page;
  final bool hasMore;
  UserLoadSuccess(
      {required this.users, required this.page, required this.hasMore});
  @override
  List<Object?> get props => [users, page, hasMore];
}

class UserLoadFailure extends UserState {
  final String message;
  UserLoadFailure(this.message);
  @override
  List<Object?> get props => [message];
}
