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
$partido = null;

if (!$idPartido) {
    $errores[] = 'Partido no valido.';
} else {
    try {
        $pdo = ConexionDB::getInstancia()->getConexion();

        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $token = $_POST['csrf_token'] ?? '';
            $confirmacion = $_POST['confirmacion'] ?? '';

            if (!hash_equals($_SESSION['csrf_token'], $token)) {
                $errores[] = 'Solicitud no valida.';
            } elseif ($confirmacion !== 'SI') {
                $errores[] = 'Debes escribir SI para confirmar el borrado.';
            } else {
                $stmtEliminar = $pdo->prepare('CALL sp_eliminar_partido(:id_partido)');
                $stmtEliminar->execute(['id_partido' => $idPartido]);
                $stmtEliminar->closeCursor();
                header('Location: panel.php');
                exit;
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
        $errores[] = 'No se ha podido eliminar el partido.';
    }
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Eliminar partido</title>
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
        <form class="form-card" method="post" action="eliminar_partido.php">
            <h1>Eliminar partido</h1>

            <?php foreach ($errores as $error): ?>
                <p class="alert alert-error"><?= e($error) ?></p>
            <?php endforeach; ?>

            <?php if ($partido): ?>
                <p>Vas a eliminar el partido <strong><?= e($partido['equipo_local']) ?></strong> vs <strong><?= e($partido['equipo_visitante']) ?></strong>.</p>
                <p class="alert alert-warning">Esta accion no se puede deshacer. Escribe SI para confirmar.</p>

                <input type="hidden" name="csrf_token" value="<?= e($_SESSION['csrf_token']) ?>">
                <input type="hidden" name="id_partido" value="<?= e($partido['id_partido']) ?>">

                <label>
                    Confirmacion
                    <input type="text" name="confirmacion" maxlength="2" required>
                </label>

                <button class="danger-button" type="submit">Eliminar definitivamente</button>
            <?php endif; ?>
        </form>
    </main>
</body>
</html>

