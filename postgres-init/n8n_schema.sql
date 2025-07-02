-- debes conectarte primero a la base n8n
\connect n8n;
-- ================================================
-- FUNCIONES OPCIONALES DE LIMPIEZA (si existen antes)
-- ================================================

DROP TABLE IF EXISTS chats CASCADE;
DROP TABLE IF EXISTS subcategories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ================================================
-- TABLA: users
-- ================================================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT,
    phone TEXT UNIQUE,
    email TEXT UNIQUE,
    company TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ================================================
-- TABLA: categories (temas del chatbot)
-- ================================================
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    description TEXT
);

-- ================================================
-- TABLA: subcategories (problemas del chatbot)
-- ================================================
CREATE TABLE subcategories (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    solution TEXT,
    UNIQUE (category_id, name)
);

-- ================================================
-- TABLA: chats
-- ================================================

CREATE TABLE chats (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    subcategory_id INTEGER REFERENCES subcategories(id) ON DELETE SET NULL,
    location_name TEXT,   -- nombre de la locación asociada
    device TEXT,          -- dispositivo asociado
    summary TEXT,         -- resumen del problema
    status TEXT DEFAULT 'open',
    solution_feedback BOOLEAN DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

-- ================================================
-- ÍNDICES SUGERIDOS
-- ================================================
CREATE INDEX idx_chats_user ON chats(user_id);
CREATE INDEX idx_chats_category ON chats(category_id);
CREATE INDEX idx_chats_subcategory ON chats(subcategory_id);

-- ================================================
-- CARGA DE DATOS DEMO
-- ================================================

-- categorías (temas principales)
INSERT INTO categories (name, description)
VALUES 
  ('ingreso_peatonal', 'Accesos peatonales'),
  ('ingreso_vehicular', 'Accesos vehiculares'),
  ('aplicacion', 'Problemas con la aplicación'),
  ('cctv', 'Videovigilancia'),
  ('otro', 'Otros problemas');

-- subcategorías (problemas) para ingreso_peatonal
INSERT INTO subcategories (category_id, name, solution)
VALUES
  (1, 'No me identifica', 'Revisar que el documento esté vigente y visible.'),
  (1, 'No prende el dispositivo', 'Verificar conexión eléctrica y reiniciar el equipo.'),
  (1, 'Me dice que expiró', 'Solicitar actualización de permisos con el administrador.'),
  (1, 'Otro', 'Contactar soporte.');

-- subcategorías para ingreso_vehicular
INSERT INTO subcategories (category_id, name, solution)
VALUES
  (2, 'No abre la barrera', 'Verificar permisos del vehículo y el lector.'),
  (2, 'No detecta el TAG', 'Revisar la ubicación correcta del TAG en el parabrisas.'),
  (2, 'Otro', 'Contactar soporte técnico.');

-- subcategorías para aplicacion
INSERT INTO subcategories (category_id, name, solution)
VALUES
  (3, 'No abre la aplicación', 'Reinstalar la aplicación y probar de nuevo.'),
  (3, 'No llegan notificaciones', 'Verificar permisos de notificaciones en el teléfono.'),
  (3, 'Otro', 'Contactar soporte técnico.');

-- subcategorías para cctv
INSERT INTO subcategories (category_id, name, solution)
VALUES
  (4, 'Cámara sin imagen', 'Verificar alimentación eléctrica y cables.'),
  (4, 'No graba eventos', 'Revisar configuración de grabación.'),
  (4, 'Otro', 'Contactar soporte técnico.');

-- subcategorías para otro
INSERT INTO subcategories (category_id, name, solution)
VALUES
  (5, 'Otro problema', 'Contactar soporte técnico.');

-- ================================================
-- DEMO DE USUARIOS
-- ================================================
INSERT INTO users (name, phone, email, company)
VALUES 
  ('Alice Smith', '3001234567', 'alice@example.com', 'ACME S.A.S.'),
  ('Bob Johnson', '3007654321', 'bob@example.com', 'BetaCorp Ltda.');

-- ================================================
-- DEMO DE CHATS
-- ================================================
INSERT INTO chats (user_id, category_id, subcategory_id, description, summary, status)
VALUES
  (1, 1, 1, 'Mi carnet no funciona en el torniquete.', 'Se revisó vigencia de documento.', 'open'),
  (2, 4, 9, 'La cámara del parqueadero no muestra imagen', 'Verificar alimentación eléctrica.', 'open');
