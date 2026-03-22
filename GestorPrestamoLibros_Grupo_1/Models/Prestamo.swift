import Foundation

/// Modelo que representa un préstamo de libro. Se utiliza para abstraer los
/// campos almacenados en la base de datos SQLite y facilitar el paso de
/// información entre las distintas capas de la aplicación.
struct Prestamo {
    /// Identificador único del registro en la base de datos. Es opcional
    /// porque los nuevos préstamos aún no tienen id asignado hasta ser
    /// insertados en la base de datos.
    var id: Int64?
    var codigoLibro: String
    var autor: String
    var editorial: String
    var nombreColaborador: String
    var motivo: String
    var fechaPrestamo: Date
    var estado: String
}