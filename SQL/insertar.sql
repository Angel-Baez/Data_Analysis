-- Insercion de datos aleatorios en tabla Clientes
INSERT INTO Clientes (nombre, apellido, ciudad)
SELECT

    (ARRAY['Mateo', 'Crhistian', 'Rosa', 'Alberto', 'Carla', 'Vanessa', 'Matias', 'Claudia', 'Lucas', 'Miguel', 'Angel'])[floor(random() * 10 + 1)::int] AS nombre,
    (ARRAY['Baez', 'Montenegro', 'Valdez', 'Alvarez', 'Ducan', 'Gonzales', 'Rodriguez', 'Smith', 'Buffer'])[floor(random() * 8 + 1)::int] AS apellido,
    (ARRAY['Santiago', 'Madrid', 'Seattle', 'Montevideo', 'Milan', 'Kyoto', 'Bucarest', 'Oslo'])[floor(random() * 7 + 1)::int] AS ciudad
FROM generate_series(1, 15);

-- Insercion de datos aleatorios en tabla Vendedores
INSERT INTO Vendedores ( nombre, apellido, email, telefono, salario, comision)
SELECT

    (ARRAY['Jose', 'Marta', 'Mirian', 'Eunice', 'Mathew', 'Leonela'])[floor(random() * 5 + 1)::int] AS nombre,
    (ARRAY['Perez', 'Garcia', 'Martinez', 'Ramos', 'Nuñez'])[floor(random() * 4 + 1)::int] AS apellido,
    lower((ARRAY['Jose', 'Marta', 'Mirian', 'Eunice', 'Mathew', 'Leonela'])[floor(random() * 5 + 1)::int]) || '@empresa.com' AS email,
    '1234567890' AS telefono,
    round((random() * 2000 + 1000)::numeric, 2) AS salario,
    round((random() * 10)::numeric, 2) AS comision;
FROM generate_series(1, 6);

-- Insercion de datos aleatorios en tabla Productos
INSERT INTO Productos (nombre, descripcion, precio, stock)
SELECT

    (ARRAY['Papel normal', 'Papel premiun', 'Impresora personal', 'Grapadora', 'Lapiz', 'Boligrafo', 'Impresora emplesarial', Fotocopiadora])[floor(random() * 8 + 1)::int] AS nombre,
    'Producto para oficina' AS descripcion,
    round((random()  * 300 + 50)::numeric, 2) AS precio,
    (floor(random() * 100 + 3))::int AS stock
FROM generate_series(1, 9);

-- Insercion de datos aleatorios en tabla Ventas
INSERT INTO Ventas (id_cliente, id_vendedor, fecha, total)
SELECT

    (SELECT id_cliente FROM Clientes ORDER BY random() LIMIT 1),
    (SELECT id_vendedor FROM Vendedores ORDER BY random() LIMIT 1),
    NOW() - (random() * interval '30 days'),
    0
FROM generate_series(1, 25);

-- Insercion de datos aleatorios en tabla DetallesVentas
-- Usaremos un bloque DO para recorrer cada venta y agregarle entre 1 y 3 detalles aleatorios
DO $$
DECLARE
    v_id INTEGER;
    n_details INTEGER;
    i INTEGER;
    prod_id INTEGER;
    qty INTEGER;
    prod_price NUMERIC;
BEGIN
    -- Para cada venta insertada...ABORT
    FOR v_id IN SELECT id_venta FROM Ventas LOOP
        n_details := floor(random)  * 3 + 1;
        -- Número aleatorio de detalles entre 1 y 3
