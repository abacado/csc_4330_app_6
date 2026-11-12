import 'package:supabase_flutter/supabase_flutter.dart';

const _fallback =
    'Something went wrong. Check your connection and try again.';

/// Turns anything thrown by the store or Supabase into a sentence that is
/// safe to show a member. Never returns the exception's own `toString()`.
String friendlyError(Object error) => switch (error) {
  // The store throws these with messages written for members.
  ArgumentError(:final message?) => '$message',
  StateError(:final message) => message,
  AuthRetryableFetchException() => _fallback,
  AuthException() => _authMessage(error),
  PostgrestException() => _databaseMessage(error),
  _ => _fallback,
};

String _authMessage(AuthException error) {
  if (error.statusCode == '429') {
    return 'Too many attempts. Wait a moment and try again.';
  }
  return switch (error.code) {
    'invalid_credentials' => 'That email and password do not match.',
    'user_already_exists' ||
    'email_exists' => 'An account with that email already exists. Try signing in.',
    'email_not_confirmed' => 'Confirm your email first, then sign in.',
    'weak_password' => 'Choose a stronger password.',
    'email_address_invalid' ||
    'validation_failed' => 'Enter a valid email address.',
    'signup_disabled' => 'New accounts are not being accepted right now.',
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => 'Too many attempts. Wait a moment and try again.',
    _ => 'We could not sign you in. Check your details and try again.',
  };
}

String _databaseMessage(PostgrestException error) => switch (error.code) {
  '23505' => 'That already exists. Try a different name.',
  '23514' => 'Some of that is too long or missing. Check it and try again.',
  '42501' => 'You do not have permission to do that.',
  'PGRST301' || 'PGRST303' => 'Your session has expired. Sign in again.',
  _ => _fallback,
};
