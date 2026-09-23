import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'app/data/services/fcm_service.dart';
import 'app/modules/home/controllers/home_controller.dart';
import 'app/routes/app_pages.dart';
import 'core/constants/app_theme.dart';
import 'core/network/api_client.dart';
import 'core/services/crash_reporter_service.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/app_logger.dart';
import 'core/widgets/connectivity_banner.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Load environment variables (.env)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    AppLogger.w('Failed to load .env file: $e');
  }

  // Initialize Crash Reporter & Offline Observability Service
  try {
    await CrashReporterService.instance.initialize();
  } catch (e) {
    AppLogger.w('CrashReporterService initialization warning: $e');
  }

  // Global Flutter UI Framework Error Handler
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    CrashReporterService.instance.recordFlutterFatalError(details);
  };

  // Global Asynchronous Unhandled Error Handler
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    CrashReporterService.instance.recordError(
      error,
      stack,
      fatal: true,
      reason: 'PlatformDispatcher Unhandled Async Error',
    );
    return true;
  };

  // Initialize Storage and API Client
  final storage = await LocalStorageService.getInstance();
  await ApiClient.initialize(storage);

  // Initialize Push Notifications (FCM) non-blockingly
  try {
    FcmService.initialize();
  } catch (e) {
    AppLogger.w('FCM initialization deferred: $e');
  }

  final initialRoute = determineInitialRoute(storage);

  // Remove splash after short delay
  Future.delayed(const Duration(milliseconds: 800), () {
    FlutterNativeSplash.remove();
  });

  runApp(CyberStoreApp(initialRoute: initialRoute));
}

String determineInitialRoute(LocalStorageService storage) {
  if (storage.hasToken) {
    AppLogger.i('Existing session found. Launching Home.');
    Get.put(HomeController(), permanent: true);
    return Routes.HOME;
  } else {
    AppLogger.i('No active session. Launching Onboarding.');
    return Routes.ONBOARDING;
  }
}

class CyberStoreApp extends StatelessWidget {
  final String initialRoute;

  const CyberStoreApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Cyber Store - Apple Official Reseller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 250),
      builder: (context, child) {
        return ConnectivityBanner(child: child ?? const SizedBox());
      },
    );
  }
}
