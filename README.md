# GestorPrestamoLibros

## Descripción

**GestorPrestamoLibros** es una aplicación iOS desarrollada con **UIKit**, **Storyboard** y **SQLite3** para gestionar préstamos de libros.

La aplicación permite registrar préstamos, consultar los préstamos almacenados, editar registros existentes, eliminar préstamos y consultar específicamente los libros que ya fueron entregados.

---

## Objetivo del proyecto

Facilitar el control básico de préstamos de libros mediante una aplicación móvil con persistencia local usando SQLite.

El proyecto implementa un flujo completo de gestión de datos:

- crear préstamos,
- listar préstamos,
- consultar detalles,
- actualizar información,
- eliminar registros,
- y filtrar préstamos entregados.

---

## Funcionalidades principales

- Menú principal de navegación.
- Registro de nuevos préstamos.
- Validación de campos obligatorios.
- Listado de préstamos registrados.
- Vista de detalle para consultar y editar un préstamo.
- Eliminación de préstamos desde la lista o desde el detalle.
- Consulta de libros entregados.
- Persistencia local mediante base de datos SQLite.

---

## Tecnologías utilizadas

- **Swift**
- **UIKit**
- **Storyboard**
- **SQLite3**
- **Xcode**

---

## Arquitectura general

La app utiliza una estructura sencilla basada en controladores de vista y una clase central para el manejo de la base de datos.

### Flujo principal

1. La aplicación inicia desde un **Navigation Controller** definido en `Main.storyboard`.
2. La pantalla inicial es `InicioViewController`, que muestra el menú principal.
3. Desde el menú se puede:
   - ver préstamos registrados,
   - registrar un nuevo préstamo,
   - consultar libros entregados.
4. Los datos se guardan localmente en SQLite mediante `SQLiteManager`.

---

## Pantallas del proyecto

### `InicioViewController.swift`
Pantalla inicial basada en `UITableViewController`.

Muestra tres opciones del menú:

- **Ver préstamos registrados**
- **Registrar nuevo préstamo**
- **Consultar libros entregados**

### `PrestamosListViewController.swift`
Muestra la lista de préstamos almacenados.

Características:
- carga todos los préstamos o solo los entregados,
- permite navegar al detalle de un préstamo,
- permite eliminar registros desde la lista,
- incluye botón para agregar un nuevo préstamo.

### `RegistroPrestamoViewController.swift`
Presenta el formulario para registrar un nuevo préstamo.

Campos utilizados:
- código del libro,
- autor,
- editorial,
- nombre del estudiante,
- motivo,
- fecha del préstamo,
- estado (`Prestado` o `Entregado`).

También realiza validación para evitar guardar campos vacíos.

### `DetallePrestamoViewController.swift`
Permite ver y editar un préstamo existente.

Funciones principales:
- mostrar la información del préstamo seleccionado,
- actualizar datos,
- cambiar estado,
- eliminar el registro.

---

## Modelo de datos

### `Prestamo.swift`

Este archivo define la estructura principal del modelo:

```swift
struct Prestamo {
    var id: Int64?
    var codigoLibro: String
    var autor: String
    var editorial: String
    var nombreColaborador: String
    var motivo: String
    var fechaPrestamo: Date
    var estado: String
}
```

Representa cada préstamo almacenado en la base de datos.

---

## Persistencia de datos

### `SQLiteManager.swift`

Este archivo encapsula toda la lógica de acceso a SQLite.

Responsabilidades principales:
- abrir o crear la base de datos,
- crear la tabla `prestamos` si no existe,
- insertar nuevos préstamos,
- consultar todos los préstamos,
- actualizar registros,
- eliminar préstamos,
- consultar solo préstamos entregados.

### Tabla utilizada

```sql
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
```

La base de datos se guarda localmente dentro del contenedor de la aplicación con el nombre:

```text
prestamos.sqlite
```

---

## Archivos principales del proyecto

### Archivos de aplicación
- `AppDelegate.swift`
- `SceneDelegate.swift`

### Archivos de interfaz y navegación
- `Main.storyboard`
- `LaunchScreen.storyboard`

### Archivos de lógica y vistas
- `InicioViewController.swift`
- `PrestamosListViewController.swift`
- `RegistroPrestamoViewController.swift`
- `DetallePrestamoViewController.swift`

### Archivos de modelo y persistencia
- `Prestamo.swift`
- `SQLiteManager.swift`

---

## Interfaz

La aplicación combina:

- **Storyboard** para definir el arranque y la navegación inicial,
- **UIKit programático** para construir formularios y pantallas internas.

Se utiliza un `Navigation Controller` como contenedor principal para mover al usuario entre las distintas vistas.

---

## Validaciones implementadas

El proyecto incluye validaciones básicas en el formulario de registro y edición:

- no permite guardar si hay campos vacíos,
- muestra alertas al usuario cuando faltan datos,
- muestra mensajes de éxito o error al guardar, actualizar o eliminar registros.

---

## Operaciones CRUD implementadas

La aplicación implementa el ciclo completo CRUD:

- **Create:** registrar un nuevo préstamo
- **Read:** consultar préstamos registrados y entregados
- **Update:** editar préstamos desde la vista de detalle
- **Delete:** eliminar préstamos desde la lista o desde el detalle

---

## Cómo ejecutar el proyecto

1. Abre el proyecto en **Xcode**.
2. Selecciona un simulador de iPhone o un dispositivo físico.
3. Ejecuta la aplicación con **Run** o con `Cmd + R`.
4. Usa el menú principal para navegar entre las opciones de la app.

---

## Posibles mejoras futuras

Algunas mejoras que podrían implementarse en versiones posteriores:

- búsqueda por código o nombre del colaborador,
- filtros por fecha,
- validación más estricta del código del libro,
- diseño visual más elaborado,
- uso de `UITableViewCell` personalizada,
- exportación de préstamos,
- o sincronización con una base de datos remota.

---

## Integrantes

- Yader Carrillo
- Diego Narváez
- Zared Vega
---

## Conclusión

**GestorPrestamoLibros** es una aplicación funcional para la administración básica de préstamos de libros. El proyecto integra navegación con UIKit, persistencia local con SQLite y operaciones CRUD completas, lo que lo convierte en un buen ejemplo académico de una app iOS con almacenamiento local y manejo estructurado de datos.
