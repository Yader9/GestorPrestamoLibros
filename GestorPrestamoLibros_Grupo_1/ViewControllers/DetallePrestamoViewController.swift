import UIKit

/// Controlador que presenta el detalle de un préstamo existente y permite
/// editar sus atributos o eliminarlo de la base de datos. La interfaz es
/// similar a la del formulario de registro, reutilizando los mismos tipos
/// de controles.
class DetallePrestamoViewController: UIViewController {
    private var prestamo: Prestamo

    // Campos de entrada reutilizados para permitir edición
    private let codigoLibroField = UITextField()
    private let autorField = UITextField()
    private let editorialField = UITextField()
    private let nombreField = UITextField()
    private let motivoTextView = UITextView()
    private let datePicker = UIDatePicker()
    private let estadoSegmented = UISegmentedControl(items: ["Prestado", "Entregado"])

    init(prestamo: Prestamo) {
        self.prestamo = prestamo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        fillData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Guardar", style: .done, target: self, action: #selector(saveChanges))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Eliminar", style: .plain, target: self, action: #selector(deleteRecord))
    }

    private func setupUI() {
        // Configuración de campos
        codigoLibroField.placeholder = "Código del libro"
        autorField.placeholder = "Autor"
        editorialField.placeholder = "Editorial"
        nombreField.placeholder = "Nombre del estudiante"
        motivoTextView.layer.borderColor = UIColor.systemGray4.cgColor
        motivoTextView.layer.borderWidth = 0.5
        motivoTextView.layer.cornerRadius = 5
        motivoTextView.font = UIFont.systemFont(ofSize: 16)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        // Pila vertical para organizar los campos
        let stackView = UIStackView(arrangedSubviews: [
            createLabeledView(label: "Código del libro", control: codigoLibroField),
            createLabeledView(label: "Autor", control: autorField),
            createLabeledView(label: "Editorial", control: editorialField),
            createLabeledView(label: "Nombre del estudiante", control: nombreField),
            createLabeledView(label: "Motivo", control: motivoTextView, isTextView: true),
            createLabeledView(label: "Fecha del préstamo", control: datePicker),
            createLabeledView(label: "Estado", control: estadoSegmented)
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
    }

    private func fillData() {
        codigoLibroField.text = prestamo.codigoLibro
        autorField.text = prestamo.autor
        editorialField.text = prestamo.editorial
        nombreField.text = prestamo.nombreColaborador
        motivoTextView.text = prestamo.motivo
        datePicker.date = prestamo.fechaPrestamo
        // Ajustar estado
        if prestamo.estado.lowercased() == "entregado" {
            estadoSegmented.selectedSegmentIndex = 1
        } else {
            estadoSegmented.selectedSegmentIndex = 0
        }
    }

    private func createLabeledView(label text: String, control: UIView, isTextView: Bool = false) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(control)
        if isTextView {
            (control as? UITextView)?.heightAnchor.constraint(equalToConstant: 80).isActive = true
        }
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.topAnchor.constraint(equalTo: container.topAnchor),
            control.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            control.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            control.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    // MARK: - Acciones
    @objc private func saveChanges() {
        guard
            let codigo = codigoLibroField.text, !codigo.trimmingCharacters(in: .whitespaces).isEmpty,
            let autor = autorField.text, !autor.trimmingCharacters(in: .whitespaces).isEmpty,
            let editorial = editorialField.text, !editorial.trimmingCharacters(in: .whitespaces).isEmpty,
            let nombre = nombreField.text, !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
            let motivo = motivoTextView.text, !motivo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            let id = prestamo.id
        else {
            presentAlert(title: "Campos obligatorios", message: "Por favor complete todos los campos.")
            return
        }
        let estado = estadoSegmented.titleForSegment(at: estadoSegmented.selectedSegmentIndex) ?? "Prestado"
        let actualizado = Prestamo(id: id, codigoLibro: codigo, autor: autor, editorial: editorial, nombreColaborador: nombre, motivo: motivo, fechaPrestamo: datePicker.date, estado: estado)
        if SQLiteManager.shared.update(prestamo: actualizado) {
            self.prestamo = actualizado
            presentAlert(title: "Actualizado", message: "Préstamo actualizado exitosamente.") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            presentAlert(title: "Error", message: "No se pudo actualizar el registro.")
        }
    }

    @objc private func deleteRecord() {
        let alert = UIAlertController(title: "Eliminar", message: "¿Desea eliminar este préstamo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive, handler: { [weak self] _ in
            if let id = self?.prestamo.id, SQLiteManager.shared.delete(prestamoID: id) {
                self?.presentAlert(title: "Eliminado", message: "Préstamo eliminado exitosamente.") {
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.presentAlert(title: "Error", message: "No se pudo eliminar el registro.")
            }
        }))
        present(alert, animated: true, completion: nil)
    }

    private func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
}