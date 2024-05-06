import 'dart:math';

String generatePosition() {
  final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final random = Random();

  final randomDay = days[random.nextInt(days.length)];

  final randomLetter = String.fromCharCode(random.nextInt(26) + 65);

  final randomNumbers = random.nextInt(900) + 100;

  return '$randomDay$randomLetter$randomNumbers';
}

