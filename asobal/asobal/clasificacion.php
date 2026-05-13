<?php
declare(strict_types=1);

require_once __DIR__ . '/clases/ConexionDB.php';

function e(mixed $valor): string
{
    return htmlspecialchars((string) $valor, ENT_QUOTES, 'UTF-8');
}

try {
    $pdo = ConexionDB::getInstancia()->getConexion();
    $stmt = $pdo->prepare('CALL sp_listar_clasificacion()');
    $stmt->execute();
    $clasificacion = $stmt->fetchAll();
    $stmt->closeCursor();
    $error = '';
} catch (Throwable $e) {
    $clasificacion = [];
    $error = 'No se ha podido cargar la clasificacion.';
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ASOBAL - Clasificacion</title>
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
        <h1>Clasificacion</h1>

        <?php if ($error !== ''): ?>
            <p class="alert alert-error"><?= e($error) ?></p>
        <?php else: ?>
            <div class="table-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>Pos</th>
                            <th>Equipo</th>
                            <th>Pts</th>
                            <th>V</th>
                            <th>E</th>
                            <th>D</th>
                            <th>GF</th>
                            <th>GC</th>
                            <th>DG</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($clasificacion as $fila): ?>
                            <tr>
                                <td><?= e($fila['posicion']) ?></td>
                                <td><?= e($fila['nombre_club']) ?></td>
                                <td><strong><?= e($fila['puntos']) ?></strong></td>
                                <td><?= e($fila['victorias']) ?></td>
                                <td><?= e($fila['empates']) ?></td>
                                <td><?= e($fila['derrotas']) ?></td>
                                <td><?= e($fila['goles_favor']) ?></td>
                                <td><?= e($fila['goles_contra']) ?></td>
                                <td><?= e($fila['diferencia_goles']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </main>
</body>
</html>

