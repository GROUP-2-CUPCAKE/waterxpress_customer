import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../detail_pesanan/views/detail_pesanan_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(), 
    const Center(child: Text('Pesanan')), 
    const Center(child: Text('Riwayat')), 
    const Center(child: Text('Profil')), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40C4FF), Color(0xFF0288D1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            if (_currentIndex == 0) 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.account_circle,
                            size: 40,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'WaterXpress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Pesan Air di Depot Kenzi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    ImageCarousel(),
                  ],
                ),
              ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                child: Container(
                  color: const Color.fromARGB(255, 252, 252, 252),
                  child: _pages[_currentIndex], 
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: const Color(0xFF0288D1),
        buttonBackgroundColor: const Color(0xFF40C4FF),
        height: 60,
        items: const <CurvedNavigationBarItem>[
          CurvedNavigationBarItem(
            child: Icon(Icons.home, size: 30, color: Colors.white),
            label: 'Beranda',
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.list_alt, size: 30, color: Colors.white),
            label: 'Pesanan',
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.history, size: 30, color: Colors.white),
            label: 'Riwayat',
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person, size: 30, color: Colors.white),
            label: 'Profil',
            labelStyle: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({Key? key}) : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView(
            controller: _pageController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/banner1.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/banner2.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/banner3.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: 3,
          effect: const ExpandingDotsEffect(
            activeDotColor: Color(0xFF0288D1),
            dotColor: Colors.grey,
            dotHeight: 8,
            dotWidth: 8,
          ),
        ),
      ],
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> products = [
      {"name": "Air Mineral Bioglass", "price": 10000, "stock": 100},
      {"name": "Air Mineral Hexagonal", "price": 5000, "stock": 50},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: const Color.fromARGB(255, 237, 246, 255),
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/image.png'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Rp${product["price"]},00",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stok: ${product["stock"]}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPesananView(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF0288D1),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Pesan Sekarang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
