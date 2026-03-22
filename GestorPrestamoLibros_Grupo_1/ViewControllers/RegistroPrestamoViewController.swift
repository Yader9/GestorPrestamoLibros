import UIKit

/// Controlador responsable de presentar el formulario de creación de un nuevo
/// préstamo. Utiliza una pila vertical (`UIStackView`) para organizar los
/// campos de entrada y gestiona la validación y el almacenamiento de los
/// datos introducidos por el usuario en la base de datos.
class RegistroPrestamoViewController: UIViewController {
    // Campos de entrada
    private let codigoLibroField = UITextField()
    private let autorField = UITextField()
    private let editorialField = UITextField()
    private let nombreField = UITextField()
    private let motivoTextView = UITextView()
    private let datePicker = UIDatePicker()
    private let estadoSegmented = UISegmentedControl(items: ["Prestado", "Entregado"])

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Guardar", style: .done, target: self, action: #selector(saveButtonTapped))
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
        // Estado por defecto
        estadoSegmented.selectedSegmentIndex = 0

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

    /// Crea una vista compuesta por una etiqueta y un control, utilizada para
    /// organizar de forma consistente los distintos campos del formulario.
    private func createLabeledView(label text: String, control: UIView, isTextView: Bool = false) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        control.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        container.addSubview(control)
        // Para text views agregamos una altura mínima
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

    // MARK: - Guardar
    @objc private func saveButtonTapped() {
        // Validación de campos obligatorios
        guard
            let codigo = codigoLibroField.text, !codigo.trimmingCharacters(in: .whitespaces).isEmpty,
            let autor = autorField.text, !autor.trimmingCharacters(in: .whitespaces).isEmpty,
            let editorial = editorialField.text, !editorial.trimmingCharacters(in: .whitespaces).isEmpty,
            let nombre = nombreField.text, !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
            let motivo = motivoTextView.text, !motivo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            presentAlert(title: "Campos obligatorios", message: "Por favor complete todos los campos.")
            return
        }
        let estado = estadoSegmented.titleForSegment(at: estadoSegmented.selectedSegmentIndex) ?? "Prestado"
        let nuevoPrestamo = Prestamo(id: nil, codigoLibro: codigo, autor: autor, editorial: editorial, nombreColaborador: nombre, motivo: motivo, fechaPrestamo: datePicker.date, estado: estado)
        if SQLiteManager.shared.insert(prestamo: nuevoPrestamo) {
            presentAlert(title: "Éxito", message: "Préstamo registrado correctamente.") { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            presentAlert(title: "Error", message: "No se pudo guardar el préstamo. Intente nuevamente.")
        }
    }

    private func presentAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true, completion: nil)
    }
}