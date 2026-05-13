<?php
declare(strict_types=1);

require_once __DIR__ . '/../clases/ConexionDB.php';

session_set_cookie_params([
    'httponly' => true,
    'samesite' => 'Lax',
    'secure' => isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on',
]);
session_start();

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

function e(mixed $valor): string
{
    return htmlspecialchars((string) $valor, ENT_QUOTES, 'UTF-8');
}

$mensajes = [];
$erroresFormulario = [];

if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

try {
    $pdo = ConexionDB::getInstancia()->getConexion();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $token = $_POST['csrf_token'] ?? '';
        $accion = $_POST['accion'] ?? '';

        if (!hash_equals($_SESSION['csrf_token'], $token)) {
            $erroresFormulario[] = 'Solicitud no valida.';
        } elseif ($accion === 'crear_equipo') {
            $nombre = trim($_POST['nombre_club'] ?? '');
            $ciudad = trim($_POST['ciudad'] ?? '');
            $presupuesto = filter_input(INPUT_POST, 'presupuesto', FILTER_VALIDATE_FLOAT);
            $anioFundacion = filter_input(INPUT_POST, 'anio_fundacion', FILTER_VALIDATE_INT);
            $presidente = trim($_POST['presidente'] ?? '');
            $titulos = filter_input(INPUT_POST, 'titulos', FILTER_VALIDATE_INT);

            if ($nombre === '' || strlen($nombre) > 100) {
                $erroresFormulario[] = 'El nombre del club es obligatorio y no puede superar 100 caracteres.';
            }
            if ($ciudad === '' || strlen($ciudad) > 80) {
                $erroresFormulario[] = 'La ciudad es obligatoria y no puede superar 80 caracteres.';
            }
            if ($presupuesto === false || $presupuesto < 0) {
                $erroresFormulario[] = 'El presupuesto debe ser un numero positivo.';
            }
            if ($anioFundacion === false || $anioFundacion < 1800 || $anioFundacion > (int) date('Y')) {
                $erroresFormulario[] = 'El ano de fundacion no es valido.';
            }
            if ($presidente === '' || strlen($presidente) > 100) {
                $erroresFormulario[] = 'El presidente es obligatorio y no puede superar 100 caracteres.';
            }
            if ($titulos === false || $titulos < 0 || $titulos > 100) {
                $erroresFormulario[] = 'Los titulos deben estar entre 0 y 100.';
            }

            if ($erroresFormulario === []) {
                $stmtCrearEquipo = $pdo->prepare('CALL sp_insertar_equipo(:nombre, :ciudad, :presupuesto, :anio, :presidente, :titulos)');
                $stmtCrearEquipo->execute([
                    'nombre' => $nombre,
                    'ciudad' => $ciudad,
                    'presupuesto' => $presupuesto,
                    'anio' => $anioFundacion,
                    'presidente' => $presidente,
                    'titulos' => $titulos,
                ]);
                $stmtCrearEquipo->closeCursor();
                $mensajes[] = 'Equipo creado correctamente.';
            }
        }
    }

    $stmtPartidos = $pdo->prepare('CALL sp_listar_partidos(:tipo)');
    $stmtPartidos->execute(['tipo' => 'todos']);
    $partidos = $stmtPartidos->fetchAll();
    $stmtPartidos->closeCursor();

    $stmtEquipos = $pdo->prepare('CALL sp_listar_equipos()');
    $stmtEquipos->execute();
    $equipos = $stmtEquipos->fetchAll();
    $stmtEquipos->closeCursor();

    $error = '';
} catch (Throwable $e) {
    $partidos = [];
    $equipos = [];
    $error = 'No se han podido cargar los datos del panel.';
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Panel administrador</title>
    <link rel="stylesheet" href="../assets/css/estilos.css">
</head>
<body>
    <header class="site-header">
        <nav class="nav">
            <a class="brand" href="panel.php">Panel ASOBAL</a>
            <a href="nuevo_partido.php">Nuevo partido</a>
            <a href="../index.php">Web publica</a>
            <a href="logout.php">Salir</a>
        </nav>
    </header>

    <main class="container">
        <h1>Backoffice</h1>
        <p class="muted">Sesion iniciada como <?= e($_SESSION['admin_usuario'] ?? 'admin') ?>.</p>

        <?php if ($error !== ''): ?>
            <p class="alert alert-error"><?= e($error) ?></p>
        <?php endif; ?>
        <?php foreach ($erroresFormulario as $errorFormulario): ?>
            <p class="alert alert-error"><?= e($errorFormulario) ?></p>
        <?php endforeach; ?>
        <?php foreach ($mensajes as $mensaje): ?>
            <p class="alert alert-success"><?= e($mensaje) ?></p>
        <?php endforeach; ?>

        <section class="admin-section">
            <div class="section-title">
                <h2>Partidos</h2>
                <a class="button-link" href="nuevo_partido.php">Crear partido</a>
            </div>

            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Local</th>
                            <th>Resultado</th>
                            <th>Visitante</th>
                            <th>Jornada</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($partidos as $partido): ?>
                            <tr>
                                <td><?= e(date('d/m/Y H:i', strtotime($partido['fecha']))) ?></td>
                                <td><?= e($partido['equipo_local']) ?></td>
                                <td><?= e($partido['goles_local']) ?> - <?= e($partido['goles_visitante']) ?></td>
                                <td><?= e($partido['equipo_visitante']) ?></td>
                                <td><?= e($partido['jornada']) ?></td>
                                <td class="actions">
                                    <a href="editar_resultado.php?id=<?= e($partido['id_partido']) ?>">Editar</a>
                                    <a class="danger" href="eliminar_partido.php?id=<?= e($partido['id_partido']) ?>">Eliminar</a>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </section>

        <section class="admin-section">
            <h2>Equipos registrados</h2>
            <form class="inline-form" method="post" action="panel.php">
                <input type="hidden" name="csrf_token" value="<?= e($_SESSION['csrf_token']) ?>">
                <input type="hidden" name="accion" value="crear_equipo">
                <input type="text" name="nombre_club" placeholder="Nombre del club" maxlength="100" required>
                <input type="text" name="ciudad" placeholder="Ciudad" maxlength="80" required>
                <input type="number" name="presupuesto" placeholder="Presupuesto" min="0" step="0.01" required>
                <input type="number" name="anio_fundacion" placeholder="Ano fundacion" min="1800" max="<?= e(date('Y')) ?>" required>
                <input type="text" name="presidente" placeholder="Presidente" maxlength="100" required>
                <input type="number" name="titulos" placeholder="Titulos" min="0" max="100" required>
                <button type="submit">Crear equipo</button>
            </form>
            <div class="team-grid compact">
                <?php foreach ($equipos as $equipo): ?>
                    <article class="team-card">
                        <h3><?= e($equipo['nombre_club']) ?></h3>
                        <p><?= e($equipo['ciudad']) ?></p>
                    </article>
                <?php endforeach; ?>
            </div>
        </section>
    </main>
</body>
</html>


