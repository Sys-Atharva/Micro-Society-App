import 'package:flutter/material.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:micro_society_app/screens/auth/login_screen.dart';
import 'package:micro_society_app/screens/auth/register_screen.dart';
import 'package:micro_society_app/screens/auth/role_selection_screen.dart';
import 'package:micro_society_app/screens/common/splash_screen.dart';
import 'package:micro_society_app/screens/owner/bank_details_screen.dart';
import 'package:micro_society_app/screens/owner/event_detail_screen.dart';
import 'package:micro_society_app/screens/owner/issues_screen.dart';
import 'package:micro_society_app/screens/owner/manage_flats_screen.dart';
import 'package:micro_society_app/screens/owner/owner_dashboard.dart';
import 'package:micro_society_app/screens/owner/profile_screen.dart';
import 'package:micro_society_app/screens/tenant/issues_screen.dart';
import 'package:micro_society_app/screens/tenant/join_building_screen.dart';
import 'package:micro_society_app/screens/tenant/payments_screen.dart';
import 'package:micro_society_app/screens/tenant/tenant_dashboard.dart';
import 'package:micro_society_app/screens/tenant/waiting_room_screen.dart';
import 'package:provider/provider.dart';

class MicroSocietyApp extends StatelessWidget {
  const MicroSocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FlatProvider()),
        ChangeNotifierProvider(create: (_) => IssueProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: MaterialApp(
        title: 'Micro Society',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/role-selection': (context) => const RoleSelectionScreen(),
          '/owner/dashboard': (context) => const OwnerDashboard(),
          '/owner/flats': (context) => const ManageFlatsScreen(),
          '/owner/issues': (context) => const OwnerIssuesScreen(),
          '/owner/bank-details': (context) => const BankDetailsScreen(),
          '/owner/profile': (context) => const OwnerProfileScreen(),
          '/owner/event-detail': (context) => EventDetailScreen(
                eventId: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/tenant/dashboard': (context) => const TenantDashboard(),
          '/tenant/waiting': (context) => const WaitingRoomScreen(),
          '/tenant/join': (context) => const JoinBuildingScreen(),
          '/tenant/payments': (context) => const PaymentsScreen(),
          '/tenant/issues': (context) => const TenantIssuesScreen(),
        },
      ),
    );
  }
}
