import 'package:flutter/material.dart';

class UsersAdminPage extends StatefulWidget {
  const UsersAdminPage({super.key});

  @override
  State<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends State<UsersAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Todos';
  
  // Colores modernos
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF1E293B);
  static const Color _surfaceBg = Color(0xFF334155);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _dangerRed = Color(0xFFEF4444);
  static const Color _purpleAccent = Color(0xFF8B5CF6);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  // Lista simulada de usuarios (reemplazar con API call)
  List<User> _users = [
    User(
      id: 1,
      name: 'Juan Pérez',
      email: 'juan.perez@email.com',
      phone: '+1-234-567-8900',
      role: 'Customer',
      status: 'Activo',
      registrationDate: DateTime(2023, 12, 15),
      lastLogin: DateTime(2024, 1, 20, 14, 30),
      totalTickets: 12,
      totalSpent: 150.75,
      avatar: '👤',
    ),
    User(
      id: 2,
      name: 'María González',
      email: 'maria.gonzalez@email.com',
      phone: '+1-234-567-8901',
      role: 'Manager',
      status: 'Activo',
      registrationDate: DateTime(2023, 10, 20),
      lastLogin: DateTime(2024, 1, 20, 16, 45),
      totalTickets: 5,
      totalSpent: 90.00,
      avatar: '👩‍💼',
    ),
    User(
      id: 3,
      name: 'Carlos Rivera',
      email: 'carlos.rivera@email.com',
      phone: '+1-234-567-8902',
      role: 'Customer',
      status: 'Inactivo',
      registrationDate: DateTime(2024, 1, 5),
      lastLogin: DateTime(2024, 1, 18, 10, 15),
      totalTickets: 3,
      totalSpent: 45.50,
      avatar: '👨',
    ),
    User(
      id: 4,
      name: 'Ana López',
      email: 'ana.lopez@email.com',
      phone: '+1-234-567-8903',
      role: 'Admin',
      status: 'Activo',
      registrationDate: DateTime(2023, 8, 10),
      lastLogin: DateTime(2024, 1, 20, 9, 30),
      totalTickets: 0,
      totalSpent: 0.00,
      avatar: '👩‍💻',
    ),
    User(
      id: 5,
      name: 'Roberto Sánchez',
      email: 'roberto.sanchez@email.com',
      phone: '+1-234-567-8904',
      role: 'Customer',
      status: 'Suspendido',
      registrationDate: DateTime(2023, 11, 8),
      lastLogin: DateTime(2024, 1, 15, 20, 10),
      totalTickets: 25,
      totalSpent: 320.00,
      avatar: '👨‍🦱',
    ),
  ];

  final List<String> _filterOptions = ['Todos', 'Activo', 'Inactivo', 'Suspendido'];
  final List<String> _roleOptions = ['Customer', 'Manager', 'Admin'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<User> get _filteredUsers {
    List<User> filtered = _users;
    
    if (_selectedFilter != 'Todos') {
      filtered = filtered.where((user) => user.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) =>
        user.name.toLowerCase().contains(_searchQuery) ||
        user.email.toLowerCase().contains(_searchQuery) ||
        user.role.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    return filtered;
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gestión de Usuarios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrar cuentas y permisos',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_users.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: () => _showAddUserDialog(),
            backgroundColor: _successGreen,
            heroTag: "addUser",
            child: const Icon(Icons.person_add, color: Colors.white),
          ),
          const SizedBox(height: 24),
          _buildSearchAndFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedFilter,
            dropdownColor: _surfaceBg,
            underline: const SizedBox(),
            icon: Icon(Icons.filter_list, color: Colors.white.withOpacity(0.8)),
            style: const TextStyle(color: Colors.white),
            items: _filterOptions.map((filter) => DropdownMenuItem(
              value: filter,
              child: Text(filter, style: const TextStyle(color: Colors.white)),
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFilter = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final activeUsers = _users.where((u) => u.status == 'Activo').length;
    final totalCustomers = _users.where((u) => u.role == 'Customer').length;
    final totalRevenue = _users.fold<double>(0.0, (sum, user) => sum + user.totalSpent);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Activos', activeUsers.toString(), Icons.check_circle, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Clientes', totalCustomers.toString(), Icons.group, _primaryBlue),
          const SizedBox(width: 12),
          _buildStatCard('Ingresos', '\$${totalRevenue.toStringAsFixed(0)}', Icons.attach_money, _warningAmber),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: _textLight,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: _filteredUsers.length,
          itemBuilder: (context, index) {
            final user = _filteredUsers[index];
            return _buildUserCard(user, index);
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(User user, int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(user.status).withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header del usuario
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            user.avatar,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.name,
                                    style: const TextStyle(
                                      color: _textLight,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(user.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: _textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(user.role).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    user.role,
                                    style: TextStyle(
                                      color: _getRoleColor(user.role),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.phone, color: _textMuted, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  user.phone,
                                  style: TextStyle(color: _textMuted, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: _textMuted),
                        color: _surfaceBg,
                        onSelected: (value) => _handleMenuAction(value, user),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, color: _primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Text('Ver Perfil', style: TextStyle(color: _textLight)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: _successGreen, size: 18),
                                const SizedBox(width: 8),
                                Text('Editar', style: TextStyle(color: _textLight)),
                              ],
                            ),
                          ),
                          if (user.status == 'Activo')
                            PopupMenuItem(
                              value: 'suspend',
                              child: Row(
                                children: [
                                  Icon(Icons.block, color: _warningAmber, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Suspender', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                          if (user.status == 'Suspendido')
                            PopupMenuItem(
                              value: 'activate',
                              child: Row(
                                children: [
                                  Icon(Icons.check_circle, color: _successGreen, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Activar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: _dangerRed, size: 18),
                                const SizedBox(width: 8),
                                Text('Eliminar', style: TextStyle(color: _textLight)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Estadísticas del usuario
                  Row(
                    children: [
                      Expanded(
                        child: _buildUserStat('Tickets', user.totalTickets.toString(), Icons.confirmation_number),
                      ),
                      Expanded(
                        child: _buildUserStat('Gastado', '\$${user.totalSpent.toStringAsFixed(2)}', Icons.attach_money),
                      ),
                      Expanded(
                        child: _buildUserStat(
                          'Registro',
                          '${user.registrationDate.day}/${user.registrationDate.month}/${user.registrationDate.year}',
                          Icons.calendar_today,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _textMuted.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: _textMuted, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Último acceso: ${user.lastLogin.day}/${user.lastLogin.month}/${user.lastLogin.year} ${user.lastLogin.hour}:${user.lastLogin.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: _textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _textMuted, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _textLight,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            color: _textMuted,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Activo': return _successGreen;
      case 'Inactivo': return _textMuted;
      case 'Suspendido': return _dangerRed;
      default: return _textMuted;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin': return _dangerRed;
      case 'Manager': return _warningAmber;
      case 'Customer': return _primaryBlue;
      default: return _textMuted;
    }
  }

  void _handleMenuAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserProfile(user);
        break;
      case 'edit':
        _showEditUserDialog(user);
        break;
      case 'suspend':
        _suspendUser(user);
        break;
      case 'activate':
        _activateUser(user);
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showAddUserDialog() {
    _showUserDialog(title: 'Agregar Usuario');
  }

  void _showEditUserDialog(User user) {
    _showUserDialog(title: 'Editar Usuario', user: user);
  }

  void _showUserDialog({required String title, User? user}) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    String selectedRole = user?.role ?? 'Customer';
    String selectedStatus = user?.status ?? 'Activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: _textLight)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: _textLight),
                decoration: _buildInputDecoration('Nombre completo'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: _textLight),
                decoration: _buildInputDecoration('Email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: _textLight),
                decoration: _buildInputDecoration('Teléfono'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                style: const TextStyle(color: _textLight),
                decoration: _buildInputDecoration('Rol'),
                dropdownColor: _surfaceBg,
                items: _roleOptions.map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role, style: const TextStyle(color: _textLight)),
                )).toList(),
                onChanged: (value) => selectedRole = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                style: const TextStyle(color: _textLight),
                decoration: _buildInputDecoration('Estado'),
                dropdownColor: _surfaceBg,
                items: ['Activo', 'Inactivo', 'Suspendido'].map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status, style: const TextStyle(color: _textLight)),
                )).toList(),
                onChanged: (value) => selectedStatus = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveUser(user, nameController.text, emailController.text, 
                       phoneController.text, selectedRole, selectedStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(user == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _textMuted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryBlue),
      ),
    );
  }

  void _saveUser(User? existingUser, String name, String email, String phone, String role, String status) {
    if (existingUser == null) {
      // Agregar nuevo usuario
      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        email: email,
        phone: phone,
        role: role,
        status: status,
        registrationDate: DateTime.now(),
        lastLogin: DateTime.now(),
        totalTickets: 0,
        totalSpent: 0.0,
        avatar: '👤',
      );
      setState(() {
        _users.add(newUser);
      });
    } else {
      // Editar usuario existente
      setState(() {
        existingUser.name = name;
        existingUser.email = email;
        existingUser.phone = phone;
        existingUser.role = role;
        existingUser.status = status;
      });
    }
  }

  void _showUserProfile(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(user.avatar, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text('Perfil de Usuario', style: const TextStyle(color: _textLight)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Nombre', user.name),
              _buildDetailRow('Email', user.email),
              _buildDetailRow('Teléfono', user.phone),
              _buildDetailRow('Rol', user.role),
              _buildDetailRow('Estado', user.status),
              _buildDetailRow('Tickets comprados', user.totalTickets.toString()),
              _buildDetailRow('Total gastado', '\$${user.totalSpent.toStringAsFixed(2)}'),
              _buildDetailRow('Registro', '${user.registrationDate.day}/${user.registrationDate.month}/${user.registrationDate.year}'),
              _buildDetailRow('Último acceso', '${user.lastLogin.day}/${user.lastLogin.month}/${user.lastLogin.year}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: _textMuted, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: _textLight),
            ),
          ),
        ],
      ),
    );
  }

  void _suspendUser(User user) {
    setState(() {
      user.status = 'Suspendido';
    });
  }

  void _activateUser(User user) {
    setState(() {
      user.status = 'Activo';
    });
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
        content: Text(
          '¿Estás seguro de que deseas eliminar el usuario "${user.name}"?',
          style: TextStyle(color: _textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _deleteUser(User user) {
    setState(() {
      _users.removeWhere((u) => u.id == user.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            _buildUsersList(),
          ],
        ),
      ),
    );
  }
}

class User {
  int id;
  String name;
  String email;
  String phone;
  String role;
  String status;
  DateTime registrationDate;
  DateTime lastLogin;
  int totalTickets;
  double totalSpent;
  String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.registrationDate,
    required this.lastLogin,
    required this.totalTickets,
    required this.totalSpent,
    required this.avatar,
  });
}