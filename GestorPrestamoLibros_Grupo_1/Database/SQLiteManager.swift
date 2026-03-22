import Foundation
import SQLite3

/// Clase encargada de gestionar la conexión y las operaciones CRUD sobre la
/// base de datos SQLite. Al encapsular toda la lógica de base de datos en
/// un solo lugar, la aplicación mantiene una separación clara entre la
/// interfaz de usuario y la persistencia de datos.
class SQLiteManager {
    static let shared = SQLiteManager()

    private var db: OpaquePointer?
    private let dbName = "prestamos.sqlite"

    /// Ruta donde se almacenará la base de datos dentro del contenedor de la aplicación.
    private var dbURL: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent(dbName)
    }

    private init() {
        openDatabase()
        createTableIfNeeded()
    }

    deinit {
        closeDatabase()
    }

    /// Abre o crea la base de datos en la ruta designada.
    private func openDatabase() {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK {
            print("Error al abrir la base de datos")
        }
    }

    /// Cierra la conexión a la base de datos.
    private func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
        }
    }

    /// Crea la tabla principal de préstamos si no existe.
    private func createTableIfNeeded() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS prestamos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigolibro TEXT NOT NULL,
            autor TEXT NOT NULL,
            editorial TEXT NOT NULL,
            nombreColaborador TEXT NOT NULL,
            motivo TEXT NOT NULL,
            fechaPrestamo TEXT NOT NULL,
            estado TEXT NOT NULL
        );
        """
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) != SQLITE_DONE {
                print("No se pudo crear la tabla")
            }
        } else {
            print("Error al preparar la creación de tabla")
        }
        sqlite3_finalize(createTableStatement)
    }

    // MARK: - CRUD

    /// Inserta un nuevo préstamo en la base de datos.
    /// - Parameter prestamo: Objeto de tipo `Prestamo` a insertar. El id se ignora ya que se autogenera.
    /// - Returns: `true` si la operación fue exitosa; `false` en caso contrario.
    func insert(prestamo: Prestamo) -> Bool {
        let insertString = "INSERT INTO prestamos (codigolibro, autor, editorial, nombreColaborador, motivo, fechaPrestamo, estado) VALUES (?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        var success = false
        if sqlite3_prepare_v2(db, insertString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (prestamo.codigoLibro as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (prestamo.autor as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (prestamo.editorial as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, (prestamo.nombreColaborador as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 5, (prestamo.motivo as NSString).utf8String, -1, nil)
            let dateString = Self.dateFormatter.string(from: prestamo.fechaPrestamo)
            sqlite3_bind_text(insertStatement, 6, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 7, (prestamo.estado as NSString).utf8String, -1, nil)
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                success = true
            }
        } else {
            print("Error al preparar la sentencia de inserción")
        }
        sqlite3_finalize(insertStatement)
        return success
    }

    /// Recupera todos los préstamos de la base de datos.
    /// - Returns: Arreglo de objetos `Prestamo`.
    func getAllPrestamos() -> [Prestamo] {
        let queryString = "SELECT id, codigolibro, autor, editorial, nombreColaborador, motivo, fechaPrestamo, estado FROM prestamos ORDER BY fechaPrestamo DESC;"
        var queryStatement: OpaquePointer?
        var prestamos: [Prestamo] = []
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int64(queryStatement, 0)
                let codigoLibro = String(cString: sqlite3_column_text(queryStatement, 1))
                let autor = String(cString: sqlite3_column_text(queryStatement, 2))
                let editorial = String(cString: sqlite3_column_text(queryStatement, 3))
                let nombreColaborador = String(cString: sqlite3_column_text(queryStatement, 4))
                let motivo = String(cString: sqlite3_column_text(queryStatement, 5))
                let fechaString = String(cString: sqlite3_column_text(queryStatement, 6))
                let estado = String(cString: sqlite3_column_text(queryStatement, 7))
                let fecha = Self.dateFormatter.date(from: fechaString) ?? Date()
                let prestamo = Prestamo(id: id, codigoLibro: codigoLibro, autor: autor, editorial: editorial, nombreColaborador: nombreColaborador, motivo: motivo, fechaPrestamo: fecha, estado: estado)
                prestamos.append(prestamo)
            }
        } else {
            print("Error al preparar la consulta de selección")
        }
        sqlite3_finalize(queryStatement)
        return prestamos
    }

    /// Actualiza un préstamo existente.
    /// - Parameter prestamo: Objeto con la información a actualizar. Su campo `id` debe estar definido.
    /// - Returns: `true` si la operación fue exitosa; `false` en caso contrario.
    func update(prestamo: Prestamo) -> Bool {
        guard let id = prestamo.id else { return false }
        let updateString = "UPDATE prestamos SET codigolibro = ?, autor = ?, editorial = ?, nombreColaborador = ?, motivo = ?, fechaPrestamo = ?, estado = ? WHERE id = ?;"
        var updateStatement: OpaquePointer?
        var success = false
        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(updateStatement, 1, (prestamo.codigoLibro as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, (prestamo.autor as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, (prestamo.editorial as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, (prestamo.nombreColaborador as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 5, (prestamo.motivo as NSString).utf8String, -1, nil)
            let dateString = Self.dateFormatter.string(from: prestamo.fechaPrestamo)
            sqlite3_bind_text(updateStatement, 6, (dateString as NSString).utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 7, (prestamo.estado as NSString).utf8String, -1, nil)
            sqlite3_bind_int64(updateStatement, 8, id)
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                success = true
            }
        } else {
            print("Error al preparar la sentencia de actualización")
        }
        sqlite3_finalize(updateStatement)
        return success
    }

    /// Elimina un préstamo de la base de datos.
    /// - Parameter id: Identificador del préstamo a eliminar.
    /// - Returns: `true` si la operación fue exitosa; `false` en caso contrario.
    func delete(prestamoID id: Int64) -> Bool {
        let deleteString = "DELETE FROM prestamos WHERE id = ?;"
        var deleteStatement: OpaquePointer?
        var success = false
        if sqlite3_prepare_v2(db, deleteString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int64(deleteStatement, 1, id)
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                success = true
            }
        } else {
            print("Error al preparar la sentencia de eliminación")
        }
        sqlite3_finalize(deleteStatement)
        return success
    }

    /// Recupera todos los préstamos que se encuentran en estado "Entregado".
    func getPrestamosEntregados() -> [Prestamo] {
        let queryString = "SELECT id, codigolibro, autor, editorial, nombreColaborador, motivo, fechaPrestamo, estado FROM prestamos WHERE estado = 'Entregado' ORDER BY fechaPrestamo DESC;"
        var queryStatement: OpaquePointer?
        var prestamos: [Prestamo] = []
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int64(queryStatement, 0)
                let codigoLibro = String(cString: sqlite3_column_text(queryStatement, 1))
                let autor = String(cString: sqlite3_column_text(queryStatement, 2))
                let editorial = String(cString: sqlite3_column_text(queryStatement, 3))
                let nombreColaborador = String(cString: sqlite3_column_text(queryStatement, 4))
                let motivo = String(cString: sqlite3_column_text(queryStatement, 5))
                let fechaString = String(cString: sqlite3_column_text(queryStatement, 6))
                let estado = String(cString: sqlite3_column_text(queryStatement, 7))
                let fecha = Self.dateFormatter.date(from: fechaString) ?? Date()
                let prestamo = Prestamo(id: id, codigoLibro: codigoLibro, autor: autor, editorial: editorial, nombreColaborador: nombreColaborador, motivo: motivo, fechaPrestamo: fecha, estado: estado)
                prestamos.append(prestamo)
            }
        } else {
            print("Error al preparar la consulta de préstamos entregados")
        }
        sqlite3_finalize(queryStatement)
        return prestamos
    }

    /// Formatea fechas al formato ISO8601. Se utiliza de forma estática para
    /// garantizar consistencia en todo el módulo.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
}