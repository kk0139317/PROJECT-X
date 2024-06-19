import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PredictionsScreen extends StatefulWidget {
  @override
  _PredictionsScreenState createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  List<dynamic> _predictions = [];

  final String apiUrl = 'http://192.168.1.244:8001/api/predictions/';

  Future<void> fetchPredictions() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          _predictions = jsonDecode(response.body);
        });
      } else {
        print('Failed to load predictions with status ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching predictions: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPredictions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predictions'),
      ),
      body: _predictions.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                var prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction['image_name'] ?? 'Unnamed'),
                  subtitle: Text(
                    'Prediction: ${prediction['prediction']}, Confidence: ${prediction['confidence'].toStringAsFixed(2)}%, Timestamp: ${prediction['timestamp']}',
                  ),
                  onTap: () {
                    _showPredictionDetailsDialog(prediction);
                  },
                );
              },
            ),
    );
  }

  void _showPredictionDetailsDialog(Map<String, dynamic> prediction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                prediction['url'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              ListTile(
                title: Text('Prediction: ${prediction['prediction']}'),
                subtitle: Text('Confidence: ${prediction['confidence'].toStringAsFixed(2)}%'),
              ),
              ListTile(
                title: Text('Timestamp: ${prediction['timestamp']}'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
