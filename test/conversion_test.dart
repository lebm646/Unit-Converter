import 'package:flutter_test/flutter_test.dart';
import 'package:converter/conversion.dart';

void main() {
  test('km to mi ~ 0.621371', () {
    final v = convert(value: 1, fromCode: 'km', toCode: 'mi');
    expect((v - 0.621371).abs() < 1e-6, true);
  });

  test('lb to kg ~ 0.45359237', () {
    final v = convert(value: 1, fromCode: 'lb', toCode: 'kg');
    expect((v - 0.45359237).abs() < 1e-9, true);
  });

  test('in to cm = 2.54 (via m and g bases)', () {
    final v = convert(value: 1, fromCode: 'in', toCode: 'm') * 100;
    expect((v - 2.54).abs() < 1e-9, true);
  });
}
