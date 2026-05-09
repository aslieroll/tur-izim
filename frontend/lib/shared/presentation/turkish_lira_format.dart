/// Para gösterimi (TRY için «3.500 TL»). İş kuralı içermez.
String formatTurkishLiraAmount(double amount, {String currencyCode = 'TRY'}) {
  final rounded = amount.round();
  final negative = rounded < 0;
  final n = negative ? -rounded : rounded;
  final chars = n.toString().split('');
  final buf = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && (chars.length - i) % 3 == 0) {
      buf.write('.');
    }
    buf.write(chars[i]);
  }
  final core = buf.toString();
  final prefix = negative ? '-' : '';
  if (currencyCode == 'TRY') {
    return '$prefix$core TL';
  }
  return '$prefix$core $currencyCode';
}
