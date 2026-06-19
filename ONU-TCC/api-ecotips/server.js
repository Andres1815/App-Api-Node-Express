const express = require('express');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());

let retos = [
  {
    id: 1,
    titulo: "Apagar luces innecesarias",
    descripcion: "Reducir el consumo de energía eléctrica apagando luces que no se utilizan.",
    completado: false
  },
  {
    id: 2,
    titulo: "Usar botella reutilizable",
    descripcion: "Evitar el uso de botellas plásticas desechables.",
    completado: false
  },
  {
    id: 3,
    titulo: "Reciclar papel o cartón",
    descripcion: "Separar papel y cartón para reciclaje.",
    completado: false
  },
  {
    id: 4,
    titulo: "Ahorrar agua al bañarse",
    descripcion: "Reducir el tiempo de la ducha para ahorrar agua.",
    completado: false
  },
  {
    id: 5,
    titulo: "Caminar en lugar de usar vehículo",
    descripcion: "Realizar trayectos cortos caminando para reducir emisiones.",
    completado: false
  },
  {
    id: 6,
    titulo: "Llevar tu propia bolsa al supermercado",
    descripcion: "Evitar bolsas plásticas de un solo uso.",
    completado: false
  },
  {
    id: 7,
    titulo: "Desconectar cargadores sin uso",
    descripcion: "Reducir el consumo eléctrico innecesario.",
    completado: false
  },
  {
    id: 8,
    titulo: "Separar residuos orgánicos",
    descripcion: "Clasificar adecuadamente los residuos biodegradables.",
    completado: false
  },
  {
    id: 9,
    titulo: "Usar transporte público",
    descripcion: "Reducir el uso de vehículos particulares.",
    completado: false
  },
  {
    id: 10,
    titulo: "Plantar una planta o árbol",
    descripcion: "Contribuir al cuidado del medio ambiente.",
    completado: false
  },
  {
    id: 11,
    titulo: "Reducir el uso de plástico",
    descripcion: "Disminuir el consumo de productos plásticos.",
    completado: false
  },
  {
    id: 12,
    titulo: "Reutilizar hojas impresas",
    descripcion: "Dar un segundo uso al papel ya utilizado.",
    completado: false
  },
  {
    id: 13,
    titulo: "Apagar el computador al terminar",
    descripcion: "Ahorrar energía apagando equipos que no se usan.",
    completado: false
  },
  {
    id: 14,
    titulo: "Consumir productos locales",
    descripcion: "Apoyar la economía local y reducir transporte.",
    completado: false
  },
  {
    id: 15,
    titulo: "Recoger basura de espacios públicos",
    descripcion: "Ayudar a mantener limpios los espacios comunes.",
    completado: false
  },
  {
    id: 16,
    titulo: "Usar focos LED",
    descripcion: "Reducir el consumo energético del hogar.",
    completado: false
  },
  {
    id: 17,
    titulo: "Evitar desperdiciar alimentos",
    descripcion: "Consumir responsablemente y reducir desperdicios.",
    completado: false
  },
  {
    id: 18,
    titulo: "Cerrar la llave al cepillarse",
    descripcion: "Ahorrar agua durante el cepillado dental.",
    completado: false
  },
  {
    id: 19,
    titulo: "Donar ropa que no uses",
    descripcion: "Dar una segunda vida útil a la ropa.",
    completado: false
  },
  {
    id: 20,
    titulo: "Compartir un consejo ecológico",
    descripcion: "Promover hábitos sostenibles con otras personas.",
    completado: false
  },
  {
    id: 21,
    titulo: "Crear una compostera casera",
    descripcion: "Aprovechar residuos orgánicos para compostaje.",
    completado: false
  },
  {
    id: 22,
    titulo: "Usar bicicleta durante un día",
    descripcion: "Reducir emisiones utilizando bicicleta.",
    completado: false
  },
  {
    id: 23,
    titulo: "Comprar productos ecológicos",
    descripcion: "Elegir productos con menor impacto ambiental.",
    completado: false
  },
  {
    id: 24,
    titulo: "Participar en una limpieza comunitaria",
    descripcion: "Colaborar en actividades de limpieza del entorno.",
    completado: false
  },
  {
    id: 25,
    titulo: "Crear un huerto casero",
    descripcion: "Cultivar alimentos en casa de forma sostenible.",
    completado: false
  }
];

app.get('/retos', (req, res) => {
  res.json(retos);
});

app.post('/retos', (req, res) => {
  const nuevoReto = {
    id: retos.length + 1,
    ...req.body
  };

  retos.push(nuevoReto);
  res.status(201).json(nuevoReto);
});

app.put('/retos/:id', (req, res) => {
  const id = parseInt(req.params.id);

  const index = retos.findIndex(r => r.id === id);

  if (index === -1) {
    return res.status(404).json({
      mensaje: 'Reto no encontrado'
    });
  }

  retos[index] = {
    ...retos[index],
    ...req.body
  };

  res.json(retos[index]);
});

app.delete('/retos/:id', (req, res) => {
  const id = parseInt(req.params.id);

  retos = retos.filter(r => r.id !== id);

  res.json({
    mensaje: 'Reto eliminado'
  });
});

app.listen(PORT, () => {
  console.log(`Servidor ejecutándose en http://localhost:${PORT}`);
});