CREATE DATABASE IF NOT EXISTS `Adapt`;
USE `Adapt`;

CREATE TABLE IF NOT EXISTS `Player` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `position` varchar(45) DEFAULT NULL,
  `weight` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `Training` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `baseType` int(11) DEFAULT NULL,
  `biasPointX` double DEFAULT NULL,
  `biasPointY` double DEFAULT NULL,
  `data` json DEFAULT NULL,
  `dateTime` datetime DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `legType` int(11) DEFAULT NULL,
  `score` float DEFAULT NULL,
  `trainingType` int(11) DEFAULT NULL,
  `assessmentType` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
