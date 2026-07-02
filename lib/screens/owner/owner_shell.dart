import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:micro_society_app/config/theme.dart';
import 'package:micro_society_app/providers/auth_provider.dart';
import 'package:micro_society_app/providers/event_provider.dart';
import 'package:micro_society_app/providers/flat_provider.dart';
import 'package:micro_society_app/providers/issue_provider.dart';
import 'package:micro_society_app/providers/tenant_request_provider.dart';
import 'package:micro_society_app/screens/owner/tabs/events_tab.dart';
import 'package:micro_society_app/screens/owner/tabs/flats_tab.dart';
import 'package:micro_society_app/screens/owner/tabs/home_tab.dart';
import 'package:micro_society_app/screens/owner/tabs/issues_tab.dart';
import 'package:micro_society_app/services/firestore_service.dart';
import 'package:micro_society_app/utils/building_code_generator.dart';
import 'package:provider/provider.dart';

class OwnerShell extends StatefulWidget {
  const OwnerShell({super.key});

  @override
  State<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends State<OwnerShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStreams();
    });
  }

  Future<void> _initializeStreams() async {
    final auth = context.read<AuthProvider>();
    var buildingCode = auth.userModel?.buildingCode;
    final ownerId = auth.firebaseUser?.uid;

    if (buildingCode == null && ownerId != null) {
      final firestoreService = FirestoreService();
      buildingCode = await BuildingCodeGenerator.generateUnique();
      await firestoreService.updateDocument(
        collection: 'users',
        docId: ownerId,
        data: {'buildingCode': buildingCode},
      );
      if (!mounted) return;
      await auth.refreshUser();
    }

    if (!mounted) return;

    if (buildingCode != null) {
      context.read<FlatProvider>().streamFlatsByBuilding(buildingCode);
      context.read<IssueProvider>().streamIssuesByBuilding(buildingCode);
      context.read<EventProvider>().streamEventsByBuilding(buildingCode);
      context.read<TenantRequestProvider>().streamPendingTenants(buildingCode);
    } else if (ownerId != null) {
      context.read<FlatProvider>().streamFlatsByOwner(ownerId);
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'O';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: AppTheme.surfaceColor,
          body: Column(
            children: [
              _buildAppBar(auth),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: const [
                    HomeTab(),
                    FlatsTab(),
                    EventsTab(),
                    IssuesTab(),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildAppBar(AuthProvider auth) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(204),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0B1C30).withAlpha(8),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 20,
                  color: AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Micro-Society',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurfaceColor,
                      ),
                    ),
                    Text(
                      'Owner Dashboard',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.onPrimaryContainerColor,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/owner/profile'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryFixedColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.secondaryColor.withAlpha(60),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(auth.userModel?.name),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(12),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _NavItem(
                    icon: Icons.domain_rounded,
                    label: 'Flats',
                    isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _NavItem(
                    icon: Icons.event_rounded,
                    label: 'Events',
                    isActive: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _NavItem(
                    icon: Icons.report_problem_rounded,
                    label: 'Issues',
                    isActive: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.secondaryContainerColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive
                  ? Colors.white
                  : AppTheme.onSurfaceVariantColor,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
