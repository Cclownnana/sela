-- ============================================================
-- db/queries.sql — SQL-запросы для приложения C# (пара 11)
-- Схема: shoe_store. Знак ? — параметр: в него C#-код подставляет
-- значение из формы (MySqlCommand / MySqlCommand.Parameters).
-- Пункты в комментариях — пункты чек-листа ДЭ.
-- ============================================================

-- ------------------------------------------------------------
-- Этап 4. Вход в приложение (чек-лист 2.5, 2.6, 3.17)
-- Верный логин/пароль -> ровно одна строка (ФИО + роль);
-- неверный -> пустой результат.
-- ------------------------------------------------------------
SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = ? AND u.password = ?;

-- ------------------------------------------------------------
-- Этап 5. Каталог товаров для окон Гостя и Администратора
-- (чек-лист 2.7–2.11): названия категории, производителя и
-- поставщика подтягиваются JOIN-ом вместо голых id.
-- ------------------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id;

-- ------------------------------------------------------------
-- Этап 6. Поиск + фильтр + сортировка одновременно
-- (чек-лист 3.2–3.3 сортировка, 3.4–3.5 фильтр, 3.6 совместно).
-- Пример: поиск по названию + фильтр по поставщику +
-- сортировка по остатку на складе. Условия в WHERE и ORDER BY
-- меняются от набора включённых опций — окно одно.
-- ------------------------------------------------------------
SELECT p.id, p.article, p.name, p.unit, p.price, p.discount, p.stock_qty,
       p.description, p.photo,
       c.name AS category, m.name AS manufacturer, s.name AS supplier
FROM products p
JOIN categories c ON c.id = p.category_id
JOIN manufacturers m ON m.id = p.manufacturer_id
JOIN suppliers s ON s.id = p.supplier_id
WHERE p.name LIKE CONCAT('%', ?, '%') AND p.supplier_id = ?
ORDER BY p.stock_qty DESC;

-- ------------------------------------------------------------
-- Этап 7. Добавление и редактирование товара
-- (чек-лист 3.7, 3.10, 3.12, 3.19)
-- ------------------------------------------------------------

-- справочники для выпадающих списков в форме
SELECT id, name FROM categories;
SELECT id, name FROM manufacturers;
SELECT id, name FROM suppliers;

-- добавление товара
INSERT INTO products
(article, name, unit, price, discount, stock_qty, description, photo,
 category_id, manufacturer_id, supplier_id)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- открыть товар для редактирования — заполнить все поля сразу
SELECT * FROM products WHERE id = ?;

-- сохранить изменения
UPDATE products
SET article=?, name=?, unit=?, price=?, discount=?, stock_qty=?,
    description=?, photo=?, category_id=?, manufacturer_id=?, supplier_id=?
WHERE id = ?;

-- ------------------------------------------------------------
-- Этап 8. Защита от удаления купленного товара (чек-лист 3.16)
-- ------------------------------------------------------------
SELECT COUNT(*) AS used_in_orders FROM prodorders WHERE product_id = ?;

-- Попытка удалить товар, который уже покупали, отклоняется базой:
-- связь prodorders -> products (fk_prodorders_product, No Action)
-- даёт ошибку «Cannot delete or update a parent row:
-- a foreign key constraint fails». Результат COUNT(*) > 0 —
-- заранее показать пользователю понятное предупреждение.
DELETE FROM products WHERE id = ?;
