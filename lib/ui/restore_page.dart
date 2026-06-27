import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/account.dart';
import '../data/backup.dart';

/// Restore from an encrypted backup file the user picks from ANY provider
/// (iCloud/Drive/Proton/Files) via the OS document picker, decrypted locally
/// with their Recovery Key.
class RestorePage extends StatefulWidget {
  const RestorePage({super.key, required this.state});
  final AppState state;

  @override
  State<RestorePage> createState() => _RestorePageState();
}

class _RestorePageState extends State<RestorePage> {
  String? _envelope;
  String? _fileName;
  final _key = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _error = null);
    const group = XTypeGroup(label: 'AgnosticOTP backup', extensions: ['json', 'aotp']);
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    final content = await file.readAsString();
    setState(() {
      _envelope = content;
      _fileName = file.name;
    });
  }

  Future<void> _restore() async {
    final env = _envelope;
    if (env == null || _key.text.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plaintext =
          await BackupCodec.decrypt(envelopeJson: env, passphrase: _key.text);
      final decoded = jsonDecode(plaintext);
      if (decoded is! List) throw const FormatException('Bad backup contents.');
      final accounts = <Account>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          accounts.add(Account.fromJson(item));
        }
      }
      await widget.state.importAccounts(accounts);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Restored ${accounts.length} account'
                '${accounts.length == 1 ? '' : 's'}.')));
      }
    } on BackupDecryptException {
      setState(() => _error = 'Wrong Recovery Key, or the file is corrupt.');
    } on BackupFormatException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not restore this file.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Restore backup')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pick your encrypted backup from any cloud, then enter your '
              'Recovery Key.', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open),
            label: Text(_fileName ?? 'Choose backup file…'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _key,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Recovery Key',
              hintText: 'number*Word-word+word=word-word/number',
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: (_envelope != null && !_busy) ? _restore : null,
            icon: const Icon(Icons.restore),
            label: const Text('Restore'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}
