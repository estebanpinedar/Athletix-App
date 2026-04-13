import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { db } from "./db.js";

async function crearNotificacion(id_usuario, mensaje) {
  await db.execute({
    sql: `
      INSERT INTO notificaciones (id_usuario, mensaje, fecha)
      VALUES (?, ?, datetime('now'))
    `,
    args: [id_usuario, mensaje],
  });
}

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// =========================
// 🔥 MIDDLEWARES
// =========================
app.use(cors());
app.use(express.json());

// 🔥 LOG DE PETICIONES
app.use((req, res, next) => {
  console.log("REQUEST:", req.method, req.url);
  next();
});


// =========================
// 🔐 LOGIN
// =========================
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.json({
      success: false,
      msg: "Faltan datos",
    });
  }

  try {
    const result = await db.execute({
      sql: "SELECT * FROM usuarios WHERE email = ?",
      args: [email],
    });

    if (result.rows.length === 0) {
      return res.json({
        success: false,
        msg: "No existe el usuario",
      });
    }

    const user = result.rows[0];

    if (user.password !== password) {
      return res.json({
        success: false,
        msg: "Contraseña incorrecta",
      });
    }

    res.json({
      success: true,
      id: user.id_usuario,
      nombre: user.nombre,
      rol: user.rol,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});


// =========================
// 👤 OBTENER USUARIOS
// =========================
app.get("/usuarios", async (req, res) => {
  try {
    const result = await db.execute("SELECT * FROM usuarios");
    res.json(result.rows);
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});


// =========================
// ➕ REGISTRAR USUARIO
// =========================
app.post("/usuarios", async (req, res) => {
  const { nombre, email, password, rol, documento } = req.body;

  if (!nombre || !email || !password || !rol || !documento) {
    return res.json({
      success: false,
      msg: "Faltan datos",
    });
  }

  try {
    // 🔥 VERIFICAR SI EXISTE
    const check = await db.execute({
      sql: "SELECT * FROM usuarios WHERE email = ?",
      args: [email],
    });

    if (check.rows.length > 0) {
      return res.json({
        success: false,
        msg: "El usuario ya existe",
      });
    }

    // =========================
    // 🔥 INSERTAR EN USUARIOS
    // =========================
    const userResult = await db.execute({
      sql: `
        INSERT INTO usuarios (nombre, email, password, rol, documento)
        VALUES (?, ?, ?, ?, ?)
      `,
      args: [nombre, email, password, rol, documento],
    });

    const userId = userResult.lastInsertRowid;

    // =========================
    // 🔥 INSERTAR SEGÚN ROL
    // =========================
    if (rol === "alumno") {
      await db.execute({
        sql: `
          INSERT INTO alumnos (nombre, documento, correo, id_usuario)
          VALUES (?, ?, ?, ?)
        `,
        args: [nombre, documento, email, userId],
      });
    }

    if (rol === "entrenador") {
      await db.execute({
        sql: `
          INSERT INTO entrenadores (nombre, correo, id_usuario, documento)
          VALUES (?, ?, ?, ?)
        `,
        args: [nombre, email, userId, documento],
      });
    }

    res.json({
      success: true,
      msg: "Usuario registrado correctamente",
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

app.post("/usuario", async (req, res) => {
  const { id } = req.body;

  try {
    const result = await db.execute({
      sql: "SELECT id_usuario, nombre, email, documento FROM usuarios WHERE id_usuario = ?",
      args: [id],
    });

    if (result.rows.length === 0) {
      return res.json({
        success: false,
        msg: "Usuario no encontrado",
      });
    }

    const user = result.rows[0];

    res.json({
      success: true,
      nombre: user.nombre,
      correo: user.email,
      documento: user.documento,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// =========================
// ✏️ ACTUALIZAR USUARIO
// =========================
app.put("/usuarios/:id", async (req, res) => {
  const { id } = req.params;
  const { nombre, documento, correo } = req.body;

  try {
    // 1. OBTENER USUARIO (para saber el rol)
    const userResult = await db.execute({
      sql: "SELECT rol FROM usuarios WHERE id_usuario = ?",
      args: [id],
    });

    if (userResult.rows.length === 0) {
      return res.json({ success: false, msg: "Usuario no encontrado" });
    }

    const rol = userResult.rows[0].rol;

    // 2. ACTUALIZAR USUARIO PRINCIPAL
    await db.execute({
      sql: `
        UPDATE usuarios
        SET nombre = ?, documento = ?, email = ?
        WHERE id_usuario = ?
      `,
      args: [nombre, documento, correo, id],
    });

    // 3. ACTUALIZAR TABLA SEGÚN ROL
    if (rol === "alumno") {
      await db.execute({
        sql: `
          UPDATE alumnos
          SET nombre = ?, documento = ?, correo = ?
          WHERE id_usuario = ?
        `,
        args: [nombre, documento, correo, id],
      });
    }

    if (rol === "entrenador") {
      await db.execute({
        sql: `
          UPDATE entrenadores
          SET nombre = ?, documento = ?, correo = ?
          WHERE id_usuario = ?
        `,
        args: [nombre, documento, correo, id],
      });
    }

    res.json({ success: true });

  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, error: error.message });
  }
});

app.put("/usuario/password", async (req, res) => {
  const { id, password } = req.body;

  try {
    await db.execute({
      sql: `
        UPDATE usuarios
        SET password = ?
        WHERE id_usuario = ?
      `,
      args: [password, id],
    });

    res.json({ success: true });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// =========================
//  ELIMINAR USUARIO
// =========================
app.delete("/usuarios/:id", async (req, res) => {
  const { id } = req.params;

  try {
    // 1. OBTENER ROL DEL USUARIO
    const userResult = await db.execute({
      sql: "SELECT rol FROM usuarios WHERE id_usuario = ?",
      args: [id],
    });

    if (userResult.rows.length === 0) {
      return res.json({ success: false, msg: "Usuario no encontrado" });
    }

    const rol = userResult.rows[0].rol;

    // 2. ELIMINAR EN TABLA SECUNDARIA SEGÚN ROL
    if (rol === "alumno") {
      await db.execute({
        sql: "DELETE FROM alumnos WHERE id_usuario = ?",
        args: [id],
      });
    }

    if (rol === "entrenador") {
      await db.execute({
        sql: "DELETE FROM entrenadores WHERE id_usuario = ?",
        args: [id],
      });
    }

    // 3. ELIMINAR EN USUARIOS (SIEMPRE)
    await db.execute({
      sql: "DELETE FROM usuarios WHERE id_usuario = ?",
      args: [id],
    });

    res.json({ success: true });

  } catch (error) {
    console.log(error);
    res.status(500).json({ success: false, error: error.message });
  }
});

//OBTENER DEPORTES
app.get("/deportes", async (req, res) => {
  try {
    const result = await db.execute("SELECT id_deporte, nombre FROM deportes");

    res.json({
      success: true,
      deportes: result.rows,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

//REGISTRAR ESPACIO
app.post("/espacios", async (req, res) => {
  const { nombre, descripcion, id_deporte, id_usuario } = req.body;

  try {
    // 🔥 convertir usuario → entrenador
    const result = await db.execute({
      sql: "SELECT id_entrenador FROM entrenadores WHERE id_usuario = ?",
      args: [id_usuario],
    });

    if (result.rows.length === 0) {
      return res.json({
        success: false,
        error: "El usuario no es entrenador",
      });
    }

    const id_entrenador = result.rows[0].id_entrenador;

    // 🔥 guardar el ID CORRECTO
    await db.execute({
      sql: `INSERT INTO espacios (nombre, descripcion, id_deporte, id_entrenador)
            VALUES (?, ?, ?, ?)`,
      args: [nombre, descripcion, id_deporte, id_entrenador],
    });

    res.json({ success: true });

  } catch (error) {
    console.log(error);
    res.json({ success: false, error: error.message });
  }
  await crearNotificacion(
  id_usuario,
  "Registraste un nuevo espacio deportivo"
);
});

// 🔥 OBTENER ESPACIOS POR ENTRENADOR
app.get("/espacios/:idUsuario", async (req, res) => {
  const { idUsuario } = req.params;

  try {
    // 🔥 convertir usuario → entrenador
    const resultEntrenador = await db.execute({
      sql: "SELECT id_entrenador FROM entrenadores WHERE id_usuario = ?",
      args: [idUsuario],
    });

    if (resultEntrenador.rows.length === 0) {
      return res.json({ success: false, error: "No es entrenador" });
    }

    const id_entrenador = resultEntrenador.rows[0].id_entrenador;

    // 🔥 ahora sí buscar espacios
    const result = await db.execute({
      sql: "SELECT * FROM espacios WHERE id_entrenador = ?",
      args: [id_entrenador],
    });

    res.json({
      success: true,
      data: result.rows,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

// =========================
// ✏️ MODIFICAR ESPACIO
// =========================
app.put("/espacios/:id", async (req, res) => {
  const { id } = req.params;
  const { nombre, descripcion, id_deporte } = req.body;

  try {
    await db.execute({
      sql: `
        UPDATE espacios 
        SET nombre = ?, descripcion = ?, id_deporte = ?
        WHERE id_espacio = ?
      `,
      args: [nombre, descripcion, id_deporte, id],
    });

    res.json({ success: true });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
  // buscar entrenador
const entrenador = await db.execute({
  sql: "SELECT id_usuario FROM entrenadores WHERE id_entrenador = (SELECT id_entrenador FROM espacios WHERE id_espacio = ?)",
  args: [id],
});

if (entrenador.rows.length > 0) {
  await crearNotificacion(
    entrenador.rows[0].id_usuario,
    "Modificaste un espacio"
  );
}
});

// ELIMINAR ESPACIO
app.delete("/espacios/:id", async (req, res) => {
  const { id } = req.params;
  const id_usuario = req.query.id_usuario; // ✅ CLAVE

  try {
    await db.execute({
      sql: "DELETE FROM espacios WHERE id_espacio = ?",
      args: [id],
    });

    res.json({ success: true });

    // 🔥 NOTIFICACIÓN
    crearNotificacion(
      id_usuario,
      "Eliminaste un espacio",
      "espacio"
    );

  } catch (error) {
    console.log("ERROR ELIMINAR ESPACIO:", error);
    res.json({
      success: false,
      error: error.message,
    });
  }
});

//ESPACIOS POR DEPORTE (CON ENTRENADOR)
app.get("/espacios/deporte/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await db.execute({
      sql: `
        SELECT 
          e.id_espacio, 
          e.nombre, 
          u.nombre as entrenador
        FROM espacios e
        JOIN entrenadores en ON e.id_entrenador = en.id_entrenador
        JOIN usuarios u ON en.id_usuario = u.id_usuario
        WHERE e.id_deporte = ?
      `,
      args: [id],
    });

    res.json(result.rows);

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

//GUARDAR ENTRENAMIENTO
app.post("/entrenamientos", async (req, res) => {
  const { id_deporte, id_espacio, fecha, hora } = req.body;

  try {
    // 🔥 1) Traer directamente el id_entrenador REAL
    const espacio = await db.execute({
      sql: "SELECT id_entrenador FROM espacios WHERE id_espacio = ?",
      args: [id_espacio],
    });

    if (espacio.rows.length === 0) {
      return res.json({ success: false, error: "Espacio no encontrado" });
    }

    const id_entrenador = espacio.rows[0].id_entrenador; // ✅ YA ES CORRECTO

    // 🔥 2) Insertar directamente
    await db.execute({
      sql: `
        INSERT INTO entrenamientos 
        (id_deporte, id_espacio, id_entrenador, fecha, hora)
        VALUES (?, ?, ?, ?, ?)
      `,
      args: [id_deporte, id_espacio, id_entrenador, fecha, hora],
    });

    res.json({ success: true });

  } catch (error) {
    console.log("ERROR ENTRENAMIENTO:", error);
    res.json({ success: false, error: error.message });
  }
});

//OBTENER EQUIPOS POR ENTRENADOR
app.get("/equipos/:idUsuario", async (req, res) => {
  const { idUsuario } = req.params;

  try {
    // 🔥 convertir usuario → entrenador
    const entrenador = await db.execute({
      sql: "SELECT id_entrenador FROM entrenadores WHERE id_usuario = ?",
      args: [idUsuario],
    });

    if (entrenador.rows.length === 0) {
      return res.json({ success: false, error: "No es entrenador" });
    }

    const id_entrenador = entrenador.rows[0].id_entrenador;

    // 🔥 traer equipos con info completa
    const result = await db.execute({
      sql: `
        SELECT 
          e.*,
          d.nombre AS deporte,
          c.nombre AS categoria,
          es.nombre AS espacio
        FROM equipos e
        JOIN deportes d ON e.id_deporte = d.id_deporte
        JOIN categorias c ON e.id_categoria = c.id_categoria
        JOIN espacios es ON e.id_espacio = es.id_espacio
        WHERE e.id_entrenador = ?
      `,
      args: [id_entrenador],
    });

    res.json({
      success: true,
      data: result.rows,
    });

  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

//REGISTRAR EQUIPOS
app.post("/equipos", async (req, res) => {
  const {
    nombre,
    descripcion,
    capacidad_maxima,
    id_deporte,
    id_espacio,
    id_categoria,
    id_usuario,
    dias,   // 🔥 NUEVO
    hora    // 🔥 NUEVO
  } = req.body;

  try {
    // 🔥 1. convertir usuario → entrenador
    const entrenador = await db.execute({
      sql: "SELECT id_entrenador FROM entrenadores WHERE id_usuario = ?",
      args: [id_usuario],
    });

    if (entrenador.rows.length === 0) {
      return res.json({
        success: false,
        error: "El usuario no es entrenador",
      });
    }

    const id_entrenador = entrenador.rows[0].id_entrenador;

    // 🔥 2. insertar equipo
    const result = await db.execute({
      sql: `
        INSERT INTO equipos
        (nombre, descripcion, capacidad_maxima, id_deporte, id_espacio, id_entrenador, id_categoria)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `,
      args: [
        nombre,
        descripcion,
        capacidad_maxima,
        id_deporte,
        id_espacio,
        id_entrenador,
        id_categoria
      ],
    });

    const equipoId = result.lastInsertRowid;

    // 🔥 3. insertar horarios (si vienen)
    if (dias && dias.length > 0 && hora) {
      for (let dia of dias) {
        await db.execute({
          sql: `
            INSERT INTO horarios_equipo (id_equipo, dia, hora)
            VALUES (?, ?, ?)
          `,
          args: [equipoId, dia, hora],
        });
      }
    }

    res.json({ success: true });

  } catch (error) {
    console.log("ERROR EQUIPO:", error);
    res.json({
      success: false,
      error: error.message,
    });
  }
  await crearNotificacion(
  id_usuario,
  "Creaste un nuevo equipo"
);
});

//MODIFICAR EQUIPOS
app.put("/equipos/:id", async (req, res) => {
  const { id } = req.params;

  const {
    nombre,
    descripcion,
    capacidad_maxima,
    id_deporte,
    id_espacio,
    id_categoria,
    dias,
    hora,
    id_usuario // 🔥 viene del frontend
  } = req.body;

  try {
    // =========================
    // 1. ACTUALIZAR EQUIPO
    // =========================
    await db.execute({
      sql: `
        UPDATE equipos
        SET nombre = ?, descripcion = ?, capacidad_maxima = ?, 
            id_deporte = ?, id_espacio = ?, id_categoria = ?
        WHERE id_equipo = ?
      `,
      args: [
        nombre,
        descripcion,
        capacidad_maxima,
        id_deporte,
        id_espacio,
        id_categoria,
        id
      ],
    });

    // =========================
    // 2. HORARIOS
    // =========================
    // =========================
// 2. HORARIOS (CORREGIDO)
// =========================
const actual = await db.execute({
  sql: `SELECT dia FROM horarios_equipo WHERE id_equipo = ?`,
  args: [id],
});

const diasActuales = actual.rows.map(r => r.dia);
const nuevosDias = dias || [];

// eliminar días quitados
for (let dia of diasActuales) {
  if (!nuevosDias.includes(dia)) {
    await db.execute({
      sql: `DELETE FROM horarios_equipo WHERE id_equipo = ? AND dia = ?`,
      args: [id, dia],
    });
  }
}

// 🔥 SOLO insertar si hay hora válida
if (hora) {
  for (let dia of nuevosDias) {
    if (!diasActuales.includes(dia)) {
      await db.execute({
        sql: `
          INSERT INTO horarios_equipo (id_equipo, dia, hora)
          VALUES (?, ?, ?)
        `,
        args: [id, dia, hora],
      });
    }
  }

  // actualizar hora existente
  await db.execute({
    sql: `UPDATE horarios_equipo SET hora = ? WHERE id_equipo = ?`,
    args: [hora, id],
  });
}

    // =========================
    // 🔔 NOTIFICACIÓN (NO ROMPE NADA)
    // =========================
    try {
      if (id_usuario) {
        await db.execute({
          sql: `
            INSERT INTO notificaciones (id_usuario, mensaje, tipo)
            VALUES (?, ?, ?)
          `,
          args: [id_usuario, "Modificaste un equipo", "equipo"],
        });
      }
    } catch (e) {
      console.log("ERROR NOTIFICACION:", e);
    }

    // =========================
    // RESPUESTA FINAL
    // =========================
    res.json({ success: true });

  } catch (error) {
    console.log("ERROR MODIFICAR EQUIPO:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

//ELIMINAR EQUIPOS
app.delete("/equipos/:id", async (req, res) => {
  const { id } = req.params;
  const id_usuario = req.query.id_usuario; // ✅ CAMBIO CLAVE

  try {
    await db.execute({
      sql: "DELETE FROM horarios_equipo WHERE id_equipo = ?",
      args: [id],
    });

    await db.execute({
      sql: "DELETE FROM equipos WHERE id_equipo = ?",
      args: [id],
    });

    res.json({ success: true });

    // 🔥 NOTIFICACIÓN
    crearNotificacion(
      id_usuario,
      "Eliminaste un equipo",
      "equipo"
    );

  } catch (error) {
    console.log("ERROR ELIMINAR EQUIPO:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

//ESPACIOS POR DEPORTE + ENTRENADOR

app.get("/espacios/deporte-entrenador/:idDeporte/:idUsuario", async (req, res) => {
  const { idDeporte, idUsuario } = req.params;

  try {
    // 🔥 Convertir usuario → entrenador
    const entrenador = await db.execute({
      sql: "SELECT id_entrenador FROM entrenadores WHERE id_usuario = ?",
      args: [idUsuario],
    });

    if (entrenador.rows.length === 0) {
      return res.json({
        success: false,
        error: "Usuario no es entrenador",
      });
    }

    const id_entrenador = entrenador.rows[0].id_entrenador;

    // 🔥 Filtrar espacios por deporte + entrenador
    const espacios = await db.execute({
      sql: `
        SELECT id_espacio, nombre
        FROM espacios
        WHERE id_deporte = ? AND id_entrenador = ?
      `,
      args: [idDeporte, id_entrenador],
    });

    res.json({
      success: true,
      data: espacios.rows,
    });

  } catch (error) {
    console.log("ERROR ESPACIOS:", error);
    res.json({
      success: false,
      error: error.message,
    });
  }
});

//OBTENER TODAS LAS CATEGORÍAS
app.get("/categorias", async (req, res) => {
  try {
    const result = await db.execute({
      sql: "SELECT * FROM categorias",
      args: [],
    });

    res.json({
      success: true,
      categorias: result.rows,
    });

  } catch (error) {
    console.log("ERROR CATEGORIAS:", error);
    res.json({
      success: false,
      error: error.message,
    });
  }
});

app.get("/equipos/:id/horario", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await db.execute({
      sql: `
        SELECT dia, hora
        FROM horarios_equipo
        WHERE id_equipo = ?
      `,
      args: [id],
    });

    const rows = result.rows;

    const dias = rows.map(r => r.dia);

    res.json({
      success: true,
      dias,
      hora: rows.length > 0 ? rows[0].hora : null,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

//INSCRIPCIÓN + VALIDACIÓN CAPACIDAD
app.post("/inscribir", async (req, res) => {
  const { id_equipo, id_usuario } = req.body;

  try {
    const inscritos = await db.execute({
      sql: "SELECT COUNT(*) as total FROM inscripcion WHERE id_equipo = ?",
      args: [id_equipo],
    });

    const equipo = await db.execute({
      sql: "SELECT capacidad_maxima FROM equipos WHERE id_equipo = ?",
      args: [id_equipo],
    });

    if (inscritos.rows[0].total >= equipo.rows[0].capacidad_maxima) {
      return res.json({
        success: false,
        msg: "Equipo lleno",
      });
    }

    // después del insert
    await db.execute({
      sql: `
    INSERT INTO inscripcion (id_equipo, id_usuario)
    VALUES (?, ?)
  `,
      args: [id_equipo, id_usuario],
    });

    // 🔔 NOTIFICACIÓN
    await crearNotificacion(
      id_usuario,
      "Te inscribiste a un equipo correctamente"
    );

    res.json({ success: true });

  } catch (e) {
    res.json({ success: false, msg: e.message });
  }

});

//EQUIPOS FILTRADOS
// EQUIPOS FILTRADOS (CORREGIDO)
app.get("/equipos/disponibles/:deporte/:categoria", async (req, res) => {
  const { deporte, categoria } = req.params;

  try {
    const result = await db.execute({
      sql: `
        SELECT 
          e.*,
          COUNT(i.id_inscripcion) as inscritos
        FROM equipos e
        LEFT JOIN inscripcion i 
          ON e.id_equipo = i.id_equipo
        WHERE e.id_deporte = ? 
          AND e.id_categoria = ?
        GROUP BY e.id_equipo
      `,
      args: [deporte, categoria],
    });

    res.json({ success: true, data: result.rows });

  } catch (e) {
    console.log("ERROR EQUIPOS DISPONIBLES:", e);
    res.json({ success: false, error: e.message });
  }
});

app.get("/equipos/filtrados", async (req, res) => {
  const { deporte, categoria } = req.query;

  try {
    const result = await db.execute({
      sql: `
        SELECT e.*, 
        COUNT(i.id_equipo) as inscritos
        FROM equipos e
        LEFT JOIN inscripcion i 
        ON e.id_equipo = i.id_equipo
        WHERE e.id_deporte = ?
        AND e.id_categoria = ?
        GROUP BY e.id_equipo
      `,
      args: [deporte, categoria],
    });

    res.json({
      success: true,
      data: result.rows,
    });

  } catch (error) {
    res.json({ success: false, error: error.message });
  }
});

//ELIMINAR INSCRIPCION
app.get("/mis-inscripciones/:idUsuario", async (req, res) => {
  const { idUsuario } = req.params;

  try {
    const result = await db.execute({
      sql: `
        SELECT 
          e.id_equipo,
          e.nombre,
          d.nombre as deporte,
          c.nombre as categoria
        FROM inscripcion i
        JOIN equipos e ON i.id_equipo = e.id_equipo
        JOIN deportes d ON e.id_deporte = d.id_deporte
        JOIN categorias c ON e.id_categoria = c.id_categoria
        WHERE i.id_usuario = ?
      `,
      args: [idUsuario],
    });

    res.json({
      success: true,
      data: result.rows,
    });

  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

app.delete("/inscripcion", async (req, res) => {
  const { id_usuario, id_equipo } = req.body;

  try {
    await db.execute({
  sql: `
    DELETE FROM inscripcion
    WHERE id_usuario = ? AND id_equipo = ?
  `,
  args: [id_usuario, id_equipo],
});

// 🔔 NOTIFICACIÓN
await crearNotificacion(
  id_usuario,
  "Te diste de baja de un equipo"
);

    res.json({ success: true });

  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

// 📅 ENTRENAMIENTOS POR USUARIO (ALUMNO)
app.get("/calendario/usuario/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const result = await db.execute({
      sql: `
        SELECT 
          e.nombre,
          he.dia,
          he.hora
        FROM inscripcion i
        JOIN equipos e ON i.id_equipo = e.id_equipo
        JOIN horarios_equipo he ON e.id_equipo = he.id_equipo
        WHERE i.id_usuario = ?
      `,
      args: [id],
    });

    res.json({ success: true, data: result.rows });
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

// 📅 ENTRENAMIENTOS POR ENTRENADOR
app.get("/calendario/entrenador/:id", async (req, res) => {
  const { id } = req.params;

  try {
    const entrenador = await db.execute({
      sql: "SELECT id_entrenador FROM entrenadores WHERE id_usuario = ?",
      args: [id],
    });

    const id_entrenador = entrenador.rows[0].id_entrenador;

    const result = await db.execute({
      sql: `
        SELECT 
          e.nombre,
          he.dia,
          he.hora
        FROM equipos e
        JOIN horarios_equipo he ON e.id_equipo = he.id_equipo
        WHERE e.id_entrenador = ?
      `,
      args: [id_entrenador],
    });

    res.json({ success: true, data: result.rows });
  } catch (e) {
    res.json({ success: false, error: e.message });
  }
});

// =========================
// 🔔 OBTENER NOTIFICACIONES
// =========================
app.get("/notificaciones/:idUsuario", async (req, res) => {
  const { idUsuario } = req.params;

  try {
    const result = await db.execute({
      sql: `
        SELECT *
        FROM notificaciones
        WHERE id_usuario = ?
        ORDER BY fecha DESC
      `,
      args: [idUsuario],
    });

    res.json({
      success: true,
      data: result.rows, // 🔥 IMPORTANTE
    });

  } catch (error) {
    console.log("ERROR NOTIFICACIONES:", error);
    res.json({
      success: false,
      error: error.message,
    });
  }
});

//ELIMINAR NOTIFICACIÓN (SWIPE)
app.delete("/notificaciones/:id", async (req, res) => {
  const { id } = req.params;

  try {
    await db.execute({
      sql: "DELETE FROM notificaciones WHERE id_notificacion = ?",
      args: [id],
    });

    res.json({ success: true });

  } catch (error) {
    res.json({ success: false, error: error.message });
  }
});

// =========================
// 🚀 SERVIDOR
// =========================
app.listen(PORT, "0.0.0.0", () => {
  console.log(`🚀 API corriendo en http://0.0.0.0:${PORT}`);
});