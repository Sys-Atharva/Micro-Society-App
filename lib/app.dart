import 'package:flutter/material.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/providers/payment_provider.dart';
import 'package:micro_society_app/providers/tenant_request_provider.dart';
import 'package:micro_society_app/providers/user_provider.dart';
import 'package:micro_society_app/screens/auth/login_screen.dart';
import 'package:micro_society_app/screens/auth/register_screen.dart';
import 'package:micro_society_app/screens/auth/role_selection_screen.dart';
import 'package:micro_society_app/screens/common/splash_screen.dart';
import 'package:micro_society_app/screens/owner/bank_details_screen.dart';
import 'package:micro_society_app/screens/owner/edit_profile_screen.dart';
import 'package:micro_society_app/screens/owner/event_detail_screen.dart';
import 'package:micro_society_app/screens/owner/flat_detail_screen.dart';
import 'package:micro_society_app/screens/owner/issue_detail_screen.dart';
import 'package:micro_society_app/screens/owner/manage_flats_screen.dart';
import 'package:micro_society_app/screens/owner/owner_dashboard.dart';
import 'package:micro_society_app/screens/owner/privacy_screen.dart';
import 'package:micro_society_app/screens/owner/profile_screen.dart';
import 'package:micro_society_app/screens/owner/settings_screen.dart';
import 'package:micro_society_app/screens/tenant/join_building_screen.dart';
import 'package:micro_society_app/screens/tenant/payments_screen.dart';
import 'package:micro_society_app/screens/tenant/profile_screen.dart';
import 'package:micro_society_app/screens/tenant/tenant_shell.dart';
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
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => TenantRequestProvider()),
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
          '/owner/flat-detail': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final flatId = args is String ? args : '';
                return FlatDetailScreen(flatId: flatId);
              },
          '/owner/flats': (context) => const ManageFlatsScreen(),
          '/owner/bank-details': (context) => const BankDetailsScreen(),
          '/owner/profile': (context) => const OwnerProfileScreen(),
          '/owner/edit-profile': (context) => const EditProfileScreen(),
          '/owner/settings': (context) => const SettingsScreen(),
          '/owner/privacy': (context) => const PrivacyScreen(),
          '/owner/event-detail': (context) => EventDetailScreen(
                eventId: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/owner/issue-detail': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final issueId = args is String ? args : '';
                return IssueDetailScreen(issueId: issueId);
              },
          '/tenant/dashboard': (context) => const TenantShell(),
          '/tenant/waiting': (context) => const WaitingRoomScreen(),
          '/tenant/join': (context) => const JoinBuildingScreen(),
          '/tenant/payments': (context) => const PaymentsScreen(),
          '/tenant/profile': (context) => const TenantProfileScreen(),
          '/tenant/event-detail': (context) => EventDetailScreen(
                eventId: ModalRoute.of(context)!.settings.arguments as String,
              ),
          '/tenant/issue-detail': (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                final issueId = args is String ? args : '';
                return IssueDetailScreen(issueId: issueId);
              },
        },
      ),
    );
  }
}
