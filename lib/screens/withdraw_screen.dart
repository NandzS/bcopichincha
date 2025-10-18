import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/balance_service.dart';
import '../core/colors.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? _message;
  bool _isLoading = false;

  void _withdraw() async {
  
  FocusScope.of(context).unfocus();

  final amount = double.tryParse(_amountController.text) ?? 0.0;

  if (amount <= 0) {
    setState(() {
      _message = "Ingrese un monto válido mayor a cero.";
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _message = null;
  });

  final balanceService = context.read<BalanceService>();
  final error = await balanceService.withdraw(amount);

  if (!mounted) return;

  setState(() {
    _isLoading = false;
    if (error == null) {
      _message = "¡Retiro de \$${amount.toStringAsFixed(2)} exitoso!";
      _amountController.clear();
    } else {
      _message = "Error: $error";
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final currentBalance = context.select((BalanceService b) => b.balance);

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: AppColors.blancoapp,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.azulMarino,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            
            const Center(
              child: Text(
                'Retiro de Efectivo',
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
              color: AppColors.plomoapp.withOpacity(0.1),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.plomoapp, width: 1)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Saldo Disponible: \$${currentBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulMarino),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 5),

           
            Center(
              child: Image.asset(
                'assets/images/bp_tarjeta.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 5),

            
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Monto a Retirar',
                labelStyle: const TextStyle(color: AppColors.azulMarino),
                prefixText: '\$',
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
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _isLoading ? null : _withdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulMarino,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirmar Retiro',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 20),

            
            if (_message != null)
              Center(
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _message!.contains('exitoso')
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }
}