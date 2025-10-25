-- Курс: «Введення в мову
-- програмування Python
--  Модуль 15. Вступ до теорії баз даних
--  Тема: Вступ до теорії баз даних.
-- Частина 2
--  Завдання 1
--  Створіть наступні запити для бази даних з інформацією
-- про овочі та фрукти з попереднього домашнього завдання:
--  ■ Відображення усіх овочів з калорійністю, менше вказаної.
--  ■ Відображення усіх фруктів з калорійністю у вказаному
--  діапазоні.
--  ■ Відображення усіх овочів, у назві яких є вказане слово.
--  Наприклад, слово: капуста.
--  ■ Відображення усіх овочів та фруктів, у короткому описі
--  яких є вказане слово. Наприклад, слово: гемоглобін.
--  ■ Показати усі овочі та фрукти жовтого або червоного
--  кольору
-- Створення БД (за потреби зніміть коментар для створення окремої БД)
-- CREATE DATABASE vegtables_and_fruits;
-- \c vegtables_and_fruits;

-- Схема даних:
-- products: універсальна таблиця для овочів і фруктів.
-- product_type: тип (vegetable/fruit)
-- color: нормалізований довідник кольорів (для фільтрації жовтий/червоний тощо)

-- Довідники
CREATE TABLE IF NOT EXISTS product_type (
    id SERIAL PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,        -- 'vegetable' | 'fruit'
    name_uk TEXT NOT NULL             -- 'Овоч' | 'Фрукт'
);

CREATE TABLE IF NOT EXISTS color (
    id SERIAL PRIMARY KEY,
    name_en TEXT UNIQUE NOT NULL,     -- canonical key, e.g. 'yellow', 'red'
    name_uk TEXT NOT NULL             -- 'Жовтий', 'Червоний', ...
);

-- Основна таблиця
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name_uk TEXT NOT NULL,
    type_id INT NOT NULL REFERENCES product_type(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    color_id INT REFERENCES color(id) ON UPDATE CASCADE ON DELETE SET NULL,
    calories_per_100g INT NOT NULL CHECK (calories_per_100g >= 0),
    short_desc TEXT
);

-- Індекси для швидкого пошуку
CREATE INDEX IF NOT EXISTS idx_products_type ON products(type_id);
CREATE INDEX IF NOT EXISTS idx_products_color ON products(color_id);
CREATE INDEX IF NOT EXISTS idx_products_calories ON products(calories_per_100g);
-- За потреби розгляньте pg_trgm для пошуку по тексту (необов’язково)
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_products_name_trgm ON products USING gin (name_uk gin_trgm_ops);
-- CREATE INDEX IF NOT EXISTS idx_products_desc_trgm ON products USING gin (short_desc gin_trgm_ops);

-- Наповнення довідників
INSERT INTO product_type (code, name_uk) VALUES
    ('vegetable', 'Овоч'),
    ('fruit', 'Фрукт')
ON CONFLICT (code) DO NOTHING;

INSERT INTO color (name_en, name_uk) VALUES
    ('red', 'Червоний'),
    ('yellow', 'Жовтий'),
    ('green', 'Зелений'),
    ('orange', 'Помаранчевий'),
    ('purple', 'Фіолетовий'),
    ('white', 'Білий'),
    ('brown', 'Коричневий')
ON CONFLICT (name_en) DO NOTHING;

-- Допоміжні змінні (для зручних INSERT через підзапити)
-- Якщо СУБД не підтримує DO/variables, використовуємо підзапити inline в INSERT нижче.

-- Наповнення даних (прикладовий набір)
INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Помідор', pt.id, c.id, 18, 'Багатий на лікопін; корисний для серця'
FROM product_type pt, color c
WHERE pt.code = 'vegetable' AND c.name_en = 'red'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Огірок', pt.id, c.id, 16, 'Низькокалорійний, високий вміст води'
FROM product_type pt, color c
WHERE pt.code = 'vegetable' AND c.name_en = 'green'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Морква', pt.id, c.id, 41, 'Бета-каротин; підтримка зору'
FROM product_type pt, color c
WHERE pt.code = 'vegetable' AND c.name_en = 'orange'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Капуста білокачанна', pt.id, c.id, 25, 'Клітковина; може підтримувати гемоглобін'
FROM product_type pt, color c
WHERE pt.code = 'vegetable' AND c.name_en = 'green'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Капуста цвітна', pt.id, c.id, 25, 'Джерело вітаміну C'
FROM product_type pt, color c
WHERE pt.code = 'vegetable' AND c.name_en = 'white'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Яблуко', pt.id, c.id, 52, 'Клітковина; пектин'
FROM product_type pt, color c
WHERE pt.code = 'fruit' AND c.name_en = 'red'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Банан', pt.id, c.id, 89, 'Калій; енергія'
FROM product_type pt, color c
WHERE pt.code = 'fruit' AND c.name_en = 'yellow'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Лимон', pt.id, c.id, 29, 'Вітамін C; кислий смак'
FROM product_type pt, color c
WHERE pt.code = 'fruit' AND c.name_en = 'yellow'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Полуниця', pt.id, c.id, 33, 'Антиоксиданти; може сприяти гемоглобіну'
FROM product_type pt, color c
WHERE pt.code = 'fruit' AND c.name_en = 'red'
ON CONFLICT DO NOTHING;

INSERT INTO products (name_uk, type_id, color_id, calories_per_100g, short_desc)
SELECT 'Груша', pt.id, c.id, 57, 'Ніжна клітковина'
FROM product_type pt, color c
WHERE pt.code = 'fruit' AND c.name_en = 'green'
ON CONFLICT DO NOTHING;

-- ---------------------------
-- Параметри для прикладу позначені як :param, замініть своїми значеннями.

-- 1) Усі овочі з калорійністю < заданої
-- :max_calories INT
SELECT
    p.id, p.name_uk AS назва, p.calories_per_100g AS ккал_на_100г, c.name_uk AS колір
FROM products p
JOIN product_type pt ON pt.id = p.type_id
LEFT JOIN color c ON c.id = p.color_id
WHERE pt.code = 'vegetable'
  AND p.calories_per_100g < :max_calories
ORDER BY p.calories_per_100g, p.name_uk;

-- 2) Усі фрукти з калорійністю у діапазоні [min, max]
-- :min_cal INT, :max_cal INT
SELECT
    p.id, p.name_uk AS назва, p.calories_per_100g AS ккал_на_100г, c.name_uk AS колір
FROM products p
JOIN product_type pt ON pt.id = p.type_id
LEFT JOIN color c ON c.id = p.color_id
WHERE pt.code = 'fruit'
  AND p.calories_per_100g BETWEEN :min_cal AND :max_cal
ORDER BY p.calories_per_100g, p.name_uk;

-- 3) Усі овочі, у назві яких є вказане слово (напр. 'капуста')
-- :word TEXT (використовуйте LOWER і шаблон з %)
SELECT
    p.id, p.name_uk AS назва, p.calories_per_100g AS ккал_на_100г, c.name_uk AS колір
FROM products p
JOIN product_type pt ON pt.id = p.type_id
LEFT JOIN color c ON c.id = p.color_id
WHERE pt.code = 'vegetable'
  AND LOWER(p.name_uk) LIKE '%' || LOWER(:word) || '%'
ORDER BY p.name_uk;

-- 4) Усі овочі та фрукти, у короткому описі яких є вказане слово (напр. 'гемоглобін')
-- :word TEXT
SELECT
    p.id, p.name_uk AS назва, pt.name_uk AS тип, p.calories_per_100g AS ккал_на_100г, c.name_uk AS колір
FROM products p
JOIN product_type pt ON pt.id = p.type_id
LEFT JOIN color c ON c.id = p.color_id
WHERE p.short_desc IS NOT NULL
  AND LOWER(p.short_desc) LIKE '%' || LOWER(:word) || '%'
ORDER BY pt.name_uk, p.name_uk;

-- 5) Усі овочі та фрукти жовтого або червоного кольору
SELECT
    p.id, p.name_uk AS назва, pt.name_uk AS тип, c.name_uk AS колір, p.calories_per_100g AS ккал_на_100г
FROM products p
JOIN product_type pt ON pt.id = p.type_id
JOIN color c ON c.id = p.color_id
WHERE c.name_en IN ('yellow', 'red')
ORDER BY c.name_uk, pt.name_uk, p.name_uk;

-- Завдання 2
--  Створіть наступні запити для бази даних з інформацією
-- про овочі та фрукти з попереднього домашнього завдання:
--  ■ Показати кількість овочів.
-- SELECT COUNT(*) AS кількість_овочів
-- FROM products p
-- JOIN product_type pt ON pt.id = p.type_id
-- WHERE pt.code = 'vegetable';

SELECT COUNT(DISTINCT p.name_uk) AS кількість_унікальних_овочів
FROM products p
JOIN product_type pt ON pt.id = p.type_id
WHERE pt.code = 'vegetable';

SELECT p.name_uk, COUNT(*) AS кількість, COUNT(DISTINCT p.name_uk) AS кількість_унікальних
FROM products p
JOIN product_type pt ON pt.id = p.type_id
WHERE pt.code = 'vegetable'
GROUP BY p.name_uk
ORDER BY p.name_uk;

--  ■ Показати кількість фруктів.
WITH base AS (
  SELECT p.name_uk AS label,
         COUNT(*) AS qty,
         COUNT(DISTINCT p.name_uk) AS uq
  FROM products p
  JOIN product_type pt ON pt.id = p.type_id
  WHERE pt.code = 'fruit'
  GROUP BY p.name_uk
),
tot AS (
  SELECT 'ВСЬОГО'::text AS label,
         SUM(qty)::bigint AS qty,
         SUM(uq)::bigint AS uq
  FROM base
)
SELECT label, qty, uq, -1 AS ord FROM tot
UNION ALL
SELECT label, qty, uq, 0 AS ord FROM base
UNION ALL
SELECT label, qty, uq, 1 AS ord FROM tot
ORDER BY ord, label;

-- овочі і фрукти з ієрархією
WITH base AS (
  SELECT
    pt.code AS product_type,
    p.name_uk AS label,
    COUNT(*) AS qty
  FROM products p
  JOIN product_type pt ON pt.id = p.type_id
  GROUP BY pt.code, p.name_uk
),
tot_product_type AS (
  SELECT
    NULL::text AS label,
    b.product_type,
    SUM(b.qty)::bigint AS qty,
    COUNT(DISTINCT b.label)::bigint AS uq
  FROM base b
  GROUP BY b.product_type
),
tot_all AS (
  SELECT
    NULL::text AS label,
    NULL::text AS product_type,
    SUM(b.qty)::bigint AS qty,
    COUNT(DISTINCT b.label)::bigint AS uq
  FROM base b
)
SELECT label, product_type, qty, uq, -2 AS ord
FROM tot_all
UNION ALL
SELECT label, product_type, qty, uq, -1 AS ord
FROM tot_product_type
UNION ALL
SELECT b.label, b.product_type, b.qty, 1::bigint AS uq, 0 AS ord
FROM base b
UNION ALL
SELECT label, product_type, qty, uq, 1 AS ord
FROM tot_product_type
UNION ALL
SELECT label, product_type, qty, uq, 2 AS ord
FROM tot_all
ORDER BY
  ord,
  product_type NULLS FIRST,
  label NULLS LAST,
  qty DESC,
  uq DESC;

--  ■ Показати кількість овочів та фруктів заданого кольору.
SELECT pt.name_uk AS тип,
       COUNT(DISTINCT p.color_id) AS кількість,
       'red' AS колір
FROM products p
JOIN product_type pt ON pt.id = p.type_id
JOIN color c ON c.id = p.color_id AND c.name_en = 'red'
GROUP BY pt.name_uk
ORDER BY pt.name_uk;

--  ■ Показати кількість овочів та фруктів кожного кольору.
-- SELECT pt.name_uk AS тип,
--        COUNT(p.color_id) AS кількість,
--        c.name_en AS колір
-- FROM products p
-- JOIN product_type pt ON pt.id = p.type_id
-- JOIN color c ON c.id = p.color_id /* AND c.name_en = 'red' */
-- GROUP BY pt.name_uk, c.name_en
-- ORDER BY pt.name_uk, c.name_en;

--з врахуванням унікальних
SELECT
  pt.name_uk AS тип,
  c.name_en AS колір,
  COUNT(*) AS кількість_унікальних
FROM (
  SELECT DISTINCT p.name_uk, p.type_id, p.color_id
  FROM products p
) d
JOIN product_type pt ON pt.id = d.type_id
JOIN color c ON c.id = d.color_id
GROUP BY pt.name_uk, c.name_en
ORDER BY pt.name_uk, c.name_en;

--  ■ Показати колір мінімальної кількості овочів та фруктів.
SELECT MIN(p.calories_per_100g) AS мін_ккал_на_100г
FROM products p;

--  ■ Показати колір максимальної кількості овочів та фруктів.

--  ■ Показати мінімальну калорійність овочів та фруктів.
--  ■ Показати максимальну калорійність овочів та фруктів.
SELECT MAX(p.calories_per_100g) AS макс_ккал_на_100г
FROM products p;

--  ■ Показати середню калорійність овочів та фруктів.
-- Середня калорійність (усі продукти)
SELECT ROUND(AVG(p.calories_per_100g)::numeric, 2) AS середня_ккал_на_100г
FROM products p;

--  ■ Показати фрукт з мінімальною калорійністю.
-- Фрукт з мінімальною калорійністю
SELECT p.*
FROM products p
JOIN product_type pt ON pt.id = p.type_id
WHERE pt.code = 'fruit'
ORDER BY p.calories_per_100g ASC, p.name_uk
LIMIT 1;

--  ■ Показати фрукт з максимальною калорійністю.
-- Фрукт з максимальною калорійністю
SELECT p.*
FROM products p
JOIN product_type pt ON pt.id = p.type_id
WHERE pt.code = 'fruit'
ORDER BY p.calories_per_100g DESC, p.name_uk
LIMIT 1;