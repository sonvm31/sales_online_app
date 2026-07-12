Uri? extractPasswordResetAction(Uri? uri) {
  if (uri == null) return null;

  final mode = uri.queryParameters['mode'];
  final code = uri.queryParameters['oobCode'];
  if (mode == 'resetPassword' && code != null && code.isNotEmpty) {
    return uri;
  }

  for (final key in const ['link', 'deep_link_id', 'continueUrl']) {
    final nestedLink = uri.queryParameters[key];
    if (nestedLink == null || nestedLink.isEmpty) continue;

    final nestedUri = Uri.tryParse(nestedLink);
    if (nestedUri == null) continue;

    final actionUri = extractPasswordResetAction(nestedUri);
    if (actionUri != null) return actionUri;
  }

  return null;
}
