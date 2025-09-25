import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_app/src/screens/login_screen.dart';
import 'package:user_app/src/widgets/search_bar_widget.dart';
import 'package:user_app/src/widgets/user_card_widget.dart';
import '../repositories/user_repository.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'edit_profile_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  late final UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    final userRepo = context.read<UserRepository>();
    _userBloc = UserBloc(userRepository: userRepo)..add(FetchUsers(page: 1));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      final state = _userBloc.state;
      if (state is UserLoadSuccess && state.hasMore) {
        _userBloc.add(FetchUsers(
          page: state.page + 1,
          query: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
        ));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _userBloc.close();
    super.dispose();
  }

  void _onSearch() {
    _userBloc.add(
      RefreshUsers(
        query: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (_) => false,
          );
        } else if (state is Authenticated) {
          _userBloc.add(RefreshUsers());
        }
      },
      child: BlocProvider.value(
        value: _userBloc,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              SearchBarWidget(
                controller: _searchController,
                onSearch: _onSearch,
              ),
              Expanded(child: _buildUserList()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Daftar Pengguna'),
      centerTitle: true,
      backgroundColor: Colors.redAccent.shade700,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => context.read<AuthBloc>().add(LoggedOut()),
        ),
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (_) => const EditProfileScreen()))
                .then((updated) {
              if (updated == true) _onSearch();
            });
          },
        ),
      ],
    );
  }

  Widget _buildUserList() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoadInProgress) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is UserLoadFailure) {
          return Center(
            child: Text(
              'Error: ${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (state is UserLoadSuccess) {
          if (state.users.isEmpty) {
            return const Center(child: Text('Tidak ada pengguna'));
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: state.users.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.users.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return UserCardWidget(user: state.users[index]);
            },
          );
        }
        return const Center(child: Text('Tidak ada data'));
      },
    );
  }
}
