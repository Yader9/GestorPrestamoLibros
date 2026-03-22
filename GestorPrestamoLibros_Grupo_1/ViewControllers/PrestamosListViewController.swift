import UIKit

/// Controlador que muestra la lista de préstamos almacenados en la base de datos.
/// Puede configurarse para mostrar todos los préstamos o solo aquellos que se
/// encuentran en estado "Entregado". Permite eliminar registros y navegar al
/// detalle de un préstamo individual.
class PrestamosListViewController: UITableViewController {
    private var prestamos: [Prestamo] = []
    private let mostrarSoloEntregados: Bool

    /// Inicializador designado.
    /// - Parameter mostrarSoloEntregados: Si es `true`, se filtra la lista para mostrar únicamente los préstamos con estado "Entregado".
    init(mostrarSoloEntregados: Bool = false) {
        self.mostrarSoloEntregados = mostrarSoloEntregados
        super.init(style: .plain)
    }

    required init?(coder: NSCoder) {
        self.mostrarSoloEntregados = false
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PrestamoCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func reloadData() {
        if mostrarSoloEntregados {
            prestamos = SQLiteManager.shared.getPrestamosEntregados()
        } else {
            prestamos = SQLiteManager.shared.getAllPrestamos()
        }
        tableView.reloadData()
    }

    @objc private func didTapAdd() {
        let registroVC = RegistroPrestamoViewController()
        registroVC.title = "Nuevo Préstamo"
        navigationController?.pushViewController(registroVC, animated: true)
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prestamos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrestamoCell", for: indexPath)
        let prestamo = prestamos[indexPath.row]
        var config = cell.defaultContentConfiguration()
        config.text = "Código: \(prestamo.codigoLibro) – \(prestamo.nombreColaborador)"
        // Formatear fecha para presentación
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        let fecha = dateFormatter.string(from: prestamo.fechaPrestamo)
        config.secondaryText = "Fecha: \(fecha) • Estado: \(prestamo.estado)"
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let prestamo = prestamos[indexPath.row]
        let detalleVC = DetallePrestamoViewController(prestamo: prestamo)
        detalleVC.title = "Detalle"
        navigationController?.pushViewController(detalleVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let prestamo = prestamos[indexPath.row]
            if let id = prestamo.id {
                _ = SQLiteManager.shared.delete(prestamoID: id)
                prestamos.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}