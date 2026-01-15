import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Core
import 'core/constants/app_theme.dart';
import 'core/services/database_helper.dart';
import 'core/services/eligibility_engine.dart';

// Data Layer
import 'data/datasources/scheme_local_datasource.dart';
import 'data/datasources/scheme_remote_datasource.dart';
import 'data/datasources/user_session_local_datasource.dart';
import 'data/repositories/scheme_repository_impl.dart';
import 'data/repositories/user_session_repository_impl.dart';

// Domain Layer
import 'domain/usecases/scheme_usecases.dart';
import 'domain/usecases/user_session_usecases.dart';

// Presentation Layer
import 'presentation/viewmodels/scheme_viewmodel.dart';
import 'presentation/viewmodels/voice_intake_viewmodel.dart';
import 'presentation/viewmodels/eligibility_viewmodel.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const AawaazPlusApp());
}

class AawaazPlusApp extends StatelessWidget {
  const AawaazPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final dbHelper = DatabaseHelper();
    final httpClient = http.Client();
    
    // Data sources
    final schemeLocalDataSource = SchemeLocalDataSource(dbHelper);
    final schemeRemoteDataSource = SchemeRemoteDataSource(httpClient);
    final userSessionLocalDataSource = UserSessionLocalDataSource(dbHelper);
    
    // Repositories
    final schemeRepository = SchemeRepositoryImpl(
      remoteDataSource: schemeRemoteDataSource,
      localDataSource: schemeLocalDataSource,
    );
    final userSessionRepository = UserSessionRepositoryImpl(
      localDataSource: userSessionLocalDataSource,
    );
    
    // Use cases
    final syncSchemes = SyncSchemes(schemeRepository);
    final getActiveSchemes = GetActiveSchemes(schemeRepository);
    final saveUserSession = SaveUserSession(userSessionRepository);
    
    // Services
    final eligibilityEngine = EligibilityEngine();
    
    return MultiProvider(
      providers: [
        // ViewModels
        ChangeNotifierProvider(
          create: (_) => SchemeViewModel(
            syncSchemes: syncSchemes,
            getActiveSchemes: getActiveSchemes,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VoiceIntakeViewModel(
            saveUserSession: saveUserSession,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EligibilityViewModel(
            eligibilityEngine: eligibilityEngine,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Aawaaz Plus',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
