import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/user_repository.dart';
import '../../models/user.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  int _page = 1;
  bool _hasMore = true;
  String? _query;
  List<UserModel> _users = [];

  UserBloc({required this.userRepository}) : super(UserInitial()) {
    on<FetchUsers>(_onFetch);
    on<RefreshUsers>(_onRefresh);
  }

  Future<void> _onFetch(FetchUsers event, Emitter<UserState> emit) async {
    if (!_hasMore && event.page != 1) return;

    try {
      if (event.page == 1) {
        emit(UserLoadInProgress());
        _users = [];
        _page = 1;
        _hasMore = true;
      } else {
        emit(UserLoadMore());
        _page = event.page;
      }

      _query = event.query;

      final result = await userRepository.fetchUsers(page: _page, q: _query);
      final newUsers = result['users'] as List<UserModel>;
      final currentPage = result['currentPage'] as int;
      final perPage = result['perPage'] as int;
      final total = result['total'] as int;

      // tambahkan user baru jika pagination, replace kalau refresh
      if (_page == 1) {
        _users = newUsers;
      } else {
        _users = [..._users, ...newUsers];
      }

      // hitung apakah masih ada halaman berikutnya
      _hasMore = (currentPage * perPage) < total;

      emit(UserLoadSuccess(users: _users, page: _page, hasMore: _hasMore));
    } catch (e) {
      emit(UserLoadFailure(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshUsers event, Emitter<UserState> emit) async {
    _page = 1;
    _query = event.query;
    add(FetchUsers(page: 1, query: _query));
  }
}
