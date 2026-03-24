import 'package:flutter_test/flutter_test.dart';
import 'package:edu_assistant/utils/helpers.dart';

void main() {
  group('String Extension Tests', () {
    test('isNullOrEmpty should return true for empty string', () {
      expect(''.isNullOrEmpty, true);
      expect('   '.isNullOrEmpty, true);
      expect('hello'.isNullOrEmpty, false);
    });
    
    test('isValidEmail should validate email', () {
      expect('test@example.com'.isValidEmail, true);
      expect('user.name@domain.co.uk'.isValidEmail, true);
      expect('invalid'.isValidEmail, false);
      expect('@example.com'.isValidEmail, false);
      expect('user@'.isValidEmail, false);
    });
    
    test('isValidPhone should validate Chinese phone number', () {
      expect('13800138000'.isValidPhone, true);
      expect('19912345678'.isValidPhone, true);
      expect('12345678901'.isValidPhone, false);
      expect('1380013800'.isValidPhone, false);
    });
    
    test('isValidPassword should validate password', () {
      expect('123456'.isValidPassword, true);
      expect('password'.isValidPassword, true);
      expect('12345'.isValidPassword, false);
      expect(''.isValidPassword, false);
    });
    
    test('capitalize should capitalize first letter', () {
      expect('hello'.capitalize(), 'Hello');
      expect('H'.capitalize(), 'H');
      expect(''.capitalize(), '');
    });
    
    test('mask should hide middle characters', () {
      expect('13800138000'.mask(), '138****8000');
      expect('test@example.com'.mask(start: 4, end: 7), 'test****e.com');
    });
  });
  
  group('DateTime Extension Tests', () {
    test('formatDate should format correctly', () {
      final date = DateTime(2024, 1, 15);
      expect(date.formatDate(), '2024-01-15');
    });
    
    test('formatTime should format correctly', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      expect(date.formatTime(), '14:30');
    });
    
    test('formatDateTime should format correctly', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      expect(date.formatDateTime(), '2024-01-15 14:30');
    });
    
    test('isToday should work correctly', () {
      final today = DateTime.now();
      expect(today.isToday, true);
      
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(yesterday.isToday, false);
    });
    
    test('isYesterday should work correctly', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      // Set same hour, minute, second to ensure only day differs
      final yesterdaySameTime = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
      );
      expect(yesterdaySameTime.isYesterday, true);
    });
    
    test('isOverdue should work correctly', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(past.isOverdue, true);
      
      final future = DateTime.now().add(const Duration(days: 1));
      expect(future.isOverdue, false);
    });
  });
  
  group('Num Extension Tests', () {
    test('toCurrency should format correctly', () {
      expect((100.5).toCurrency(), '¥100.50');
      expect((99).toCurrency(), '¥99.00');
    });
    
    test('toPercentage should format correctly', () {
      expect((85.5).toPercentage(), '85.5%');
      expect((100).toPercentage(decimals: 0), '100%');
    });
    
    test('formatNumber should add thousand separators', () {
      expect((1000).formatNumber(), '1,000');
      expect((1000000).formatNumber(), '1,000,000');
      expect((100).formatNumber(), '100');
    });
  });
  
  group('List Extension Tests', () {
    test('safeGet should return null for out of bounds', () {
      final list = [1, 2, 3];
      
      expect(list.safeGet(0), 1);
      expect(list.safeGet(2), 3);
      expect(list.safeGet(3), null);
      expect(list.safeGet(-1), null);
    });
    
    test('groupBy should group correctly', () {
      final items = [
        {'name': 'Alice', 'age': 20},
        {'name': 'Bob', 'age': 25},
        {'name': 'Charlie', 'age': 20},
      ];
      
      final grouped = items.groupBy((item) => item['age']);
      
      expect(grouped[20]?.length, 2);
      expect(grouped[25]?.length, 1);
    });
    
    test('distinct should remove duplicates', () {
      final list = [1, 2, 2, 3, 3, 3];
      expect(list.distinct(), [1, 2, 3]);
      
      final items = [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
        {'id': 1, 'name': 'Alice'},
      ];
      
      final distinct = items.distinct((item) => item['id']);
      expect(distinct.length, 2);
    });
  });
  
  group('Validator Tests', () {
    test('validateUsername should validate correctly', () {
      expect(Validator.validateUsername(''), '请输入用户名');
      expect(Validator.validateUsername('ab'), '用户名至少 3 个字符');
      expect(Validator.validateUsername('valid_user'), null);
      expect(Validator.validateUsername('用户 123'), null);
    });
    
    test('validateEmail should validate correctly', () {
      expect(Validator.validateEmail(''), '请输入邮箱');
      expect(Validator.validateEmail('invalid'), '请输入有效的邮箱地址');
      expect(Validator.validateEmail('test@example.com'), null);
    });
    
    test('validatePassword should validate correctly', () {
      expect(Validator.validatePassword(''), '请输入密码');
      expect(Validator.validatePassword('12345'), '密码至少 6 个字符');
      expect(Validator.validatePassword('123456'), null);
    });
    
    test('validateConfirmPassword should validate correctly', () {
      expect(Validator.validateConfirmPassword('', '123456'), '请确认密码');
      expect(Validator.validateConfirmPassword('123456', '1234567'), '两次输入的密码不一致');
      expect(Validator.validateConfirmPassword('123456', '123456'), null);
    });
    
    test('validateRequired should validate correctly', () {
      expect(Validator.validateRequired('', '姓名'), '请输入姓名');
      expect(Validator.validateRequired('张三', '姓名'), null);
    });
    
    test('validateLength should validate correctly', () {
      expect(Validator.validateLength('', 1, 10, '内容'), '请输入内容');
      expect(Validator.validateLength('ab', 3, 10, '内容'), '内容至少 3 个字符');
      expect(Validator.validateLength('abcdefghijk', 1, 10, '内容'), '内容最多 10 个字符');
      expect(Validator.validateLength('abc', 1, 10, '内容'), null);
    });
  });
  
  group('Bool Extension Tests', () {
    test('fold should return correct value', () {
      expect(true.fold('yes', 'no'), 'yes');
      expect(false.fold('yes', 'no'), 'no');
    });
    
    test('ifTrue should execute action when true', () {
      var executed = false;
      true.ifTrue(() => executed = true);
      expect(executed, true);
      
      executed = false;
      false.ifTrue(() => executed = true);
      expect(executed, false);
    });
    
    test('ifFalse should execute action when false', () {
      var executed = false;
      false.ifFalse(() => executed = true);
      expect(executed, true);
      
      executed = false;
      true.ifFalse(() => executed = true);
      expect(executed, false);
    });
  });
}
