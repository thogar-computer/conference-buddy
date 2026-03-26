import 'package:flutter/material.dart';
import '../models/conference.dart';
import '../services/conference_service.dart';
import 'package:intl/intl.dart';

class ConferenceListScreen extends StatefulWidget {
  const ConferenceListScreen({super.key});

  @override
  State<ConferenceListScreen> createState() => _ConferenceListScreenState();
}

class _ConferenceListScreenState extends State<ConferenceListScreen> {
  final ConferenceService _conferenceService = ConferenceService();
  List<Conference> _conferences = [];
  bool _isLoading = true;
  String? _error;

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
      final conferences = await _conferenceService.getConferences();
      setState(() {
        _conferences = conferences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConferences,
          ),
        ],
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
              'No conferences available',
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
          return _ConferenceCard(conference: conference);
        },
      ),
    );
  }
}

class _ConferenceCard extends StatelessWidget {
  final Conference conference;

  const _ConferenceCard({required this.conference});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final isUpcoming = conference.startDate.isAfter(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    conference.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isUpcoming ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isUpcoming ? 'Upcoming' : 'Past',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(conference.startDate)} - ${dateFormat.format(conference.endDate)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // View details
                  },
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Details'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Register for conference
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Join'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}