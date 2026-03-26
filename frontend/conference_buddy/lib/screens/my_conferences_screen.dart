import 'package:flutter/material.dart';
import '../models/user_conference.dart';
import '../services/conference_service.dart';
import '../services/nearby_service.dart';

class MyConferencesScreen extends StatefulWidget {
  const MyConferencesScreen({super.key});

  @override
  State<MyConferencesScreen> createState() => _MyConferencesScreenState();
}

class _MyConferencesScreenState extends State<MyConferencesScreen> {
  final ConferenceService _conferenceService = ConferenceService();
  final NearbyService _nearbyService = NearbyService();
  List<UserConference> _conferences = [];
  bool _isLoading = true;
  String? _error;
  Map<String, int> _nearbyCounts = {};

  @override
  void initState() {
    super.initState();
    _loadConferences();
  }

  Future<void> _loadConferences() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final conferences = await _conferenceService.getUserConferences();
      setState(() {
        _conferences = conferences;
        _isLoading = false;
      });
      _loadNearbyCounts();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyCounts() async {
    for (final conference in _conferences) {
      try {
        final result = await _nearbyService.getNearbyCount(conference.conferenceId);
        setState(() {
          _nearbyCounts[conference.conferenceId] = result['count'];
        });
      } catch (e) {
        // Ignore errors for individual counts
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Conferences'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadConferences,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_conferences.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'You haven\'t joined any conferences yet',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadConferences,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _conferences.length,
        itemBuilder: (context, index) {
          final conference = _conferences[index];
          return _MyConferenceCard(
            conference: conference,
            nearbyCount: _nearbyCounts[conference.conferenceId] ?? 0,
            onUpdateLocation: () {
              // Show location picker
            },
          );
        },
      ),
    );
  }
}

class _MyConferenceCard extends StatelessWidget {
  final UserConference conference;
  final int nearbyCount;
  final VoidCallback onUpdateLocation;

  const _MyConferenceCard({
    required this.conference,
    required this.nearbyCount,
    required this.onUpdateLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conference.conferenceName ?? 'Conference',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (conference.hotelName != null) ...[
              Row(
                children: [
                  const Icon(Icons.hotel, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conference.hotelName!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              if (conference.hotelAddress != null) ...[
                const SizedBox(height: 4),
                Text(
                  conference.hotelAddress!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ] else ...[
              const Text(
                'No hotel location set',
                style: TextStyle(color: Colors.orange),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '$nearbyCount nearby',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onUpdateLocation,
                  icon: const Icon(Icons.edit_location_alt, size: 18),
                  label: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}