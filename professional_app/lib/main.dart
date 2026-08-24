import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Professional App',
      debugShowCheckedModeBanner: false,
      home: const BookingsScreen(),
    );
  }
}

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  List bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/bookings'),
    );
    if (response.statusCode == 200) {
      setState(() {
        bookings = jsonDecode(response.body);
      });
    }
  }

  Future<void> updateStatus(int bookingId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('http://127.0.0.1:8000/bookings/$bookingId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      fetchBookings();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Update failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking #${booking['id']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Customer: ${booking['customer_name']}'),
                          const SizedBox(height: 4),
                          Text('Status: ${booking['status']}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (booking['status'] == 'pending')
                                ElevatedButton(
                                  onPressed: () =>
                                      updateStatus(booking['id'], 'accepted'),
                                  child: const Text('Accept'),
                                ),
                              if (booking['status'] == 'accepted') ...[
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () =>
                                      updateStatus(booking['id'], 'completed'),
                                  child: const Text('Mark Complete'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
