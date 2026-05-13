# 🏐 Proyecto ASOBAL
 
### Aplicación web en PHP y MySQL para consultar la liga de balonmano ASOBAL y gestionar partidos
 
![PHP](https://img.shields.io/badge/PHP-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![Status](https://img.shields.io/badge/Estado-Completo-success?style=for-the-badge)
![Type](https://img.shields.io/badge/Tipo-Proyecto%20Escolar-blue?style=for-the-badge)
 
---
 
### 📋 Sobre el proyecto
 
Aplicación web completa para la gestión y consulta de la **Liga NEXUS ENERGÍA ASOBAL** (competición profesional de balonmano). Incluye visualización pública de partidos, clasificación, equipos y jugadores, además de un panel de administración completo para gestionar partidos.
 
---
 
### ⚙️ Funcionalidades
 
| Funcionalidad | Descripción |
|---------------|-------------|
| `Portada` | Partidos destacados y clasificación resumida |
| `Clasificación completa` | Tabla de posiciones de todos los equipos |
| `Resultados` | Partidos jugados y próximos encuentros |
| `Equipos y jugadores` | Listado completo de equipos con sus plantillas |
| `Panel de administración` | Login seguro para administradores |
| `Gestión de partidos` | Crear, editar y eliminar partidos |
| `Gestión de equipos` | Crear equipos y actualizar plantillas |
 
---
 
### 🛠️ Stack
 
| Tecnología | Uso |
|------------|-----|
| `PHP 8+` | Backend con tipado estricto y programación orientada a objetos |
| `MySQL` | Base de datos con procedimientos almacenados, funciones y triggers |
| `HTML5/CSS3` | Frontend responsive y semántico |
| `SQL` | Procedimientos almacenados, funciones y triggers para lógica de negocio |
 
---
 
### 📂 Estructura del proyecto
 
```
asobal/
├── admin/
│   ├── login.php
│   ├── panel.php
│   ├── nuevo_partido.php
│   ├── editar_resultado.php
│   ├── eliminar_partido.php
│   └── logout.php
├── assets/
│   └── css/
│       └── estilos.css
├── clases/
│   └── ConexionDB.php
├── SQL/
│   ├── Base de datos Competición/
│   ├── Procedimientos Almacenados/
│   ├── Funciones/
│   ├── Triggers/
│   └── instalacion_completa_asobal.sql
├── index.php
├── clasificacion.php
├── resultados.php
└── equipos.php
```
 
---
 
### 🖥️ Requisitos
 
```
- Servidor local: XAMPP / WAMP / LAMP
- PHP >= 8.0
- MySQL >= 5.7
- Navegador moderno
```
 
---
