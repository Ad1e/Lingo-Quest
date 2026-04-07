/// Utility class for form validation
/// 
/// Provides reusable validation methods for email, password, and username fields
/// with comprehensive error messages.

class Validators {
  /// Email validation using regex pattern
  /// 
  /// Validates:
  /// - Basic RFC 5322 compliance
  /// - Valid domain name
  /// - TLD required
  /// - No leading/trailing dots in local part
  /// 
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty || email.trim() != email) {
      return 'Email is required and cannot contain spaces';
    }

    // Check for consecutive dots
    if (email.contains('..')) {
      return 'Email cannot contain consecutive dots';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Check for leading or trailing dots in local part (before @)
    final atIndex = email.indexOf('@');
    if (atIndex > 0) {
      final localPart = email.substring(0, atIndex);
      if (localPart.startsWith('.') || localPart.endsWith('.')) {
        return 'Email cannot start or end with a dot in the username part';
      }
    }

    return null;
  }

  /// Password strength validation
  /// 
  /// Requires:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// 
  /// Returns error message if weak, null if strong
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.trim() != password) {
      return 'Password cannot contain leading or trailing spaces';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Username validation
  /// 
  /// Requires:
  /// - 3-32 characters
  /// - Alphanumeric, underscore, and hyphen only
  /// - Must start with letter
  /// 
  /// Returns error message if invalid, null if valid
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty || username.trim() != username) {
      return 'Username is required and cannot contain spaces';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (username.length > 32) {
      return 'Username must be at most 32 characters long';
    }

    // Must start with letter
    if (!username[0].contains(RegExp(r'[a-zA-Z]'))) {
      return 'Username must start with a letter';
    }

    // Only alphanumeric, underscore, hyphen
    final usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_-]*$');
    if (!usernameRegex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, underscores, and hyphens';
    }

    return null;
  }

  /// Password confirmation validation
  /// 
  /// Compares two passwords for exact match
  /// 
  /// Returns error message if mismatch, null if match
  static String? validatePasswordMatch(String? password, String? confirmation) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (confirmation == null || confirmation.isEmpty) {
      return 'Password confirmation is required';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate entire signup form at once
  /// 
  /// Returns map of field errors (empty if all valid)
  static Map<String, String> validateSignupForm({
    required String email,
    required String username,
    required String password,
    required String passwordConfirmation,
  }) {
    final errors = <String, String>{};

    final emailError = validateEmail(email);
    if (emailError != null) errors['email'] = emailError;

    final usernameError = validateUsername(username);
    if (usernameError != null) errors['username'] = usernameError;

    final passwordError = validatePassword(password);
    if (passwordError != null) errors['password'] = passwordError;

    final confirmError = validatePasswordMatch(password, passwordConfirmation);
    if (confirmError != null) errors['confirmation'] = confirmError;

    return errors;
  }

  /// Validate entire login form at once
  /// 
  /// Returns map of field errors (empty if all valid)
  static Map<String, String> validateLoginForm({
    required String email,
    required String password,
  }) {
    final errors = <String, String>{};

    final emailError = validateEmail(email);
    if (emailError != null) errors['email'] = emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) errors['password'] = passwordError;

    return errors;
  }
}
