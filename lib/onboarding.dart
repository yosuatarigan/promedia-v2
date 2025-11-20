import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/8.png',
      title: 'Tracking Kebutuhan Pasien',
      description:
          'Dengan aplikasi Promedia, pasien diabetes, keluarga mendapatkan kemudahan dalam melakukan tracking kebutuhan pasien dengan Diabetes',
    ),
    OnboardingData(
      image: 'assets/9.png',
      title: 'Fitur Pengingat',
      description:
          'Dengan dilengkapi fitur pengingat maka pasien dengan Diabetes tidak perlu khawatir melewatkan waktu penting dalam kebutuhan pasien. Keluarga pasien juga dapat mengingatkan melalui aplikasi.',
    ),
    OnboardingData(
      image: 'assets/10.png',
      title: 'Sistem Terintegrasi',
      description:
          'Aplikasi Promedia adalah Program Manajemen Edukasi Diabetes yang terintegrasi antara pasien dan keluarga. Sehingga seluruh kebutuhan dan perawatan pasien dapat dipantau oleh keluarga.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFD7F0), Color(0xFFE8C5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/1.png', height: 40),
                    TextButton(
                      onPressed: () {
                        // Navigate to home or login
                      },
                      child: Text(
                        'Lewati',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return OnboardingPage(data: _pages[index]);
                  },
                ),
              ),

              // Image Indicator
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Image.asset(
                    _getIndicatorImage(),
                    key: ValueKey(_currentPage),
                    height: 50,
                    width: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getIndicatorImage() {
    switch (_currentPage) {
      case 0:
        return 'assets/5.png';
      case 1:
        return 'assets/6.png';
      case 2:
        return 'assets/7.png';
      default:
        return 'assets/5.png';
    }
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Illustration
          Image.asset(
            data.image,
            height: 280,
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            data.title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.justify,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}