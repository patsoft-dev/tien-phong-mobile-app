import 'package:flutter/material.dart';
import 'package:qr_app/helper/services/navigation_service.dart';
import 'package:qr_app/helper/storage/local_storage.dart';
import 'package:qr_app/helper/theme/app_style.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:qr_app/helper/localization/app_localization_delegate.dart';
import 'package:qr_app/helper/localization/language.dart';
import 'package:qr_app/helper/theme/app_notifier.dart';
import 'package:qr_app/helper/theme/app_theme.dart';
import 'package:qr_app/helper/theme/theme_customizer.dart';
import 'package:qr_app/services/printer/print_service.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:qr_app/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Nạp cấu hình & tự động kết nối máy in Bluetooth đã lưu
  await PrintService.initPrintService();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  setPathUrlStrategy();

  await LocalStorage.init();
  AppStyle.init();
  await ThemeCustomizer.init();

  runApp(
    ChangeNotifierProvider<AppNotifier>(
      create: (context) => AppNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (_, notifier, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeCustomizer.instance.theme,
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: "/auth/login",
          getPages: getPageRoute(),
          builder: (context, child) {
            NavigationService.registerContext(context);
            return Directionality(
              textDirection: AppTheme.textDirection,
              child: Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => child ?? const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
        );
      },
    );
  }
}
