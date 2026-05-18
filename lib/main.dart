import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: Colors.blueAccent,
      ),
      home: const HelloWorldPage(),
    );
  }
}

class HelloWorldPage extends StatefulWidget {
  const HelloWorldPage({super.key});

  @override
  State<HelloWorldPage> createState() => _HelloWorldPageState();
}

class _HelloWorldPageState extends State<HelloWorldPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _clickCount = 0;
  final List<String> _greetings = [
    "Hello, World!",
    "Assalam-o-Alaikum!",
    "Khush Amdeed!",
    "Welcome to Ustad Finder!",
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onCardTap() {
    setState(() {
      _clickCount = (_clickCount + 1) % _greetings.length;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: _onCardTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 50.0,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.language_rounded,
                          size: 48,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _greetings[_clickCount],
                          key: ValueKey<int>(_clickCount),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tap the card to change greeting',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_greetings.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: _clickCount == index ? 24.0 : 8.0,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: _clickCount == index
                                  ? Colors.blueAccent
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
