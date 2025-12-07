import 'package:flutter/material.dart';
import '../../../models/room.dart';
import '../../../services/room_service.dart';

class RoomsAdminPage extends StatefulWidget {
  const RoomsAdminPage({super.key});

  @override
  State<RoomsAdminPage> createState() => _RoomsAdminPageState();
}

class _RoomsAdminPageState extends State<RoomsAdminPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final RoomService _roomService = RoomService();
  
  String _searchQuery = '';
  List<Room> _rooms = [];
  bool _isLoading = true;
  
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

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSearchListener();
    _loadRooms();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await _roomService.getAllRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error al cargar salas: $e');
    }
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
      room.roomName.toLowerCase().contains(_searchQuery) ||
      room.roomCapacity.toString().contains(_searchQuery)
    ).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  tooltip: 'Volver',
                ),
              ),
              const SizedBox(width: 16),
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
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Administrar salas de cine',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showRoomDialog(title: 'Nueva Sala'),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: _primaryBlue,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Agregar',
                            style: TextStyle(
                              color: _primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Color(0xFF1E2A47),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar salas por nombre o capacidad...',
          hintStyle: TextStyle(
            color: _textMuted.withOpacity(0.5),
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              color: _textMuted.withOpacity(0.6),
              size: 24,
            ),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: _textMuted,
                    size: 20,
                  ),
                  onPressed: () => _searchController.clear(),
                  tooltip: 'Limpiar búsqueda',
                )
              : null,
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _primaryBlue.withOpacity(0.5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalCapacity = _rooms.fold<int>(0, (sum, room) => sum + room.roomCapacity);
    final avgCapacity = _rooms.isNotEmpty ? (totalCapacity / _rooms.length).round() : 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Total Salas', _rooms.length.toString(), Icons.meeting_room, _successGreen),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: _textLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomsList() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(color: _primaryBlue),
        ),
      );
    }

    if (_filteredRooms.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.meeting_room_outlined, size: 80, color: _textMuted.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? 'No hay salas registradas' : 'No se encontraron resultados',
                style: TextStyle(color: _textMuted, fontSize: 16),
              ),
              if (_searchQuery.isEmpty) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showRoomDialog(title: 'Nueva Sala'),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar primera sala'),
                  style: ElevatedButton.styleFrom(
                    
                    backgroundColor: _primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

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
      duration: Duration(milliseconds: 400 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _primaryBlue.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.meeting_room,
                            color: _primaryBlue,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.roomName,
                                style: const TextStyle(
                                  color: _textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.event_seat, color: _textMuted, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${room.roomCapacity} asientos',
                                    style: TextStyle(
                                      color: _textMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: _textMuted, size: 20),
                          color: _surfaceBg,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) => _handleMenuAction(value, room),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: _primaryBlue, size: 18),
                                  const SizedBox(width: 12),
                                  Text('Editar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: _dangerRed, size: 18),
                                  const SizedBox(width: 12),
                                  Text('Eliminar', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildInfoItem(
                            'ID',
                            room.roomId?.toString() ?? 'N/A',
                            Icons.tag,
                          ),
                        ),
                        Expanded(
                          child: _buildInfoItem(
                            'Capacidad',
                            '${room.roomCapacity}',
                            Icons.people,
                          ),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _textMuted, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: _textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _textLight,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _handleMenuAction(String action, Room room) {
    switch (action) {
      case 'edit':
        _showRoomDialog(title: 'Editar Sala', room: room);
        break;
      case 'delete':
        _showDeleteConfirmation(room);
        break;
    }
  }

  void _showRoomDialog({required String title, Room? room}) {
    final nameController = TextEditingController(text: room?.roomName ?? '');
    final capacityController = TextEditingController(text: room?.roomCapacity.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryBlue, _primaryBlue.withOpacity(0.8)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      room == null ? Icons.add_circle_outline : Icons.edit,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormLabel('Nombre de la sala *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: _textLight, fontSize: 16),
                      decoration: _buildInputDecoration('Ej: Sala A1', Icons.meeting_room),
                    ),
                    const SizedBox(height: 20),
                    _buildFormLabel('Capacidad *'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: _textLight, fontSize: 16),
                      decoration: _buildInputDecoration('Ej: 100', Icons.event_seat),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '* Campos obligatorios',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceBg.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(color: _textMuted, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_validateRoomForm(nameController.text, capacityController.text)) {
                          Navigator.pop(context);
                          _saveRoom(
                            room,
                            nameController.text,
                            int.tryParse(capacityController.text) ?? 0,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(room == null ? Icons.add : Icons.save, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            room == null ? 'Agregar' : 'Guardar',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: _textLight,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _textMuted.withOpacity(0.5), fontSize: 15),
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _textMuted.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: _surfaceBg.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  bool _validateRoomForm(String name, String capacity) {
    if (name.trim().isEmpty) {
      _showErrorSnackBar('El nombre de la sala es requerido');
      return false;
    }
    if (capacity.trim().isEmpty || int.tryParse(capacity) == null) {
      _showErrorSnackBar('La capacidad debe ser un número válido');
      return false;
    }
    if (int.parse(capacity) <= 0) {
      _showErrorSnackBar('La capacidad debe ser mayor a 0');
      return false;
    }
    return true;
  }

  Future<void> _saveRoom(Room? existingRoom, String name, int capacity) async {
    try {
      if (existingRoom == null) {
        // Crear nueva sala
        final newRoom = Room(roomName: name, roomCapacity: capacity);
        await _roomService.createRoom(newRoom);
        _showSuccessSnackBar('Sala creada exitosamente');
      } else {
        // Actualizar sala existente
        final updatedRoom = Room(
          roomId: existingRoom.roomId,
          roomName: name,
          roomCapacity: capacity,
        );
        await _roomService.updateRoom(existingRoom.roomId!, updatedRoom);
        _showSuccessSnackBar('Sala actualizada exitosamente');
      }
      _loadRooms();
    } catch (e) {
      _showErrorSnackBar('Error al guardar sala: $e');
    }
  }

  void _showDeleteConfirmation(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _warningAmber, size: 28),
            const SizedBox(width: 12),
            const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${room.roomName}"?\n\nEsta acción no se puede deshacer.',
          style: TextStyle(color: _textMuted, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text('Cancelar', style: TextStyle(color: _textMuted, fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRoom(room);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _dangerRed,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRoom(Room room) async {
    try {
      await _roomService.deleteRoom(room.roomId!);
      _showSuccessSnackBar('Sala eliminada exitosamente');
      _loadRooms();
    } catch (e) {
      _showErrorSnackBar('Error al eliminar sala: $e');
    }
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