<?php
declare(strict_types=1);
require_once __DIR__ . '/clases/ConexionDB.php';
function e(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }

try {
    $pdo = ConexionDB::getInstancia()->getConexion();
    $s   = $pdo->prepare('CALL sp_listar_equipos()'); $s->execute(); $equipos = $s->fetchAll(); $s->closeCursor();
    $jugadores = [];
    foreach ($equipos as $eq) {
        $s = $pdo->prepare('CALL sp_listar_jugadores_equipo(:id)'); $s->execute(['id' => (int)$eq['id_equipo']]);
        $jugadores[$eq['id_equipo']] = $s->fetchAll(); $s->closeCursor();
    }
    $error = '';
} catch (Throwable $ex) { $equipos = []; $jugadores = []; $error = 'No se han podido cargar los equipos.'; error_log($ex->getMessage()); }
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ASOBAL - Equipos</title>
    <link rel="stylesheet" href="assets/css/estilos.css">
</head>
<body>
<header class="site-header">
    <div class="top-strip">
        <span>36ª Liga NEXUS ENERGÍA ASOBAL</span>
        <span>Competición profesional de balonmano</span>
    </div>
    <nav class="nav">
        <a class="brand" href="index.php">ASOBAL</a>
        <a href="index.php">Inicio</a>
        <a href="clasificacion.php">Clasificación</a>
        <a href="resultados.php">Resultados</a>
        <a href="equipos.php" class="nav-active">Equipos</a>
        <a href="admin/login.php" class="btn-admin">Admin</a>
    </nav>
</header>

<main class="container">
    <div class="section-title">
        <span>Temporada 2024-25</span>
        <h1>Equipos y plantillas</h1>
    </div>

    <?php if ($error !== ''): ?>
        <p class="alert alert-error"><?= e($error) ?></p>
    <?php elseif ($equipos === []): ?>
        <p class="empty">No hay equipos registrados.</p>
    <?php else: ?>
        <div class="team-grid">
            <?php foreach ($equipos as $eq): ?>
                <?php $pl = $jugadores[$eq['id_equipo']] ?? []; ?>
                <section class="team-card">
                    <div class="team-card-header">
                        <h2><?= e($eq['nombre_club']) ?></h2>
                        <span class="badge-jugadores"><?= count($pl) ?> jug.</span>
                    </div>
                    <p class="team-meta">
                        ðŸ“ <?= e($eq['ciudad']) ?>
                        <?php if (!empty($eq['anio_fundacion'])): ?> · Fund. <?= e($eq['anio_fundacion']) ?><?php endif; ?>
                        <?php if (!empty($eq['presidente'])): ?> · <?= e($eq['presidente']) ?><?php endif; ?>
                    </p>
                    <?php if ($pl === []): ?>
                        <p class="empty compact-empty">Sin jugadores registrados.</p>
                    <?php else: ?>
                        <ul class="player-list">
                            <?php foreach ($pl as $j): ?>
                                <li>
                                    <strong>#<?= e($j['dorsal']) ?> <?= e($j['nombre']) ?></strong>
                                    <span><?= e($j['posicion']) ?></span>
                                </li>
                            <?php endforeach; ?>
                        </ul>
                    <?php endif; ?>
                </section>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>
</main>

<footer class="site-footer">
    <div class="container footer-grid">
        <strong>ASOBAL</strong>
        <span>Proyecto PHP + MySQL · ASIX 1 · iFP L'Hospitalet</span>
    </div>
</footer>
</body>
</html>

