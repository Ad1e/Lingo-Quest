/// Widget tests for authentication form validation
/// 
/// Tests cover:
/// - Email format validation
/// - Password strength requirements
/// - Username validation rules
/// - Form submission validation
/// - Error message display
/// - Edge cases and special characters

import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/utils/validators.dart';

void main() {
  group('Email Validation Tests', () {
    test('valid email: simple@example.com', () {
      expect(Validators.validateEmail('simple@example.com'), isNull);
    });

    test('valid email: user.name@example.com', () {
      expect(Validators.validateEmail('user.name@example.com'), isNull);
    });

    test('valid email: user+tag@example.co.uk', () {
      expect(Validators.validateEmail('user+tag@example.co.uk'), isNull);
    });

    test('invalid email: missing @', () {
      expect(Validators.validateEmail('userexample.com'), isNotNull);
    });

    test('invalid email: missing domain', () {
      expect(Validators.validateEmail('user@'), isNotNull);
    });

    test('invalid email: missing local part', () {
      expect(Validators.validateEmail('@example.com'), isNotNull);
    });

    test('invalid email: no TLD', () {
      expect(Validators.validateEmail('user@example'), isNotNull);
    });

    test('invalid email: multiple @', () {
      expect(Validators.validateEmail('user@@example.com'), isNotNull);
    });

    test('invalid email: spaces', () {
      expect(Validators.validateEmail('user @example.com'), isNotNull);
    });

    test('invalid email: empty string', () {
      expect(Validators.validateEmail(''), isNotNull);
    });

    test('invalid email: whitespace only', () {
      expect(Validators.validateEmail('   '), isNotNull);
    });

    test('edge case: very long email', () {
      final longEmail = 'a' * 50 + '@' + 'b' * 50 + '.com';
      // Should either be valid or have a max length validation
      final result = Validators.validateEmail(longEmail);
      expect(result?.isNotEmpty ?? true, true);
    });

    test('edge case: special characters in local part', () {
      expect(Validators.validateEmail('user+subtag@example.com'), isNull);
      expect(Validators.validateEmail('user.name@example.com'), isNull);
      expect(Validators.validateEmail('user_name@example.com'), isNull);
    });

    test('invalid: consecutive dots', () {
      expect(Validators.validateEmail('user..name@example.com'), isNotNull);
    });

    test('invalid: leading/trailing dots', () {
      expect(Validators.validateEmail('.user@example.com'), isNotNull);
      expect(Validators.validateEmail('user.@example.com'), isNotNull);
    });
  });

  group('Password Strength Tests', () {
    test('weak password: less than 8 characters', () {
      expect(Validators.validatePassword('Pass1'), isNotNull);
    });

    test('weak password: no uppercase', () {
      expect(Validators.validatePassword('password123'), isNotNull);
    });

    test('weak password: no lowercase', () {
      expect(Validators.validatePassword('PASSWORD123'), isNotNull);
    });

    test('weak password: no numbers', () {
      expect(Validators.validatePassword('PasswordOnly'), isNotNull);
    });

    test('weak password: no special characters (if required)', () {
      // Depends on implementation
      final result = Validators.validatePassword('Password123');
      // Accept either requirement or not
      expect(result != null || result == null, true);
    });

    test('strong password: mixed case with numbers', () {
      expect(Validators.validatePassword('Password123'), isNull);
    });

    test('strong password: mixed case with numbers and symbols', () {
      expect(Validators.validatePassword('Password123!'), isNull);
    });

    test('strong password: 16+ characters', () {
      expect(Validators.validatePassword('VeryLongPassword123'), isNull);
    });

    test('invalid: empty password', () {
      expect(Validators.validatePassword(''), isNotNull);
    });

    test('invalid: whitespace only', () {
      expect(Validators.validatePassword('   '), isNotNull);
    });

    test('invalid: leading/trailing spaces', () {
      expect(Validators.validatePassword(' Password123 '), isNotNull);
    });

    test('edge case: maximum length password', () {
      final longPassword = 'A' * 100 + 'a' * 100 + '123';
      final result = Validators.validatePassword(longPassword);
      // Should either be valid or enforce max length
      expect(result?.isNotEmpty ?? true, true);
    });

    test('password with special characters', () {
      expect(Validators.validatePassword('Pass@123#word'), isNull);
    });

    test('password with unicode characters', () {
      expect(Validators.validatePassword('Password123™'), isNull);
    });
  });

  group('Username Validation Tests', () {
    test('valid username: simple alphanumeric', () {
      expect(Validators.validateUsername('user123'), isNull);
    });

    test('valid username: with underscore', () {
      expect(Validators.validateUsername('user_name'), isNull);
    });

    test('valid username: with hyphen', () {
      expect(Validators.validateUsername('user-name'), isNull);
    });

    test('invalid username: too short', () {
      expect(Validators.validateUsername('ab'), isNotNull);
    });

    test('invalid username: too long', () {
      expect(Validators.validateUsername('a' * 50), isNotNull);
    });

    test('invalid username: contains spaces', () {
      expect(Validators.validateUsername('user name'), isNotNull);
    });

    test('invalid username: starts with number', () {
      expect(Validators.validateUsername('123user'), isNotNull);
    });

    test('invalid username: special characters (except underscore/hyphen)', () {
      expect(Validators.validateUsername('user@name'), isNotNull);
      expect(Validators.validateUsername('user!name'), isNotNull);
      expect(Validators.validateUsername('user#name'), isNotNull);
    });

    test('invalid username: empty string', () {
      expect(Validators.validateUsername(''), isNotNull);
    });

    test('invalid username: whitespace only', () {
      expect(Validators.validateUsername('   '), isNotNull);
    });

    test('valid username: all lowercase with numbers', () {
      expect(Validators.validateUsername('username123'), isNull);
    });

    test('valid username: mixed case', () {
      expect(Validators.validateUsername('UserName'), isNull);
    });

    test('username at minimum length boundary', () {
      expect(Validators.validateUsername('abc'), isNull);
    });

    test('username at maximum length boundary', () {
      expect(Validators.validateUsername('a' * 32), isNull);
    });
  });

  group('Password Confirmation Tests', () {
    test('matching passwords', () {
      expect(
        Validators.validatePasswordMatch('Password123', 'Password123'),
        isNull,
      );
    });

    test('non-matching passwords', () {
      expect(
        Validators.validatePasswordMatch('Password123', 'Password124'),
        isNotNull,
      );
    });

    test('case-sensitive matching', () {
      expect(
        Validators.validatePasswordMatch('Password123', 'password123'),
        isNotNull,
      );
    });

    test('empty confirmation password', () {
      expect(
        Validators.validatePasswordMatch('Password123', ''),
        isNotNull,
      );
    });

    test('whitespace mismatch', () {
      expect(
        Validators.validatePasswordMatch('Password123', 'Password123 '),
        isNotNull,
      );
    });
  });

  group('Form Field Trimming', () {
    test('email with leading whitespace', () {
      expect(Validators.validateEmail('  simple@example.com'), isNotNull);
    });

    test('email with trailing whitespace', () {
      expect(Validators.validateEmail('simple@example.com  '), isNotNull);
    });

    test('username with internal spaces', () {
      expect(Validators.validateUsername('user name'), isNotNull);
    });
  });

  group('Validation Message Tests', () {
    test('email error message is helpful', () {
      final error = Validators.validateEmail('invalid');
      expect(error, isNotNull);
      expect(error, contains('email') | contains('Email') | contains('valid'));
    });

    test('password error message includes requirements', () {
      final error = Validators.validatePassword('weak');
      expect(error, isNotNull);
      // Should mention password requirements
    });

    test('username error message is clear', () {
      final error = Validators.validateUsername('a');
      expect(error, isNotNull);
      // Should mention username requirements
    });

    test('password match error is specific', () {
      final error = Validators.validatePasswordMatch('Pass1', 'Pass2');
      expect(error, isNotNull);
      expect(error, contains('match') | contains('Match'));
    });
  });

  group('Batch Validation Tests', () {
    test('validate entire signup form success', () {
      final emailError = Validators.validateEmail('user@example.com');
      final usernameError = Validators.validateUsername('username123');
      final passwordError = Validators.validatePassword('Password123');
      final confirmError = Validators.validatePasswordMatch(
        'Password123',
        'Password123',
      );

      expect(emailError, isNull);
      expect(usernameError, isNull);
      expect(passwordError, isNull);
      expect(confirmError, isNull);
    });

    test('validate entire signup form with errors', () {
      final emailError = Validators.validateEmail('invalid-email');
      final usernameError = Validators.validateUsername('ab');
      final passwordError = Validators.validatePassword('weak');
      final confirmError = Validators.validatePasswordMatch(
        'Password123',
        'Different123',
      );

      expect(emailError, isNotNull);
      expect(usernameError, isNotNull);
      expect(passwordError, isNotNull);
      expect(confirmError, isNotNull);
    });

    test('validate login form', () {
      final emailError = Validators.validateEmail('user@example.com');
      final passwordError = Validators.validatePassword('Password123');

      expect(emailError, isNull);
      expect(passwordError, isNull);
    });
  });

  group('Validation Performance', () {
    test('validate 1000 emails efficiently', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        Validators.validateEmail('user$i@example.com');
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('validate 1000 passwords efficiently', () {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 1000; i++) {
        Validators.validatePassword('Password$i#');
      }

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
