<?php
declare(strict_types=1);
require_once __DIR__ . '/clases/ConexionDB.php';

function e(mixed $v): string { return htmlspecialchars((string)$v, ENT_QUOTES, 'UTF-8'); }
function fecha(string $f, string $fmt = 'd M · H:i'): string { $t = strtotime($f); return $t ? date($fmt, $t) : $f; }
function resClase(mixed $gl, mixed $gv): string { return (int)$gl > (int)$gv ? 'resultado--local' : ((int)$gl < (int)$gv ? 'resultado--visitante' : 'resultado--empate'); }

try {
    $pdo = ConexionDB::getInstancia()->getConexion();
    $s = $pdo->prepare('CALL sp_listar_partidos(:t)'); $s->execute(['t'=>'portada']); $partidos = $s->fetchAll(); $s->closeCursor();
    $s = $pdo->prepare('CALL sp_listar_clasificacion()'); $s->execute(); $clasificacion = array_slice($s->fetchAll(), 0, 8); $s->closeCursor();
    $error = '';
} catch (Throwable $ex) { $partidos = []; $clasificacion = []; $error = 'No se han podido cargar los datos.'; error_log($ex->getMessage()); }
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ASOBAL - Liga de Balonmano</title>
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
        <a href="index.php" class="nav-active">Inicio</a>
        <a href="clasificacion.php">Clasificación</a>
        <a href="resultados.php">Resultados</a>
        <a href="equipos.php">Equipos</a>
        <a href="admin/login.php" class="btn-admin">Admin</a>
    </nav>
</header>

<main>
    <section class="home-hero">
        <div class="home-hero__content">
            <p class="eyebrow">Liga profesional</p>
            <h1>La competición ASOBAL,<br>en tiempo real</h1>
            <p>Resultados, calendario, clasificación y equipos gestionados desde un backoffice privado con PHP nativo, PDO y procedimientos almacenados.</p>
        </div>
    </section>

    <section class="container">
        <?php if ($error !== ''): ?><p class="alert alert-error"><?= e($error) ?></p><?php endif; ?>
        <div class="portal-grid">
            <aside class="league-panel">
                <div class="panel-title"><span>Liga</span><strong>Clasificación</strong></div>
                <?php if ($clasificacion === []): ?>
                    <p class="empty compact-empty">Sin datos disponibles.</p>
                <?php else: ?>
                    <ol class="standing-list">
                        <?php foreach ($clasificacion as $fila): ?>
                            <li>
                                <span class="standing-pos"><?= e($fila['posicion']) ?></span>
                                <span class="standing-team"><?= e($fila['nombre_club']) ?></span>
                                <strong><?= e($fila['puntos']) ?> pts</strong>
                            </li>
                        <?php endforeach; ?>
                    </ol>
                    <a class="text-link" href="clasificacion.php">Ver clasificación completa &rarr;</a>
                <?php endif; ?>
            </aside>

            <section class="feature-news">
                <p class="eyebrow dark">Actualidad</p>
                <h2>Jornada ASOBAL</h2>
                <p>Consulta los cruces más recientes, revisa los marcadores y sigue la evolución de los equipos durante toda la temporada.</p>
                <div class="feature-actions">
                    <a class="button-link" href="resultados.php">Ver resultados</a>
                    <a class="button-link secondary" href="equipos.php">Ver equipos</a>
                </div>
            </section>
        </div>
    </section>

    <section class="container section-tight">
        <div class="section-title">
            <span>Calendario</span>
            <h2>Últimos partidos</h2>
        </div>
        <?php if ($partidos === [] && $error === ''): ?>
            <p class="empty">Sin partidos disponibles.</p>
        <?php else: ?>
            <div class="match-grid">
                <?php foreach ($partidos as $p): ?>
                    <article class="match-card <?= resClase($p['goles_local'], $p['goles_visitante']) ?>">
                        <header class="match-header">
                            <span class="jornada-badge">J<?= e($p['jornada']) ?></span>
                            <time class="match-date"><?= e(fecha($p['fecha'])) ?></time>
                        </header>
                        <div class="match-body">
                            <div class="team"><?= e($p['equipo_local']) ?></div>
                            <div class="score"><?= e($p['goles_local']) ?> - <?= e($p['goles_visitante']) ?></div>
                            <div class="team"><?= e($p['equipo_visitante']) ?></div>
                        </div>
                        <footer class="match-footer"><?= e($p['pabellon'] ?? 'Pabellón por definir') ?></footer>
                    </article>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </section>
</main>

<footer class="site-footer">
    <div class="container footer-grid">
        <strong>ASOBAL</strong>
        <span>Proyecto PHP + MySQL · ASIX 1 · iFP L'Hospitalet</span>
    </div>
</footer>
</body>
</html>
