import UIKit

/// Controlador de la pantalla inicial que presenta el menú principal con las
/// distintas opciones de la aplicación. Utiliza una tabla simple para
/// mostrar las opciones de navegación.
class InicioViewController: UITableViewController {
    private enum MenuOption: Int, CaseIterable {
        case verPrestamos = 0
        case registrarPrestamo
        case verEntregados

        var title: String {
            switch self {
            case .verPrestamos: return "Ver préstamos registrados"
            case .registrarPrestamo: return "Registrar nuevo préstamo"
            case .verEntregados: return "Consultar libros entregados"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Inicio"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MenuCell")
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuOption.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
        if let option = MenuOption(rawValue: indexPath.row) {
            var config = cell.defaultContentConfiguration()
            config.text = option.title
            cell.contentConfiguration = config
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let option = MenuOption(rawValue: indexPath.row) else { return }
        switch option {
        case .verPrestamos:
            let vc = PrestamosListViewController()
            vc.title = "Préstamos"
            navigationController?.pushViewController(vc, animated: true)
        case .registrarPrestamo:
            let vc = RegistroPrestamoViewController()
            vc.title = "Nuevo Préstamo"
            navigationController?.pushViewController(vc, animated: true)
        case .verEntregados:
            let vc = PrestamosListViewController(mostrarSoloEntregados: true)
            vc.title = "Libros entregados"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}