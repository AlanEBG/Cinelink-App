import 'package:flutter/material.dart';

class RoomsAdminPage extends StatefulWidget {
  const RoomsAdminPage({super.key});

  @override
  State<RoomsAdminPage> createState() => _RoomsAdminPageState();
}

class _RoomsAdminPageState extends State<RoomsAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Colores modernos
  static const Color _darkBg = Color(0xFF0F172A);
  static const Color _cardBg = Color(0xFF1E293B);
  static const Color _surfaceBg = Color(0xFF334155);
  static const Color _primaryBlue = Color(0xFF3B82F6);
  static const Color _successGreen = Color(0xFF10B981);
  static const Color _warningAmber = Color(0xFFF59E0B);
  static const Color _dangerRed = Color(0xFFEF4444);
  static const Color _textLight = Color(0xFFF8FAFC);
  static const Color _textMuted = Color(0xFF94A3B8);

  // Lista simulada de salas (reemplazar con API call)
  List<Room> _rooms = [
    Room(
      id: 1,
      name: 'Sala Premium 1',
      capacity: 80,
      type: 'Premium',
      isActive: true,
      features: ['Dolby Atmos', 'Asientos Reclinables', '4K Digital'],
    ),
    Room(
      id: 2,
      name: 'Sala VIP 2',
      capacity: 40,
      type: 'VIP',
      isActive: true,
      features: ['IMAX', 'Servicio de Mesa', 'Asientos de Lujo'],
    ),
    Room(
      id: 3,
      name: 'Sala Estándar 3',
      capacity: 120,
      type: 'Estándar',
      isActive: true,
      features: ['Digital', 'Sonido Surround'],
    ),
    Room(
      id: 4,
      name: 'Sala 4D Experience',
      capacity: 60,
      type: 'Especial',
      isActive: false,
      features: ['Efectos 4D', 'Asientos Móviles', 'Efectos Ambientales'],
    ),
  ];

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

  List<Room> get _filteredRooms {
    if (_searchQuery.isEmpty) return _rooms;
    return _rooms.where((room) =>
      room.name.toLowerCase().contains(_searchQuery) ||
      room.type.toLowerCase().contains(_searchQuery)
    ).toList();
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
                      'Gestión de Salas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrar salas de cine',
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
                  '${_rooms.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchAndActions(),
        ],
      ),
    );
  }

  Widget _buildSearchAndActions() {
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
                hintText: 'Buscar salas...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton(
          onPressed: () => _showAddRoomDialog(),
          backgroundColor: _successGreen,
          heroTag: "addRoom",
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final activeRooms = _rooms.where((r) => r.isActive).length;
    final totalCapacity = _rooms.fold<int>(0, (sum, room) => sum + room.capacity);
    final avgCapacity = _rooms.isNotEmpty ? (totalCapacity / _rooms.length).round() : 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Salas Activas', activeRooms.toString(), Icons.meeting_room, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Capacidad Total', totalCapacity.toString(), Icons.event_seat, _warningAmber),
          const SizedBox(width: 12),
          _buildStatCard('Promedio', avgCapacity.toString(), Icons.analytics, _primaryBlue),
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
                fontSize: 20,
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

  Widget _buildRoomsList() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: _filteredRooms.length,
          itemBuilder: (context, index) {
            final room = _filteredRooms[index];
            return _buildRoomCard(room, index);
          },
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room, int index) {
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
                  color: room.isActive ? _successGreen.withOpacity(0.3) : _textMuted.withOpacity(0.3),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getTypeColor(room.type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getTypeIcon(room.type),
                          color: _getTypeColor(room.type),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                color: _textLight,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(room.type).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    room.type,
                                    style: TextStyle(
                                      color: _getTypeColor(room.type),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: room.isActive ? _successGreen.withOpacity(0.2) : _dangerRed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    room.isActive ? 'Activa' : 'Inactiva',
                                    style: TextStyle(
                                      color: room.isActive ? _successGreen : _dangerRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: _textMuted),
                        color: _surfaceBg,
                        onSelected: (value) => _handleMenuAction(value, room),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: _primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Text('Editar', style: TextStyle(color: _textLight)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  room.isActive ? Icons.visibility_off : Icons.visibility,
                                  color: _warningAmber,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  room.isActive ? 'Desactivar' : 'Activar',
                                  style: TextStyle(color: _textLight),
                                ),
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
                  Row(
                    children: [
                      Icon(Icons.event_seat, color: _textMuted, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Capacidad: ${room.capacity} asientos',
                        style: TextStyle(color: _textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: room.features.map((feature) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _primaryBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          color: _primaryBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Premium': return _warningAmber;
      case 'VIP': return _primaryBlue;
      case 'Especial': return Colors.purple;
      default: return _successGreen;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Premium': return Icons.star;
      case 'VIP': return Icons.diamond;
      case 'Especial': return Icons.auto_awesome;
      default: return Icons.meeting_room;
    }
  }

  void _handleMenuAction(String action, Room room) {
    switch (action) {
      case 'edit':
        _showEditRoomDialog(room);
        break;
      case 'toggle':
        _toggleRoomStatus(room);
        break;
      case 'delete':
        _showDeleteConfirmation(room);
        break;
    }
  }

  void _showAddRoomDialog() {
    _showRoomDialog(title: 'Agregar Sala');
  }

  void _showEditRoomDialog(Room room) {
    _showRoomDialog(title: 'Editar Sala', room: room);
  }

  void _showRoomDialog({required String title, Room? room}) {
    final nameController = TextEditingController(text: room?.name ?? '');
    final capacityController = TextEditingController(text: room?.capacity.toString() ?? '');
    String selectedType = room?.type ?? 'Estándar';
    bool isActive = room?.isActive ?? true;

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
                decoration: InputDecoration(
                  labelText: 'Nombre de la sala',
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
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: _textLight),
                decoration: InputDecoration(
                  labelText: 'Capacidad',
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
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                style: const TextStyle(color: _textLight),
                decoration: InputDecoration(
                  labelText: 'Tipo de sala',
                  labelStyle: TextStyle(color: _textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
                  ),
                ),
                dropdownColor: _surfaceBg,
                items: ['Estándar', 'Premium', 'VIP', 'Especial']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: const TextStyle(color: _textLight)),
                        ))
                    .toList(),
                onChanged: (value) => selectedType = value!,
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
              // Aquí implementar la lógica para guardar
              Navigator.pop(context);
              _saveRoom(room, nameController.text, int.tryParse(capacityController.text) ?? 0, selectedType, isActive);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(room == null ? 'Agregar' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveRoom(Room? existingRoom, String name, int capacity, String type, bool isActive) {
    if (existingRoom == null) {
      // Agregar nueva sala
      final newRoom = Room(
        id: DateTime.now().millisecondsSinceEpoch,
        name: name,
        capacity: capacity,
        type: type,
        isActive: isActive,
        features: _getDefaultFeatures(type),
      );
      setState(() {
        _rooms.add(newRoom);
      });
    } else {
      // Editar sala existente
      setState(() {
        existingRoom.name = name;
        existingRoom.capacity = capacity;
        existingRoom.type = type;
        existingRoom.isActive = isActive;
      });
    }
  }

  List<String> _getDefaultFeatures(String type) {
    switch (type) {
      case 'Premium':
        return ['Dolby Atmos', 'Asientos Reclinables', '4K Digital'];
      case 'VIP':
        return ['IMAX', 'Servicio de Mesa', 'Asientos de Lujo'];
      case 'Especial':
        return ['Efectos 4D', 'Asientos Móviles'];
      default:
        return ['Digital', 'Sonido Surround'];
    }
  }

  void _toggleRoomStatus(Room room) {
    setState(() {
      room.isActive = !room.isActive;
    });
  }

  void _showDeleteConfirmation(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${room.name}"?',
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
              _deleteRoom(room);
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

  void _deleteRoom(Room room) {
    setState(() {
      _rooms.removeWhere((r) => r.id == room.id);
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
            _buildRoomsList(),
          ],
        ),
      ),
    );
  }
}

class Room {
  int id;
  String name;
  int capacity;
  String type;
  bool isActive;
  List<String> features;

  Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.type,
    required this.isActive,
    required this.features,
  });
}