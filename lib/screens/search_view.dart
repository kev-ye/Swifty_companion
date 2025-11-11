import 'package:flutter/material.dart';
import '../services/intra_api.dart';
import 'login_view.dart';
import 'user_detail_view.dart';

// 搜索页面
class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _controller = TextEditingController();
  final IntraApi _api = IntraApi();
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUserLogin;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  void _loadCurrentUser() async {
    final userData = await _api.getCurrentUser();
    if (userData != null && mounted) {
      setState(() {
        _currentUserLogin = userData['login'] as String?;
      });
    }
  }

  void _searchUser() async {
    if (_controller.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a login';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userData = await _api.searchUser(_controller.text.trim());

    setState(() {
      _isLoading = false;
    });

    if (userData == null) {
      setState(() {
        _errorMessage = 'Failed to fetch data';
      });
    } else if (userData.containsKey('error')) {
      setState(() {
        _errorMessage = userData['error'] as String;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailView(userData: userData),
        ),
      );
    }
  }

  void _logout() async {
    await _api.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginView(forceLogin: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentUserLogin != null) ...[
              Text(
                'Logged in as: $_currentUserLogin',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Search 42 User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Login',
                border: const OutlineInputBorder(),
                errorText: _errorMessage,
              ),
              onSubmitted: (_) => _searchUser(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _searchUser,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

