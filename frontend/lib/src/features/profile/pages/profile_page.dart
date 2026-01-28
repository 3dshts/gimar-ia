// frontend/lib/src/features/profile/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/common_widgets/custom_app_bar.dart';
import '../../../core/common_widgets/floating_back_button.dart';
import '../../../core/common_widgets/admin_toggle_slider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/user/user_cubit.dart';
import '../../../core/user/user_state.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/models/user.model.dart';
import '../../../core/models/log.model.dart';
import '../widgets/user_table.dart';
import '../widgets/log_table.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _mostrarUsuarios = true;
  late Future<List<UserModel>> _usersFuture;
  late Future<List<LogModel>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
    _logsFuture = _loadLogs();
  }

  Future<List<UserModel>> _loadUsers() async {
    final response = await DioClient.getAllUsers();
    final List data = response.data;
    return data.map((json) => UserModel.fromJson(json)).toList();
  }

  Future<List<LogModel>> _loadLogs() async {
    final response = await DioClient.getAllLogs();
    final List data = response.data['logs'];
    return data.map((json) => LogModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    // Definir breakpoints responsive
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    String username = 'CARGANDO';
    String fullName = '';
    String email = '';
    bool isAdmin = false;

    if (userState is UserLoaded) {
      username = userState.username;
      fullName = userState.fullName;
      email = userState.email;
      isAdmin = userState.isAdmin;
    }

    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(screenWidth),
                    vertical: _getVerticalPadding(screenWidth),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight -
                          _getVerticalPadding(screenWidth) * 2,
                    ),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(
                          maxWidth: _getMaxWidth(screenWidth),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(context, isMobile),
                            SizedBox(height: isMobile ? 24 : 32),
                            _buildDivider(),
                            SizedBox(height: isMobile ? 16 : 24),
                            _buildUserInfoSection(
                              username,
                              fullName,
                              email,
                              isMobile,
                            ),
                            if (isAdmin) ...[
                              SizedBox(height: isMobile ? 24 : 32),
                              _buildAdminSection(context, isMobile, isTablet),
                            ],
                            // Espaciado adicional para evitar overflow
                            SizedBox(height: isMobile ? 80 : 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const FloatingBackButton(),
          ],
        ),
      ),
    );
  }

  // Métodos para calcular padding y dimensiones responsive
  double _getHorizontalPadding(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1024) return 32.0;
    return 48.0;
  }

  double _getVerticalPadding(double screenWidth) {
    if (screenWidth < 600) return 16.0;
    if (screenWidth < 1024) return 24.0;
    return 32.0;
  }

  double _getMaxWidth(double screenWidth) {
    if (screenWidth < 600) return double.infinity;
    if (screenWidth < 1024) return 700.0;
    return 900.0;
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Center(
      child: Text(
        'Perfil',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 20 : 24,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: AppColors.accent, thickness: 2, height: 2);
  }

  Widget _buildUserInfoSection(
    String username,
    String fullName,
    String email,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField('Usuario', username, isMobile),
        SizedBox(height: isMobile ? 16 : 20),
        _buildFormField('Nombre completo', fullName, isMobile),
        SizedBox(height: isMobile ? 16 : 20),
        _buildFormField('Correo electrónico', email, isMobile),
      ],
    );
  }

  Widget _buildFormField(String label, String value, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 6),
        TextFormField(
          initialValue: value,
          readOnly: true,
          decoration: _disabledDecoration(),
          style: TextStyle(fontSize: isMobile ? 14 : 16),
        ),
      ],
    );
  }

  Widget _buildAdminSection(
    BuildContext context,
    bool isMobile,
    bool isTablet,
  ) {
    return Column(
      children: [
        _buildDivider(),
        SizedBox(height: isMobile ? 16 : 24),
        Center(
          child: Text(
            'Zona de Administración',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _buildToggleSection(isMobile),
        SizedBox(height: isMobile ? 16 : 24),
        _buildAdminTable(isMobile, isTablet),
      ],
    );
  }

  Widget _buildToggleSection(bool isMobile) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: isMobile ? 8 : 12,
        children: [
          Text(
            'Usuarios',
            style: TextStyle(
              fontWeight: _mostrarUsuarios
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _mostrarUsuarios ? AppColors.primary : AppColors.text,
              fontSize: isMobile ? 0 : 14,
            ),
          ),
          AdminToggleSlider(
            isUserSelected: _mostrarUsuarios,
            onChanged: (val) => setState(() => _mostrarUsuarios = val),
          ),
          Text(
            'Logs',
            style: TextStyle(
              fontWeight: _mostrarUsuarios
                  ? FontWeight.normal
                  : FontWeight.bold,
              color: _mostrarUsuarios ? AppColors.text : AppColors.primary,
              fontSize: isMobile ? 0 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminTable(bool isMobile, bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: _mostrarUsuarios
          ? FutureBuilder<List<UserModel>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: isMobile ? 200 : 300,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: isMobile ? 100 : 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: isMobile ? 32 : 48,
                          ),
                          SizedBox(height: isMobile ? 8 : 12),
                          Text(
                            'Error al cargar usuarios',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.data?.isEmpty ?? true) {
                  return SizedBox(
                    height: isMobile ? 100 : 150,
                    child: Center(
                      child: Text(
                        'No hay usuarios disponibles',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return UserTable(users: snapshot.data!);
                }
              },
            )
          : FutureBuilder<List<LogModel>>(
              future: _logsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: isMobile ? 200 : 300,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: isMobile ? 100 : 150,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: isMobile ? 32 : 48,
                          ),
                          SizedBox(height: isMobile ? 8 : 12),
                          Text(
                            'Error al cargar logs',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.data?.isEmpty ?? true) {
                  return SizedBox(
                    height: isMobile ? 100 : 150,
                    child: Center(
                      child: Text(
                        'No hay logs disponibles',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return LogTable(logs: snapshot.data!);
                }
              },
            ),
    );
  }

  InputDecoration _disabledDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
    );
  }
}
