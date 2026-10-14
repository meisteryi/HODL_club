import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers/hodl_provider.dart';
import 'screens/main_layout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DopamineHodlApp());
}

class DopamineHodlApp extends StatelessWidget {
  const DopamineHodlApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.dark().textTheme;
    final textTheme = GoogleFonts.notoSansKrTextTheme(baseTextTheme);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HodlProvider()),
      ],
      child: MaterialApp(
        title: '금딸 존버 클럽 (NoFap HODL)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.neonGreen,
            secondary: AppColors.electricRed,
            surface: AppColors.surface,
            error: AppColors.electricRed,
            onPrimary: AppColors.textInverse,
            onSurface: AppColors.textPrimary,
          ),
          textTheme: textTheme.apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
          dividerColor: AppColors.border,
          cardColor: AppColors.cardSurface,
          dialogTheme: const DialogThemeData(backgroundColor: AppColors.surface),
        ),
        home: const MainLayoutScreen(),
      ),
    );
  }
}
