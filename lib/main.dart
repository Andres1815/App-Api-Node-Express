import 'api_service.dart';
import 'package:flutter/material.dart';
import 'database/database_helper.dart';
void main() {
  runApp(const EcoTipsApp());
}

class EcoTipsApp extends StatelessWidget {
  const EcoTipsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoTips',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<bool> completed;

  int currentLevel = 1;

  List<Map<String, dynamic>> challenges = [
    {"title": "Apagar luces innecesarias", "icon": Icons.lightbulb_outline},
    {"title": "Usar botella reutilizable", "icon": Icons.water_drop_outlined},
    {"title": "Reciclar papel o cartón", "icon": Icons.recycling},
    {"title": "Ahorrar agua al bañarse", "icon": Icons.shower},
    {
      "title": "Caminar en lugar de usar vehículo",
      "icon": Icons.directions_walk,
    },
    {
      "title": "Llevar tu propia bolsa al supermercado",
      "icon": Icons.shopping_bag,
    },

    {"title": "Desconectar cargadores sin uso", "icon": Icons.power},
    {"title": "Separar residuos orgánicos", "icon": Icons.delete_outline},
    {"title": "Usar transporte público", "icon": Icons.directions_bus},
    {"title": "Plantar una planta o árbol", "icon": Icons.park},
    {"title": "Reducir el uso de plástico", "icon": Icons.no_drinks},
    {"title": "Reutilizar hojas impresas", "icon": Icons.description},
    {"title": "Apagar el computador al terminar", "icon": Icons.computer},
    {"title": "Consumir productos locales", "icon": Icons.store},
    {
      "title": "Recoger basura de espacios públicos",
      "icon": Icons.cleaning_services,
    },
    {"title": "Usar focos LED", "icon": Icons.light},
    {"title": "Evitar desperdiciar alimentos", "icon": Icons.restaurant},
    {"title": "Cerrar la llave al cepillarse", "icon": Icons.water},
    {"title": "Donar ropa que no uses", "icon": Icons.checkroom},
    {"title": "Compartir un consejo ecológico", "icon": Icons.share},
  ];

  final List<Map<String, dynamic>> extraChallenges = [
    {"title": "Crear una compostera casera", "icon": Icons.grass},
    {"title": "Usar bicicleta durante un día", "icon": Icons.pedal_bike},
    {"title": "Comprar productos ecológicos", "icon": Icons.eco},
    {
      "title": "Participar en una limpieza comunitaria",
      "icon": Icons.cleaning_services,
    },
    {"title": "Crear un huerto casero", "icon": Icons.yard},
    
  ];


  Future<void> saveProgress() async {
  int completedCount =
      completed.where((c) => c).length;

  int points = completedCount * 20;

  await DatabaseHelper.instance.updateProgress(
    points,
    currentLevel,
  );
}

Future<void> loadProgress() async {
  final data =
      await DatabaseHelper.instance.getProgress();

  final savedChallenges =
      await DatabaseHelper.instance.loadChallenges(
        challenges.length,
      );

  setState(() {
    currentLevel = data['nivel'];

    completed = savedChallenges;
  });
}

  @override
void initState() {
  super.initState();

  ApiService.getRetos().then((data) {
  debugPrint("Datos recibidos desde la API:");
  debugPrint(data.toString());
});
ApiService.crearReto(
  "Prueba Flutter",
  "Reto creado desde Flutter",
);
  completed = List<bool>.generate(
    challenges.length,
    (_) => false,
    growable: true,
  );

  loadProgress();
}

  void _toggleChallenge(int index, bool? value) {
  setState(() {
    completed[index] = value ?? false;
    DatabaseHelper.instance.saveChallenge(
  index,
  completed[index],
);

    saveProgress();

    bool allCompleted = completed.every((item) => item);

    if (allCompleted && currentLevel == 1) {
      challenges.addAll(extraChallenges);

      completed.addAll(
        List.filled(
          extraChallenges.length,
          false,
          growable: true,
        ),
      );

      currentLevel = 2;
      saveProgress();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🎉 ¡Has desbloqueado nuevos retos!',
          ),
        ),
      );
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final completedCount = completed.where((c) => c).length;
    final points = completedCount * 20;

    final List<Widget> screens = [
      const HomeTab(),
      ChallengesTab(
        challenges: challenges,
        completed: completed,
        onChanged: _toggleChallenge,
      ),
      const LearnTab(),
      ImpactTab(
        completed: completedCount,
        total: challenges.length,
        points: points,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Retos'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Aprender'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Mi Impacto'),
        ],
      ),
    );
  }
}

// ====================== TABS ======================

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green.shade50, Colors.green.shade100],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Icon(Icons.eco, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  '¡Hola, EcoAmigo!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  'Pequeñas acciones, grandes cambios',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb, color: Colors.amber),
                          SizedBox(width: 10),
                          Text(
                            'Consejo del día',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '❄️ Mantén el refrigerador a 3-5°C y el congelador a -18°C. Así consumes menos energía.',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Datos que te inspirarán',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    EcoFactCard(
                      icon: Icons.forest,
                      title:
                          'Un árbol puede absorber hasta 22 kg de CO₂ al año',
                      description:
                          'Plantar un árbol es una de las acciones más efectivas contra el cambio climático.',
                    ),
                    EcoFactCard(
                      icon: Icons.water_drop,
                      title:
                          'Cerrar la llave mientras te cepillas ahorra 12 litros de agua',
                      description:
                          'Si todos lo hicieran, se salvarían millones de litros diarios.',
                    ),
                    EcoFactCard(
                      icon: Icons.recycling,
                      title: 'El plástico tarda hasta 500 años en degradarse',
                      description:
                          'Reduce, reusa y recicla para frenar la contaminación.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EcoFactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EcoFactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.green.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== RETOS ====================
class ChallengesTab extends StatelessWidget {
  final List<Map<String, dynamic>> challenges;
  final List<bool> completed;
  final Function(int, bool?) onChanged;

  const ChallengesTab({
    super.key,
    required this.challenges,
    required this.completed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = completed.where((c) => c).length;
    final progress = challenges.isNotEmpty
        ? completedCount / challenges.length
        : 0.0;
    final points = completedCount * 20;

    return Column(
      children: [
        AppBar(
          title: const Text('Retos Ecológicos'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Mi progreso',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$completedCount de ${challenges.length} retos completados',
                        ),
                        Text(
                          '🏆 Puntos: $points',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final isCompleted = index < completed.length
                          ? completed[index]
                          : false;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: CheckboxListTile(
                          secondary: Icon(
                            challenges[index]['icon'] as IconData,
                            color: Colors.green,
                          ),
                          title: Text(
                            challenges[index]['title'],
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted ? Colors.grey : Colors.black,
                            ),
                          ),
                          value: isCompleted,
                          onChanged: (value) => onChanged(index, value),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== APRENDER ====================
class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Aprende y Actúa'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                _buildArticle(
                  '🌍 ¿Qué es la Huella de Carbono?',
                  'La huella de carbono es la cantidad de gases de efecto invernadero que producimos con nuestras actividades diarias...',
                  Icons.eco,
                ),
                _buildArticle(
                  '💧 El Poder del Agua',
                  'Solo el 2.5% del agua del planeta es dulce, y gran parte está en glaciares...',
                  Icons.water_drop,
                ),
                _buildArticle(
                  '♻️ La Regla de las 3R',
                  'Reducir, Reutilizar y Reciclar...',
                  Icons.recycling,
                ),
                _buildArticle(
                  '🚲 Movilidad Sostenible',
                  'Caminar, usar bicicleta o transporte público reduce emisiones...',
                  Icons.directions_bike,
                ),
                _buildArticle(
                  '🌍 ¿Qué es la Huella de Carbono?',
                  'La huella de carbono es la cantidad de gases de efecto invernadero que producimos con nuestras actividades diarias, como usar transporte, consumir electricidad o comprar productos. Reducirla ayuda a combatir el cambio climático.',
                  Icons.eco,
                ),

                _buildArticle(
                  '💧 El Poder del Agua',
                  'Solo el 2.5% del agua del planeta es dulce, y gran parte está congelada en glaciares. Ahorrar agua en actividades cotidianas ayuda a garantizar este recurso para futuras generaciones.',
                  Icons.water_drop,
                ),

                _buildArticle(
                  '♻️ La Regla de las 3R',
                  'Reducir, Reutilizar y Reciclar son acciones fundamentales para disminuir la cantidad de residuos que terminan en vertederos y océanos.',
                  Icons.recycling,
                ),

                _buildArticle(
                  '🚲 Movilidad Sostenible',
                  'Caminar, usar bicicleta o transporte público reduce las emisiones contaminantes y mejora la calidad del aire en las ciudades.',
                  Icons.directions_bike,
                ),

                _buildArticle(
                  '⚡ Ahorro de Energía',
                  'Apagar luces innecesarias, desconectar cargadores y utilizar bombillas LED puede reducir significativamente el consumo eléctrico en el hogar.',
                  Icons.bolt,
                ),

                _buildArticle(
                  '🌳 Importancia de los Árboles',
                  'Los árboles absorben dióxido de carbono, producen oxígeno y ayudan a regular la temperatura del planeta. Plantar árboles contribuye a la conservación ambiental.',
                  Icons.park,
                ),

                _buildArticle(
                  '🛍️ Consumo Responsable',
                  'Comprar solo lo necesario, elegir productos duraderos y evitar el desperdicio ayuda a reducir la explotación excesiva de recursos naturales.',
                  Icons.shopping_cart,
                ),

                _buildArticle(
                  '🥤 Reduce el Uso de Plásticos',
                  'Utilizar botellas reutilizables, bolsas de tela y recipientes reutilizables disminuye la contaminación causada por plásticos de un solo uso.',
                  Icons.no_drinks,
                ),

                _buildArticle(
                  '🍃 Energías Renovables',
                  'La energía solar, eólica e hidráulica son alternativas limpias que ayudan a reducir la dependencia de combustibles fósiles.',
                  Icons.solar_power,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArticle(String title, String content, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.green.shade700, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 15, height: 1.4)),
          ],
        ),
      ),
    );
  }
}

// ==================== IMPACTO ====================
class ImpactTab extends StatelessWidget {
  final int completed;
  final int total;
  final int points;

  const ImpactTab({
    super.key,
    required this.completed,
    required this.total,
    required this.points,
  });

  String getLevel() {
    if (points >= 500) return "👑 Guardián del Planeta";
    if (points >= 300) return "🏆 Eco Maestro";
    if (points >= 200) return "🏅 Eco Héroe";
    if (points >= 100) return "🌿 Eco Protector";
    if (points >= 50) return "🍃 Eco Aprendiz";
    return "🌱 Principiante";
  }

  String getMotivation(double percent) {
    if (percent >= 100) {
      return "🎉 ¡Has completado todos los retos disponibles!";
    }

    if (percent >= 75) {
      return "🌟 Estás muy cerca de convertirte en un Eco Héroe.";
    }

    if (percent >= 50) {
      return "💚 Tu impacto ambiental ya es significativo.";
    }

    if (percent >= 25) {
      return "🚀 Vas por buen camino, sigue completando retos.";
    }

    return "🌱 Todo gran cambio comienza con pequeñas acciones.";
  }

  @override
  Widget build(BuildContext context) {
    double percent = total > 0 ? (completed / total) * 100 : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green.shade100,
            child: const Icon(
              Icons.eco,
              size: 60,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            getLevel(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${percent.toStringAsFixed(0)}% completado',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          // Estadísticas rápidas
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.assignment_turned_in,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$completed",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Retos"),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "$points",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Puntos"),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(
                        Icons.eco,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${percent.toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text("Impacto"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          ImpactCard(
            icon: Icons.forest,
            title: 'CO₂ evitado',
            value: '${completed * 2} kg',
            color: Colors.teal,
          ),

          ImpactCard(
            icon: Icons.water_drop,
            title: 'Agua ahorrada',
            value: '${completed * 15} litros',
            color: Colors.blue,
          ),

          ImpactCard(
            icon: Icons.recycling,
            title: 'Residuos reciclados',
            value: '${completed * 3} kg',
            color: Colors.green,
          ),

          ImpactCard(
            icon: Icons.energy_savings_leaf,
            title: 'Energía ahorrada',
            value: '${completed * 5} kWh',
            color: Colors.orange,
          ),

          const SizedBox(height: 25),

          const Text(
            "🏆 Insignias",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (completed >= 5)
                const Chip(
                  avatar: Icon(Icons.eco),
                  label: Text("Eco Inicial"),
                ),

              if (completed >= 10)
                const Chip(
                  avatar: Icon(Icons.recycling),
                  label: Text("Reciclador"),
                ),

              if (completed >= 15)
                const Chip(
                  avatar: Icon(Icons.water_drop),
                  label: Text("Ahorrador de Agua"),
                ),

              if (completed >= 20)
                const Chip(
                  avatar: Icon(Icons.forest),
                  label: Text("Protector Verde"),
                ),

              if (completed >= 25)
                const Chip(
                  avatar: Icon(Icons.emoji_events),
                  label: Text("Eco Campeón"),
                ),
            ],
          ),

          const SizedBox(height: 25),

          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                getMotivation(percent),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ImpactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const ImpactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(40),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
