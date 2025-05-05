import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}
    
class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _page = 0;

  final List<_OnboardingStep> steps = [
    _OnboardingStep(
      title: 'Nişan Al ve At',
      description: 'Parmağını/fareyi sürükleyerek nişan al, bırakınca topu fırlat.',
      icon: Icons.sports_esports,
    ),
    _OnboardingStep(
      title: 'Aynı Renkleri Patlat',
      description: 'Aynı renkten 3 veya daha fazla balonu bir araya getirerek patlat.',
      icon: Icons.bubble_chart,
    ),
    _OnboardingStep(
      title: 'Güçlendiriciler',
      description: 'Joker (beyaz), +1 (turuncu), taş (gri, patlamaz), buz (mavi, 2 vuruşta patlar) balonlara dikkat!',
      icon: Icons.flash_on,
    ),
    _OnboardingStep(
      title: 'Atış Limiti ve Skor',
      description: 'Her seviyede sınırlı atış hakkın var. Skorunu artırmak için stratejik oyna!',
      icon: Icons.score,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: steps.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _buildStep(steps[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == _page ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  if (_page == steps.length - 1) {
                    widget.onFinish();
                  } else {
                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  }
                },
                child: Text(_page == steps.length - 1 ? 'Başla' : 'Devam'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(_OnboardingStep step) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(step.icon, size: 80, color: Colors.white),
            const SizedBox(height: 32),
            Text(
              step.title,
              style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              step.description,
              style: const TextStyle(fontSize: 20, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  const _OnboardingStep({required this.title, required this.description, required this.icon});
} 