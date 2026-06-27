import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../app_state.dart';
import '../core/migration_import.dart';

/// Import from another authenticator or a browser/extension export — scan the
/// export QR (Google Authenticator `otpauth-migration://`, or a single
/// `otpauth://`) or pick an exported file (newline list of otpauth:// URIs).
class ImportPage extends StatelessWidget {
  const ImportPage({super.key, required this.state});
  final AppState state;

  Future<void> _apply(BuildContext context, ImportResult result) async {
    if (result.accounts.isNotEmpty) {
      await state.importAccounts(result.accounts);
    }
    if (!context.mounted) return;
    Navigator.pop(context);
    final msg = result.accounts.isEmpty
        ? 'Nothing to import.'
        : 'Imported ${result.importedCount}'
            '${result.skippedCount > 0 ? ', skipped ${result.skippedCount}' : ''}.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _scan(BuildContext context) async {
    final raw = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ImportScanPage()),
    );
    if (raw == null || !context.mounted) return;
    try {
      await _apply(context, AuthenticatorImport.fromText(raw));
    } catch (e) {
      if (context.mounted) _err(context, 'Could not read that QR code.');
    }
  }

  Future<void> _fromFile(BuildContext context) async {
    const group = XTypeGroup(label: 'export', extensions: ['txt', 'json']);
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null || !context.mounted) return;
    final text = await file.readAsString();
    if (!context.mounted) return;
    try {
      await _apply(context, AuthenticatorImport.fromText(text));
    } catch (e) {
      if (context.mounted) _err(context, 'Could not read that file.');
    }
  }

  void _err(BuildContext context, String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Import accounts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Move accounts from Google Authenticator, a browser password '
            'manager, or another app.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan export QR'),
              subtitle: const Text('Google Authenticator "export accounts", or an otpauth:// QR'),
              onTap: () => _scan(context),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Import from file'),
              subtitle: const Text('A list of otpauth:// URIs (browser/extension export)'),
              onTap: () => _fromFile(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportScanPage extends StatefulWidget {
  const _ImportScanPage();

  @override
  State<_ImportScanPage> createState() => _ImportScanPageState();
}

class _ImportScanPageState extends State<_ImportScanPage> {
  final MobileScannerController _controller =
      MobileScannerController(formats: const [BarcodeFormat.qrCode]);
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _handled = true;
        Navigator.pop<String>(context, raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan export QR')),
      body: MobileScanner(controller: _controller, onDetect: _onDetect),
    );
  }
}
