import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://cxzzmfqxyxondlzledjn.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4enptZnF4eXhvbmRsemxlZGpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI1NDExNDMsImV4cCI6MjA5ODExNzE0M30.JcSfMGc6u6PmlSNEzZA96r9IoWdV88C7z-n68RiouMk';

  static const String acpUrl = 'https://qcycuwfohxmdatrtawlw.supabase.co';
  static const String acpAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjeWN1d2ZvaHhtZGF0cnRhd2x3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNzIyMTQsImV4cCI6MjA5ODY0ODIxNH0.mXTx31wzcQGIn1nrIP2LZCAQjVwFp2hUa_ppTOnKL_s';

  static SupabaseClient? _acpClient;
  static SupabaseClient get acpClient {
    _acpClient ??= SupabaseClient(acpUrl, acpAnonKey);
    return _acpClient!;
  }

  static SupabaseClient? _odour2Client;
  static SupabaseClient get odour2Client {
    _odour2Client ??= SupabaseClient(url, anonKey);
    return _odour2Client!;
  }
}
