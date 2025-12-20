import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pitch_perfect_flutter/forum/screens/post_detail.dart';
import '../models/forum_entry.dart' as forum_model;

class OfficialNewsCard extends StatefulWidget {
  final List<forum_model.ForumEntry> news;
  const OfficialNewsCard({super.key, required this.news});

  @override
  State<OfficialNewsCard> createState() => _OfficialNewsCardState();
}

class _OfficialNewsCardState extends State<OfficialNewsCard> {
  int _currentIndex = 0;
  Timer? _timer;

  String get _baseUrl {
    if (kIsWeb) {
      return "http://localhost:8000";
    } else {
      return "http://10.0.2.2:8000";
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(OfficialNewsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.news.length != oldWidget.news.length || widget.news != oldWidget.news) {
      _currentIndex = 0;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.news.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
        _goToNextNews(widget.news.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToNextNews(int newsCount) {
    if (mounted && newsCount > 0) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % newsCount;
      });
    }
  }

  void _goToPreviousNews(int newsCount) {
    if (mounted && newsCount > 0) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + newsCount) % newsCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.news.isEmpty) {
      return const Center(child: Text('No official news found.'));
    }

    final newsList = widget.news;
    if (_currentIndex >= newsList.length) {
      _currentIndex = 0;
    }
    final currentNews = newsList[_currentIndex];

    if (currentNews.images.isNotEmpty) {
      currentNews.images.sort((a, b) => a.order.compareTo(b.order));
    }

    final imageUrl = currentNews.images.isNotEmpty
        ? '$_baseUrl/forum/proxy-image/?url=${Uri.encodeComponent(currentNews.images[0].url)}'
        : 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wCEAAkGBxAOBg8QDw4QDg8QEA4PDg4NDRIPDw8PFREYFhUSFRMYKCggGB0lGxMTITEhJSkrLi4uFx8zODMsNygtLjcBCgoKBQUFDgUFDisZExkrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrK//AABEIALcBFAMBIgACEQEDEQH/xAAaAAEAAwEBAQAAAAAAAAAAAAAAAwQFAgEH/8QAMBABAAEBBAYKAgMBAAAAAAAAAAECAwQRURMhM3GBkRIUMTRBUmGiscGCoSIjQtH/xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8A+zgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADyaojtmOaOq8Ux/rlrBKK03ynwiZ/SOq+z4UxxnEF0UaLzVNpGM6sYxiIXgAAAAAAAAAAAAAAAAAAAAAAARXnHQzhOGGAJcXFVtTHbVDN1zV4zPN3F2rn/ADhv1At1XumM53QjqvuVPOXFNzq8ZiP2kpuceNUz+gRTeqpyjdCKbWqe2qea/F2oyx3y7iiI7IiAZtNEzPZMpKbrVPhhvloAKcXKfGqOES7pudMeMysgMquMLSYylqUzjTChfKf759da5d5xsad2AJAAAAAAAAAAAAAAAAAAAAAAHNpGNnMek/DoBmWFWFvTPq02VXGFpPpM/LUpnGkFe8280VxhEdnii67VlBftrG77dXewpqssZ+cAc9dqyg67VlCXQWefvNBZ5+8EXXasoOu1ZQk0Fnn7zQWefvBH12rKDrtWUJNBZ5+80Fnn7wVba1murGcODuyvM004RhxT6Czz973QWefvBF1yrKElheZqtYicPHseW13piymY4a8UN028bpBogAAAAAAAAAAAAAAAAAAAAAzr3Thbz64Su3ecbGncrX+n+UT6YJbjV/VhlIIr9tY3faS692nj8I79tY3faS692nj8AoytWd0macZnD0VonW1aKomnGPEGbbWM0Va+Eo1y/Vxqjx7VMAE93sOlOvs+QQCxebv0dca4+FcF6e4/jHyr3TbxulYnuP4x8q9028bpBogAAAAAAAAAAAAAAAAAAAAArX6P6onKflHcKv5VRulYvMY2FXNUuk4W8euMA7v21jd9pLr3aePwjv21jd9pLr3aePwCi9iqY7JmN0vHVFnNU6oxBziPZjCcJ1T6u7GymurCOM5A9u9l06vSO2WjTTERhHY8s6Ippwh0BMYxr1s68WPRq9J7P+NFzXRFVOEggnuP4x8q9028bpWrano3SYyj7Vbpt43SDRAAAAAAAAAAAAAAAAAAAAAB5VGNMwzLOcLSPSYajLtowtqt8gmv21jd9pbr3aePwq2lpNVUTP6XLlseMggsbrM66tUfuV2mmIjCIwegOLWyiqNccfEsrOKacI55uwAAAAEV62FW77U7pt43SuXrYVbvtTum3jdINEAAAAAAAAAAAAAAAAAAAAABBXdoqtJmZnWnAZ97s4priIyRU2kxGqZhqTTE+DzoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGbpqvNPM01Xmnm0uhGUcjoRlHIGZNrVMYTMzxSXPbxxX+hGUcnsUxlHIHoAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP/9k=';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailPage(post: currentNews),
          ),
        );
      },
      child: Card(
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
      ),
    );
  }
}