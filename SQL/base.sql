-- Tabla Clientes
CREATE TABLE IF NOT EXISTS Clientes(
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50)
);
-- Tabla Vendedores
CREATE TABLE IF NOT EXISTS Vendedores(
    id_vendedor SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    salario DECIMAL(10, 2),
    comision DECIMAL(5, 2)
);
-- Tabla Productos
CREATE TABLE IF NOT EXISTS Productos(
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    precio DECIMAL(10, 2),
    stock INTEGER
);
-- Tabla Ventas (cabecera)
CREATE TABLE IF NOT EXISTS Ventas(
    id_venta SERIAL PRIMARY KEY,
    id_cliente INTEGER REFERENCES Clientes(id_cliente),
    id_vendedor INTEGER REFERENCES Vendedores(id_vendedor),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10, 2)
);
-- Tabla DetallesVenta
CREATE TABLE IF NOT EXISTS DetallesVenta(
    id_detalle SERIAL PRIMARY KEY,
    id_venta INTEGER REFERENCES Ventas(id_venta),
    id_producto INTEGER REFERENCES Productos(id_producto),
    cantidad INTEGER,
    precio_unitario DECIMAL(10, 2),
    subtotal DECIMAL(10, 2)
);

-- Triggers
-- Funcion para recalcular y actualizar el total de la venta
CREATE OR REPLACE FUNCTION fn_actualizar_total_venta()
RETURNS TRIGGER AS $$
DECLARE
    venta_id INTEGER;
BEGIN
-- Determinar el id_venta dependiendo de la operacion
    IF TG_OP = 'INSERT' OR TG_OP ='UPDATE' THEN
        venta_id := NEW.id_venta;
    ELSIF TG_OP = 'DELETE' THEN
        venta_id := OLD.id_venta;
    END IF;

-- Actualizar el total de la venta en la tabla Ventas
    UPDATE Ventas
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM DetallesVenta
        WHERE id_venta = venta_id
    )
    WHERE id_venta = venta_id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger despues de INSERT en DetallesVenta
CREATE TRIGGER trg_actualizar_total_venta_insert
AFTER INSERT ON DetallesVenta
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_total_venta();

-- Trigger despues de UPDATE en DetallesVenta
CREATE TRIGGER trg_actualizar_total_venta_update
AFTER UPDATE ON DetallesVenta
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_total_venta();

-- Trigger despues de DELETE en DetallesVenta
CREATE TRIGGER trg_actualizar_total_venta_delete
AFTER DELETE ON DetallesVenta
FOR EACH ROW
EXECUTE FUNCTION fn_actualizar_total_venta();


-- Funcion que calcula el subtotal antes  de insertar o actualizar un registro en DetalleVentas
CREATE OR REPLACE FUNCTION fn_calcular_subtotal_detalleventa()
RETURNS TRIGGER AS $$
BEGIN

-- Calcular el subtotal multiplicando la cantidad por el precio unitario
    NEW.subtotal := NEW.cantidad * NEW.precio_unitario;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que se ejecuta antes de INSERT o UPDATE en la tabla DetallesVenta
CREATE TRIGGER trg_calcular_subtotal_detalleventa
BEFORE INSERT OR UPDATE ON DetallesVenta
FOR EACH ROW
EXECUTE FUNCTION fn_calcular_subtotal_detalleventa();