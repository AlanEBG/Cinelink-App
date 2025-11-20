import 'package:flutter/material.dart';

class TicketsAdminPage extends StatefulWidget {
  const TicketsAdminPage({super.key});

  @override
  State<TicketsAdminPage> createState() => _TicketsAdminPageState();
}

class _TicketsAdminPageState extends State<TicketsAdminPage> with SingleTickerProviderStateMixin {
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

  // Lista simulada de tickets (reemplazar con API call)
  List<Ticket> _tickets = [
    Ticket(
      id: 'TK001',
      movieTitle: 'Avatar: El Camino del Agua',
      customerName: 'Juan Pérez',
      customerEmail: 'juan@email.com',
      roomName: 'Sala Premium 1',
      showtime: DateTime(2024, 1, 20, 19, 30),
      seatNumber: 'F-12',
      price: 12.50,
      status: 'Confirmado',
      purchaseDate: DateTime(2024, 1, 15, 14, 20),
      paymentMethod: 'Tarjeta de Crédito',
    ),
    Ticket(
      id: 'TK002',
      movieTitle: 'Top Gun: Maverick',
      customerName: 'María González',
      customerEmail: 'maria@email.com',
      roomName: 'Sala VIP 2',
      showtime: DateTime(2024, 1, 20, 21, 00),
      seatNumber: 'A-5',
      price: 18.00,
      status: 'Pendiente',
      purchaseDate: DateTime(2024, 1, 19, 16, 45),
      paymentMethod: 'PayPal',
    ),
    Ticket(
      id: 'TK003',
      movieTitle: 'Dune: Parte Dos',
      customerName: 'Carlos Rivera',
      customerEmail: 'carlos@email.com',
      roomName: 'Sala IMAX',
      showtime: DateTime(2024, 1, 21, 15, 30),
      seatNumber: 'H-8',
      price: 15.75,
      status: 'Cancelado',
      purchaseDate: DateTime(2024, 1, 18, 10, 15),
      paymentMethod: 'Tarjeta de Débito',
    ),
    Ticket(
      id: 'TK004',
      movieTitle: 'Spider-Man: No Way Home',
      customerName: 'Ana López',
      customerEmail: 'ana@email.com',
      roomName: 'Sala Estándar 3',
      showtime: DateTime(2024, 1, 22, 17, 00),
      seatNumber: 'D-15',
      price: 10.00,
      status: 'Confirmado',
      purchaseDate: DateTime(2024, 1, 20, 9, 30),
      paymentMethod: 'Efectivo',
    ),
  ];

  final List<String> _filterOptions = ['Todos', 'Confirmado', 'Pendiente', 'Cancelado'];

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

  List<Ticket> get _filteredTickets {
    List<Ticket> filtered = _tickets;
    
    if (_selectedFilter != 'Todos') {
      filtered = filtered.where((ticket) => ticket.status == _selectedFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ticket) =>
        ticket.movieTitle.toLowerCase().contains(_searchQuery) ||
        ticket.customerName.toLowerCase().contains(_searchQuery) ||
        ticket.id.toLowerCase().contains(_searchQuery)
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
                      'Gestión de Tickets',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Administrar ventas y reservas',
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
                  '${_tickets.length}',
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
          _buildSearchAndFilters(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        Row(
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
                    hintText: 'Buscar tickets...',
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
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final confirmedTickets = _tickets.where((t) => t.status == 'Confirmado').length;
    final pendingTickets = _tickets.where((t) => t.status == 'Pendiente').length;
    final totalRevenue = _tickets.where((t) => t.status == 'Confirmado').fold<double>(0.0, (sum, ticket) => sum + ticket.price);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          _buildStatCard('Confirmados', confirmedTickets.toString(), Icons.check_circle, _successGreen),
          const SizedBox(width: 12),
          _buildStatCard('Pendientes', pendingTickets.toString(), Icons.pending, _warningAmber),
          const SizedBox(width: 12),
          _buildStatCard('Ingresos', '\$${totalRevenue.toStringAsFixed(2)}', Icons.attach_money, _primaryBlue),
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

  Widget _buildTicketsList() {
    return Expanded(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: _filteredTickets.length,
          itemBuilder: (context, index) {
            final ticket = _filteredTickets[index];
            return _buildTicketCard(ticket, index);
          },
        ),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket, int index) {
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
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _getStatusColor(ticket.status).withOpacity(0.3),
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
                  // Header del ticket
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status).withOpacity(0.1),
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
                            color: _getStatusColor(ticket.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.confirmation_number,
                            color: _getStatusColor(ticket.status),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.id,
                                style: const TextStyle(
                                  color: _textLight,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                ticket.movieTitle,
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(ticket.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ticket.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: _textMuted),
                          color: _surfaceBg,
                          onSelected: (value) => _handleMenuAction(value, ticket),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, color: _primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Ver Detalles', style: TextStyle(color: _textLight)),
                                ],
                              ),
                            ),
                            if (ticket.status == 'Pendiente')
                              PopupMenuItem(
                                value: 'confirm',
                                child: Row(
                                  children: [
                                    Icon(Icons.check, color: _successGreen, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Confirmar', style: TextStyle(color: _textLight)),
                                  ],
                                ),
                              ),
                            if (ticket.status != 'Cancelado')
                              PopupMenuItem(
                                value: 'cancel',
                                child: Row(
                                  children: [
                                    Icon(Icons.cancel, color: _dangerRed, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Cancelar', style: TextStyle(color: _textLight)),
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
                  ),
                  // Contenido del ticket
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem('Cliente', ticket.customerName, Icons.person),
                            ),
                            Expanded(
                              child: _buildInfoItem('Asiento', ticket.seatNumber, Icons.event_seat),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem('Sala', ticket.roomName, Icons.meeting_room),
                            ),
                            Expanded(
                              child: _buildInfoItem('Precio', '\$${ticket.price.toStringAsFixed(2)}', Icons.attach_money),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoItem(
                                'Función',
                                '${ticket.showtime.day}/${ticket.showtime.month} ${ticket.showtime.hour}:${ticket.showtime.minute.toString().padLeft(2, '0')}',
                                Icons.schedule,
                              ),
                            ),
                            Expanded(
                              child: _buildInfoItem('Pago', ticket.paymentMethod, Icons.payment),
                            ),
                          ],
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Confirmado': return _successGreen;
      case 'Pendiente': return _warningAmber;
      case 'Cancelado': return _dangerRed;
      default: return _textMuted;
    }
  }

  void _handleMenuAction(String action, Ticket ticket) {
    switch (action) {
      case 'view':
        _showTicketDetails(ticket);
        break;
      case 'confirm':
        _confirmTicket(ticket);
        break;
      case 'cancel':
        _cancelTicket(ticket);
        break;
      case 'delete':
        _showDeleteConfirmation(ticket);
        break;
    }
  }

  void _showTicketDetails(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.confirmation_number, color: _primaryBlue),
            const SizedBox(width: 8),
            Text('Detalles del Ticket', style: const TextStyle(color: _textLight)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', ticket.id),
              _buildDetailRow('Película', ticket.movieTitle),
              _buildDetailRow('Cliente', ticket.customerName),
              _buildDetailRow('Email', ticket.customerEmail),
              _buildDetailRow('Sala', ticket.roomName),
              _buildDetailRow('Asiento', ticket.seatNumber),
              _buildDetailRow('Precio', '\$${ticket.price.toStringAsFixed(2)}'),
              _buildDetailRow('Estado', ticket.status),
              _buildDetailRow('Método de Pago', ticket.paymentMethod),
              _buildDetailRow('Compra', '${ticket.purchaseDate.day}/${ticket.purchaseDate.month}/${ticket.purchaseDate.year}'),
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
            width: 80,
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

  void _confirmTicket(Ticket ticket) {
    setState(() {
      ticket.status = 'Confirmado';
    });
  }

  void _cancelTicket(Ticket ticket) {
    setState(() {
      ticket.status = 'Cancelado';
    });
  }

  void _showDeleteConfirmation(Ticket ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación', style: TextStyle(color: _textLight)),
        content: Text(
          '¿Estás seguro de que deseas eliminar el ticket "${ticket.id}"?',
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
              _deleteTicket(ticket);
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

  void _deleteTicket(Ticket ticket) {
    setState(() {
      _tickets.removeWhere((t) => t.id == ticket.id);
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
            _buildTicketsList(),
          ],
        ),
      ),
    );
  }
}

class Ticket {
  String id;
  String movieTitle;
  String customerName;
  String customerEmail;
  String roomName;
  DateTime showtime;
  String seatNumber;
  double price;
  String status;
  DateTime purchaseDate;
  String paymentMethod;

  Ticket({
    required this.id,
    required this.movieTitle,
    required this.customerName,
    required this.customerEmail,
    required this.roomName,
    required this.showtime,
    required this.seatNumber,
    required this.price,
    required this.status,
    required this.purchaseDate,
    required this.paymentMethod,
  });
}