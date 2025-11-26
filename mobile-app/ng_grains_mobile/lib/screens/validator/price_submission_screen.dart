import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class PriceSubmissionScreen extends StatefulWidget {
  const PriceSubmissionScreen({super.key});

  @override
  State<PriceSubmissionScreen> createState() => _PriceSubmissionScreenState();
}

class _PriceSubmissionScreenState extends State<PriceSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  List<dynamic> _commodities = [];
  List<dynamic> _markets = [];
  
  int? _selectedCommodityId;
  int? _selectedMarketId;
  double? _price;
  String _qualityGrade = 'A';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final [commodities, markets] = await Future.wait([
        ApiService.getCommodities(),
        ApiService.getMarkets(),
      ]);
      
      setState(() {
        _commodities = commodities;
        _markets = markets;
        
        // Auto-select first items
        if (_commodities.isNotEmpty) _selectedCommodityId = _commodities[0]['id'];
        if (_markets.isNotEmpty) _selectedMarketId = _markets[0]['id'];
      });
    } catch (e) {
      _showError('Failed to load form data: $e');
    }
  }

  Future<void> _submitPrice() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final supabase = Supabase.instance.client;
      
      // Get validator profile
      final profile = await AuthService.getProfile();
      final validatorId = profile?['market_id']; // Assuming market_id links to validator
      
      final response = await supabase
          .from('price_entries')
          .insert({
            'market_id': _selectedMarketId,
            'commodity_id': _selectedCommodityId,
            'price': _price,
            'quality_grade': _qualityGrade,
            'validator_id': validatorId,
            'status': 'pending',
          })
          .select();

      if (response.isNotEmpty) {
        _showSuccess('Price submitted successfully! Awaiting admin approval.');
        _formKey.currentState!.reset();
      }
    } catch (e) {
      _showError('Failed to submit price: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Price Entry'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Market Selection
              DropdownButtonFormField<int>(
                initialValue: _selectedMarketId,
                items: _markets.map((market) {
                  return DropdownMenuItem<int>(
                    value: market['id'],
                    child: Text(market['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedMarketId = value),
                decoration: const InputDecoration(
                  labelText: 'Market',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select a market' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Commodity Selection
              DropdownButtonFormField<int>(
                initialValue: _selectedCommodityId,
                items: _commodities.map((commodity) {
                  return DropdownMenuItem<int>(
                    value: commodity['id'],
                    child: Text(commodity['name']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCommodityId = value),
                decoration: const InputDecoration(
                  labelText: 'Commodity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null ? 'Please select a commodity' : null,
              ),
              
              const SizedBox(height: 16),
              
              // Price Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price (₦ per bag)',
                  border: OutlineInputBorder(),
                  prefixText: '₦',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter price';
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) return 'Please enter valid price';
                  return null;
                },
                onSaved: (value) => _price = double.tryParse(value ?? '0'),
              ),
              
              const SizedBox(height: 16),
              
              // Quality Grade
              DropdownButtonFormField<String>(
                initialValue: _qualityGrade,
                items: ['A', 'B', 'C'].map((grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text('Grade $grade'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _qualityGrade = value!),
                decoration: const InputDecoration(
                  labelText: 'Quality Grade',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitPrice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Submit Price Entry'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}