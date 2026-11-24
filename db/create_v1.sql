-- ============================================================
-- db/create_v1.sql — структура БД «shoe_store» (магазин обуви)
-- Пара 10: схема из EER-модели (Forward Engineering), MySQL 8 /
-- MariaDB, кодировка utf8mb4. Одна схема, 10 таблиц, 9 связей.
-- Пара 11, этап 3: этот файл пересоздаёт БД с нуля (пустую),
-- затем выполняется db/data.sql с данными.
-- ============================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- ------------------------------------------------------------
-- Схема
-- ------------------------------------------------------------
DROP SCHEMA IF EXISTS `shoe_store`;
CREATE SCHEMA IF NOT EXISTS `shoe_store` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
USE `shoe_store` ;

-- ------------------------------------------------------------
-- Таблица `categories`: справочник категорий товара
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `manufacturers`: справочник производителей
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `manufacturers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `suppliers`: справочник поставщиков
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `suppliers` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `roles`: справочник ролей пользователей
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `roles` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `orderstatus`: справочник статусов заказа
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orderstatus` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `users`: пользователи (сотрудники и клиенты)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(60) NOT NULL,
  `login` VARCHAR(50) NOT NULL,
  `password` VARCHAR(30) NOT NULL,
  `role_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_users_role_idx` (`role_id` ASC) VISIBLE,
  CONSTRAINT `fk_users_role`
    FOREIGN KEY (`role_id`)
    REFERENCES `roles` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `pvz`: пункты выдачи заказов
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `pvz` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `postcode` CHAR(6) NOT NULL,
  `city` VARCHAR(30) NOT NULL,
  `street` VARCHAR(30) NOT NULL,
  `house` VARCHAR(5) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `products`: товары
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `article` VARCHAR(10) NOT NULL,
  `name` VARCHAR(50) NOT NULL,
  `unit` VARCHAR(10) NOT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `discount` INT NOT NULL,
  `stock_qty` INT NOT NULL,
  `description` VARCHAR(100) NULL,
  `photo` VARCHAR(50) NULL,
  `category_id` INT NOT NULL,
  `manufacturer_id` INT NOT NULL,
  `supplier_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_products_category_idx` (`category_id` ASC) VISIBLE,
  INDEX `fk_products_manufacturer_idx` (`manufacturer_id` ASC) VISIBLE,
  INDEX `fk_products_supplier_idx` (`supplier_id` ASC) VISIBLE,
  CONSTRAINT `fk_products_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `categories` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_manufacturer`
    FOREIGN KEY (`manufacturer_id`)
    REFERENCES `manufacturers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_products_supplier`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `suppliers` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `orders`: заказы
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_date` DATETIME NOT NULL,
  `delivery_date` DATETIME NULL,
  `pvz_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `receive_code` VARCHAR(10) NOT NULL,
  `status_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_orders_pvz_idx` (`pvz_id` ASC) VISIBLE,
  INDEX `fk_orders_user_idx` (`user_id` ASC) VISIBLE,
  INDEX `fk_orders_status_idx` (`status_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_pvz`
    FOREIGN KEY (`pvz_id`)
    REFERENCES `pvz` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_user`
    FOREIGN KEY (`user_id`)
    REFERENCES `users` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_status`
    FOREIGN KEY (`status_id`)
    REFERENCES `orderstatus` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- ------------------------------------------------------------
-- Таблица `prodorders`: состав заказов (товары в заказах)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `prodorders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `qty` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_prodorders_order_idx` (`order_id` ASC) VISIBLE,
  INDEX `fk_prodorders_product_idx` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_prodorders_order`
    FOREIGN KEY (`order_id`)
    REFERENCES `orders` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_prodorders_product`
    FOREIGN KEY (`product_id`)
    REFERENCES `products` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
