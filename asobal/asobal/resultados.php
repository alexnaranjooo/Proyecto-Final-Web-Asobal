<?php
declare(strict_types=1);

require_once __DIR__ . '/clases/ConexionDB.php';

function e(mixed $valor): string
{
    return htmlspecialchars((string) $valor, ENT_QUOTES, 'UTF-8');
}

try {
    $pdo = ConexionDB::getInstancia()->getConexion();
    $stmt = $pdo->prepare('CALL sp_listar_partidos(:tipo)');
    $stmt->execute(['tipo' => 'jugados']);
    $partidos = $stmt->fetchAll();
    $stmt->closeCursor();
    $error = '';
} catch (Throwable $e) {
    $partidos = [];
    $error = 'No se han podido cargar los resultados.';
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ASOBAL - Resultados</title>
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body>
    <header class="site-header">
        <nav class="nav">
            <a class="brand" href="index.php">ASOBAL</a>
            <a href="clasificacion.php">Clasificacion</a>
            <a href="resultados.php">Resultados</a>
            <a href="equipos.php">Equipos</a>
            <a href="admin/login.php">Admin</a>
        </nav>
    </header>

    <main class="container">
        <h1>Resultados</h1>

        <?php if ($error !== ''): ?>
            <p class="alert alert-error"><?= e($error) ?></p>
        <?php elseif ($partidos === []): ?>
            <p class="empty">No hay resultados registrados.</p>
        <?php else: ?>
            <div class="match-list">
                <?php foreach ($partidos as $partido): ?>
                    <article class="result-row">
                        <span><?= e(date('d/m/Y', strtotime($partido['fecha']))) ?></span>
                        <strong><?= e($partido['equipo_local']) ?></strong>
                        <span class="score"><?= e($partido['goles_local']) ?> - <?= e($partido['goles_visitante']) ?></span>
                        <strong><?= e($partido['equipo_visitante']) ?></strong>
                        <span>Jornada <?= e($partido['jornada']) ?></span>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </main>
</body>
</html>

