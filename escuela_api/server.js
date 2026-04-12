import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import { db } from "./db.js";

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
  const { nombre, descripcion, id_deporte, id_entrenador } = req.body;

  try {
    await db.execute({
      sql: `INSERT INTO espacios (nombre, descripcion, id_deporte, id_entrenador)
            VALUES (?, ?, ?, ?)`,
      args: [nombre, descripcion, id_deporte, id_entrenador],
    });

    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 🔥 OBTENER ESPACIOS POR ENTRENADOR
app.get("/espacios/:idEntrenador", async (req, res) => {
  const { idEntrenador } = req.params;

  try {
    const result = await db.execute({
      sql: "SELECT * FROM espacios WHERE id_entrenador = ?",
      args: [idEntrenador],
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
});

// ELIMINAR ESPACIO
app.delete("/espacios/:id", async (req, res) => {
  const { id } = req.params;

  try {
    await db.execute({
      sql: "DELETE FROM espacios WHERE id_espacio = ?",
      args: [id],
    });

    res.json({ success: true });
  } catch (error) {
    res.json({
      success: false,
      error: error.message,
    });
  }
});

//OBTENER DEPORTES
app.get("/deportes", async (req, res) => {
  const result = await db.execute("SELECT * FROM deportes");
  res.json(result.rows);
});

//ESPACIOS POR DEPORTE (CON ENTRENADOR)
app.get("/espacios/deporte/:id", async (req, res) => {
  const { id } = req.params;

  const result = await db.execute({
    sql: `
      SELECT e.id_espacio, e.nombre, u.nombre as entrenador
      FROM espacios e
      JOIN usuarios u ON e.id_entrenador = u.id_usuario
      WHERE e.id_deporte = ?
    `,
    args: [id],
  });

  res.json(result.rows);
});

//GUARDAR ENTRENAMIENTO
app.post("/entrenamientos", async (req, res) => {
  const { id_deporte, id_espacio, id_entrenador, fecha, hora } = req.body;

  try {
    await db.execute({
      sql: `
        INSERT INTO entrenamientos (id_deporte, id_espacio, id_entrenador, fecha, hora)
        VALUES (?, ?, ?, ?, ?)
      `,
      args: [id_deporte, id_espacio, id_entrenador, fecha, hora],
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