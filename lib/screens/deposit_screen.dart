import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/balance_service.dart';
import '../core/colors.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  
  Map<String, String>? _selectedRecipient;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleTransaction() async {
    if (_isLoading) return;

    
    if (_selectedRecipient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un destinatario.')),
      );
      return;
    }

    FocusScope.of(context).unfocus(); 

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final balanceService = context.read<BalanceService>();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto debe ser mayor a cero.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? error;
    final isTransfer = _selectedRecipient!['id']!.isNotEmpty;

    if (isTransfer) {
      error = await balanceService.transferFunds(_selectedRecipient!['id']!, amount);
    } else {
      error = await balanceService.creditOwnAccount(amount);
    }

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      _amountController.clear();
      final message = isTransfer
          ? 'Transferencia exitosa a ${_selectedRecipient!['nombre']}'
          : 'Depósito exitoso a ${_selectedRecipient!['nombre']} de \$${amount.toStringAsFixed(2)}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${isTransfer ? 'Error de Transferencia' : 'Error de Depósito'}: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectRecipient(BuildContext context) async {
    final balanceService = context.read<BalanceService>();
    final users = balanceService.allUsers;

    final selected = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          extendBodyBehindAppBar: false,
          appBar: AppBar(
          
            title: const Text('Seleccionar Destinatario'),
            backgroundColor: AppColors.blancoapp,
            foregroundColor: AppColors.azulMarino,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle, color: AppColors.azulMarino),
                title: const Text('Depósito a mi cuenta'),
                onTap: () => Navigator.pop(context, {'id': '', 'nombre': 'Tu Cuenta'}),
              ),
              const Divider(),
              ...users.map((user) => ListTile(
                    leading: const Icon(Icons.account_circle, color: AppColors.azulMarino),
                    title: Text(user['nombre'] as String),
                    onTap: () => Navigator.pop(context, {
                      'id': user['id'] as String,
                      'nombre': user['nombre'] as String
                    }),
                  )),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        
        _selectedRecipient = selected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blancoapp,
        elevation: 1,
        foregroundColor: AppColors.azulMarino,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<BalanceService>(
          builder: (context, balanceService, child) {
            final isTransferMode = _selectedRecipient != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                const Center(
                  child: Text(
                    'Depositar / Transferir',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulMarino,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Saldo Actual
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Tu Saldo: \$${balanceService.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

             
                const Text(
                  'Selecciona un destinatario',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.plomoapp),
                ),
                const SizedBox(height: 8),

                
                ElevatedButton(
                  onPressed: () => _selectRecipient(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulMarino,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _selectedRecipient == null
                        ? 'Seleccionar'
                        : 'Destinatario: ${_selectedRecipient!['nombre']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),

             
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: isTransferMode ? 'Monto a Transferir' : 'Monto a Depositar',
                    labelStyle: const TextStyle(color: AppColors.azulMarino),
                    prefixIcon: const Icon(Icons.attach_money),
                    filled: true,
                    fillColor: AppColors.blancoapp,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.azulMarino, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.plomoapp, width: 1),
                    ),
                  ),
                  style: const TextStyle(fontSize: 20, color: AppColors.azulMarino),
                ),
                const SizedBox(height: 24),

                
                ElevatedButton(
                  onPressed: (_isLoading || _selectedRecipient == null) ? null : _handleTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_selectedRecipient == null)
                        ? Colors.grey
                        : AppColors.azulMarino,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isTransferMode ? 'Confirmar Transferencia' : 'Confirmar Depósito',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}