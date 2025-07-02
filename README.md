# N8nEvolutionApi - Orquestación de WhatsApp con Evolution API y n8n

Este proyecto le permite orquestar de manera eficiente sus flujos de trabajo de WhatsApp utilizando **Evolution API** en conjunto con **n8n** para la automatización.

---

## Contenido

- [Estructura del Proyecto](#estructura-del-proyecto)
- [Requisitos](#requisitos)
- [Configuración](#configuración)
  - [Archivo `.env`](#1-archivo-env)
  - [Archivos de Inicialización de PostgreSQL](#2-archivos-de-inicialización-de-postgresql)
  - [Flujos de Trabajo de n8n](#3-flujos-de-trabajo-de-n8n)
- [Uso](#uso)
  - [Iniciar los servicios](#iniciar-los-servicios)
  - [Acceso a las interfaces](#acceso-a-las-interfaces)
  - [Detener los servicios](#detener-los-servicios)
- [Detalles de los Servicios](#detalles-de-los-servicios)
  - [Evolution API (`api`)](#evolution-api-api)
  - [Redis (`redis`)](#redis-redis)
  - [PostgreSQL (`postgres`)](#postgresql-postgres)
  - [n8n (`n8n`)](#n8n-n8n)
- [Volúmenes](#volúmenes)
- [Red](#red)

---

## Estructura del Proyecto

La estructura de directorios del proyecto es la siguiente:

.├── docker-compose.yaml├── postgres-init│   ├── create_n8n.sql│   └── n8n_schema.sql├── README.md└── workflows└── Final workflow.json
---

## Requisitos

Asegúrese de tener instalados los siguientes componentes en su sistema:

-   **Docker**: Para la gestión de contenedores.
-   **Docker Compose**: Para definir y ejecutar aplicaciones Docker de múltiples contenedores.

---

## Configuración

Antes de iniciar los servicios, necesita crear un archivo de entorno y configurar los flujos de trabajo.

### 1. Archivo `.env`

Cree un archivo llamado `.env` en la raíz del proyecto (al mismo nivel que `docker-compose.yaml`) y defina las siguientes variables:

```dotenv
# Configuración para N8n (Opcional, pero recomendado para seguridad)
N8N_BASIC_AUTH_USER=su_usuario_n8n
N8N_BASIC_AUTH_PASSWORD=su_contraseña_n8n

# URL del servidor de Webhook para n8n (reemplace con su dominio o IP pública si es necesario)
# Si está ejecutando localmente y no expone n8n a Internet, 'http://localhost:5678' es suficiente.
# Para despliegues en la nube, use su URL pública (ej: [https://su-dominio.com/n8n](https://su-dominio.com/n8n))
WEBHOOK_SERVER=http://localhost:5678
Asegúrese de reemplazar su_usuario_n8n y su_contraseña_n8n con credenciales seguras para acceder a la interfaz de n8n.2. Archivos de Inicialización de PostgreSQLLos archivos SQL dentro de postgres-init/ se utilizan para inicializar la base de datos de PostgreSQL con el esquema requerido para n8n.create_n8n.sql: Contiene las sentencias para crear la base de datos n8n.n8n_schema.sql: Contiene el esquema de tablas necesario para n8n.Estos archivos se montan en el contenedor de postgres y se ejecutan automáticamente cuando el contenedor se inicia por primera vez, asegurando que la base de datos n8n esté lista para su uso.3. Flujos de Trabajo de n8nEl archivo workflows/Final workflow.json contiene un flujo de trabajo de n8n preconfigurado. Después de iniciar n8n, puede importar este archivo a su instancia de n8n para comenzar a usar el flujo de trabajo de ejemplo.UsoUna vez que haya configurado el archivo .env y asegurado los archivos de inicialización, puede iniciar la aplicación.Iniciar los serviciosDesde el directorio raíz del proyecto, ejecute el siguiente comando para levantar todos los servicios definidos en docker-compose.yaml:docker compose up -d
Este comando:Descargará las imágenes de Docker necesarias si aún no están presentes.Creará y arrancará los contenedores para api, redis, postgres, y n8n.Los contenedores se ejecutarán en segundo plano (-d para detached mode).Acceso a las interfacesEvolution API: Acceda a la API a través de http://localhost:8080.n8n: Acceda a la interfaz de usuario de n8n a través de http://localhost:5678. Utilice las credenciales que configuró en el archivo .env.Detener los serviciosPara detener y remover todos los contenedores, redes y volúmenes definidos en docker-compose.yaml, ejecute:docker compose down
Para detener los servicios sin eliminar los volúmenes (útil si desea mantener los datos), ejecute:docker compose down --remove-orphans
Detalles de los ServiciosEvolution API (api)container_name: evolution_api: Nombre del contenedor.image: evoapicloud/evolution-api:latest: Utiliza la última imagen de Evolution API.restart: always: El contenedor se reiniciará automáticamente si se detiene.depends_on: redis, postgres: Asegura que Redis y PostgreSQL estén en funcionamiento antes de iniciar la API.ports: 8080:8080: Mapea el puerto 8080 del host al puerto 8080 del contenedor.volumes: evolution_instances:/evolution/instances: Persiste los datos de las instancias de Evolution API.networks: evolution-net: Conecta el servicio a la red interna evolution-net.env_file: .env: Carga las variables de entorno desde el archivo .env.expose: 8080: Expone el puerto 8080 dentro de la red Docker.Redis (redis)image: redis:latest: Utiliza la última imagen de Redis.networks: evolution-net: Conecta el servicio a la red interna evolution-net.container_name: redis: Nombre del contenedor.env_file: .env: Carga las variables de entorno desde el archivo .env.command: redis-server --port 6379 --appendonly yes: Inicia Redis con persistencia de datos (AOF).volumes: evolution_redis:/data: Persiste los datos de Redis.ports: 127.0.0.1:6379:6379: Mapea el puerto 6379 del host (solo accesible localmente) al puerto 6379 del contenedor.PostgreSQL (postgres)container_name: postgres: Nombre del contenedor.image: postgres:15: Utiliza la imagen de PostgreSQL versión 15.networks: evolution-net: Conecta el servicio a la red interna evolution-net.command: ["postgres", "-c", "max_connections=1000", "-c", "listen_addresses=*"]: Configura PostgreSQL para permitir más conexiones y escuchar en todas las interfaces.restart: always: El contenedor se reiniciará automáticamente si se detiene.ports: 127.0.0.1:5432:5432: Mapea el puerto 5432 del host (solo accesible localmente) al puerto 5432 del contenedor.environment: Define variables de entorno para la configuración de PostgreSQL, incluyendo usuario, contraseña y base de datos inicial.env_file: .env: Carga variables de entorno adicionales desde el archivo .env.volumes:./postgres-init/create_n8n.sql:/docker-entrypoint-initdb.d/01_create_n8n.sql: Script para crear la base de datos n8n../postgres-init/n8n_schema.sql:/docker-entrypoint-initdb.d/02_n8n_schema.sql: Script para crear el esquema de n8n.postgres_data:/var/lib/postgresql/data: Persiste los datos de la base de datos PostgreSQL.expose: 5432: Expone el puerto 5432 dentro de la red Docker.n8n (n8n)image: n8nio/n8n: Utiliza la imagen oficial de n8n.container_name: n8n: Nombre del contenedor.ports: 5678:5678: Mapea el puerto 5678 del host al puerto 5678 del contenedor.networks: evolution-net: Conecta el servicio a la red interna evolution-net.environment: Configura n8n con autenticación básica, host, puerto, habilitación de runners y la URL del webhook. También configura la conexión a la base de datos PostgreSQL y Redis.volumes: n8n_data:/home/node/.n8n: Persiste los datos de configuración y flujos de trabajo de n8n.restart: always: El contenedor se reiniciará automáticamente si se detiene.depends_on: redis, postgres: Asegura que Redis y PostgreSQL estén en funcionamiento antes de iniciar n8n.VolúmenesEl docker-compose.yaml define los siguientes volúmenes para asegurar la persistencia de los datos:evolution_instances: Utilizado por el servicio api para almacenar datos de instancias de Evolution API.evolution_redis: Utilizado por el servicio redis para almacenar los datos de Redis.postgres_data: Utilizado por el servicio postgres para almacenar los datos de la base de datos PostgreSQL.n8n_data: Utilizado por el servicio n8n para almacenar la configuración, credenciales y flujos de trabajo de n8n.Estos volúmenes son gestionados por Docker y aseguran que sus datos no se pierdan cuando los contenedores se detienen o se eliminan.RedEl proyecto utiliza una red Docker personalizada llamada evolution-net. Esta red de tipo bridge permite que todos los servicios (api, redis, postgres, n8n) se comuniquen entre sí utilizando sus nombres de servicio como nombres de host. Esto simplifica la configuración de las conexiones internas entre los contenedores.networks:
  evolution-net:
    name: evolution-net
    driver: bridge
