abstract final class Environment {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://sxrnykzboumtpqcokkxf.supabase.co',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN4cm55a3pib3VtdHBxY29ra3hmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQyMzA2ODksImV4cCI6MjEwOTgwNjY4OX0.xbgEr-YEnfeLq5AgJLgjohyTk1xWsnbC0igmxtGR9go',
  );
}
