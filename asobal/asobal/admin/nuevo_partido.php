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

if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

$errores = [];
$exito = '';

try {
    $pdo = ConexionDB::getInstancia()->getConexion();
    $stmtEquipos = $pdo->prepare('CALL sp_listar_equipos()');
    $stmtEquipos->execute();
    $equipos = $stmtEquipos->fetchAll();
    $stmtEquipos->closeCursor();
} catch (Throwable $e) {
    $equipos = [];
    $errores[] = 'No se han podido cargar los equipos.';
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $fecha = trim($_POST['fecha'] ?? '');
    $idJornada = filter_input(INPUT_POST, 'id_jornada', FILTER_VALIDATE_INT);
    $idPabellon = filter_input(INPUT_POST, 'id_pabellon', FILTER_VALIDATE_INT);
    $idLocal = filter_input(INPUT_POST, 'id_equipo_local', FILTER_VALIDATE_INT);
    $idVisitante = filter_input(INPUT_POST, 'id_equipo_visitante', FILTER_VALIDATE_INT);
    $token = $_POST['csrf_token'] ?? '';

    if (!hash_equals($_SESSION['csrf_token'], $token)) {
        $errores[] = 'Solicitud no valida.';
    }
    if ($fecha === '' || strtotime($fecha) === false) {
        $errores[] = 'La fecha del partido no es valida.';
    }
    if (!$idJornada || !$idPabellon || !$idLocal || !$idVisitante) {
        $errores[] = 'Todos los identificadores deben ser numeros validos.';
    }
    if ($idLocal && $idVisitante && $idLocal === $idVisitante) {
        $errores[] = 'El equipo local y visitante no pueden ser el mismo.';
    }

    if ($errores === []) {
        try {
            $stmt = $pdo->prepare('CALL sp_insertar_partido(:fecha, :id_jornada, :id_pabellon, :id_local, :id_visitante)');
            $stmt->execute([
                'fecha' => date('Y-m-d H:i:s', strtotime($fecha)),
                'id_jornada' => $idJornada,
                'id_pabellon' => $idPabellon,
                'id_local' => $idLocal,
                'id_visitante' => $idVisitante,
            ]);
            $stmt->closeCursor();
            $exito = 'Partido creado correctamente.';
        } catch (Throwable $e) {
            $errores[] = 'No se ha podido crear el partido. Revisa jornada, pabellon y equipos.';
        }
    }
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nuevo partido</title>
    <link rel="stylesheet" href="../assets/css/estilos.css">
</head>
<body>
    <header class="site-header">
        <nav class="nav">
            <a class="brand" href="panel.php">Panel ASOBAL</a>
            <a href="panel.php">Partidos</a>
            <a href="logout.php">Salir</a>
        </nav>
    </header>

    <main class="container narrow">
        <form class="form-card" method="post" action="nuevo_partido.php">
            <h1>Crear partido</h1>

            <?php foreach ($errores as $error): ?>
                <p class="alert alert-error"><?= e($error) ?></p>
            <?php endforeach; ?>
            <?php if ($exito !== ''): ?>
                <p class="alert alert-success"><?= e($exito) ?></p>
            <?php endif; ?>

            <input type="hidden" name="csrf_token" value="<?= e($_SESSION['csrf_token']) ?>">

            <label>
                Fecha y hora
                <input type="datetime-local" name="fecha" required>
            </label>

            <label>
                ID jornada
                <input type="number" name="id_jornada" min="1" required>
            </label>

            <label>
                ID pabellon
                <input type="number" name="id_pabellon" min="1" required>
            </label>

            <label>
                Equipo local
                <select name="id_equipo_local" required>
                    <option value="">Selecciona equipo</option>
                    <?php foreach ($equipos as $equipo): ?>
                        <option value="<?= e($equipo['id_equipo']) ?>"><?= e($equipo['nombre_club']) ?></option>
                    <?php endforeach; ?>
                </select>
            </label>

            <label>
                Equipo visitante
                <select name="id_equipo_visitante" required>
                    <option value="">Selecciona equipo</option>
                    <?php foreach ($equipos as $equipo): ?>
                        <option value="<?= e($equipo['id_equipo']) ?>"><?= e($equipo['nombre_club']) ?></option>
                    <?php endforeach; ?>
                </select>
            </label>

            <button type="submit">Guardar partido</button>
        </form>
    </main>
</body>
</html>

