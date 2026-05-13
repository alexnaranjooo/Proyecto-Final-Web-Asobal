
# Proyecto ASOBAL

Aplicacion web en PHP y MySQL para consultar una liga de balonmano ASOBAL y gestionar partidos desde un panel de administracion.

## Funcionalidades

- Portada con partidos y clasificacion resumida.
- Clasificacion completa.
- Resultados y proximos partidos.
- Listado de equipos y jugadores.
- Panel de administracion.
- Login de administrador con `admin` / `password`.
- Creacion de equipos.
- Creacion, edicion y eliminacion de partidos.
- Scripts SQL con base de datos, procedimientos, funciones y triggers del proyecto.

## Estructura

```text
asobal/
  admin/       Panel de administracion
  assets/      CSS y recursos visuales
  clases/      Conexion a base de datos
  SQL/         Base de datos, procedimientos, funciones y triggers
  index.php    Pagina principal
```

## Instalacion local con XAMPP

1. Copia la carpeta `asobal/` dentro de `htdocs`.
2. Abre phpMyAdmin.
3. Importa este unico archivo desde phpMyAdmin:

```text
asobal/SQL/instalacion_completa_asobal.sql
```

4. Revisa la conexion en:

```text
asobal/clases/ConexionDB.php
```

Por defecto usa:

```text
host: 127.0.0.1
base de datos: Asobal
usuario: root
password:
puerto: 3307
```

5. Entra en:

```text
http://localhost/asobal/asobal
```

## Login administrador

```text
usuario: admin
contrasena: password
```

## Subir a hosting

Para publicar la web necesitas un hosting con PHP y MySQL. GitHub Pages no sirve para este proyecto porque no ejecuta PHP ni MySQL.

En el hosting:

1. Sube el contenido de la carpeta `asobal/`.
2. Crea una base de datos MySQL.
3. Importa los SQL del proyecto.
4. Configura las variables de entorno si el hosting lo permite:

```text
DB_HOST
DB_NAME
DB_USER
DB_PASS
DB_PORT
```

Si el hosting no permite variables de entorno, cambia esos datos directamente en `asobal/clases/ConexionDB.php`.

## GitHub

Este repositorio esta pensado para mostrar el codigo del proyecto. Para mostrar la web funcionando, anade en esta seccion el enlace de tu hosting cuando lo tengas publicado.
