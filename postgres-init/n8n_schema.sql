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
-- tabla subcategories con auto-relación
CREATE TABLE subcategories (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES categories(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    solution TEXT,
    related_subcategory_id INTEGER REFERENCES subcategories(id) ON DELETE SET NULL,
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
    solution_gived BOOLEAN DEFAULT FAlSE, -- si se ha dado una solución
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
  (1, 'puerta no me abre', null),                                                                                                                         --1
    (1, 'lector apagado', 'Toca el lector para activarlo\nAcerca nuevamente tu rostro para el reconocimiento'),                                           --2
    (1, 'no me identifica', 'Verifica que estés a la distancia adecuada\nAsegúrate de que no haya otras personas alrededor'),                             --3
    (1, 'me identifica pero no abre', 'Confirma que la exclusa esté cerrada\nHala suavemente la puerta y vuelve a poner tu rostro frente al lector'),     --4
  (1, 'puerta no cierra', null),                                                                                                                          --5
    (1, 'puerta abierta totalmente', null),                                                                                                               --6
    (1, 'electroimán no asegura', null),                                                                                                                  --7
    (1, 'sirena está sonando', 'Asegúrate de que la puerta esté completamente cerrada');                                                                  --8

-- actualizamos los hijos para asociarlos con su padre
UPDATE subcategories SET related_subcategory_id = 1 WHERE id IN (2,3,4);
UPDATE subcategories SET related_subcategory_id = 5 WHERE id IN (6,7);
-- la sirena (id 8) queda sola

INSERT INTO subcategories (category_id, name, solution)
VALUES
  (2, 'No puedo entrar', NULL),                                                                                                                           -- id 9
    (2, 'lector apagado', 'Toca el lector para activarlo\nAcerca nuevamente tu rostro para el reconocimiento'),                                           -- id 10
    (2, 'no me identifica', 'Verifica que estés a la distancia adecuada\nAsegúrate de que no haya otras personas alrededor'),                             -- id 11
    (2, 'me identifica pero no abre', 'Si no te abre puedes ingresar desde la app\nRetrocede el vehículo y vuelve a intentarlo'),                         -- id 12
    (2, 'Sistema LPR', 'Retrocede el vehículo y vuelve a intentarlo'),                                                                                    -- id 13
  (2, 'No puedo salir', NULL),                                                                                                                            -- id 14
    (2, 'Problemas con doble validación', 'Da reversa y al volver a salir asegúrate de que las dos luces del indicador estén en verde');                  -- id 15

   

UPDATE subcategories SET related_subcategory_id = 9 WHERE id IN (10,11,12,13);
UPDATE subcategories SET related_subcategory_id = 14 WHERE id IN (10,11,12,15);

