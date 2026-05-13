<?php
declare(strict_types=1);

/**
 * Clase Singleton para centralizar la conexion PDO a MySQL.
 * Ningun otro archivo del proyecto debe crear objetos PDO directamente.
 */
final class ConexionDB
{
    private static ?ConexionDB $instancia = null;
    private PDO $conexion;

    private function __construct()
    {
        $host = getenv('DB_HOST') ?: '127.0.0.1';
        $bd = getenv('DB_NAME') ?: 'Asobal';
        $usuario = getenv('DB_USER') ?: 'root';
        $password = getenv('DB_PASS') ?: '';
        $puerto = getenv('DB_PORT') ?: '3307';
        $charset = 'utf8mb4';

        $dsn = "mysql:host={$host};port={$puerto};dbname={$bd};charset={$charset}";

        $this->conexion = new PDO($dsn, $usuario, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }

    public static function getInstancia(): ConexionDB
    {
        if (self::$instancia === null) {
            self::$instancia = new self();
        }

        return self::$instancia;
    }

    public function getConexion(): PDO
    {
        return $this->conexion;
    }

    private function __clone()
    {
    }

    public function __wakeup(): void
    {
        throw new RuntimeException('No se puede deserializar una instancia Singleton.');
    }
}

