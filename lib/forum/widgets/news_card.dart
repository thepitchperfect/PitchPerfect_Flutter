import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/forum_entry.dart' as forum_model;

class OfficialNewsCard extends StatefulWidget {
  const OfficialNewsCard({super.key});

  @override
  State<OfficialNewsCard> createState() => _OfficialNewsCardState();
}

class _OfficialNewsCardState extends State<OfficialNewsCard> {
  late Future<List<forum_model.ForumEntry>> _futureNews;
  int _currentIndex = 0;
  Timer? _timer;

  // Use 10.0.2.2 for Android Emulator to connect to host machine's localhost
  String get _baseUrl {
    if (kIsWeb) {
      // If running on the web, use localhost
      return "http://localhost:8000";
    } else {
      // If not on the web (i.e., mobile), use the Android emulator IP.
      // Note: This assumes you are only testing on Android for now. A more
      // robust solution would check Platform.isAndroid specifically here.
      return "http://10.0.2.2:8000";
    }
  }

  @override
  void initState() {
    super.initState();
    _futureNews = _fetchNews();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<List<forum_model.ForumEntry>> _fetchNews() async {
    final response = await http.get(Uri.parse('$_baseUrl/forum/json/'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<forum_model.ForumEntry> news = forum_model.forumEntryFromJson(response.body);
      final officialNews = news.where((entry) => entry.postType.toLowerCase() == 'news').toList();

      if (mounted && officialNews.isNotEmpty) {
        _timer?.cancel(); // Cancel any existing timer
        _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
          _goToNextNews(officialNews.length);
        });
      }
      return officialNews;
    } else {
      throw Exception('Failed to load news. Status code: ${response.statusCode}');
    }
  }

  void _goToNextNews(int newsCount) {
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % newsCount;
      });
    }
  }

  void _goToPreviousNews(int newsCount) {
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + newsCount) % newsCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<forum_model.ForumEntry>>(
      future: _futureNews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No official news found.'));
        }

        final newsList = snapshot.data!;
        if (newsList.isEmpty) {
            return const Center(child: Text('No official news available.'));
        }
        final currentNews = newsList[_currentIndex];
        // Sort images by order and get the first one
        if (currentNews.images.isNotEmpty) {
          currentNews.images.sort((a, b) => a.order.compareTo(b.order));
        }

        final imageUrl = currentNews.images.isNotEmpty
            ? '$_baseUrl/forum/proxy-image/?url=${Uri.encodeComponent(currentNews.images[0].url)}'
            : 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxAOBg8QDw4QDg8QEA4PDg4NDRIPDw8PFREYFhUSFRMYKCggGB0lGxMTITEhJSkrLi4uFx8zODMsNygtLjcBCgoKBQUFDgUFDisZExkrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrK//AABEIALcBFAMBIgACEQEDEQH/xAAaAAEAAwEBAQAAAAAAAAAAAAAAAwQFAgEH/8QAMBABAAEBBAYKAgMBAAAAAAAAAAECAwQRURMhM3GBkRIUMTRBUmGiscGCoSIjQtH/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8A+zgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADyaojtmOaOq8Ux/rlrBKK03ynwiZ/SOq+z4UxxnEF0UaLzVNpGM6sYxiIXgAAAAAAAAAAAAAAAAAAAAAAARXnHQzhOGGAJcXFVtTHbVDN1zV4zPN3F2rn/ADhv1At1XumM53QjqvuVPOXFNzq8ZiP2kpuceNUz+gRTeqpyjdCKbWqe2qea/F2oyx3y7iiI7IiAZtNEzPZMpKbrVPhhvloAKcXKfGqOES7pudMeMysgMquMLSYylqUzjTChfKf759da5d5xsad2AJAAAAAAAAAAAAAAAAAAAAAAHNpGNnMek/DoBmWFWFvTPq02VXGFpPpM/LUpnGkFe8280VxhEdnii67VlBftrG77dXewpqssZ+cAc9dqyg67VlCXQWefvNBZ5+8EXXasoOu1ZQk0Fnn7zQWefvBH12rKDrtWUJNBZ5+80Fnn7wVba1murGcODuyvM004RhxT6Czz973QWefvBF1yrKElheZqtYicPHseW13piymY4a8UN028bpBogAAAAAAAAAAAAAAAAAAAAAzr3Thbz64Su3ecbGncrX+n+UT6YJbjV/VhlIIr9tY3faS692nj8I79tY3faS692nj8AoytWd0macZnD0VonW1aKomnGPEGbbWM0Va+Eo1y/Vxqjx7VMAE93sOlOvs+QQCxebv0dca4+FcF6e4/jHyr3TbxulYnuP4x8q9028bpBogAAAAAAAAAAAAAAAAAAAAArX6P6onKflHcKv5VRulYvMY2FXNUuk4W8euMA7v21jd9pLr3aePwjv21jd9pLr3aePwCi9iqY7JmN0vHVFnNU6oxBziPZjCcJ1T6u7GymurCOM5A9u9l06vSO2WjTTERhHY8s6Ippwh0BMYxr1s68WPRq9J7P+NFzXRFVOEggnuP4x8q9028bpWrano3SYyj7Vbpt43SDRAAAAAAAAAAAAAAAAAAAAAB5VGNMwzLOcLSPSYajLtowtqt8gmv21jd9pbr3aePwq2lpNVUTP6XLlseMggsbrM66tUfuV2mmIjCIwegOLWyiqNccfEsrOKacI55uwAAAAEV62FW77U7pt43SuXrYVbvtTum3jdINEAAAAAAAAAAAAAAAAAAAAABBXdoqtJmZnWnAZ97s4priIyRU2kxGqZhqTTE+DzoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGZNrVMYTMzxSXPbxxX+hGUcnsUxlHIHoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/9k=';


        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // To debug image loading issues
                    print("Failed to load image: $imageUrl, Error: $error");
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12.0),
                    bottomRight: Radius.circular(12.0),
                  ),
                ),
                child: Text(
                  currentNews.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => _goToPreviousNews(newsList.length),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                          onPressed: () => _goToNextNews(newsList.length),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
