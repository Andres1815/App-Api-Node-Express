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
    {"title": "Separar papel y cartón limpios", "icon": Icons.description},
    {"title": "Lavar y secar envases aprovechables", "icon": Icons.local_drink},
    {"title": "Depositar residuos aprovechables en la caneca blanca", "icon": Icons.recycling},
    {"title": "Identificar los residuos no aprovechables", "icon": Icons.delete_outline},
    {"title": "Separar los residuos orgánicos aprovechables", "icon": Icons.compost},
    {"title": "Evitar mezclar residuos limpios con residuos contaminados", "icon": Icons.remove_circle_outline},
    {"title": "Reutilizar un recipiente antes de desecharlo", "icon": Icons.replay},
    {"title": "Reducir el uso de productos desechables", "icon": Icons.no_drinks},
    {"title": "Reconocer el código de colores de separación", "icon": Icons.palette},
    {"title": "Disponer correctamente pilas y residuos especiales", "icon": Icons.battery_alert},
    {"title": "Aprovechar restos vegetales para compostaje", "icon": Icons.grass},
    {"title": "Consultar dónde entregar materiales reciclables", "icon": Icons.location_on},
    {"title": "Enseñar a otra persona cómo separar residuos", "icon": Icons.people},
    {"title": "Revisar la separación de residuos en casa", "icon": Icons.home},
    {"title": "Evitar arrojar basura en calles, canales y playas", "icon": Icons.cleaning_services},
    {"title": "Preferir productos con menos empaques", "icon": Icons.shopping_bag},
    {"title": "Separar correctamente latas y envases metálicos", "icon": Icons.inventory_2},
    {"title": "Doblar y almacenar el cartón limpio y seco", "icon": Icons.all_inbox},
    {"title": "Identificar los residuos que no van en reciclaje común", "icon": Icons.info_outline},
    {"title": "Participar en una jornada de limpieza comunitaria", "icon": Icons.volunteer_activism},
  ];

  final List<Map<String, dynamic>> extraChallenges = [
    {"title": "Preparar una pequeña compostera", "icon": Icons.compost},
    {"title": "Organizar un punto de separación en casa", "icon": Icons.delete_sweep},
    {"title": "Realizar una limpieza de un espacio comunitario", "icon": Icons.cleaning_services},
    {"title": "Investigar cómo se aprovecha el aceite de cocina usado", "icon": Icons.oil_barrel},
    {"title": "Crear una guía de separación para la familia", "icon": Icons.menu_book},
    
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
                        'Antes de tirar algo a la basura, identifica si puede aprovecharse. Deposita el papel, cartón, plástico, vidrio y metales limpios y secos en el recipiente blanco. Así facilitas el reciclaje y evitas que materiales útiles terminen en el relleno sanitario.',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
const Text(
  'Aprende sobre la gestión de residuos',
  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
),
const SizedBox(height: 12),
Expanded(
  child: ListView(
    children: const [
      EcoFactCard(
        icon: Icons.recycling,
        title: 'Separar los residuos facilita su aprovechamiento',
        description:
            'Clasificar correctamente los residuos permite recuperar materiales que pueden transformarse en nuevos productos.',
      ),
      EcoFactCard(
        icon: Icons.delete_outline,
        title: 'El color blanco identifica los residuos aprovechables',
        description:
            'En Colombia, el recipiente blanco se utiliza para depositar plástico, cartón, papel, vidrio y metales limpios y secos.',
      ),
      EcoFactCard(
        icon: Icons.delete,
        title: 'El recipiente negro es para residuos no aprovechables',
        description:
            'Allí se depositan residuos como papel higiénico usado, servilletas contaminadas y otros materiales que no pueden aprovecharse.',
      ),
      EcoFactCard(
        icon: Icons.eco,
        title: 'Los residuos orgánicos pueden convertirse en abono',
        description:
            'Restos de frutas, verduras y otros residuos orgánicos pueden aprovecharse mediante procesos como el compostaje.',
      ),
      EcoFactCard(
        icon: Icons.water_drop,
        title: 'Los envases deben estar limpios y secos',
        description:
            'Antes de depositar recipientes reciclables, procura vaciarlos, limpiarlos y dejarlos secar para evitar contaminar otros materiales.',
      ),
      EcoFactCard(
        icon: Icons.battery_full,
        title: 'Las pilas usadas necesitan una disposición especial',
        description:
            'No deben mezclarse con los residuos domésticos. Llévalas a puntos de recolección autorizados para su manejo adecuado.',
      ),
      EcoFactCard(
        icon: Icons.shopping_bag,
        title: 'Reducir el consumo también ayuda a gestionar los residuos',
        description:
            'Utilizar bolsas reutilizables, evitar productos desechables y comprar solo lo necesario disminuye la cantidad de basura generada.',
      ),
      EcoFactCard(
        icon: Icons.local_shipping,
        title: 'Los residuos tienen diferentes destinos',
        description:
            'Algunos materiales pueden reciclarse, otros convertirse en abono y los que no son aprovechables requieren una disposición final adecuada.',
      ),
      EcoFactCard(
        icon: Icons.beach_access,
        title: 'La basura en las calles puede llegar al mar',
        description:
            'Los residuos abandonados pueden ser arrastrados por la lluvia hacia canales, cuerpos de agua y playas, afectando los ecosistemas.',
      ),
      EcoFactCard(
        icon: Icons.lightbulb_outline,
        title: 'Las tres R promueven un consumo responsable',
        description:
            'Reducir, reutilizar y reciclar son acciones fundamentales para disminuir los residuos y aprovechar mejor los recursos.',
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
                  '♻️ ¿Qué significa gestionar los residuos?',
                  'La gestión de residuos comprende las acciones para reducir, separar, almacenar, recolectar y aprovechar los materiales que descartamos. Una buena gestión evita que muchos residuos terminen en calles, canales, cuerpos de agua y espacios naturales.',
                  Icons.recycling,
                ),
                _buildArticle(
                  '⚪ Residuos aprovechables: caneca blanca',
                  'Deposita papel, cartón, plástico, vidrio y metales. Estos materiales deben estar vacíos, limpios y secos para facilitar su aprovechamiento. Si están contaminados con comida o líquidos, pueden dejar de ser aprovechables.',
                  Icons.delete_outline,
                ),
                _buildArticle(
                  '⚫ Residuos no aprovechables: caneca negra',
                  'En esta categoría se depositan residuos que no pueden aprovecharse en el esquema ordinario de separación, como papel higiénico, servilletas usadas, papeles metalizados y residuos contaminados con comida o grasa.',
                  Icons.delete,
                ),
                _buildArticle(
                  '🟢 Residuos orgánicos aprovechables: caneca verde',
                  'Incluye restos de comida y residuos vegetales que pueden aprovecharse mediante procesos como el compostaje, de acuerdo con las condiciones del sistema de recolección disponible.',
                  Icons.compost,
                ),
                _buildArticle(
                  '🧴 ¿Cómo preparar los materiales reciclables?',
                  'Vacía los envases, retira los restos de comida, enjuágalos cuando sea necesario y déjalos secar. Mantén el papel y el cartón secos. Evita mezclar materiales aprovechables con residuos sanitarios o grasosos.',
                  Icons.local_drink,
                ),
                _buildArticle(
                  '🔋 ¿Qué hacer con pilas y residuos especiales?',
                  'Las pilas, baterías, medicamentos vencidos, bombillas y aparatos electrónicos no deben mezclarse con los residuos ordinarios. Busca programas o puntos de recolección posconsumo autorizados para entregarlos de forma segura.',
                  Icons.battery_alert,
                ),
                _buildArticle(
                  '🍂 ¿Qué es el compostaje?',
                  'Es un proceso mediante el cual ciertos residuos orgánicos se transforman en abono. Se pueden aprovechar restos vegetales y de frutas, evitando incorporar materiales que no sean adecuados para el sistema de compostaje utilizado.',
                  Icons.grass,
                ),
                _buildArticle(
                  '🌊 ¿Por qué es importante en Cartagena?',
                  'La disposición inadecuada de residuos puede afectar calles, canales, playas, manglares y cuerpos de agua. Separar en la fuente, reducir los desechables y disponer correctamente la basura ayuda a proteger los espacios naturales y la calidad de vida de la comunidad.',
                  Icons.water,
                ),
                _buildArticle(
                  '🔄 Las 3R: reducir, reutilizar y reciclar',
                  'Reducir significa consumir menos y evitar residuos innecesarios. Reutilizar consiste en dar nuevos usos a los objetos. Reciclar permite transformar materiales aprovechables para incorporarlos nuevamente a procesos productivos.',
                  Icons.autorenew,
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
  icon: Icons.recycling,
  title: 'Residuos separados',
  value: '$completed',
  color: Colors.green,
),

ImpactCard(
  icon: Icons.eco,
  title: 'Acciones de reutilización',
  value: '$completed',
  color: Colors.teal,
),

ImpactCard(
  icon: Icons.compost,
  title: 'Acciones de aprovechamiento',
  value: '$completed',
  color: Colors.lightGreen,
),

ImpactCard(
  icon: Icons.school,
  title: 'Actividades educativas',
  value: '$completed',
  color: Colors.blue,
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
                  label: Text("Eco-Inicial"),
                ),

              if (completed >= 10)
                const Chip(
                  avatar: Icon(Icons.recycling),
                  label: Text("Eco-Reciclador"),
                ),

              if (completed >= 15)
                const Chip(
                  avatar: Icon(Icons.water_drop),
                  label: Text("Eco-Reciclador II"),
                ),

              if (completed >= 20)
                const Chip(
                  avatar: Icon(Icons.forest),
                  label: Text("Eco-Protector Verde"),
                ),

              if (completed >= 25)
                const Chip(
                  avatar: Icon(Icons.emoji_events),
                  label: Text("Eco-Campeón"),
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
