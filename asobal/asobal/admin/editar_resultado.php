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

$idPartido = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT) ?: filter_input(INPUT_POST, 'id_partido', FILTER_VALIDATE_INT);
$errores = [];
$exito = '';
$partido = null;

if (!$idPartido) {
    $errores[] = 'Partido no valido.';
} else {
    try {
        $pdo = ConexionDB::getInstancia()->getConexion();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $golesLocal = filter_input(INPUT_POST, 'goles_local', FILTER_VALIDATE_INT);
            $golesVisitante = filter_input(INPUT_POST, 'goles_visitante', FILTER_VALIDATE_INT);
            $token = $_POST['csrf_token'] ?? '';

            if (!hash_equals($_SESSION['csrf_token'], $token)) {
                $errores[] = 'Solicitud no valida.';
            }
            if ($golesLocal === false || $golesLocal < 0 || $golesLocal > 100) {
                $errores[] = 'Los goles locales deben estar entre 0 y 100.';
            }
            if ($golesVisitante === false || $golesVisitante < 0 || $golesVisitante > 100) {
                $errores[] = 'Los goles visitantes deben estar entre 0 y 100.';
            }

            if ($errores === []) {
                $stmt = $pdo->prepare('CALL sp_actualizar_resultado(:id_partido, :goles_local, :goles_visitante)');
                $stmt->execute([
                    'id_partido' => $idPartido,
                    'goles_local' => $golesLocal,
                    'goles_visitante' => $golesVisitante,
                ]);
                $stmt->closeCursor();
                $exito = 'Resultado actualizado correctamente.';
            }
        }

        $stmtPartido = $pdo->prepare('CALL sp_obtener_partido(:id_partido)');
        $stmtPartido->execute(['id_partido' => $idPartido]);
        $partido = $stmtPartido->fetch();
        $stmtPartido->closeCursor();

        if (!$partido) {
            $errores[] = 'El partido no existe.';
        }
    } catch (Throwable $e) {
        $errores[] = 'No se ha podido procesar el partido.';
    }
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar resultado</title>
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
        <form class="form-card" method="post" action="editar_resultado.php">
            <h1>Editar resultado</h1>

            <?php foreach ($errores as $error): ?>
                <p class="alert alert-error"><?= e($error) ?></p>
            <?php endforeach; ?>
            <?php if ($exito !== ''): ?>
                <p class="alert alert-success"><?= e($exito) ?></p>
            <?php endif; ?>

            <?php if ($partido): ?>
                <p><strong><?= e($partido['equipo_local']) ?></strong> vs <strong><?= e($partido['equipo_visitante']) ?></strong></p>
                <input type="hidden" name="csrf_token" value="<?= e($_SESSION['csrf_token']) ?>">
                <input type="hidden" name="id_partido" value="<?= e($partido['id_partido']) ?>">

                <label>
                    Goles local
                    <input type="number" name="goles_local" min="0" max="100" value="<?= e($partido['goles_local']) ?>" required>
                </label>

                <label>
                    Goles visitante
                    <input type="number" name="goles_visitante" min="0" max="100" value="<?= e($partido['goles_visitante']) ?>" required>
                </label>

                <button type="submit">Actualizar resultado</button>
            <?php endif; ?>
        </form>
    </main>
</body>
</html>

