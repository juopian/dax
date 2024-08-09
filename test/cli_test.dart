import 'package:dax/dax.dart';
import 'package:test/test.dart';

void main() {
  test('calculate', () {
    Scanner scanner = Scanner('var a = 1;');
    scanner.scanToken();
    expect(scanner.current, 3);
  });
}
