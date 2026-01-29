
void main() {
  print(' System Timezone Check');
  print('-----------------------');
  
  final now = DateTime.now();
  print('Now (Local): $now');
  print('Now (UTC):   ${now.toUtc()}');
  print('TimeZone Name: ${now.timeZoneName}');
  print('TimeZone Offset: ${now.timeZoneOffset}');
  
  print('\n Parsing Check');
  print('-----------------------');
  final dateStr = "2026-01-30";
  final parsed = DateTime.parse(dateStr);
  print('Parsed "$dateStr": $parsed');
  print('Is UTC? ${parsed.isUtc}');
  
  print('\n Constructor Check');
  print('-----------------------');
  final constructed = DateTime(2026, 1, 30, 8, 0); // 8:00 AM
  print('Constructed (2026, 1, 30, 8, 0): $constructed');
  print('Is UTC? ${constructed.isUtc}');
  print('In UTC: ${constructed.toUtc()}');
  
  final utcConstructed = DateTime.utc(2026, 1, 30, 8, 0);
  print('UTC Constructed (8, 0): $utcConstructed');
  print('UTC Constructed in Local: ${utcConstructed.toLocal()}');
}
