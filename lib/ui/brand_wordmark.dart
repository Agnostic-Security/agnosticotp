import 'package:flutter/material.dart';

import 'theme.dart';

/// "AgnosticOTP" wordmark in brand colours: **Agnostic** in Agnostic Orange,
/// **OTP** in Agnostic Blue (theme primary, which lightens on dark for contrast).
class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.style});

  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = (style ??
            theme.appBarTheme.titleTextStyle ??
            theme.textTheme.titleLarge ??
            const TextStyle())
        .copyWith(fontWeight: FontWeight.w700);
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: 'Agnostic',
          style: base.copyWith(color: BrandColors.agnosticOrange),
        ),
        TextSpan(
          text: 'OTP',
          style: base.copyWith(color: theme.colorScheme.primary),
        ),
      ]),
    );
  }
}
