import 'package:flutter/material.dart';
import '../../../supabase_client.dart';

class LoginDialog extends StatefulWidget {
  final void Function(String nickname, String password, bool isLogin) onSubmit;
  const LoginDialog({super.key, required this.onSubmit});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;
  String? _error;
  bool _loading = false;

  Future<void> _handleAuth() async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text.trim();
    if (nickname.isEmpty || password.isEmpty) {
      setState(() => _error = '全て入力してください');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        // ログイン: usersテーブルからnickname/password一致を検索
        final res =
            await supabase
                .from('users')
                .select('id, nickname')
                .eq('nickname', nickname)
                .eq('password', password)
                .maybeSingle();
        if (res == null) {
          setState(() => _error = 'ニックネームまたはパスワードが違います');
        } else {
          Navigator.pop(context, {
            'user_id': res['id'],
            'nickname': res['nickname'],
          });
        }
      } else {
        // 新規登録: nickname重複チェック
        final exists =
            await supabase
                .from('users')
                .select('id')
                .eq('nickname', nickname)
                .maybeSingle();
        if (exists != null) {
          setState(() => _error = 'このニックネームは既に使われています');
        } else {
          final insertRes =
              await supabase
                  .from('users')
                  .insert({'nickname': nickname, 'password': password})
                  .select('id, nickname')
                  .maybeSingle();
          if (insertRes == null) {
            setState(() => _error = '登録に失敗しました');
          } else {
            Navigator.pop(context, {
              'user_id': insertRes['id'],
              'nickname': insertRes['nickname'],
            });
          }
        }
      }
    } catch (e) {
      setState(() => _error = '通信エラー: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isLogin ? 'ログイン' : '新規登録'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(labelText: 'ニックネーム'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'パスワード',
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error ?? '', style: const TextStyle(color: Colors.red)),
          ],
          if (_loading) ...[
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? '新規登録はこちら' : 'ログインはこちら'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _handleAuth,
          child: Text(_isLogin ? 'ログイン' : '登録'),
        ),
      ],
    );
  }
}
