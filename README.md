
# Evolution Platform with n8n


## 📦 Descripción

Este proyecto despliega una plataforma de automatización y orquestación con:

- **Evolution API**
- **PostgreSQL**
- **Redis**
- **n8n**

Orquestado vía `docker-compose` para simplificar el despliegue, con infraestructura de persistencia y colas.

---

## 🚀 Servicios incluidos

- **evolution_api**  
  Expone la API principal de Evolution en el puerto `8080`.

- **postgres**  
  Base de datos PostgreSQL con esquema inicial y datos para Evolution y n8n (puerto `5432`).

- **redis**  
  Redis como motor de caché y colas (puerto `6379`).

- **n8n**  
  Plataforma de automatización de flujos (puerto `5678`) protegida con autenticación básica.

---

## 🗂️ Estructura del proyecto

 ```bash
    N8nEvolutionApi/
    ├── docker-compose.yaml  
    ├── postgres-init  
    │   ├── create\_n8n.sql  
    │   └── n8n\_schema.sql  
    ├── README.md  
    └── workflows  
    └── Final workflow\.json
 ```


  





## 📥 Clonar el repositorio

Usa SSH (asegúrate de tener tu clave pública agregada a tu cuenta de GitHub):

```bash
git clone git@github.com:jeanpaulrestedur1234/n8nandEvolutionApi.git
cd n8nandEvolutionApi
```


## ⚙️ Configuración de variables de entorno

Primero copia el archivo de ejemplo:

```bash
cp .env.example .env
```

Luego edita `.env` con tus credenciales reales (API keys, contraseñas de base de datos, etc).

---

## 🐳 Levantar los servicios

Ejecuta:

```bash
docker compose up -d
```

Docker levantará:

* Evolution API (`:8080`)
* PostgreSQL (`:5432`)
* Redis (`:6379`)
* n8n (`:5678`)

---

## 🌐 Accesos

* Evolution API: [http://localhost:8080](http://localhost:8080)
* n8n: [http://localhost:5678](http://localhost:5678) *(con usuario y clave desde tu `.env`)*

---

## 🗑️ Borrar todo

Para reiniciar limpio:

```bash
docker compose down -v --remove-orphans
```

O para eliminar **absolutamente todo** (cuidado):

```bash
docker system prune -a --volumes
```

---

## 🛡️ Seguridad

* Ajusta los permisos del archivo de configuración de n8n con:

  ```bash
  chmod 600 /home/node/.n8n/config
  ```
* Personaliza `AUTHENTICATION_API_KEY` antes de exponer el servicio.
* Cambia el usuario/clave de n8n (`N8N_BASIC_AUTH_USER` y `N8N_BASIC_AUTH_PASSWORD`) en entornos de producción.

---

## 📄 Notas adicionales

* Los scripts de inicialización de PostgreSQL se encuentran en `postgres-init/`.
* Los flujos de trabajo de n8n (`Final workflow.json`) están en `workflows/`.
* El volumen `evolution_instances` mantiene los datos persistentes de Evolution API.



✅ **Copia tal cual** este bloque, pégalo en tu `README.md` del repositorio, ¡y listo!
Si quieres después agregar badges, documentación de endpoints o diagramas de arquitectura, avísame y te ayudo a generarlos también.

