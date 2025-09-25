part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUsers extends UserEvent {
  final int page;
  final String? query;
  FetchUsers({this.page = 1, this.query});
  @override
  List<Object?> get props => [page, query];
}

class RefreshUsers extends UserEvent {
  final String? query;
  RefreshUsers({this.query});
  @override
  List<Object?> get props => [query];
}
