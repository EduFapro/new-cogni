import 'dart:io';

Future<void> main() async {
  print("🔥 Running fake seed generation + applying to database...\n");

  // 1. Generate encrypted SQL
  final gen = await Process.run(
    'dart',
    ['run', 'lib/fake_prod_seed.dart'],
  );

  stdout.write(gen.stdout);
  stderr.write(gen.stderr);

  // Check for errors
  if (gen.exitCode != 0) {
    print('❌ Failed generating fake seeds.');
    exit(gen.exitCode);
  }

  print('\n✅ Fake seed SQL generation complete.\n');

  // 2. Apply SQL into local sqflite database
  final apply = await Process.run(
    'dart',
    ['run', 'lib/apply_fake_seed.dart'],
  );

  stdout.write(apply.stdout);
  stderr.write(apply.stderr);

  if (apply.exitCode != 0) {
    print('❌ Failed applying SQL to local DB.');
    exit(apply.exitCode);
  }

  print('\n🎉 ALL DONE — database seeded successfully!');
}
