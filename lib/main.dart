import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Prayer Times in Korea')),
        body: PrayerTimesWidget(),
      ),
    );
  }
}

class PrayerTimesWidget extends StatefulWidget {
  @override
  _PrayerTimesWidgetState createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  List<dynamic> prayerTimes = [];
  bool isLoading = true;
  String selectedCity = "Seoul"; // Default city
  int month = DateTime.now().month; // Current month
  int year = DateTime.now().year; // Current year

  // List of cities in Korea
  List<String> cities = ["Seoul", "Busan", "Incheon", "Daegu", "Daejeon"];

  Future<void> fetchPrayerTimes(String city) async {
    final String apiUrl =
        'http://api.aladhan.com/v1/calendarByCity/$year/$month?city=$city&country=KR&method=2';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          prayerTimes = json.decode(response.body)['data'];
          isLoading = false;
        });
        print('Fetched prayer times for $city');
      } else {
        setState(() {
          isLoading = false;
          print('Error: ${response.statusCode}');
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Exception: $e');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes(selectedCity); // Fetch for default city
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: selectedCity,
            icon: Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.teal, fontSize: 18),
            underline: Container(
              height: 2,
              color: Colors.tealAccent,
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedCity = newValue!;
                isLoading = true;
                fetchPrayerTimes(selectedCity);
              });
            },
            items: cities.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: prayerTimes.length,
                  itemBuilder: (context, index) {
                    final timings = prayerTimes[index]['timings'];
                    final date = prayerTimes[index]['date']['readable'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text(
                            date,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.0),
                              _buildPrayerTimeRow('Fajr', timings['Fajr']),
                              _buildPrayerTimeRow(
                                  'Sunrise', timings['Sunrise']),
                              _buildPrayerTimeRow('Dhuhr', timings['Dhuhr']),
                              _buildPrayerTimeRow('Asr', timings['Asr']),
                              _buildPrayerTimeRow(
                                  'Maghrib', timings['Maghrib']),
                              _buildPrayerTimeRow('Isha', timings['Isha']),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Prayer Times on $date'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildPrayerTimeRow(
                                          'Imsak', timings['Imsak']),
                                      _buildPrayerTimeRow(
                                          'Fajr', timings['Fajr']),
                                      _buildPrayerTimeRow(
                                          'Sunrise', timings['Sunrise']),
                                      _buildPrayerTimeRow(
                                          'Dhuhr', timings['Dhuhr']),
                                      _buildPrayerTimeRow(
                                          'Asr', timings['Asr']),
                                      _buildPrayerTimeRow(
                                          'Maghrib', timings['Maghrib']),
                                      _buildPrayerTimeRow(
                                          'Isha', timings['Isha']),
                                      _buildPrayerTimeRow(
                                          'Midnight', timings['Midnight']),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Closes the dialog
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimeRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(fontSize: 16)),
          Text(time,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
