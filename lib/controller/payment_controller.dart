import 'package:flutter/material.dart';
import 'package:test_flutter1/screens/payment_successful.dart';


class PaymentController extends StatefulWidget {
  @override
  _PaymentControllerState createState() => _PaymentControllerState();
}

class _PaymentControllerState extends State<PaymentController> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expDateController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method'),
        backgroundColor: Color(0xFF34A0A4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note: There is an added service charge when reserving a position. These fee will be deducted from the final bill.',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Payment Method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name on the card',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name on the card';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expDateController,
                          decoration: InputDecoration(
                            labelText: 'Exp. Date',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter exp. date';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter CVV';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Navigate to payment successful screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PaymentSuccessful()),
                        );
                      }
                    },
                    child: Text('Pay'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF34A0A4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
