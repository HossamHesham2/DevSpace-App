import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@module
abstract class FirebaseModule {
  @lazySingleton
  Supabase get supabase => Supabase.instance;

  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}