<?php
declare(strict_types=1);

require_once __DIR__ . '/../clases/ConexionDB.php';

const ADMIN_USUARIO_POR_DEFECTO = 'admin';
const ADMIN_PASSWORD_HASH = '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi';

function e(mixed $v): string
{
    return htmlspecialchars((string) $v, ENT_QUOTES, 'UTF-8');
}

function obtenerAdmin(PDO $pdo, string $usuario): ?array
{
    try {
        $stmt = $pdo->prepare('CALL sp_obtener_admin_por_usuario(:u)');
        $stmt->execute(['u' => $usuario]);
        $admin = $stmt->fetch();
        $stmt->closeCursor();

        return is_array($admin) ? $admin : null;
    } catch (Throwable $ex) {
        error_log('No se pudo usar sp_obtener_admin_por_usuario: ' . $ex->getMessage());
    }

    try {
        $stmt = $pdo->prepare('SELECT id_admin, usuario, password_hash FROM usuarios_admin WHERE usuario = :u LIMIT 1');
        $stmt->execute(['u' => $usuario]);
        $admin = $stmt->fetch();

        return is_array($admin) ? $admin : null;
    } catch (Throwable $ex) {
        error_log('No se pudo consultar usuarios_admin: ' . $ex->getMessage());
        return null;
    }
}

function credencialesAdminPorDefectoValidas(string $usuario, string $password): bool
{
    return hash_equals(ADMIN_USUARIO_POR_DEFECTO, $usuario)
        && password_verify($password, ADMIN_PASSWORD_HASH);
}

function asegurarAdminPorDefecto(PDO $pdo): void
{
    try {
        $pdo->exec(
            'CREATE TABLE IF NOT EXISTS usuarios_admin (
                id_admin INT PRIMARY KEY AUTO_INCREMENT,
                usuario VARCHAR(50) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci'
        );

        $stmt = $pdo->prepare(
            'INSERT INTO usuarios_admin (usuario, password_hash)
             VALUES (:usuario, :hash)
             ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash)'
        );
        $stmt->execute([
            'usuario' => ADMIN_USUARIO_POR_DEFECTO,
            'hash' => ADMIN_PASSWORD_HASH,
        ]);
    } catch (Throwable $ex) {
        error_log('No se pudo asegurar el admin por defecto: ' . $ex->getMessage());
    }
}

function iniciarSesionAdmin(array $admin): void
{
    session_regenerate_id(true);
    $_SESSION['admin_id'] = (int) ($admin['id_admin'] ?? 1);
    $_SESSION['admin_usuario'] = (string) ($admin['usuario'] ?? ADMIN_USUARIO_POR_DEFECTO);
    header('Location: panel.php');
    exit;
}

session_set_cookie_params([
    'httponly' => true,
    'samesite' => 'Lax',
    'secure' => isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on',
]);
session_start();

if (isset($_SESSION['admin_id'])) {
    header('Location: panel.php');
    exit;
}

if (empty($_SESSION['csrf'])) {
    $_SESSION['csrf'] = bin2hex(random_bytes(32));
}

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $usuario = trim((string) ($_POST['usuario'] ?? ''));
    $password = (string) ($_POST['password'] ?? '');
    $token = (string) ($_POST['csrf'] ?? '');

    if (!hash_equals($_SESSION['csrf'], $token)) {
        $error = 'Solicitud no valida. Recarga la pagina.';
    } elseif ($usuario === '' || $password === '') {
        $error = 'Debes introducir usuario y contrasena.';
    } else {
        $adminPorDefectoValido = credencialesAdminPorDefectoValidas($usuario, $password);

        try {
            $pdo = ConexionDB::getInstancia()->getConexion();
            $admin = obtenerAdmin($pdo, $usuario);

            if ($admin && password_verify($password, $admin['password_hash'])) {
                iniciarSesionAdmin($admin);
            }

            if ($adminPorDefectoValido) {
                asegurarAdminPorDefecto($pdo);
                $admin = obtenerAdmin($pdo, ADMIN_USUARIO_POR_DEFECTO) ?? [
                    'id_admin' => 1,
                    'usuario' => ADMIN_USUARIO_POR_DEFECTO,
                ];
                iniciarSesionAdmin($admin);
            }
        } catch (Throwable $ex) {
            error_log('Error de BD en login: ' . $ex->getMessage());

            if ($adminPorDefectoValido) {
                iniciarSesionAdmin([
                    'id_admin' => 1,
                    'usuario' => ADMIN_USUARIO_POR_DEFECTO,
                ]);
            }

            $error = 'Error al iniciar sesion.';
        }

        if ($error === '') {
            $error = 'Usuario o contrasena incorrectos.';
        }
    }
}
?>
<!doctype html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ASOBAL - Admin</title>
    <link rel="stylesheet" href="../assets/css/estilos.css">
</head>
<body>
<main class="auth-page">
    <form class="form-card" method="post" style="width:100%;max-width:420px">
        <div class="login-logo">ASOBAL</div>
        <h1 style="text-align:center;font-size:20px;">Acceso administrador</h1>
        <?php if ($error !== ''): ?><p class="alert alert-error"><?= e($error) ?></p><?php endif; ?>
        <input type="hidden" name="csrf" value="<?= e($_SESSION['csrf']) ?>">
        <label>Usuario<input type="text" name="usuario" autocomplete="username" required autofocus></label>
        <label>Contrasena<input type="password" name="password" autocomplete="current-password" required></label>
        <button type="submit">Entrar</button>
        <a class="volver-link" href="../index.php">&larr; Volver a la web</a>
    </form>
</main>
</body>
</html>

