-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tempo de Geração: Fev 04, 2017 as 03:55 
-- Versão do Servidor: 5.1.41
-- Versão do PHP: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Banco de Dados: `global`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `accounts`
--

CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) NOT NULL DEFAULT '',
  `password` varchar(255) NOT NULL,
  `salt` varchar(40) NOT NULL DEFAULT '',
  `premdays` int(11) NOT NULL DEFAULT '0',
  `lastday` int(10) unsigned NOT NULL DEFAULT '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `key` varchar(20) NOT NULL DEFAULT '0',
  `blocked` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'internal usage',
  `warnings` int(11) NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '1',
  `loot_time` int(15) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `accounts`
--

INSERT INTO `accounts` (`id`, `name`, `password`, `salt`, `premdays`, `lastday`, `email`, `key`, `blocked`, `warnings`, `group_id`, `loot_time`) VALUES
(1, '1', '1', '', 65535, 0, '', '0', 0, 0, 1, 0);

--
-- Gatilhos `accounts`
--
DROP TRIGGER IF EXISTS `ondelete_accounts`;
DELIMITER //
CREATE TRIGGER `ondelete_accounts` BEFORE DELETE ON `accounts`
 FOR EACH ROW BEGIN
        DELETE FROM `bans` WHERE `type` IN (3, 4) AND `value` = OLD.`id`;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `account_viplist`
--

CREATE TABLE IF NOT EXISTS `account_viplist` (
  `account_id` int(11) NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `player_id` int(11) NOT NULL,
  UNIQUE KEY `account_id_2` (`account_id`,`player_id`),
  KEY `account_id` (`account_id`),
  KEY `player_id` (`player_id`),
  KEY `world_id` (`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `account_viplist`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `auction_system`
--

CREATE TABLE IF NOT EXISTS `auction_system` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `count` int(11) DEFAULT NULL,
  `cost` int(11) DEFAULT NULL,
  `date` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `auction_system`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `bans`
--

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `type` tinyint(1) NOT NULL COMMENT '1 - ip banishment, 2 - namelock, 3 - account banishment, 4 - notation, 5 - deletion',
  `value` int(10) unsigned NOT NULL COMMENT 'ip address (integer), player guid or account number',
  `param` int(10) unsigned NOT NULL DEFAULT '4294967295' COMMENT 'used only for ip banishment mask (integer)',
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `expires` int(11) NOT NULL,
  `added` int(10) unsigned NOT NULL,
  `admin_id` int(10) unsigned NOT NULL DEFAULT '0',
  `comment` text NOT NULL,
  `reason` int(10) unsigned NOT NULL DEFAULT '0',
  `action` int(10) unsigned NOT NULL DEFAULT '0',
  `statement` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `type` (`type`,`value`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `bans`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `environment_killers`
--

CREATE TABLE IF NOT EXISTS `environment_killers` (
  `kill_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `kill_id` (`kill_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `environment_killers`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `global_storage`
--

CREATE TABLE IF NOT EXISTS `global_storage` (
  `key` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '0',
  UNIQUE KEY `key` (`key`,`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `global_storage`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `guilds`
--

CREATE TABLE IF NOT EXISTS `guilds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `creationdata` int(11) NOT NULL,
  `checkdata` int(11) NOT NULL,
  `motd` varchar(255) NOT NULL,
  `balance` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `guilds`
--


--
-- Gatilhos `guilds`
--
DROP TRIGGER IF EXISTS `oncreate_guilds`;
DELIMITER //
CREATE TRIGGER `oncreate_guilds` AFTER INSERT ON `guilds`
 FOR EACH ROW BEGIN
        INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Leader', 3, NEW.`id`);
        INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Vice-Leader', 2, NEW.`id`);
        INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('Member', 1, NEW.`id`);
END
//
DELIMITER ;
DROP TRIGGER IF EXISTS `ondelete_guilds`;
DELIMITER //
CREATE TRIGGER `ondelete_guilds` BEFORE DELETE ON `guilds`
 FOR EACH ROW BEGIN
        UPDATE `players` SET `guildnick` = '', `rank_id` = 0 WHERE `rank_id` IN (SELECT `id` FROM `guild_ranks` WHERE `guild_id` = OLD.`id`);
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_invites`
--

CREATE TABLE IF NOT EXISTS `guild_invites` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `guild_id` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `player_id` (`player_id`,`guild_id`),
  KEY `guild_id` (`guild_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `guild_invites`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_kills`
--

CREATE TABLE IF NOT EXISTS `guild_kills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild_id` int(11) NOT NULL,
  `war_id` int(11) NOT NULL,
  `death_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `guild_kills_ibfk_1` (`war_id`),
  KEY `guild_kills_ibfk_2` (`death_id`),
  KEY `guild_kills_ibfk_3` (`guild_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `guild_kills`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_ranks`
--

CREATE TABLE IF NOT EXISTS `guild_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `level` int(11) NOT NULL COMMENT '1 - leader, 2 - vice leader, 3 - member',
  PRIMARY KEY (`id`),
  KEY `guild_id` (`guild_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `guild_ranks`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `guild_wars`
--

CREATE TABLE IF NOT EXISTS `guild_wars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild_id` int(11) NOT NULL,
  `enemy_id` int(11) NOT NULL,
  `begin` bigint(20) NOT NULL DEFAULT '0',
  `end` bigint(20) NOT NULL DEFAULT '0',
  `frags` int(10) unsigned NOT NULL DEFAULT '0',
  `payment` bigint(20) unsigned NOT NULL DEFAULT '0',
  `guild_kills` int(10) unsigned NOT NULL DEFAULT '0',
  `enemy_kills` int(10) unsigned NOT NULL DEFAULT '0',
  `status` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `guild_id` (`guild_id`),
  KEY `enemy_id` (`enemy_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `guild_wars`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `houses`
--

CREATE TABLE IF NOT EXISTS `houses` (
  `id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `owner` int(11) NOT NULL,
  `paid` int(10) unsigned NOT NULL DEFAULT '0',
  `warnings` int(11) NOT NULL DEFAULT '0',
  `lastwarning` int(10) unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `town` int(10) unsigned NOT NULL DEFAULT '0',
  `size` int(10) unsigned NOT NULL DEFAULT '0',
  `price` int(10) unsigned NOT NULL DEFAULT '0',
  `rent` int(10) unsigned NOT NULL DEFAULT '0',
  `doors` int(10) unsigned NOT NULL DEFAULT '0',
  `beds` int(10) unsigned NOT NULL DEFAULT '0',
  `tiles` int(10) unsigned NOT NULL DEFAULT '0',
  `guild` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `clear` tinyint(1) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `id` (`id`,`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `houses`
--

INSERT INTO `houses` (`id`, `world_id`, `owner`, `paid`, `warnings`, `lastwarning`, `name`, `town`, `size`, `price`, `rent`, `doors`, `beds`, `tiles`, `guild`, `clear`) VALUES
(2, 0, 0, 0, 0, 0, 'Market Street 4 (Shop)', 1, 96, 208000, 5105, 7, 6, 208, 0, 0),
(4, 0, 0, 0, 0, 0, 'Market Street 3', 1, 70, 150000, 3475, 3, 4, 150, 0, 0),
(5, 0, 0, 0, 0, 0, 'Market Street 2', 1, 96, 207000, 4925, 5, 6, 207, 0, 0),
(6, 0, 0, 0, 0, 0, 'Market Street 1', 1, 133, 258000, 6680, 5, 6, 258, 0, 0),
(7, 0, 0, 0, 0, 0, 'Old Lighthouse', 1, 73, 177000, 3610, 1, 4, 177, 0, 0),
(8, 0, 0, 0, 0, 0, 'Seagull Walk 1', 1, 106, 210000, 5095, 6, 4, 210, 0, 0),
(9, 0, 0, 0, 0, 0, 'Seagull Walk 2', 1, 50, 132000, 2765, 4, 6, 132, 0, 0),
(10, 0, 0, 0, 0, 0, 'Dream Street 4', 1, 68, 168000, 3765, 5, 8, 168, 0, 0),
(11, 0, 0, 0, 0, 0, 'Elm Street 2', 1, 51, 112000, 2665, 2, 4, 112, 0, 0),
(12, 0, 0, 0, 0, 0, 'Elm Street 1', 1, 53, 120000, 2710, 2, 4, 120, 0, 0),
(13, 0, 0, 0, 0, 0, 'Elm Street 3', 1, 52, 126000, 2855, 1, 6, 126, 0, 0),
(14, 0, 0, 0, 0, 0, 'Elm Street 4', 1, 51, 120000, 3765, 2, 4, 120, 0, 0),
(15, 0, 0, 0, 0, 0, 'Dream Street 3', 1, 53, 117000, 2710, 2, 4, 117, 0, 0),
(16, 0, 0, 0, 0, 0, 'Dream Street 2', 1, 67, 147000, 3340, 4, 4, 147, 0, 0),
(18, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 13', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(19, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 12', 1, 8, 25000, 685, 1, 4, 25, 0, 0),
(23, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 14', 1, 10, 24000, 585, 1, 2, 24, 0, 0),
(24, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 15', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(25, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 16', 1, 10, 29000, 585, 1, 2, 29, 0, 0),
(26, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 17', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(27, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 18', 1, 4, 20000, 315, 1, 2, 20, 0, 0),
(28, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 01', 1, 6, 24000, 405, 1, 2, 24, 0, 0),
(29, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 02', 1, 7, 25000, 450, 1, 2, 25, 0, 0),
(30, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 03', 1, 6, 20000, 405, 1, 2, 20, 0, 0),
(31, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 04', 1, 8, 25000, 450, 1, 2, 25, 0, 0),
(32, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 05', 1, 4, 15000, 315, 1, 2, 15, 0, 0),
(33, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 06', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(34, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 07', 1, 8, 23000, 685, 1, 4, 23, 0, 0),
(35, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 21', 1, 5, 20000, 315, 1, 2, 20, 0, 0),
(36, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 22', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(37, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 23', 1, 10, 30000, 585, 1, 2, 30, 0, 0),
(38, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 24', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(39, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 26', 1, 7, 20000, 450, 1, 2, 20, 0, 0),
(40, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 28', 1, 4, 15000, 315, 1, 2, 15, 0, 0),
(41, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 27', 1, 8, 25000, 685, 1, 4, 25, 0, 0),
(42, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 25', 1, 10, 20000, 585, 1, 2, 20, 0, 0),
(43, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 31', 1, 16, 40000, 855, 1, 2, 40, 0, 0),
(44, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 32', 1, 18, 50000, 1135, 2, 4, 50, 0, 0),
(45, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 33', 1, 14, 32000, 765, 2, 2, 32, 0, 0),
(46, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 34', 1, 30, 60000, 1675, 2, 4, 60, 0, 0),
(47, 0, 0, 0, 0, 0, 'Salvation Street 1 (Shop)', 1, 119, 249000, 6240, 7, 8, 249, 0, 0),
(49, 0, 0, 0, 0, 0, 'Dream Street 1 (Shop)', 1, 81, 192000, 4330, 6, 4, 192, 0, 0),
(50, 0, 0, 0, 0, 0, 'Blessed Shield Guildhall', 1, 126, 258000, 8090, 7, 18, 258, 0, 0),
(51, 0, 0, 0, 0, 0, 'Dagger Alley 1', 1, 52, 116000, 2665, 2, 4, 116, 0, 0),
(52, 0, 0, 0, 0, 0, 'Steel Home', 1, 219, 462000, 13845, 10, 26, 462, 0, 0),
(53, 0, 0, 0, 0, 0, 'Iron Alley 1', 1, 61, 120000, 3450, 2, 8, 120, 0, 0),
(54, 0, 0, 0, 0, 0, 'Iron Alley 2', 1, 64, 144000, 3450, 2, 4, 144, 0, 0),
(55, 0, 0, 0, 0, 0, 'Swamp Watch', 1, 179, 420000, 11090, 12, 24, 420, 0, 0),
(57, 0, 0, 0, 0, 0, 'Salvation Street 2', 1, 76, 135000, 3790, 2, 4, 135, 0, 0),
(60, 0, 0, 0, 0, 0, 'Salvation Street 3', 1, 76, 162000, 3790, 2, 4, 162, 0, 0),
(61, 0, 0, 0, 0, 0, 'Silver Street 3', 1, 41, 84000, 1980, 2, 2, 84, 0, 0),
(62, 0, 0, 0, 0, 0, 'Golden Axe Guildhall', 1, 175, 390000, 10485, 12, 20, 390, 0, 0),
(63, 0, 0, 0, 0, 0, 'Silver Street 1', 1, 54, 129000, 2565, 2, 2, 129, 0, 0),
(64, 0, 0, 0, 0, 0, 'Silver Street 2', 1, 41, 105000, 1980, 2, 2, 105, 0, 0),
(66, 0, 0, 0, 0, 0, 'Silver Street 4', 1, 66, 153000, 3295, 4, 4, 153, 0, 0),
(67, 0, 0, 0, 0, 0, 'Mystic Lane 2', 1, 58, 137000, 2980, 2, 4, 137, 0, 0),
(69, 0, 0, 0, 0, 0, 'Mystic Lane 1', 1, 51, 112000, 2945, 4, 6, 112, 0, 0),
(70, 0, 0, 0, 0, 0, 'Loot Lane 1 (Shop)', 1, 88, 198000, 4565, 7, 6, 198, 0, 0),
(71, 0, 0, 0, 0, 0, 'Market Street 6', 1, 102, 217000, 5485, 5, 10, 217, 0, 0),
(72, 0, 0, 0, 0, 0, 'Market Street 7', 1, 44, 114000, 2305, 3, 4, 114, 0, 0),
(73, 0, 0, 0, 0, 0, 'Market Street 5 (Shop)', 1, 119, 243000, 6375, 5, 6, 243, 0, 0),
(194, 0, 0, 0, 0, 0, 'Lucky Lane 1 (Shop)', 1, 132, 270000, 6960, 6, 8, 270, 0, 0),
(208, 0, 0, 0, 0, 0, 'Underwood 1', 5, 26, 54000, 1495, 1, 4, 54, 0, 0),
(209, 0, 0, 0, 0, 0, 'Underwood 2', 5, 27, 55000, 1495, 1, 4, 55, 0, 0),
(210, 0, 0, 0, 0, 0, 'Underwood 5', 5, 19, 48000, 1370, 1, 6, 48, 0, 0),
(211, 0, 0, 0, 0, 0, 'Underwood 3', 5, 26, 57000, 1685, 1, 6, 57, 0, 0),
(212, 0, 0, 0, 0, 0, 'Underwood 4', 5, 35, 70000, 2235, 1, 8, 70, 0, 0),
(213, 0, 0, 0, 0, 0, 'Underwood 10', 5, 10, 23000, 585, 1, 2, 23, 0, 0),
(214, 0, 0, 0, 0, 0, 'Underwood 6', 5, 24, 55000, 1595, 1, 6, 55, 0, 0),
(215, 0, 0, 0, 0, 0, 'Great Willow 1a', 5, 7, 25000, 500, 1, 2, 25, 0, 0),
(216, 0, 0, 0, 0, 0, 'Great Willow 1b', 5, 10, 30000, 650, 1, 2, 30, 0, 0),
(217, 0, 0, 0, 0, 0, 'Great Willow 1c', 5, 10, 20000, 650, 1, 2, 20, 0, 0),
(218, 0, 0, 0, 0, 0, 'Great Willow 2d', 5, 6, 18000, 450, 1, 2, 18, 0, 0),
(219, 0, 0, 0, 0, 0, 'Great Willow 2c', 5, 10, 24000, 650, 1, 2, 24, 0, 0),
(220, 0, 0, 0, 0, 0, 'Great Willow 2b', 5, 6, 24000, 450, 1, 2, 24, 0, 0),
(221, 0, 0, 0, 0, 0, 'Great Willow 2a', 5, 11, 30000, 650, 1, 2, 30, 0, 0),
(222, 0, 0, 0, 0, 0, 'Great Willow 3d', 5, 6, 18000, 450, 1, 2, 18, 0, 0),
(223, 0, 0, 0, 0, 0, 'Great Willow 3c', 5, 10, 24000, 650, 1, 2, 24, 0, 0),
(224, 0, 0, 0, 0, 0, 'Great Willow 3b', 5, 6, 24000, 450, 1, 2, 24, 0, 0),
(225, 0, 0, 0, 0, 0, 'Great Willow 3a', 5, 10, 30000, 650, 1, 2, 30, 0, 0),
(226, 0, 0, 0, 0, 0, 'Great Willow 4b', 5, 12, 27000, 950, 1, 4, 27, 0, 0),
(227, 0, 0, 0, 0, 0, 'Great Willow 4c', 5, 12, 31000, 950, 1, 4, 31, 0, 0),
(228, 0, 0, 0, 0, 0, 'Great Willow 4d', 5, 12, 36000, 750, 1, 2, 36, 0, 0),
(229, 0, 0, 0, 0, 0, 'Great Willow 4a', 5, 12, 36000, 950, 1, 4, 36, 0, 0),
(230, 0, 0, 0, 0, 0, 'Underwood 7', 5, 21, 49000, 1460, 1, 6, 49, 0, 0),
(231, 0, 0, 0, 0, 0, 'Shadow Caves 3', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(232, 0, 0, 0, 0, 0, 'Shadow Caves 4', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(233, 0, 0, 0, 0, 0, 'Shadow Caves 2', 5, 7, 16000, 300, 1, 2, 16, 0, 0),
(234, 0, 0, 0, 0, 0, 'Shadow Caves 1', 5, 7, 19000, 300, 1, 2, 19, 0, 0),
(235, 0, 0, 0, 0, 0, 'Shadow Caves 17', 5, 7, 25000, 300, 1, 2, 25, 0, 0),
(236, 0, 0, 0, 0, 0, 'Shadow Caves 18', 5, 7, 25000, 300, 1, 2, 25, 0, 0),
(237, 0, 0, 0, 0, 0, 'Shadow Caves 15', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(238, 0, 0, 0, 0, 0, 'Shadow Caves 16', 5, 7, 19000, 300, 1, 2, 19, 0, 0),
(239, 0, 0, 0, 0, 0, 'Shadow Caves 13', 5, 7, 19000, 300, 1, 2, 19, 0, 0),
(240, 0, 0, 0, 0, 0, 'Shadow Caves 14', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(241, 0, 0, 0, 0, 0, 'Shadow Caves 11', 5, 7, 19000, 300, 1, 2, 19, 0, 0),
(242, 0, 0, 0, 0, 0, 'Shadow Caves 12', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(243, 0, 0, 0, 0, 0, 'Shadow Caves 27', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(244, 0, 0, 0, 0, 0, 'Shadow Caves 28', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(245, 0, 0, 0, 0, 0, 'Shadow Caves 25', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(246, 0, 0, 0, 0, 0, 'Shadow Caves 26', 5, 7, 16000, 300, 1, 2, 16, 0, 0),
(247, 0, 0, 0, 0, 0, 'Shadow Caves 23', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(248, 0, 0, 0, 0, 0, 'Shadow Caves 24', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(249, 0, 0, 0, 0, 0, 'Shadow Caves 21', 5, 7, 19000, 300, 1, 2, 19, 0, 0),
(250, 0, 0, 0, 0, 0, 'Shadow Caves 22', 5, 7, 20000, 300, 1, 2, 20, 0, 0),
(251, 0, 0, 0, 0, 0, 'Underwood 9', 5, 10, 28000, 585, 1, 2, 28, 0, 0),
(252, 0, 0, 0, 0, 0, 'Treetop 13', 5, 21, 48000, 1400, 1, 4, 48, 0, 0),
(254, 0, 0, 0, 0, 0, 'Underwood 8', 5, 13, 34000, 865, 1, 4, 34, 0, 0),
(255, 0, 0, 0, 0, 0, 'Mangrove 4', 5, 13, 36000, 950, 1, 4, 36, 0, 0),
(256, 0, 0, 0, 0, 0, 'Coastwood 10', 5, 19, 48000, 1630, 1, 6, 48, 0, 0),
(257, 0, 0, 0, 0, 0, 'Mangrove 1', 5, 24, 54000, 1750, 1, 6, 54, 0, 0),
(258, 0, 0, 0, 0, 0, 'Coastwood 1', 5, 11, 34000, 980, 1, 4, 34, 0, 0),
(259, 0, 0, 0, 0, 0, 'Coastwood 2', 5, 11, 28000, 980, 1, 4, 28, 0, 0),
(260, 0, 0, 0, 0, 0, 'Mangrove 2', 5, 20, 47000, 1350, 1, 4, 47, 0, 0),
(262, 0, 0, 0, 0, 0, 'Mangrove 3', 5, 16, 41000, 1150, 1, 4, 41, 0, 0),
(263, 0, 0, 0, 0, 0, 'Coastwood 9', 5, 14, 34000, 935, 1, 2, 34, 0, 0),
(264, 0, 0, 0, 0, 0, 'Coastwood 8', 5, 17, 41000, 1255, 1, 4, 41, 0, 0),
(265, 0, 0, 0, 0, 0, 'Coastwood 6 (Shop)', 5, 24, 51000, 1595, 3, 2, 51, 0, 0),
(266, 0, 0, 0, 0, 0, 'Coastwood 7', 5, 9, 29000, 660, 1, 2, 29, 0, 0),
(267, 0, 0, 0, 0, 0, 'Coastwood 5', 5, 21, 49000, 1530, 1, 4, 49, 0, 0),
(268, 0, 0, 0, 0, 0, 'Coastwood 4', 5, 14, 42000, 1145, 1, 4, 42, 0, 0),
(269, 0, 0, 0, 0, 0, 'Coastwood 3', 5, 17, 36000, 1310, 1, 4, 36, 0, 0),
(270, 0, 0, 0, 0, 0, 'Treetop 11', 5, 11, 34000, 900, 1, 4, 34, 0, 0),
(271, 0, 0, 0, 0, 0, 'Treetop 5 (Shop)', 5, 18, 53000, 1350, 3, 2, 53, 0, 0),
(272, 0, 0, 0, 0, 0, 'Treetop 7', 5, 14, 28000, 800, 1, 2, 28, 0, 0),
(273, 0, 0, 0, 0, 0, 'Treetop 6', 5, 7, 23000, 450, 1, 2, 23, 0, 0),
(274, 0, 0, 0, 0, 0, 'Treetop 8', 5, 14, 35000, 800, 1, 2, 35, 0, 0),
(275, 0, 0, 0, 0, 0, 'Treetop 9', 5, 16, 34000, 1150, 1, 4, 34, 0, 0),
(276, 0, 0, 0, 0, 0, 'Treetop 10', 5, 16, 42000, 1150, 1, 4, 42, 0, 0),
(277, 0, 0, 0, 0, 0, 'Treetop 4 (Shop)', 5, 20, 48000, 1250, 2, 2, 48, 0, 0),
(278, 0, 0, 0, 0, 0, 'Treetop 3 (Shop)', 5, 20, 60000, 1250, 2, 2, 60, 0, 0),
(279, 0, 0, 0, 0, 0, 'Treetop 2', 5, 10, 29000, 650, 1, 2, 29, 0, 0),
(280, 0, 0, 0, 0, 0, 'Treetop 1', 5, 10, 24000, 650, 1, 2, 24, 0, 0),
(281, 0, 0, 0, 0, 0, 'Treetop 12 (Shop)', 5, 20, 53000, 1350, 3, 2, 53, 0, 0),
(469, 0, 0, 0, 0, 0, 'Darashia 2, Flat 07', 10, 22, 48000, 1000, 1, 2, 48, 0, 0),
(470, 0, 0, 0, 0, 0, 'Darashia 2, Flat 01', 10, 23, 48000, 1000, 1, 2, 48, 0, 0),
(471, 0, 0, 0, 0, 0, 'Darashia 2, Flat 02', 10, 22, 42000, 1000, 1, 2, 42, 0, 0),
(472, 0, 0, 0, 0, 0, 'Darashia 2, Flat 06', 10, 10, 24000, 520, 1, 2, 24, 0, 0),
(473, 0, 0, 0, 0, 0, 'Darashia 2, Flat 05', 10, 24, 48000, 1260, 1, 4, 48, 0, 0),
(474, 0, 0, 0, 0, 0, 'Darashia 2, Flat 04', 10, 10, 24000, 520, 1, 2, 24, 0, 0),
(475, 0, 0, 0, 0, 0, 'Darashia 2, Flat 03', 10, 26, 42000, 1160, 1, 2, 42, 0, 0),
(476, 0, 0, 0, 0, 0, 'Darashia 2, Flat 13', 10, 26, 42000, 1160, 1, 2, 42, 0, 0),
(477, 0, 0, 0, 0, 0, 'Darashia 2, Flat 12', 10, 10, 24000, 520, 1, 2, 24, 0, 0),
(478, 0, 0, 0, 0, 0, 'Darashia 2, Flat 11', 10, 22, 42000, 1000, 1, 2, 42, 0, 0),
(479, 0, 0, 0, 0, 0, 'Darashia 2, Flat 14', 10, 10, 24000, 520, 1, 2, 24, 0, 0),
(480, 0, 0, 0, 0, 0, 'Darashia 2, Flat 15', 10, 24, 47000, 1260, 1, 4, 47, 0, 0),
(481, 0, 0, 0, 0, 0, 'Darashia 2, Flat 16', 10, 15, 30000, 680, 1, 2, 30, 0, 0),
(482, 0, 0, 0, 0, 0, 'Darashia 2, Flat 17', 10, 22, 48000, 1000, 1, 2, 48, 0, 0),
(483, 0, 0, 0, 0, 0, 'Darashia 2, Flat 18', 10, 14, 30000, 680, 1, 2, 30, 0, 0),
(484, 0, 0, 0, 0, 0, 'Darashia 1, Flat 05', 10, 20, 48000, 1100, 1, 4, 48, 0, 0),
(485, 0, 0, 0, 0, 0, 'Darashia 1, Flat 01', 10, 20, 48000, 1100, 1, 4, 48, 0, 0),
(486, 0, 0, 0, 0, 0, 'Darashia 1, Flat 04', 10, 22, 42000, 1000, 1, 2, 42, 0, 0),
(487, 0, 0, 0, 0, 0, 'Darashia 1, Flat 03', 10, 48, 96000, 2660, 3, 8, 96, 0, 0),
(488, 0, 0, 0, 0, 0, 'Darashia 1, Flat 02', 10, 22, 41000, 1000, 1, 2, 41, 0, 0),
(490, 0, 0, 0, 0, 0, 'Darashia 1, Flat 12', 10, 37, 66000, 1780, 2, 4, 66, 0, 0),
(491, 0, 0, 0, 0, 0, 'Darashia 1, Flat 11', 10, 20, 41000, 1100, 1, 4, 41, 0, 0),
(492, 0, 0, 0, 0, 0, 'Darashia 1, Flat 13', 10, 37, 72000, 1780, 2, 4, 72, 0, 0),
(493, 0, 0, 0, 0, 0, 'Darashia 1, Flat 14', 10, 48, 108000, 2760, 3, 10, 108, 0, 0),
(494, 0, 0, 0, 0, 0, 'Darashia 4, Flat 01', 10, 22, 48000, 1000, 1, 2, 48, 0, 0),
(495, 0, 0, 0, 0, 0, 'Darashia 4, Flat 05', 10, 21, 48000, 1100, 1, 4, 48, 0, 0),
(496, 0, 0, 0, 0, 0, 'Darashia 4, Flat 04', 10, 38, 72000, 1780, 2, 4, 72, 0, 0),
(497, 0, 0, 0, 0, 0, 'Darashia 4, Flat 03', 10, 23, 42000, 1000, 1, 2, 42, 0, 0),
(498, 0, 0, 0, 0, 0, 'Darashia 4, Flat 02', 10, 38, 66000, 1780, 2, 4, 66, 0, 0),
(499, 0, 0, 0, 0, 0, 'Darashia 4, Flat 13', 10, 37, 78000, 1780, 2, 4, 78, 0, 0),
(500, 0, 0, 0, 0, 0, 'Darashia 4, Flat 14', 10, 37, 72000, 1780, 2, 4, 72, 0, 0),
(501, 0, 0, 0, 0, 0, 'Darashia 4, Flat 11', 10, 22, 41000, 1000, 1, 2, 41, 0, 0),
(502, 0, 0, 0, 0, 0, 'Darashia 4, Flat 12', 10, 52, 96000, 2560, 3, 6, 96, 0, 0),
(503, 0, 0, 0, 0, 0, 'Darashia 7, Flat 05', 10, 20, 40000, 1225, 1, 4, 40, 0, 0),
(504, 0, 0, 0, 0, 0, 'Darashia 7, Flat 01', 10, 22, 40000, 1125, 1, 2, 40, 0, 0),
(505, 0, 0, 0, 0, 0, 'Darashia 7, Flat 02', 10, 22, 41000, 1125, 1, 2, 41, 0, 0),
(506, 0, 0, 0, 0, 0, 'Darashia 7, Flat 03', 10, 50, 108000, 2955, 3, 8, 108, 0, 0),
(507, 0, 0, 0, 0, 0, 'Darashia 7, Flat 04', 10, 23, 42000, 1125, 1, 2, 42, 0, 0),
(508, 0, 0, 0, 0, 0, 'Darashia 7, Flat 14', 10, 48, 108000, 2955, 3, 8, 108, 0, 0),
(509, 0, 0, 0, 0, 0, 'Darashia 7, Flat 13', 10, 22, 42000, 1125, 1, 2, 42, 0, 0),
(510, 0, 0, 0, 0, 0, 'Darashia 7, Flat 11', 10, 22, 41000, 1125, 1, 2, 41, 0, 0),
(511, 0, 0, 0, 0, 0, 'Darashia 7, Flat 12', 10, 49, 95000, 2955, 3, 8, 95, 0, 0),
(512, 0, 0, 0, 0, 0, 'Darashia 5, Flat 01', 10, 22, 48000, 1000, 1, 2, 48, 0, 0),
(513, 0, 0, 0, 0, 0, 'Darashia 5, Flat 05', 10, 22, 48000, 1000, 1, 2, 48, 0, 0),
(514, 0, 0, 0, 0, 0, 'Darashia 5, Flat 02', 10, 32, 61000, 1620, 2, 4, 61, 0, 0),
(515, 0, 0, 0, 0, 0, 'Darashia 5, Flat 03', 10, 22, 41000, 1000, 1, 2, 41, 0, 0),
(516, 0, 0, 0, 0, 0, 'Darashia 5, Flat 04', 10, 32, 66000, 1620, 2, 4, 66, 0, 0),
(517, 0, 0, 0, 0, 0, 'Darashia 5, Flat 11', 10, 37, 66000, 1780, 2, 4, 66, 0, 0),
(518, 0, 0, 0, 0, 0, 'Darashia 5, Flat 12', 10, 34, 65000, 1620, 2, 4, 65, 0, 0),
(519, 0, 0, 0, 0, 0, 'Darashia 5, Flat 13', 10, 37, 78000, 1780, 2, 4, 78, 0, 0),
(520, 0, 0, 0, 0, 0, 'Darashia 5, Flat 14', 10, 33, 66000, 1620, 2, 4, 66, 0, 0),
(521, 0, 0, 0, 0, 0, 'Darashia 6a', 10, 62, 117000, 3115, 3, 4, 117, 0, 0),
(522, 0, 0, 0, 0, 0, 'Darashia 6b', 10, 69, 139000, 3430, 2, 4, 139, 0, 0),
(523, 0, 0, 0, 0, 0, 'Darashia, Villa', 10, 93, 233000, 5385, 11, 8, 233, 0, 0),
(525, 0, 0, 0, 0, 0, 'Darashia, Western Guildhall', 10, 154, 376000, 10435, 16, 28, 376, 0, 0),
(526, 0, 0, 0, 0, 0, 'Darashia 3, Flat 01', 10, 20, 40000, 1100, 1, 4, 40, 0, 0),
(527, 0, 0, 0, 0, 0, 'Darashia 3, Flat 05', 10, 22, 40000, 1000, 1, 2, 40, 0, 0),
(529, 0, 0, 0, 0, 0, 'Darashia 3, Flat 02', 10, 32, 65000, 1620, 2, 4, 65, 0, 0),
(530, 0, 0, 0, 0, 0, 'Darashia 3, Flat 03', 10, 20, 42000, 1100, 1, 4, 42, 0, 0),
(531, 0, 0, 0, 0, 0, 'Darashia 3, Flat 04', 10, 33, 72000, 1620, 2, 4, 72, 0, 0),
(532, 0, 0, 0, 0, 0, 'Darashia 3, Flat 13', 10, 20, 42000, 1100, 1, 4, 42, 0, 0),
(533, 0, 0, 0, 0, 0, 'Darashia 3, Flat 14', 10, 46, 102000, 2400, 3, 6, 102, 0, 0),
(534, 0, 0, 0, 0, 0, 'Darashia 3, Flat 11', 10, 22, 41000, 1000, 1, 2, 41, 0, 0),
(535, 0, 0, 0, 0, 0, 'Darashia 3, Flat 12', 10, 42, 90000, 2600, 3, 10, 90, 0, 0),
(541, 0, 0, 0, 0, 0, 'Darashia 8, Flat 11', 10, 37, 66000, 1990, 2, 4, 66, 0, 0),
(542, 0, 0, 0, 0, 0, 'Darashia 8, Flat 12', 10, 32, 65000, 1810, 2, 4, 65, 0, 0),
(544, 0, 0, 0, 0, 0, 'Darashia 8, Flat 14', 10, 32, 66000, 1810, 2, 4, 66, 0, 0),
(545, 0, 0, 0, 0, 0, 'Darashia 8, Flat 13', 10, 36, 78000, 1990, 2, 4, 78, 0, 0),
(574, 0, 0, 0, 0, 0, 'Oskahl I j', 9, 14, 25000, 680, 1, 2, 25, 0, 0),
(575, 0, 0, 0, 0, 0, 'Oskahl I f', 9, 18, 34000, 840, 1, 2, 34, 0, 0),
(576, 0, 0, 0, 0, 0, 'Oskahl I i', 9, 18, 30000, 840, 1, 2, 30, 0, 0),
(577, 0, 0, 0, 0, 0, 'Oskahl I g', 9, 21, 42000, 1140, 1, 4, 42, 0, 0),
(578, 0, 0, 0, 0, 0, 'Oskahl I h', 9, 32, 63000, 1760, 3, 6, 63, 0, 0),
(579, 0, 0, 0, 0, 0, 'Oskahl I d', 9, 21, 36000, 1140, 1, 4, 36, 0, 0),
(580, 0, 0, 0, 0, 0, 'Oskahl I b', 9, 18, 30000, 840, 1, 2, 30, 0, 0),
(581, 0, 0, 0, 0, 0, 'Oskahl I c', 9, 14, 29000, 680, 1, 2, 29, 0, 0),
(582, 0, 0, 0, 0, 0, 'Oskahl I e', 9, 18, 33000, 840, 1, 2, 33, 0, 0),
(583, 0, 0, 0, 0, 0, 'Oskahl I a', 9, 32, 52000, 1580, 1, 4, 52, 0, 0),
(584, 0, 0, 0, 0, 0, 'Chameken I', 9, 17, 33000, 850, 1, 2, 33, 0, 0),
(585, 0, 0, 0, 0, 0, 'Charsirakh III', 9, 14, 30000, 680, 1, 2, 30, 0, 0),
(586, 0, 0, 0, 0, 0, 'Murkhol I d', 9, 8, 21000, 440, 1, 2, 21, 0, 0),
(587, 0, 0, 0, 0, 0, 'Murkhol I c', 9, 8, 18000, 440, 1, 2, 18, 0, 0),
(588, 0, 0, 0, 0, 0, 'Murkhol I b', 9, 8, 18000, 440, 1, 2, 18, 0, 0),
(589, 0, 0, 0, 0, 0, 'Murkhol I a', 9, 8, 20000, 440, 1, 2, 20, 0, 0),
(590, 0, 0, 0, 0, 0, 'Charsirakh II', 9, 21, 39000, 1140, 1, 4, 39, 0, 0),
(591, 0, 0, 0, 0, 0, 'Thanah II h', 9, 21, 40000, 1400, 2, 4, 40, 0, 0),
(592, 0, 0, 0, 0, 0, 'Thanah II g', 9, 26, 45000, 1650, 1, 4, 45, 0, 0),
(593, 0, 0, 0, 0, 0, 'Thanah II f', 9, 45, 80000, 2850, 3, 6, 80, 0, 0),
(594, 0, 0, 0, 0, 0, 'Thanah II b', 9, 7, 20000, 450, 1, 2, 20, 0, 0),
(595, 0, 0, 0, 0, 0, 'Thanah II c', 9, 6, 15000, 450, 1, 2, 15, 0, 0),
(596, 0, 0, 0, 0, 0, 'Thanah II d', 9, 4, 16000, 350, 1, 2, 16, 0, 0),
(597, 0, 0, 0, 0, 0, 'Thanah II e', 9, 4, 12000, 350, 1, 2, 12, 0, 0),
(599, 0, 0, 0, 0, 0, 'Thanah II a', 9, 22, 37000, 850, 1, 2, 37, 0, 0),
(600, 0, 0, 0, 0, 0, 'Thrarhor I c (Shop)', 9, 25, 57000, 1050, 1, 4, 57, 0, 0),
(601, 0, 0, 0, 0, 0, 'Thrarhor I d (Shop)', 9, 10, 21000, 1050, 0, 2, 21, 0, 0),
(602, 0, 0, 0, 0, 0, 'Thrarhor I a (Shop)', 9, 10, 32000, 1050, 0, 2, 32, 0, 0),
(603, 0, 0, 0, 0, 0, 'Thrarhor I b (Shop)', 9, 10, 24000, 1050, 0, 2, 24, 0, 0),
(604, 0, 0, 0, 0, 0, 'Thanah I c', 9, 51, 91000, 3250, 4, 6, 91, 0, 0),
(605, 0, 0, 0, 0, 0, 'Thanah I d', 9, 42, 80000, 2900, 4, 8, 80, 0, 0),
(606, 0, 0, 0, 0, 0, 'Thanah I b', 9, 50, 84000, 3000, 3, 6, 84, 0, 0),
(607, 0, 0, 0, 0, 0, 'Thanah I a', 9, 14, 27000, 850, 1, 2, 27, 0, 0),
(608, 0, 0, 0, 0, 0, 'Harrah I', 9, 96, 190000, 5740, 6, 20, 190, 0, 0),
(609, 0, 0, 0, 0, 0, 'Charsirakh I b', 9, 32, 51000, 1580, 1, 4, 51, 0, 0),
(610, 0, 0, 0, 0, 0, 'Charsirakh I a', 9, 4, 15000, 280, 1, 2, 15, 0, 0),
(611, 0, 0, 0, 0, 0, 'Othehothep I d', 9, 34, 68000, 2020, 3, 8, 68, 0, 0),
(612, 0, 0, 0, 0, 0, 'Othehothep I c', 9, 31, 58000, 1720, 2, 6, 58, 0, 0),
(613, 0, 0, 0, 0, 0, 'Othehothep I b', 9, 26, 49000, 1380, 2, 4, 49, 0, 0),
(614, 0, 0, 0, 0, 0, 'Othehothep I a', 9, 5, 14000, 280, 1, 2, 14, 0, 0),
(615, 0, 0, 0, 0, 0, 'Othehothep II e', 9, 26, 44000, 1340, 1, 4, 44, 0, 0),
(616, 0, 0, 0, 0, 0, 'Othehothep II f', 9, 27, 44000, 1340, 1, 4, 44, 0, 0),
(617, 0, 0, 0, 0, 0, 'Othehothep II d', 9, 18, 32000, 840, 1, 2, 32, 0, 0),
(618, 0, 0, 0, 0, 0, 'Othehothep II c', 9, 18, 30000, 840, 1, 2, 30, 0, 0),
(619, 0, 0, 0, 0, 0, 'Othehothep II b', 9, 36, 67000, 1920, 3, 6, 67, 0, 0),
(620, 0, 0, 0, 0, 0, 'Othehothep II a', 9, 8, 18000, 400, 1, 2, 18, 0, 0),
(621, 0, 0, 0, 0, 0, 'Mothrem I', 9, 21, 38000, 1140, 1, 4, 38, 0, 0),
(622, 0, 0, 0, 0, 0, 'Arakmehn I', 9, 21, 41000, 1320, 1, 6, 41, 0, 0),
(623, 0, 0, 0, 0, 0, 'Othehothep III d', 9, 23, 36000, 1040, 1, 2, 36, 0, 0),
(624, 0, 0, 0, 0, 0, 'Othehothep III c', 9, 16, 30000, 940, 1, 4, 30, 0, 0),
(625, 0, 0, 0, 0, 0, 'Othehothep III e', 9, 18, 32000, 840, 1, 2, 32, 0, 0),
(626, 0, 0, 0, 0, 0, 'Othehothep III f', 9, 14, 27000, 680, 1, 2, 27, 0, 0),
(627, 0, 0, 0, 0, 0, 'Othehothep III b', 9, 26, 49000, 1340, 3, 4, 49, 0, 0),
(628, 0, 0, 0, 0, 0, 'Othehothep III a', 9, 4, 14000, 280, 1, 2, 14, 0, 0),
(629, 0, 0, 0, 0, 0, 'Unklath I d', 9, 30, 49000, 1680, 1, 6, 49, 0, 0),
(630, 0, 0, 0, 0, 0, 'Unklath I e', 9, 32, 51000, 1580, 1, 4, 51, 0, 0),
(631, 0, 0, 0, 0, 0, 'Unklath I g', 9, 34, 51000, 1480, 1, 2, 51, 0, 0),
(632, 0, 0, 0, 0, 0, 'Unklath I f', 9, 32, 51000, 1580, 1, 4, 51, 0, 0),
(633, 0, 0, 0, 0, 0, 'Unklath I c', 9, 29, 50000, 1460, 2, 4, 50, 0, 0),
(634, 0, 0, 0, 0, 0, 'Unklath I b', 9, 28, 50000, 1460, 2, 4, 50, 0, 0),
(635, 0, 0, 0, 0, 0, 'Unklath I a', 9, 21, 38000, 1140, 1, 4, 38, 0, 0),
(636, 0, 0, 0, 0, 0, 'Arakmehn II', 9, 23, 38000, 1040, 1, 2, 38, 0, 0),
(637, 0, 0, 0, 0, 0, 'Arakmehn III', 9, 21, 38000, 1140, 1, 4, 38, 0, 0),
(638, 0, 0, 0, 0, 0, 'Unklath II b', 9, 14, 25000, 680, 1, 2, 25, 0, 0),
(639, 0, 0, 0, 0, 0, 'Unklath II c', 9, 14, 27000, 680, 1, 2, 27, 0, 0),
(640, 0, 0, 0, 0, 0, 'Unklath II d', 9, 32, 52000, 1580, 1, 4, 52, 0, 0),
(641, 0, 0, 0, 0, 0, 'Unklath II a', 9, 23, 36000, 1040, 1, 2, 36, 0, 0),
(642, 0, 0, 0, 0, 0, 'Arakmehn IV', 9, 24, 41000, 1220, 1, 4, 41, 0, 0),
(643, 0, 0, 0, 0, 0, 'Rathal I b', 9, 14, 25000, 680, 1, 2, 25, 0, 0),
(644, 0, 0, 0, 0, 0, 'Rathal I c', 9, 14, 27000, 680, 1, 2, 27, 0, 0),
(645, 0, 0, 0, 0, 0, 'Rathal I e', 9, 12, 27000, 780, 1, 4, 27, 0, 0),
(646, 0, 0, 0, 0, 0, 'Rathal I d', 9, 12, 27000, 780, 1, 4, 27, 0, 0),
(647, 0, 0, 0, 0, 0, 'Rathal I a', 9, 21, 36000, 1140, 1, 4, 36, 0, 0),
(648, 0, 0, 0, 0, 0, 'Rathal II b', 9, 14, 25000, 680, 1, 2, 25, 0, 0),
(649, 0, 0, 0, 0, 0, 'Rathal II c', 9, 14, 27000, 680, 1, 2, 27, 0, 0),
(650, 0, 0, 0, 0, 0, 'Rathal II d', 9, 29, 52000, 1460, 2, 4, 52, 0, 0),
(651, 0, 0, 0, 0, 0, 'Rathal II a', 9, 24, 38000, 1040, 1, 2, 38, 0, 0),
(653, 0, 0, 0, 0, 0, 'Esuph II a', 9, 4, 14000, 280, 1, 2, 14, 0, 0),
(654, 0, 0, 0, 0, 0, 'Uthemath II', 9, 76, 138000, 4460, 3, 16, 138, 0, 0),
(655, 0, 0, 0, 0, 0, 'Uthemath I e', 9, 16, 32000, 940, 1, 4, 32, 0, 0),
(656, 0, 0, 0, 0, 0, 'Uthemath I d', 9, 18, 30000, 840, 1, 2, 30, 0, 0),
(657, 0, 0, 0, 0, 0, 'Uthemath I f', 9, 49, 86000, 2440, 4, 6, 86, 0, 0),
(658, 0, 0, 0, 0, 0, 'Uthemath I b', 9, 17, 32000, 800, 2, 2, 32, 0, 0),
(659, 0, 0, 0, 0, 0, 'Uthemath I c', 9, 15, 34000, 900, 2, 4, 34, 0, 0),
(660, 0, 0, 0, 0, 0, 'Uthemath I a', 9, 7, 18000, 400, 1, 2, 18, 0, 0),
(661, 0, 0, 0, 0, 0, 'Botham I c', 9, 26, 49000, 1700, 2, 4, 49, 0, 0),
(662, 0, 0, 0, 0, 0, 'Botham I e', 9, 27, 44000, 1650, 1, 4, 44, 0, 0),
(663, 0, 0, 0, 0, 0, 'Botham I d', 9, 50, 80000, 3050, 2, 6, 80, 0, 0),
(664, 0, 0, 0, 0, 0, 'Botham I b', 9, 47, 83000, 3000, 3, 6, 83, 0, 0),
(666, 0, 0, 0, 0, 0, 'Horakhal', 9, 174, 277000, 9420, 5, 28, 277, 0, 0),
(667, 0, 0, 0, 0, 0, 'Esuph III b', 9, 26, 49000, 1340, 3, 4, 49, 0, 0),
(668, 0, 0, 0, 0, 0, 'Esuph III a', 9, 4, 14000, 280, 1, 2, 14, 0, 0),
(669, 0, 0, 0, 0, 0, 'Esuph IV b', 9, 7, 16000, 400, 1, 2, 16, 0, 0),
(670, 0, 0, 0, 0, 0, 'Esuph IV c', 9, 7, 18000, 400, 1, 2, 18, 0, 0),
(671, 0, 0, 0, 0, 0, 'Esuph IV d', 9, 16, 34000, 800, 2, 2, 34, 0, 0),
(672, 0, 0, 0, 0, 0, 'Esuph IV a', 9, 7, 16000, 400, 1, 2, 16, 0, 0),
(673, 0, 0, 0, 0, 0, 'Botham II e', 9, 26, 42000, 1650, 1, 4, 42, 0, 0),
(674, 0, 0, 0, 0, 0, 'Botham II g', 9, 21, 38000, 1400, 1, 4, 38, 0, 0),
(675, 0, 0, 0, 0, 0, 'Botham II f', 9, 26, 44000, 1650, 1, 4, 44, 0, 0),
(676, 0, 0, 0, 0, 0, 'Botham II d', 9, 32, 49000, 1950, 1, 4, 49, 0, 0),
(677, 0, 0, 0, 0, 0, 'Botham II c', 9, 17, 38000, 1250, 2, 4, 38, 0, 0),
(678, 0, 0, 0, 0, 0, 'Botham II b', 9, 26, 47000, 1600, 2, 4, 47, 0, 0),
(679, 0, 0, 0, 0, 0, 'Botham II a', 9, 14, 25000, 850, 1, 2, 25, 0, 0),
(680, 0, 0, 0, 0, 0, 'Botham III g', 9, 26, 42000, 1650, 1, 4, 42, 0, 0),
(681, 0, 0, 0, 0, 0, 'Botham III f', 9, 36, 56000, 2350, 1, 6, 56, 0, 0),
(682, 0, 0, 0, 0, 0, 'Botham III h', 9, 64, 98000, 3750, 3, 6, 98, 0, 0),
(683, 0, 0, 0, 0, 0, 'Botham III d', 9, 14, 27000, 850, 1, 2, 27, 0, 0),
(684, 0, 0, 0, 0, 0, 'Botham III e', 9, 15, 27000, 850, 1, 2, 27, 0, 0),
(685, 0, 0, 0, 0, 0, 'Botham III b', 9, 12, 25000, 950, 1, 4, 25, 0, 0),
(686, 0, 0, 0, 0, 0, 'Botham III c', 9, 14, 27000, 850, 1, 2, 27, 0, 0),
(687, 0, 0, 0, 0, 0, 'Botham III a', 9, 22, 36000, 1400, 1, 4, 36, 0, 0),
(688, 0, 0, 0, 0, 0, 'Botham IV i', 9, 26, 51000, 1800, 2, 6, 51, 0, 0),
(689, 0, 0, 0, 0, 0, 'Botham IV h', 9, 34, 49000, 1850, 1, 2, 49, 0, 0),
(690, 0, 0, 0, 0, 0, 'Botham IV f', 9, 26, 49000, 1700, 2, 4, 49, 0, 0),
(691, 0, 0, 0, 0, 0, 'Botham IV g', 9, 24, 49000, 1650, 3, 4, 49, 0, 0),
(692, 0, 0, 0, 0, 0, 'Botham IV c', 9, 14, 27000, 850, 1, 2, 27, 0, 0),
(693, 0, 0, 0, 0, 0, 'Botham IV e', 9, 14, 27000, 850, 1, 2, 27, 0, 0),
(694, 0, 0, 0, 0, 0, 'Botham IV d', 9, 14, 27000, 850, 1, 2, 27, 0, 0),
(695, 0, 0, 0, 0, 0, 'Botham IV b', 9, 14, 25000, 850, 1, 2, 25, 0, 0),
(696, 0, 0, 0, 0, 0, 'Botham IV a', 9, 22, 36000, 1400, 1, 4, 36, 0, 0),
(697, 0, 0, 0, 0, 0, 'Ramen Tah', 9, 90, 182000, 7650, 4, 32, 182, 0, 0),
(698, 0, 0, 0, 0, 0, 'Banana Bay 1', 8, 7, 25000, 450, 1, 2, 25, 0, 0),
(699, 0, 0, 0, 0, 0, 'Banana Bay 2', 8, 14, 36000, 765, 1, 2, 36, 0, 0),
(700, 0, 0, 0, 0, 0, 'Banana Bay 3', 8, 7, 25000, 450, 1, 2, 25, 0, 0),
(701, 0, 0, 0, 0, 0, 'Banana Bay 4', 8, 7, 25000, 450, 1, 2, 25, 0, 0),
(702, 0, 0, 0, 0, 0, 'Shark Manor', 8, 127, 286000, 8780, 8, 30, 286, 0, 0),
(703, 0, 0, 0, 0, 0, 'Coconut Quay 1', 8, 32, 64000, 1765, 1, 4, 64, 0, 0),
(704, 0, 0, 0, 0, 0, 'Coconut Quay 2', 8, 16, 42000, 1045, 1, 4, 42, 0, 0),
(705, 0, 0, 0, 0, 0, 'Coconut Quay 3', 8, 32, 70000, 2145, 1, 8, 70, 0, 0),
(706, 0, 0, 0, 0, 0, 'Coconut Quay 4', 8, 36, 72000, 2135, 1, 6, 72, 0, 0),
(707, 0, 0, 0, 0, 0, 'Crocodile Bridge 3', 8, 22, 49000, 1270, 1, 4, 49, 0, 0),
(708, 0, 0, 0, 0, 0, 'Crocodile Bridge 2', 8, 12, 36000, 865, 1, 4, 36, 0, 0),
(709, 0, 0, 0, 0, 0, 'Crocodile Bridge 1', 8, 17, 42000, 1045, 1, 4, 42, 0, 0),
(710, 0, 0, 0, 0, 0, 'Bamboo Garden 1', 8, 25, 63000, 1640, 2, 6, 63, 0, 0),
(711, 0, 0, 0, 0, 0, 'Crocodile Bridge 4', 8, 88, 176000, 4755, 3, 8, 176, 0, 0),
(712, 0, 0, 0, 0, 0, 'Crocodile Bridge 5', 8, 80, 157000, 3970, 2, 4, 157, 0, 0),
(713, 0, 0, 0, 0, 0, 'Woodway 1', 8, 14, 36000, 765, 1, 2, 36, 0, 0),
(714, 0, 0, 0, 0, 0, 'Woodway 2', 8, 11, 30000, 585, 1, 2, 30, 0, 0),
(715, 0, 0, 0, 0, 0, 'Woodway 3', 8, 27, 65000, 1540, 2, 4, 65, 0, 0),
(716, 0, 0, 0, 0, 0, 'Woodway 4', 8, 6, 24000, 405, 1, 2, 24, 0, 0),
(717, 0, 0, 0, 0, 0, 'Flamingo Flats 5', 8, 38, 84000, 1845, 1, 2, 84, 0, 0),
(718, 0, 0, 0, 0, 0, 'Bamboo Fortress', 8, 381, 848000, 21970, 14, 40, 848, 0, 0),
(719, 0, 0, 0, 0, 0, 'Bamboo Garden 3', 8, 27, 63000, 1540, 2, 4, 63, 0, 0),
(720, 0, 0, 0, 0, 0, 'Bamboo Garden 2', 8, 16, 42000, 1045, 1, 4, 42, 0, 0),
(721, 0, 0, 0, 0, 0, 'Flamingo Flats 4', 8, 12, 36000, 865, 1, 4, 36, 0, 0),
(722, 0, 0, 0, 0, 0, 'Flamingo Flats 2', 8, 16, 42000, 1045, 1, 4, 42, 0, 0),
(723, 0, 0, 0, 0, 0, 'Flamingo Flats 3', 8, 8, 30000, 685, 1, 4, 30, 0, 0),
(724, 0, 0, 0, 0, 0, 'Flamingo Flats 1', 8, 8, 30000, 685, 1, 4, 30, 0, 0),
(725, 0, 0, 0, 0, 0, 'Jungle Edge 4', 8, 12, 36000, 865, 1, 4, 36, 0, 0),
(726, 0, 0, 0, 0, 0, 'Jungle Edge 5', 8, 12, 36000, 865, 1, 4, 36, 0, 0),
(727, 0, 0, 0, 0, 0, 'Jungle Edge 6', 8, 7, 25000, 450, 1, 2, 25, 0, 0),
(728, 0, 0, 0, 0, 0, 'Jungle Edge 2', 8, 59, 128000, 3170, 3, 6, 128, 0, 0),
(729, 0, 0, 0, 0, 0, 'Jungle Edge 3', 8, 12, 36000, 865, 1, 4, 36, 0, 0),
(730, 0, 0, 0, 0, 0, 'Jungle Edge 1', 8, 44, 98000, 2495, 1, 6, 98, 0, 0),
(731, 0, 0, 0, 0, 0, 'Haggler''s Hangout 6', 8, 113, 208000, 6450, 3, 8, 208, 0, 0),
(732, 0, 0, 0, 0, 0, 'Haggler''s Hangout 5 (Shop)', 8, 24, 56000, 1550, 1, 2, 56, 0, 0),
(733, 0, 0, 0, 0, 0, 'Haggler''s Hangout 4a (Shop)', 8, 30, 56000, 1850, 2, 2, 56, 0, 0),
(734, 0, 0, 0, 0, 0, 'Haggler''s Hangout 4b (Shop)', 8, 24, 56000, 1550, 2, 2, 56, 0, 0),
(735, 0, 0, 0, 0, 0, 'Haggler''s Hangout 3', 8, 137, 256000, 7550, 1, 8, 256, 0, 0),
(736, 0, 0, 0, 0, 0, 'Haggler''s Hangout 2', 8, 23, 49000, 1300, 1, 2, 49, 0, 0),
(737, 0, 0, 0, 0, 0, 'Haggler''s Hangout 1', 8, 22, 49000, 1400, 1, 4, 49, 0, 0),
(738, 0, 0, 0, 0, 0, 'River Homes 1', 8, 66, 128000, 3485, 1, 6, 128, 0, 0),
(739, 0, 0, 0, 0, 0, 'River Homes 2a', 8, 21, 42000, 1270, 1, 4, 42, 0, 0),
(740, 0, 0, 0, 0, 0, 'River Homes 2b', 8, 24, 56000, 1595, 1, 6, 56, 0, 0),
(741, 0, 0, 0, 0, 0, 'River Homes 3', 8, 82, 176000, 5055, 3, 14, 176, 0, 0),
(742, 0, 0, 0, 0, 0, 'The Treehouse', 8, 484, 897000, 24120, 5, 46, 897, 0, 0),
(743, 0, 0, 0, 0, 0, 'Corner Shop (Shop)', 12, 36, 96000, 2215, 3, 4, 96, 0, 0),
(744, 0, 0, 0, 0, 0, 'Tusk Flats 1', 12, 14, 40000, 765, 1, 4, 40, 0, 0),
(745, 0, 0, 0, 0, 0, 'Tusk Flats 2', 12, 16, 42000, 835, 1, 4, 42, 0, 0),
(746, 0, 0, 0, 0, 0, 'Tusk Flats 3', 12, 11, 34000, 660, 1, 4, 34, 0, 0),
(747, 0, 0, 0, 0, 0, 'Tusk Flats 4', 12, 6, 24000, 315, 1, 2, 24, 0, 0),
(748, 0, 0, 0, 0, 0, 'Tusk Flats 6', 12, 12, 35000, 660, 1, 4, 35, 0, 0),
(749, 0, 0, 0, 0, 0, 'Tusk Flats 5', 12, 11, 30000, 455, 1, 2, 30, 0, 0),
(750, 0, 0, 0, 0, 0, 'Shady Rocks 5', 12, 57, 110000, 2890, 3, 4, 110, 0, 0),
(751, 0, 0, 0, 0, 0, 'Shady Rocks 4 (Shop)', 12, 50, 110000, 2710, 4, 4, 110, 0, 0),
(752, 0, 0, 0, 0, 0, 'Shady Rocks 3', 12, 77, 154000, 4115, 4, 6, 154, 0, 0),
(753, 0, 0, 0, 0, 0, 'Shady Rocks 2', 12, 29, 77000, 2010, 3, 8, 77, 0, 0),
(754, 0, 0, 0, 0, 0, 'Shady Rocks 1', 12, 65, 132000, 3630, 3, 8, 132, 0, 0),
(755, 0, 0, 0, 0, 0, 'Crystal Glance', 12, 237, 569000, 19625, 11, 48, 569, 0, 0),
(756, 0, 0, 0, 0, 0, 'Arena Walk 3', 12, 59, 126000, 3550, 2, 6, 126, 0, 0),
(757, 0, 0, 0, 0, 0, 'Arena Walk 2', 12, 21, 54000, 1400, 2, 4, 54, 0, 0),
(758, 0, 0, 0, 0, 0, 'Arena Walk 1', 12, 55, 128000, 3250, 4, 6, 128, 0, 0),
(759, 0, 0, 0, 0, 0, 'Bears Paw 2', 12, 44, 100000, 2305, 3, 4, 100, 0, 0),
(760, 0, 0, 0, 0, 0, 'Bears Paw 1', 12, 33, 72000, 1810, 2, 4, 72, 0, 0),
(761, 0, 0, 0, 0, 0, 'Spirit Homes 5', 12, 21, 56000, 1450, 2, 4, 56, 0, 0),
(762, 0, 0, 0, 0, 0, 'Glacier Side 3', 12, 30, 75000, 1950, 3, 4, 75, 0, 0),
(763, 0, 0, 0, 0, 0, 'Glacier Side 2', 12, 83, 154000, 4750, 3, 6, 154, 0, 0),
(764, 0, 0, 0, 0, 0, 'Glacier Side 1', 12, 26, 65000, 1600, 3, 4, 65, 0, 0),
(765, 0, 0, 0, 0, 0, 'Spirit Homes 1', 12, 27, 56000, 1700, 2, 4, 56, 0, 0),
(766, 0, 0, 0, 0, 0, 'Spirit Homes 2', 12, 31, 72000, 1900, 3, 4, 72, 0, 0),
(767, 0, 0, 0, 0, 0, 'Spirit Homes 3', 12, 75, 128000, 4250, 3, 6, 128, 0, 0),
(768, 0, 0, 0, 0, 0, 'Spirit Homes 4', 12, 19, 49000, 1100, 2, 2, 49, 0, 0),
(770, 0, 0, 0, 0, 0, 'Glacier Side 4', 12, 38, 75000, 2050, 2, 2, 75, 0, 0),
(771, 0, 0, 0, 0, 0, 'Shelf Site', 12, 83, 160000, 4800, 4, 6, 160, 0, 0),
(772, 0, 0, 0, 0, 0, 'Raven Corner 1', 12, 15, 45000, 855, 2, 2, 45, 0, 0),
(773, 0, 0, 0, 0, 0, 'Raven Corner 2', 12, 25, 60000, 1685, 3, 6, 60, 0, 0),
(774, 0, 0, 0, 0, 0, 'Raven Corner 3', 12, 15, 45000, 855, 2, 2, 45, 0, 0),
(775, 0, 0, 0, 0, 0, 'Bears Paw 3', 12, 35, 82000, 2090, 3, 6, 82, 0, 0),
(776, 0, 0, 0, 0, 0, 'Bears Paw 4', 12, 99, 189000, 5205, 5, 8, 189, 0, 0),
(778, 0, 0, 0, 0, 0, 'Bears Paw 5', 12, 34, 81000, 2045, 3, 6, 81, 0, 0),
(779, 0, 0, 0, 0, 0, 'Trout Plaza 5 (Shop)', 12, 73, 144000, 3880, 4, 4, 144, 0, 0),
(780, 0, 0, 0, 0, 0, 'Pilchard Bin 1', 12, 8, 30000, 685, 1, 4, 30, 0, 0),
(781, 0, 0, 0, 0, 0, 'Pilchard Bin 2', 12, 8, 24000, 685, 1, 4, 24, 0, 0),
(782, 0, 0, 0, 0, 0, 'Pilchard Bin 3', 12, 10, 24000, 585, 1, 2, 24, 0, 0),
(783, 0, 0, 0, 0, 0, 'Pilchard Bin 4', 12, 10, 24000, 585, 1, 2, 24, 0, 0),
(784, 0, 0, 0, 0, 0, 'Pilchard Bin 5', 12, 8, 24000, 685, 1, 4, 24, 0, 0),
(785, 0, 0, 0, 0, 0, 'Pilchard Bin 10', 12, 7, 20000, 450, 1, 2, 20, 0, 0),
(786, 0, 0, 0, 0, 0, 'Pilchard Bin 9', 12, 7, 20000, 450, 1, 2, 20, 0, 0),
(787, 0, 0, 0, 0, 0, 'Pilchard Bin 8', 12, 6, 20000, 450, 1, 4, 20, 0, 0),
(789, 0, 0, 0, 0, 0, 'Pilchard Bin 7', 12, 7, 20000, 450, 1, 2, 20, 0, 0),
(790, 0, 0, 0, 0, 0, 'Pilchard Bin 6', 12, 7, 25000, 450, 1, 2, 25, 0, 0),
(791, 0, 0, 0, 0, 0, 'Trout Plaza 1', 12, 43, 112000, 2395, 4, 4, 112, 0, 0),
(792, 0, 0, 0, 0, 0, 'Trout Plaza 2', 12, 26, 64000, 1540, 2, 4, 64, 0, 0),
(793, 0, 0, 0, 0, 0, 'Trout Plaza 3', 12, 18, 36000, 900, 2, 2, 36, 0, 0),
(794, 0, 0, 0, 0, 0, 'Trout Plaza 4', 12, 18, 45000, 900, 2, 2, 45, 0, 0),
(795, 0, 0, 0, 0, 0, 'Skiffs End 1', 12, 28, 70000, 1540, 3, 4, 70, 0, 0),
(796, 0, 0, 0, 0, 0, 'Skiffs End 2', 12, 13, 42000, 910, 2, 4, 42, 0, 0),
(797, 0, 0, 0, 0, 0, 'Furrier Quarter 3', 12, 20, 54000, 1010, 2, 4, 54, 0, 0),
(798, 0, 0, 0, 0, 0, 'Mammoth Belly', 12, 278, 634000, 22810, 15, 60, 634, 0, 0),
(799, 0, 0, 0, 0, 0, 'Furrier Quarter 2', 12, 21, 56000, 1045, 2, 4, 56, 0, 0),
(800, 0, 0, 0, 0, 0, 'Furrier Quarter 1', 12, 34, 84000, 1635, 3, 6, 84, 0, 0),
(801, 0, 0, 0, 0, 0, 'Fimbul Shelf 3', 12, 28, 66000, 1255, 2, 4, 66, 0, 0),
(802, 0, 0, 0, 0, 0, 'Fimbul Shelf 4', 12, 22, 56000, 1045, 2, 4, 56, 0, 0),
(803, 0, 0, 0, 0, 0, 'Fimbul Shelf 2', 12, 21, 56000, 1045, 2, 4, 56, 0, 0),
(804, 0, 0, 0, 0, 0, 'Fimbul Shelf 1', 12, 20, 48000, 975, 1, 4, 48, 0, 0),
(805, 0, 0, 0, 0, 0, 'Frost Manor', 12, 382, 806000, 26370, 16, 48, 806, 0, 0),
(806, 0, 0, 0, 0, 0, 'Lower Barracks 11', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(807, 0, 0, 0, 0, 0, 'Lower Barracks 12', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(808, 0, 0, 0, 0, 0, 'Lower Barracks 9', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(809, 0, 0, 0, 0, 0, 'Lower Barracks 10', 3, 7, 19000, 300, 1, 2, 19, 0, 0),
(810, 0, 0, 0, 0, 0, 'Lower Barracks 7', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(811, 0, 0, 0, 0, 0, 'Lower Barracks 8', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(812, 0, 0, 0, 0, 0, 'Lower Barracks 5', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(813, 0, 0, 0, 0, 0, 'Lower Barracks 6', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(814, 0, 0, 0, 0, 0, 'Lower Barracks 3', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(815, 0, 0, 0, 0, 0, 'Lower Barracks 4', 3, 7, 19000, 300, 1, 2, 19, 0, 0),
(816, 0, 0, 0, 0, 0, 'Lower Barracks 1', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(817, 0, 0, 0, 0, 0, 'Lower Barracks 2', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(818, 0, 0, 0, 0, 0, 'Lower Barracks 24', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(819, 0, 0, 0, 0, 0, 'Lower Barracks 23', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(820, 0, 0, 0, 0, 0, 'Lower Barracks 22', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(821, 0, 0, 0, 0, 0, 'Lower Barracks 21', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(822, 0, 0, 0, 0, 0, 'Lower Barracks 20', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(823, 0, 0, 0, 0, 0, 'Lower Barracks 19', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(824, 0, 0, 0, 0, 0, 'Lower Barracks 18', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(825, 0, 0, 0, 0, 0, 'Lower Barracks 17', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(826, 0, 0, 0, 0, 0, 'Lower Barracks 16', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(828, 0, 0, 0, 0, 0, 'Lower Barracks 15', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(829, 0, 0, 0, 0, 0, 'Lower Barracks 14', 3, 7, 20000, 300, 1, 2, 20, 0, 0),
(830, 0, 0, 0, 0, 0, 'Lower Barracks 13', 3, 7, 16000, 300, 1, 2, 16, 0, 0),
(831, 0, 0, 0, 0, 0, 'Marble Guildhall', 3, 282, 540000, 16810, 18, 34, 540, 0, 0),
(832, 0, 0, 0, 0, 0, 'Iron Guildhall', 3, 243, 464000, 15560, 15, 34, 464, 0, 0),
(833, 0, 0, 0, 0, 0, 'The Market 1 (Shop)', 3, 8, 25000, 650, 1, 2, 25, 0, 0),
(834, 0, 0, 0, 0, 0, 'The Market 3 (Shop)', 3, 22, 40000, 1450, 1, 2, 40, 0, 0),
(835, 0, 0, 0, 0, 0, 'The Market 2 (Shop)', 3, 17, 40000, 1100, 1, 2, 40, 0, 0),
(836, 0, 0, 0, 0, 0, 'The Market 4 (Shop)', 3, 28, 48000, 1800, 1, 2, 48, 0, 0),
(837, 0, 0, 0, 0, 0, 'Granite Guildhall', 3, 296, 589000, 17845, 18, 34, 589, 0, 0),
(838, 0, 0, 0, 0, 0, 'Upper Barracks 1', 3, 4, 20000, 210, 1, 2, 20, 0, 0),
(839, 0, 0, 0, 0, 0, 'Upper Barracks 2', 3, 4, 15000, 210, 1, 2, 15, 0, 0),
(840, 0, 0, 0, 0, 0, 'Upper Barracks 3', 3, 4, 15000, 210, 1, 2, 15, 0, 0),
(841, 0, 0, 0, 0, 0, 'Upper Barracks 4', 3, 4, 15000, 210, 1, 2, 15, 0, 0),
(842, 0, 0, 0, 0, 0, 'Upper Barracks 5', 3, 4, 12000, 210, 1, 2, 12, 0, 0),
(843, 0, 0, 0, 0, 0, 'Upper Barracks 6', 3, 4, 12000, 210, 1, 2, 12, 0, 0),
(844, 0, 0, 0, 0, 0, 'Upper Barracks 7', 3, 4, 16000, 210, 1, 2, 16, 0, 0),
(845, 0, 0, 0, 0, 0, 'Upper Barracks 8', 3, 4, 20000, 210, 1, 2, 20, 0, 0),
(847, 0, 0, 0, 0, 0, 'Upper Barracks 10', 3, 4, 15000, 210, 1, 2, 15, 0, 0),
(848, 0, 0, 0, 0, 0, 'Upper Barracks 11', 3, 4, 15000, 210, 1, 2, 15, 0, 0),
(849, 0, 0, 0, 0, 0, 'Upper Barracks 12', 3, 4, 16000, 210, 1, 2, 16, 0, 0),
(850, 0, 0, 0, 0, 0, 'Upper Barracks 13', 3, 11, 24000, 580, 1, 4, 24, 0, 0),
(851, 0, 0, 0, 0, 0, 'Nobility Quarter 4', 3, 14, 25000, 765, 1, 2, 25, 0, 0),
(852, 0, 0, 0, 0, 0, 'Nobility Quarter 5', 3, 15, 25000, 765, 1, 2, 25, 0, 0),
(853, 0, 0, 0, 0, 0, 'Nobility Quarter 7', 3, 14, 30000, 765, 1, 2, 30, 0, 0),
(854, 0, 0, 0, 0, 0, 'Nobility Quarter 6', 3, 14, 30000, 765, 1, 2, 30, 0, 0),
(855, 0, 0, 0, 0, 0, 'Nobility Quarter 8', 3, 14, 30000, 765, 1, 2, 30, 0, 0),
(856, 0, 0, 0, 0, 0, 'Nobility Quarter 9', 3, 14, 30000, 765, 1, 2, 30, 0, 0),
(857, 0, 0, 0, 0, 0, 'Nobility Quarter 2', 3, 30, 56000, 1865, 1, 6, 56, 0, 0),
(858, 0, 0, 0, 0, 0, 'Nobility Quarter 3', 3, 30, 56000, 1865, 1, 6, 56, 0, 0),
(859, 0, 0, 0, 0, 0, 'Nobility Quarter 1', 3, 30, 62000, 1865, 1, 6, 62, 0, 0),
(863, 0, 0, 0, 0, 0, 'The Farms 6, Fishing Hut', 3, 16, 36000, 1255, 1, 4, 36, 0, 0),
(864, 0, 0, 0, 0, 0, 'The Farms 5', 3, 21, 36000, 1530, 1, 4, 36, 0, 0),
(865, 0, 0, 0, 0, 0, 'The Farms 4', 3, 21, 36000, 1530, 1, 4, 36, 0, 0),
(866, 0, 0, 0, 0, 0, 'The Farms 3', 3, 21, 36000, 1530, 1, 4, 36, 0, 0),
(867, 0, 0, 0, 0, 0, 'The Farms 2', 3, 21, 36000, 1530, 1, 4, 36, 0, 0),
(868, 0, 0, 0, 0, 0, 'The Farms 1', 3, 34, 60000, 2510, 2, 6, 60, 0, 0),
(869, 0, 0, 0, 0, 0, 'Outlaw Camp 12 (Shop)', 3, 6, 12000, 280, 0, 0, 12, 0, 0),
(870, 0, 0, 0, 0, 0, 'Outlaw Camp 13 (Shop)', 3, 6, 12000, 280, 0, 0, 12, 0, 0),
(871, 0, 0, 0, 0, 0, 'Outlaw Camp 14 (Shop)', 3, 16, 30000, 640, 0, 0, 30, 0, 0),
(872, 0, 0, 0, 0, 0, 'Outlaw Camp 7', 3, 12, 38000, 780, 1, 4, 38, 0, 0),
(874, 0, 0, 0, 0, 0, 'Outlaw Camp 8', 3, 5, 20000, 280, 1, 2, 20, 0, 0),
(877, 0, 0, 0, 0, 0, 'Outlaw Camp 9', 3, 3, 12000, 200, 1, 2, 12, 0, 0),
(878, 0, 0, 0, 0, 0, 'Outlaw Camp 10', 3, 2, 12000, 200, 1, 2, 12, 0, 0),
(879, 0, 0, 0, 0, 0, 'Outlaw Camp 11', 3, 2, 16000, 200, 1, 2, 16, 0, 0),
(880, 0, 0, 0, 0, 0, 'Outlaw Camp 2', 3, 4, 20000, 280, 1, 2, 20, 0, 0),
(881, 0, 0, 0, 0, 0, 'Outlaw Camp 3', 3, 11, 35000, 740, 1, 4, 35, 0, 0),
(882, 0, 0, 0, 0, 0, 'Outlaw Camp 4', 3, 2, 12000, 200, 1, 2, 12, 0, 0),
(883, 0, 0, 0, 0, 0, 'Outlaw Camp 5', 3, 2, 12000, 200, 1, 2, 12, 0, 0),
(884, 0, 0, 0, 0, 0, 'Outlaw Camp 6', 3, 2, 16000, 200, 1, 2, 16, 0, 0),
(885, 0, 0, 0, 0, 0, 'Outlaw Camp 1', 3, 46, 91000, 1660, 1, 4, 91, 0, 0),
(886, 0, 0, 0, 0, 0, 'Outlaw Castle', 3, 158, 410000, 8000, 11, 18, 410, 0, 0),
(888, 0, 0, 0, 0, 0, 'Tunnel Gardens 1', 3, 20, 44000, 1820, 1, 6, 44, 0, 0),
(889, 0, 0, 0, 0, 0, 'Tunnel Gardens 3', 3, 23, 48000, 2000, 1, 6, 48, 0, 0),
(890, 0, 0, 0, 0, 0, 'Tunnel Gardens 4', 3, 24, 45000, 2000, 1, 6, 45, 0, 0),
(891, 0, 0, 0, 0, 0, 'Tunnel Gardens 2', 3, 20, 47000, 1820, 1, 6, 47, 0, 0),
(892, 0, 0, 0, 0, 0, 'Tunnel Gardens 5', 3, 16, 35000, 1360, 1, 4, 35, 0, 0),
(893, 0, 0, 0, 0, 0, 'Tunnel Gardens 6', 3, 16, 38000, 1360, 1, 4, 38, 0, 0),
(894, 0, 0, 0, 0, 0, 'Tunnel Gardens 8', 3, 16, 35000, 1360, 1, 4, 35, 0, 0),
(895, 0, 0, 0, 0, 0, 'Tunnel Gardens 7', 3, 16, 35000, 1360, 1, 4, 35, 0, 0),
(896, 0, 0, 0, 0, 0, 'Tunnel Gardens 12', 3, 11, 24000, 1060, 1, 4, 24, 0, 0),
(897, 0, 0, 0, 0, 0, 'Tunnel Gardens 11', 3, 11, 32000, 1060, 1, 4, 32, 0, 0),
(898, 0, 0, 0, 0, 0, 'Tunnel Gardens 9', 3, 10, 29000, 1000, 1, 4, 29, 0, 0),
(899, 0, 0, 0, 0, 0, 'Tunnel Gardens 10', 3, 10, 29000, 1000, 1, 4, 29, 0, 0),
(900, 0, 0, 0, 0, 0, 'Wolftower', 3, 316, 699000, 21550, 19, 46, 699, 0, 0),
(901, 0, 0, 0, 0, 0, 'Paupers Palace, Flat 11', 1, 4, 14000, 315, 1, 2, 14, 0, 0),
(902, 0, 0, 0, 0, 0, 'Upper Barracks 9', 3, 4, 15000, 210, 1, 2, 15, 0, 0),
(905, 0, 0, 0, 0, 0, 'Botham I a', 9, 21, 36000, 950, 1, 2, 36, 0, 0),
(906, 0, 0, 0, 0, 0, 'Esuph I', 9, 18, 39000, 680, 1, 2, 39, 0, 0),
(907, 0, 0, 0, 0, 0, 'Esuph II b', 9, 26, 51000, 1380, 2, 4, 51, 0, 0),
(1883, 0, 0, 0, 0, 0, 'Aureate Court 1', 13, 116, 276000, 5240, 7, 6, 276, 0, 0),
(1884, 0, 0, 0, 0, 0, 'Aureate Court 2', 13, 120, 198000, 4860, 2, 4, 198, 0, 0),
(1885, 0, 0, 0, 0, 0, 'Aureate Court 3', 13, 115, 226000, 4300, 4, 4, 226, 0, 0),
(1886, 0, 0, 0, 0, 0, 'Aureate Court 4', 13, 82, 208000, 3980, 5, 8, 208, 0, 0),
(1887, 0, 0, 0, 0, 0, 'Fortune Wing 1', 13, 237, 420000, 10180, 4, 8, 420, 0, 0),
(1888, 0, 0, 0, 0, 0, 'Fortune Wing 2', 13, 130, 260000, 5580, 5, 4, 260, 0, 0),
(1889, 0, 0, 0, 0, 0, 'Fortune Wing 3', 13, 135, 258000, 5740, 4, 4, 258, 0, 0),
(1890, 0, 0, 0, 0, 0, 'Fortune Wing 4', 13, 129, 305000, 5740, 4, 8, 305, 0, 0),
(1891, 0, 0, 0, 0, 0, 'Luminous Arc 1', 13, 147, 344000, 6460, 8, 4, 344, 0, 0),
(1892, 0, 0, 0, 0, 0, 'Luminous Arc 2', 13, 145, 301000, 6460, 3, 8, 301, 0, 0),
(1893, 0, 0, 0, 0, 0, 'Luminous Arc 3', 13, 121, 249000, 5400, 6, 6, 249, 0, 0),
(1894, 0, 0, 0, 0, 0, 'Luminous Arc 4', 13, 175, 343000, 8000, 7, 10, 343, 0, 0),
(1895, 0, 0, 0, 0, 0, 'Radiant Plaza 1', 13, 123, 276000, 5620, 5, 8, 276, 0, 0),
(1896, 0, 0, 0, 0, 0, 'Radiant Plaza 2', 13, 87, 179000, 3820, 2, 4, 179, 0, 0),
(1897, 0, 0, 0, 0, 0, 'Radiant Plaza 3', 13, 114, 256000, 4900, 4, 4, 256, 0, 0),
(1898, 0, 0, 0, 0, 0, 'Radiant Plaza 4', 13, 178, 367000, 7460, 4, 6, 367, 0, 0),
(1899, 0, 0, 0, 0, 0, 'Sun Palace', 13, 460, 974000, 23120, 12, 54, 974, 0, 0),
(1900, 0, 0, 0, 0, 0, 'Halls of Serenity', 13, 432, 1090000, 23360, 21, 66, 1090, 0, 0),
(1901, 0, 0, 0, 0, 0, 'Cascade Towers', 13, 315, 810000, 19500, 24, 66, 810, 0, 0),
(1902, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue 5', 2, 42, 96000, 2695, 2, 2, 96, 0, 0),
(1903, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue 1a', 2, 16, 42000, 1255, 1, 4, 42, 0, 0),
(1904, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue 1b', 2, 12, 36000, 1035, 1, 4, 36, 0, 0),
(1905, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue 1c', 2, 16, 36000, 1255, 1, 4, 36, 0, 0),
(1906, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 06', 2, 14, 40000, 1145, 1, 4, 40, 0, 0),
(1907, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 01', 2, 10, 30000, 715, 1, 2, 30, 0, 0),
(1908, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 02', 2, 10, 25000, 715, 1, 2, 25, 0, 0),
(1909, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 03', 2, 10, 30000, 715, 1, 2, 30, 0, 0),
(1910, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 04', 2, 10, 24000, 715, 1, 2, 24, 0, 0),
(1911, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 05', 2, 10, 24000, 715, 1, 2, 24, 0, 0),
(1912, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 16', 2, 14, 40000, 1145, 1, 4, 40, 0, 0),
(1913, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 11', 2, 10, 30000, 715, 1, 2, 30, 0, 0),
(1914, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 12', 2, 13, 30000, 880, 1, 2, 30, 0, 0),
(1915, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 13', 2, 13, 29000, 880, 1, 2, 29, 0, 0),
(1916, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 14', 2, 4, 15000, 385, 1, 2, 15, 0, 0),
(1917, 0, 0, 0, 0, 0, 'Beach Home Apartments, Flat 15', 2, 4, 15000, 385, 1, 2, 15, 0, 0),
(1918, 0, 0, 0, 0, 0, 'Thais Clanhall', 2, 154, 370000, 8420, 12, 20, 370, 0, 0),
(1919, 0, 0, 0, 0, 0, 'Harbour Street 4', 2, 14, 30000, 935, 1, 2, 30, 0, 0),
(1920, 0, 0, 0, 0, 0, 'Thais Hostel', 2, 63, 171000, 6980, 3, 48, 171, 0, 0),
(1921, 0, 0, 0, 0, 0, 'Lower Swamp Lane 1', 2, 62, 166000, 4740, 7, 8, 166, 0, 0),
(1923, 0, 0, 0, 0, 0, 'Lower Swamp Lane 3', 2, 62, 161000, 4740, 7, 8, 161, 0, 0),
(1924, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 01', 2, 10, 25000, 520, 1, 2, 25, 0, 0),
(1925, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 02', 2, 10, 30000, 520, 1, 2, 30, 0, 0),
(1926, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 03', 2, 10, 30000, 520, 1, 2, 30, 0, 0),
(1927, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 14', 2, 10, 30000, 520, 1, 2, 30, 0, 0),
(1929, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 13', 2, 15, 35000, 860, 1, 4, 35, 0, 0),
(1930, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 12', 2, 10, 25000, 520, 1, 2, 25, 0, 0),
(1932, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 11', 2, 10, 25000, 520, 1, 2, 25, 0, 0),
(1935, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 24', 2, 10, 30000, 520, 1, 2, 30, 0, 0),
(1936, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 23', 2, 14, 35000, 860, 1, 4, 35, 0, 0),
(1937, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 22', 2, 10, 25000, 520, 1, 2, 25, 0, 0),
(1938, 0, 0, 0, 0, 0, 'Sunset Homes, Flat 21', 2, 10, 25000, 520, 1, 2, 25, 0, 0),
(1939, 0, 0, 0, 0, 0, 'Harbour Place 1 (Shop)', 2, 16, 48000, 1100, 2, 0, 48, 0, 0),
(1940, 0, 0, 0, 0, 0, 'Harbour Place 2 (Shop)', 2, 19, 48000, 1300, 2, 2, 48, 0, 0),
(1941, 0, 0, 0, 0, 0, 'Warriors Guildhall', 2, 255, 523000, 14725, 15, 22, 523, 0, 0),
(1942, 0, 0, 0, 0, 0, 'Farm Lane, 1st floor (Shop)', 2, 15, 42000, 945, 1, 0, 42, 0, 0),
(1943, 0, 0, 0, 0, 0, 'Farm Lane, Basement (Shop)', 2, 15, 36000, 945, 1, 0, 36, 0, 0),
(1944, 0, 0, 0, 0, 0, 'Main Street 9, 1st floor (Shop)', 2, 24, 47000, 1440, 2, 0, 47, 0, 0),
(1945, 0, 0, 0, 0, 0, 'Main Street 9a, 2nd floor (Shop)', 2, 12, 30000, 765, 1, 0, 30, 0, 0),
(1946, 0, 0, 0, 0, 0, 'Main Street 9b, 2nd floor (Shop)', 2, 23, 48000, 1260, 2, 0, 48, 0, 0),
(1947, 0, 0, 0, 0, 0, 'Farm Lane, 2nd Floor (Shop)', 2, 15, 42000, 945, 1, 0, 42, 0, 0),
(1948, 0, 0, 0, 0, 0, 'The City Wall 5a', 2, 10, 24000, 585, 1, 2, 24, 0, 0),
(1949, 0, 0, 0, 0, 0, 'The City Wall 5c', 2, 10, 24000, 585, 1, 2, 24, 0, 0),
(1950, 0, 0, 0, 0, 0, 'The City Wall 5e', 2, 10, 30000, 585, 1, 2, 30, 0, 0),
(1951, 0, 0, 0, 0, 0, 'The City Wall 5b', 2, 10, 24000, 585, 1, 2, 24, 0, 0),
(1952, 0, 0, 0, 0, 0, 'The City Wall 5d', 2, 10, 24000, 585, 1, 2, 24, 0, 0),
(1953, 0, 0, 0, 0, 0, 'The City Wall 5f', 2, 10, 30000, 585, 1, 2, 30, 0, 0),
(1954, 0, 0, 0, 0, 0, 'The City Wall 3a', 2, 16, 42000, 1045, 1, 4, 42, 0, 0),
(1955, 0, 0, 0, 0, 0, 'The City Wall 3b', 2, 16, 35000, 1045, 1, 4, 35, 0, 0),
(1956, 0, 0, 0, 0, 0, 'The City Wall 3c', 2, 16, 35000, 1045, 1, 4, 35, 0, 0),
(1957, 0, 0, 0, 0, 0, 'The City Wall 3d', 2, 16, 42000, 1045, 1, 4, 42, 0, 0),
(1958, 0, 0, 0, 0, 0, 'The City Wall 3e', 2, 16, 35000, 1045, 1, 4, 35, 0, 0),
(1959, 0, 0, 0, 0, 0, 'The City Wall 3f', 2, 16, 35000, 1045, 1, 4, 35, 0, 0),
(1960, 0, 0, 0, 0, 0, 'The City Wall 1a', 2, 21, 49000, 1270, 1, 4, 49, 0, 0),
(1961, 0, 0, 0, 0, 0, 'Mill Avenue 3', 2, 21, 49000, 1400, 1, 4, 49, 0, 0),
(1962, 0, 0, 0, 0, 0, 'The City Wall 1b', 2, 21, 49000, 1270, 1, 4, 49, 0, 0),
(1963, 0, 0, 0, 0, 0, 'Mill Avenue 4', 2, 21, 49000, 1400, 1, 4, 49, 0, 0),
(1964, 0, 0, 0, 0, 0, 'Mill Avenue 5', 2, 49, 128000, 3250, 4, 8, 128, 0, 0),
(1965, 0, 0, 0, 0, 0, 'Mill Avenue 1 (Shop)', 2, 17, 54000, 1300, 2, 2, 54, 0, 0),
(1966, 0, 0, 0, 0, 0, 'Mill Avenue 2 (Shop)', 2, 38, 80000, 2350, 3, 4, 80, 0, 0),
(1967, 0, 0, 0, 0, 0, 'The City Wall 7c', 2, 12, 36000, 865, 1, 4, 36, 0, 0),
(1968, 0, 0, 0, 0, 0, 'The City Wall 7a', 2, 10, 30000, 585, 1, 2, 30, 0, 0),
(1969, 0, 0, 0, 0, 0, 'The City Wall 7e', 2, 12, 36000, 865, 1, 4, 36, 0, 0),
(1970, 0, 0, 0, 0, 0, 'The City Wall 7g', 2, 10, 30000, 585, 1, 2, 30, 0, 0),
(1971, 0, 0, 0, 0, 0, 'The City Wall 7d', 2, 12, 36000, 865, 1, 4, 36, 0, 0),
(1972, 0, 0, 0, 0, 0, 'The City Wall 7b', 2, 10, 30000, 585, 1, 2, 30, 0, 0),
(1973, 0, 0, 0, 0, 0, 'The City Wall 7f', 2, 12, 35000, 865, 1, 4, 35, 0, 0),
(1974, 0, 0, 0, 0, 0, 'The City Wall 7h', 2, 10, 30000, 585, 1, 2, 30, 0, 0),
(1975, 0, 0, 0, 0, 0, 'The City Wall 9', 2, 14, 50000, 955, 1, 4, 50, 0, 0),
(1976, 0, 0, 0, 0, 0, 'Upper Swamp Lane 12', 2, 46, 116000, 3800, 5, 6, 116, 0, 0),
(1977, 0, 0, 0, 0, 0, 'Upper Swamp Lane 10', 2, 25, 70000, 2060, 1, 6, 70, 0, 0),
(1978, 0, 0, 0, 0, 0, 'Upper Swamp Lane 8', 2, 124, 216000, 8120, 4, 6, 216, 0, 0),
(1979, 0, 0, 0, 0, 0, 'Southern Thais Guildhall', 2, 284, 596000, 22440, 20, 32, 596, 0, 0),
(1980, 0, 0, 0, 0, 0, 'Alai Flats, Flat 04', 2, 14, 30000, 765, 1, 2, 30, 0, 0),
(1981, 0, 0, 0, 0, 0, 'Alai Flats, Flat 05', 2, 20, 38000, 1225, 1, 4, 38, 0, 0),
(1982, 0, 0, 0, 0, 0, 'Alai Flats, Flat 06', 2, 20, 48000, 1225, 1, 4, 48, 0, 0),
(1983, 0, 0, 0, 0, 0, 'Alai Flats, Flat 07', 2, 14, 30000, 765, 1, 2, 30, 0, 0),
(1984, 0, 0, 0, 0, 0, 'Alai Flats, Flat 08', 2, 14, 30000, 765, 1, 2, 30, 0, 0),
(1985, 0, 0, 0, 0, 0, 'Alai Flats, Flat 03', 2, 14, 35000, 765, 1, 2, 35, 0, 0),
(1986, 0, 0, 0, 0, 0, 'Alai Flats, Flat 01', 2, 15, 25000, 765, 1, 2, 25, 0, 0),
(1987, 0, 0, 0, 0, 0, 'Alai Flats, Flat 02', 2, 14, 36000, 765, 1, 2, 36, 0, 0),
(1988, 0, 0, 0, 0, 0, 'Alai Flats, Flat 14', 2, 16, 33000, 900, 2, 2, 33, 0, 0),
(1989, 0, 0, 0, 0, 0, 'Alai Flats, Flat 15', 2, 24, 48000, 1450, 2, 4, 48, 0, 0),
(1990, 0, 0, 0, 0, 0, 'Alai Flats, Flat 16', 2, 24, 54000, 1450, 2, 4, 54, 0, 0),
(1991, 0, 0, 0, 0, 0, 'Alai Flats, Flat 17', 2, 18, 38000, 900, 2, 2, 38, 0, 0),
(1992, 0, 0, 0, 0, 0, 'Alai Flats, Flat 18', 2, 16, 38000, 900, 2, 2, 38, 0, 0),
(1993, 0, 0, 0, 0, 0, 'Alai Flats, Flat 13', 2, 14, 36000, 765, 1, 2, 36, 0, 0),
(1994, 0, 0, 0, 0, 0, 'Alai Flats, Flat 12', 2, 14, 25000, 765, 1, 2, 25, 0, 0),
(1995, 0, 0, 0, 0, 0, 'Alai Flats, Flat 11', 2, 14, 35000, 765, 1, 2, 35, 0, 0),
(1996, 0, 0, 0, 0, 0, 'Alai Flats, Flat 24', 2, 16, 36000, 900, 2, 2, 36, 0, 0),
(1997, 0, 0, 0, 0, 0, 'Alai Flats, Flat 25', 2, 24, 52000, 1450, 2, 4, 52, 0, 0),
(1998, 0, 0, 0, 0, 0, 'Alai Flats, Flat 26', 2, 24, 60000, 1450, 2, 4, 60, 0, 0),
(1999, 0, 0, 0, 0, 0, 'Alai Flats, Flat 27', 2, 16, 38000, 900, 2, 2, 38, 0, 0),
(2000, 0, 0, 0, 0, 0, 'Alai Flats, Flat 28', 2, 16, 38000, 900, 2, 2, 38, 0, 0),
(2001, 0, 0, 0, 0, 0, 'Alai Flats, Flat 23', 2, 14, 35000, 765, 1, 2, 35, 0, 0),
(2002, 0, 0, 0, 0, 0, 'Alai Flats, Flat 22', 2, 14, 25000, 765, 1, 2, 25, 0, 0),
(2003, 0, 0, 0, 0, 0, 'Alai Flats, Flat 21', 2, 14, 36000, 765, 1, 2, 36, 0, 0),
(2004, 0, 0, 0, 0, 0, 'Upper Swamp Lane 4', 2, 59, 165000, 4740, 7, 8, 165, 0, 0),
(2005, 0, 0, 0, 0, 0, 'Upper Swamp Lane 2', 2, 60, 159000, 4740, 7, 8, 159, 0, 0),
(2006, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue Labs 2c', 2, 10, 20000, 715, 1, 2, 20, 0, 0),
(2007, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue Labs 2d', 2, 10, 20000, 715, 1, 2, 20, 0, 0),
(2008, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue Labs 2e', 2, 10, 20000, 715, 1, 2, 20, 0, 0),
(2009, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue Labs 2f', 2, 10, 20000, 715, 1, 2, 20, 0, 0),
(2010, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue Labs 2b', 2, 10, 24000, 715, 1, 2, 24, 0, 0),
(2011, 0, 0, 0, 0, 0, 'Sorcerer''s Avenue Labs 2a', 2, 10, 24000, 715, 1, 2, 24, 0, 0),
(2012, 0, 0, 0, 0, 0, 'Ivory Circle 1', 7, 71, 160000, 4280, 5, 4, 160, 0, 0),
(2013, 0, 0, 0, 0, 0, 'Admiral''s Avenue 3', 7, 68, 142000, 4115, 3, 4, 142, 0, 0),
(2014, 0, 0, 0, 0, 0, 'Admiral''s Avenue 2', 7, 85, 176000, 5470, 5, 8, 176, 0, 0),
(2015, 0, 0, 0, 0, 0, 'Admiral''s Avenue 1', 7, 83, 168000, 5105, 5, 4, 168, 0, 0),
(2016, 0, 0, 0, 0, 0, 'Sugar Street 5', 7, 20, 48000, 1350, 1, 4, 48, 0, 0),
(2017, 0, 0, 0, 0, 0, 'Freedom Street 1', 7, 41, 84000, 2450, 2, 4, 84, 0, 0),
(2018, 0, 0, 0, 0, 0, 'Freedom Street 2', 7, 103, 208000, 6050, 5, 8, 208, 0, 0),
(2019, 0, 0, 0, 0, 0, 'Trader''s Point 2 (Shop)', 7, 93, 198000, 5350, 6, 4, 198, 0, 0),
(2020, 0, 0, 0, 0, 0, 'Trader''s Point 3 (Shop)', 7, 106, 195000, 5950, 5, 4, 195, 0, 0),
(2021, 0, 0, 0, 0, 0, 'Ivory Circle 2', 7, 120, 214000, 7030, 3, 4, 214, 0, 0),
(2022, 0, 0, 0, 0, 0, 'The Tavern 1a', 7, 40, 72000, 2750, 1, 8, 72, 0, 0);
INSERT INTO `houses` (`id`, `world_id`, `owner`, `paid`, `warnings`, `lastwarning`, `name`, `town`, `size`, `price`, `rent`, `doors`, `beds`, `tiles`, `guild`, `clear`) VALUES
(2023, 0, 0, 0, 0, 0, 'The Tavern 1b', 7, 31, 54000, 1900, 1, 4, 54, 0, 0),
(2024, 0, 0, 0, 0, 0, 'The Tavern 1c', 7, 73, 132000, 4150, 3, 6, 132, 0, 0),
(2025, 0, 0, 0, 0, 0, 'The Tavern 1d', 7, 24, 48000, 1550, 1, 4, 48, 0, 0),
(2026, 0, 0, 0, 0, 0, 'The Tavern 2d', 7, 20, 40000, 1350, 1, 4, 40, 0, 0),
(2027, 0, 0, 0, 0, 0, 'The Tavern 2c', 7, 16, 32000, 950, 1, 2, 32, 0, 0),
(2028, 0, 0, 0, 0, 0, 'The Tavern 2b', 7, 27, 62000, 1700, 2, 4, 62, 0, 0),
(2029, 0, 0, 0, 0, 0, 'The Tavern 2a', 7, 92, 163000, 5550, 3, 10, 163, 0, 0),
(2030, 0, 0, 0, 0, 0, 'Straycat''s Corner 4', 7, 4, 20000, 210, 1, 2, 20, 0, 0),
(2031, 0, 0, 0, 0, 0, 'Straycat''s Corner 3', 7, 4, 20000, 210, 1, 2, 20, 0, 0),
(2032, 0, 0, 0, 0, 0, 'Straycat''s Corner 2', 7, 18, 49000, 660, 2, 2, 49, 0, 0),
(2033, 0, 0, 0, 0, 0, 'Litter Promenade 5', 7, 11, 35000, 580, 1, 4, 35, 0, 0),
(2034, 0, 0, 0, 0, 0, 'Litter Promenade 4', 7, 10, 30000, 390, 1, 2, 30, 0, 0),
(2035, 0, 0, 0, 0, 0, 'Litter Promenade 3', 7, 12, 36000, 450, 1, 2, 36, 0, 0),
(2036, 0, 0, 0, 0, 0, 'Litter Promenade 2', 7, 7, 25000, 300, 1, 2, 25, 0, 0),
(2037, 0, 0, 0, 0, 0, 'Litter Promenade 1', 7, 6, 25000, 400, 1, 4, 25, 0, 0),
(2038, 0, 0, 0, 0, 0, 'The Shelter', 7, 282, 560000, 13590, 12, 62, 560, 0, 0),
(2039, 0, 0, 0, 0, 0, 'Straycat''s Corner 6', 7, 7, 25000, 300, 1, 2, 25, 0, 0),
(2040, 0, 0, 0, 0, 0, 'Straycat''s Corner 5', 7, 16, 48000, 760, 2, 4, 48, 0, 0),
(2042, 0, 0, 0, 0, 0, 'Rum Alley 3', 7, 9, 28000, 330, 1, 2, 28, 0, 0),
(2043, 0, 0, 0, 0, 0, 'Straycat''s Corner 1', 7, 7, 25000, 300, 1, 2, 25, 0, 0),
(2044, 0, 0, 0, 0, 0, 'Rum Alley 2', 7, 7, 25000, 300, 1, 2, 25, 0, 0),
(2045, 0, 0, 0, 0, 0, 'Rum Alley 1', 7, 14, 36000, 510, 1, 2, 36, 0, 0),
(2046, 0, 0, 0, 0, 0, 'Smuggler Backyard 3', 7, 15, 40000, 700, 2, 4, 40, 0, 0),
(2048, 0, 0, 0, 0, 0, 'Shady Trail 3', 7, 7, 25000, 300, 1, 2, 25, 0, 0),
(2049, 0, 0, 0, 0, 0, 'Shady Trail 1', 7, 14, 48000, 1150, 1, 10, 48, 0, 0),
(2050, 0, 0, 0, 0, 0, 'Shady Trail 2', 7, 8, 30000, 490, 1, 4, 30, 0, 0),
(2051, 0, 0, 0, 0, 0, 'Smuggler Backyard 5', 7, 11, 35000, 610, 2, 4, 35, 0, 0),
(2052, 0, 0, 0, 0, 0, 'Smuggler Backyard 4', 7, 10, 30000, 390, 1, 2, 30, 0, 0),
(2053, 0, 0, 0, 0, 0, 'Smuggler Backyard 2', 7, 15, 40000, 670, 1, 4, 40, 0, 0),
(2054, 0, 0, 0, 0, 0, 'Smuggler Backyard 1', 7, 14, 40000, 670, 1, 4, 40, 0, 0),
(2055, 0, 0, 0, 0, 0, 'Sugar Street 2', 7, 39, 84000, 2550, 2, 6, 84, 0, 0),
(2056, 0, 0, 0, 0, 0, 'Sugar Street 1', 7, 50, 84000, 3000, 2, 6, 84, 0, 0),
(2057, 0, 0, 0, 0, 0, 'Sugar Street 3a', 7, 22, 54000, 1650, 1, 6, 54, 0, 0),
(2058, 0, 0, 0, 0, 0, 'Sugar Street 3b', 7, 30, 60000, 2050, 1, 6, 60, 0, 0),
(2059, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 01', 7, 12, 36000, 950, 1, 4, 36, 0, 0),
(2060, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 03', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2061, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 05', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2062, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 02', 7, 12, 36000, 950, 1, 4, 36, 0, 0),
(2063, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 04', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2064, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 06', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2065, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 07', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2066, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 09', 7, 13, 30000, 950, 1, 4, 30, 0, 0),
(2067, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 11', 7, 12, 36000, 950, 1, 4, 36, 0, 0),
(2068, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 12', 7, 13, 36000, 950, 1, 4, 36, 0, 0),
(2069, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 10', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2070, 0, 0, 0, 0, 0, 'Harvester''s Haven, Flat 08', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2071, 0, 0, 0, 0, 0, 'Marble Lane 4', 7, 102, 192000, 6350, 3, 8, 192, 0, 0),
(2072, 0, 0, 0, 0, 0, 'Marble Lane 2', 7, 106, 200000, 6415, 3, 6, 200, 0, 0),
(2073, 0, 0, 0, 0, 0, 'Marble Lane 3', 7, 133, 240000, 8055, 4, 8, 240, 0, 0),
(2074, 0, 0, 0, 0, 0, 'Marble Lane 1', 7, 178, 320000, 11060, 7, 12, 320, 0, 0),
(2075, 0, 0, 0, 0, 0, 'Ivy Cottage', 7, 469, 858000, 30650, 10, 52, 858, 0, 0),
(2076, 0, 0, 0, 0, 0, 'Sugar Street 4d', 7, 8, 24000, 750, 1, 4, 24, 0, 0),
(2077, 0, 0, 0, 0, 0, 'Sugar Street 4c', 7, 10, 24000, 650, 1, 2, 24, 0, 0),
(2078, 0, 0, 0, 0, 0, 'Sugar Street 4b', 7, 12, 36000, 950, 1, 4, 36, 0, 0),
(2079, 0, 0, 0, 0, 0, 'Sugar Street 4a', 7, 12, 30000, 950, 1, 4, 30, 0, 0),
(2080, 0, 0, 0, 0, 0, 'Trader''s Point 1', 7, 38, 77000, 2200, 2, 4, 77, 0, 0),
(2081, 0, 0, 0, 0, 0, 'Mountain Hideout', 7, 234, 486000, 15550, 10, 34, 486, 0, 0),
(2082, 0, 0, 0, 0, 0, 'Dark Mansion', 2, 294, 573000, 17845, 13, 34, 573, 0, 0),
(2083, 0, 0, 0, 0, 0, 'Halls of the Adventurers', 2, 243, 518000, 15380, 14, 36, 518, 0, 0),
(2084, 0, 0, 0, 0, 0, 'Castle of Greenshore', 2, 254, 600000, 18860, 14, 24, 600, 0, 0),
(2085, 0, 0, 0, 0, 0, 'Greenshore Clanhall', 2, 133, 312000, 10800, 11, 20, 312, 0, 0),
(2086, 0, 0, 0, 0, 0, 'Greenshore Village 1', 2, 30, 64000, 2420, 1, 6, 64, 0, 0),
(2087, 0, 0, 0, 0, 0, 'Greenshore Village, Shop', 2, 20, 56000, 1800, 5, 2, 56, 0, 0),
(2088, 0, 0, 0, 0, 0, 'Greenshore Village, Villa', 2, 117, 263000, 8700, 8, 8, 263, 0, 0),
(2089, 0, 0, 0, 0, 0, 'Greenshore Village 2', 2, 10, 30000, 780, 1, 2, 30, 0, 0),
(2090, 0, 0, 0, 0, 0, 'Greenshore Village 3', 2, 10, 25000, 780, 1, 2, 25, 0, 0),
(2091, 0, 0, 0, 0, 0, 'Greenshore Village 5', 2, 10, 30000, 780, 1, 2, 30, 0, 0),
(2092, 0, 0, 0, 0, 0, 'Greenshore Village 4', 2, 10, 25000, 780, 1, 2, 25, 0, 0),
(2093, 0, 0, 0, 0, 0, 'Greenshore Village 6', 2, 61, 118000, 4360, 3, 4, 118, 0, 0),
(2094, 0, 0, 0, 0, 0, 'Greenshore Village 7', 2, 18, 42000, 1260, 1, 2, 42, 0, 0),
(2095, 0, 0, 0, 0, 0, 'The Tibianic', 2, 445, 871000, 34500, 10, 44, 871, 0, 0),
(2097, 0, 0, 0, 0, 0, 'Fibula Village 5', 2, 21, 42000, 1790, 1, 4, 42, 0, 0),
(2098, 0, 0, 0, 0, 0, 'Fibula Village 4', 2, 21, 42000, 1790, 1, 4, 42, 0, 0),
(2099, 0, 0, 0, 0, 0, 'Fibula Village, Tower Flat', 2, 72, 161000, 5105, 1, 4, 161, 0, 0),
(2100, 0, 0, 0, 0, 0, 'Fibula Village 1', 2, 10, 30000, 845, 1, 2, 30, 0, 0),
(2101, 0, 0, 0, 0, 0, 'Fibula Village 2', 2, 10, 30000, 845, 1, 2, 30, 0, 0),
(2102, 0, 0, 0, 0, 0, 'Fibula Village 3', 2, 45, 110000, 3810, 1, 8, 110, 0, 0),
(2103, 0, 0, 0, 0, 0, 'Mercenary Tower', 2, 525, 996000, 41955, 18, 52, 996, 0, 0),
(2104, 0, 0, 0, 0, 0, 'Guildhall of the Red Rose', 2, 340, 572000, 27725, 7, 30, 572, 0, 0),
(2105, 0, 0, 0, 0, 0, 'Fibula Village, Bar', 2, 59, 122000, 5235, 3, 4, 122, 0, 0),
(2106, 0, 0, 0, 0, 0, 'Fibula Village, Villa', 2, 181, 402000, 11490, 13, 10, 402, 0, 0),
(2107, 0, 0, 0, 0, 0, 'Fibula Clanhall', 2, 128, 290000, 11430, 12, 20, 290, 0, 0),
(2108, 0, 0, 0, 0, 0, 'Spiritkeep', 2, 316, 783000, 19210, 18, 46, 783, 0, 0),
(2109, 0, 0, 0, 0, 0, 'Snake Tower', 2, 532, 1064000, 29720, 28, 42, 1064, 0, 0),
(2110, 0, 0, 0, 0, 0, 'Bloodhall', 2, 245, 569000, 15270, 15, 30, 569, 0, 0),
(2111, 0, 0, 0, 0, 0, 'Senja Clanhall', 4, 172, 396000, 10575, 15, 18, 396, 0, 0),
(2112, 0, 0, 0, 0, 0, 'Senja Village 2', 4, 14, 36000, 765, 1, 2, 36, 0, 0),
(2113, 0, 0, 0, 0, 0, 'Senja Village 1a', 4, 14, 36000, 765, 1, 2, 36, 0, 0),
(2114, 0, 0, 0, 0, 0, 'Senja Village 1b', 4, 28, 66000, 1630, 2, 4, 66, 0, 0),
(2115, 0, 0, 0, 0, 0, 'Senja Village 4', 4, 14, 30000, 765, 1, 2, 30, 0, 0),
(2116, 0, 0, 0, 0, 0, 'Senja Village 3', 4, 28, 72000, 1765, 2, 4, 72, 0, 0),
(2117, 0, 0, 0, 0, 0, 'Senja Village 6b', 4, 14, 30000, 765, 1, 2, 30, 0, 0),
(2118, 0, 0, 0, 0, 0, 'Senja Village 6a', 4, 14, 30000, 765, 1, 2, 30, 0, 0),
(2119, 0, 0, 0, 0, 0, 'Senja Village 5', 4, 20, 48000, 1225, 1, 4, 48, 0, 0),
(2120, 0, 0, 0, 0, 0, 'Senja Village 10', 4, 30, 72000, 1485, 1, 2, 72, 0, 0),
(2121, 0, 0, 0, 0, 0, 'Senja Village 11', 4, 50, 96000, 2620, 2, 4, 96, 0, 0),
(2122, 0, 0, 0, 0, 0, 'Senja Village 9', 4, 48, 103000, 2575, 3, 4, 103, 0, 0),
(2123, 0, 0, 0, 0, 0, 'Senja Village 8', 4, 30, 57000, 1675, 1, 4, 57, 0, 0),
(2124, 0, 0, 0, 0, 0, 'Senja Village 7', 4, 12, 37000, 865, 1, 4, 37, 0, 0),
(2125, 0, 0, 0, 0, 0, 'Rosebud C', 4, 30, 70000, 1340, 1, 0, 70, 0, 0),
(2127, 0, 0, 0, 0, 0, 'Rosebud A', 4, 22, 60000, 1000, 1, 2, 60, 0, 0),
(2128, 0, 0, 0, 0, 0, 'Rosebud B', 4, 22, 60000, 1000, 1, 2, 60, 0, 0),
(2129, 0, 0, 0, 0, 0, 'Nordic Stronghold', 4, 304, 732000, 18400, 14, 22, 732, 0, 0),
(2130, 0, 0, 0, 0, 0, 'Northport Village 2', 4, 20, 40000, 1475, 1, 4, 40, 0, 0),
(2131, 0, 0, 0, 0, 0, 'Northport Village 1', 4, 20, 48000, 1475, 1, 4, 48, 0, 0),
(2132, 0, 0, 0, 0, 0, 'Northport Village 3', 4, 96, 178000, 5435, 2, 4, 178, 0, 0),
(2133, 0, 0, 0, 0, 0, 'Northport Village 4', 4, 42, 81000, 2630, 1, 4, 81, 0, 0),
(2134, 0, 0, 0, 0, 0, 'Northport Village 5', 4, 26, 56000, 1805, 1, 4, 56, 0, 0),
(2135, 0, 0, 0, 0, 0, 'Northport Village 6', 4, 32, 64000, 2135, 1, 4, 64, 0, 0),
(2136, 0, 0, 0, 0, 0, 'Seawatch', 4, 364, 749000, 25010, 15, 38, 749, 0, 0),
(2137, 0, 0, 0, 0, 0, 'Northport Clanhall', 4, 130, 292000, 9810, 10, 20, 292, 0, 0),
(2138, 0, 0, 0, 0, 0, 'Druids Retreat D', 4, 22, 54000, 1180, 1, 4, 54, 0, 0),
(2139, 0, 0, 0, 0, 0, 'Druids Retreat A', 4, 26, 60000, 1340, 1, 4, 60, 0, 0),
(2140, 0, 0, 0, 0, 0, 'Druids Retreat C', 4, 17, 45000, 980, 1, 4, 45, 0, 0),
(2141, 0, 0, 0, 0, 0, 'Druids Retreat B', 4, 24, 55000, 980, 1, 4, 55, 0, 0),
(2142, 0, 0, 0, 0, 0, 'Theater Avenue 14 (Shop)', 4, 36, 83000, 2115, 2, 2, 83, 0, 0),
(2143, 0, 0, 0, 0, 0, 'Theater Avenue 12', 4, 14, 28000, 955, 1, 4, 28, 0, 0),
(2144, 0, 0, 0, 0, 0, 'Theater Avenue 10', 4, 17, 45000, 1090, 1, 4, 45, 0, 0),
(2145, 0, 0, 0, 0, 0, 'Theater Avenue 11c', 4, 10, 24000, 585, 1, 2, 24, 0, 0),
(2146, 0, 0, 0, 0, 0, 'Theater Avenue 11b', 4, 10, 24000, 585, 1, 2, 24, 0, 0),
(2147, 0, 0, 0, 0, 0, 'Theater Avenue 11a', 4, 24, 54000, 1405, 1, 4, 54, 0, 0),
(2148, 0, 0, 0, 0, 0, 'Magician''s Alley 1', 4, 14, 35000, 1050, 1, 4, 35, 0, 0),
(2149, 0, 0, 0, 0, 0, 'Magician''s Alley 1a', 4, 7, 29000, 700, 1, 4, 29, 0, 0),
(2150, 0, 0, 0, 0, 0, 'Magician''s Alley 1d', 4, 6, 24000, 450, 1, 2, 24, 0, 0),
(2151, 0, 0, 0, 0, 0, 'Magician''s Alley 1b', 4, 8, 24000, 750, 1, 4, 24, 0, 0),
(2152, 0, 0, 0, 0, 0, 'Magician''s Alley 1c', 4, 7, 20000, 500, 1, 2, 20, 0, 0),
(2153, 0, 0, 0, 0, 0, 'Magician''s Alley 5a', 4, 4, 14000, 350, 1, 2, 14, 0, 0),
(2154, 0, 0, 0, 0, 0, 'Magician''s Alley 5b', 4, 7, 25000, 500, 1, 2, 25, 0, 0),
(2155, 0, 0, 0, 0, 0, 'Magician''s Alley 5d', 4, 7, 20000, 500, 1, 2, 20, 0, 0),
(2156, 0, 0, 0, 0, 0, 'Magician''s Alley 5e', 4, 7, 25000, 500, 1, 2, 25, 0, 0),
(2157, 0, 0, 0, 0, 0, 'Magician''s Alley 5c', 4, 16, 35000, 1150, 1, 4, 35, 0, 0),
(2158, 0, 0, 0, 0, 0, 'Magician''s Alley 5f', 4, 16, 42000, 1150, 1, 4, 42, 0, 0),
(2159, 0, 0, 0, 0, 0, 'Carlin Clanhall', 4, 167, 364000, 10750, 1, 20, 364, 0, 0),
(2160, 0, 0, 0, 0, 0, 'Magician''s Alley 4', 4, 40, 96000, 2750, 1, 8, 96, 0, 0),
(2161, 0, 0, 0, 0, 0, 'Lonely Sea Side Hostel', 4, 218, 454000, 10540, 4, 16, 454, 0, 0),
(2162, 0, 0, 0, 0, 0, 'Suntower', 4, 204, 450000, 10080, 14, 14, 450, 0, 0),
(2163, 0, 0, 0, 0, 0, 'Harbour Lane 3', 4, 77, 145000, 3560, 1, 6, 145, 0, 0),
(2164, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 11', 4, 10, 24000, 520, 1, 2, 24, 0, 0),
(2165, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 13', 4, 10, 24000, 520, 1, 2, 24, 0, 0),
(2166, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 15', 4, 6, 18000, 360, 1, 2, 18, 0, 0),
(2167, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 17', 4, 6, 24000, 360, 1, 2, 24, 0, 0),
(2168, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 12', 4, 7, 20000, 400, 1, 2, 20, 0, 0),
(2169, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 14', 4, 7, 20000, 400, 1, 2, 20, 0, 0),
(2170, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 16', 4, 7, 20000, 400, 1, 2, 20, 0, 0),
(2171, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 18', 4, 7, 25000, 400, 1, 2, 25, 0, 0),
(2172, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 21', 4, 14, 35000, 860, 1, 4, 35, 0, 0),
(2173, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 22', 4, 17, 45000, 980, 1, 4, 45, 0, 0),
(2174, 0, 0, 0, 0, 0, 'Harbour Flats, Flat 23', 4, 7, 25000, 400, 1, 2, 25, 0, 0),
(2175, 0, 0, 0, 0, 0, 'Harbour Lane 2a (Shop)', 4, 12, 32000, 680, 1, 0, 32, 0, 0),
(2176, 0, 0, 0, 0, 0, 'Harbour Lane 2b (Shop)', 4, 12, 40000, 680, 1, 0, 40, 0, 0),
(2177, 0, 0, 0, 0, 0, 'Harbour Lane 1 (Shop)', 4, 19, 54000, 1040, 1, 0, 54, 0, 0),
(2178, 0, 0, 0, 0, 0, 'Theater Avenue 6e', 4, 11, 31000, 820, 1, 4, 31, 0, 0),
(2179, 0, 0, 0, 0, 0, 'Theater Avenue 6c', 4, 2, 12000, 225, 1, 2, 12, 0, 0),
(2180, 0, 0, 0, 0, 0, 'Theater Avenue 6a', 4, 11, 35000, 820, 1, 4, 35, 0, 0),
(2181, 0, 0, 0, 0, 0, 'Theater Avenue 6f', 4, 11, 31000, 820, 1, 4, 31, 0, 0),
(2182, 0, 0, 0, 0, 0, 'Theater Avenue 6d', 4, 2, 12000, 225, 1, 2, 12, 0, 0),
(2183, 0, 0, 0, 0, 0, 'Theater Avenue 6b', 4, 11, 35000, 820, 1, 4, 35, 0, 0),
(2184, 0, 0, 0, 0, 0, 'East Lane 1a', 4, 48, 95000, 2260, 1, 4, 95, 0, 0),
(2185, 0, 0, 0, 0, 0, 'East Lane 1b', 4, 34, 83000, 1700, 0, 4, 83, 0, 0),
(2186, 0, 0, 0, 0, 0, 'East Lane 2', 4, 87, 172000, 3900, 1, 4, 172, 0, 0),
(2191, 0, 0, 0, 0, 0, 'Northern Street 5', 4, 41, 94000, 1980, 1, 4, 94, 0, 0),
(2192, 0, 0, 0, 0, 0, 'Northern Street 7', 4, 34, 83000, 1700, 1, 4, 83, 0, 0),
(2193, 0, 0, 0, 0, 0, 'Northern Street 3a', 4, 11, 31000, 740, 1, 4, 31, 0, 0),
(2194, 0, 0, 0, 0, 0, 'Northern Street 3b', 4, 12, 36000, 780, 1, 4, 36, 0, 0),
(2195, 0, 0, 0, 0, 0, 'Northern Street 1c', 4, 11, 31000, 740, 1, 4, 31, 0, 0),
(2196, 0, 0, 0, 0, 0, 'Northern Street 1b', 4, 16, 37000, 740, 1, 4, 37, 0, 0),
(2197, 0, 0, 0, 0, 0, 'Northern Street 1a', 4, 16, 41000, 940, 1, 4, 41, 0, 0),
(2198, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 06', 4, 4, 20000, 315, 1, 2, 20, 0, 0),
(2199, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 01', 4, 4, 15000, 315, 1, 2, 15, 0, 0),
(2200, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 05', 4, 6, 20000, 405, 1, 2, 20, 0, 0),
(2201, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 02', 4, 6, 20000, 405, 1, 2, 20, 0, 0),
(2202, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 04', 4, 8, 20000, 495, 1, 2, 20, 0, 0),
(2203, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 03', 4, 6, 19000, 405, 1, 2, 19, 0, 0),
(2204, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 14', 4, 8, 20000, 495, 1, 2, 20, 0, 0),
(2205, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 13', 4, 6, 17000, 405, 1, 2, 17, 0, 0),
(2206, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 15', 4, 6, 19000, 405, 1, 2, 19, 0, 0),
(2207, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 16', 4, 6, 20000, 405, 1, 2, 20, 0, 0),
(2208, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 11', 4, 8, 23000, 495, 1, 2, 23, 0, 0),
(2209, 0, 0, 0, 0, 0, 'Theater Avenue 7, Flat 12', 4, 6, 15000, 405, 1, 2, 15, 0, 0),
(2210, 0, 0, 0, 0, 0, 'Theater Avenue 8a', 4, 21, 50000, 1270, 1, 4, 50, 0, 0),
(2211, 0, 0, 0, 0, 0, 'Theater Avenue 8b', 4, 19, 49000, 1370, 1, 6, 49, 0, 0),
(2212, 0, 0, 0, 0, 0, 'Central Plaza 3', 4, 8, 20000, 600, 0, 0, 20, 0, 0),
(2213, 0, 0, 0, 0, 0, 'Central Plaza 2', 4, 8, 20000, 600, 0, 0, 20, 0, 0),
(2214, 0, 0, 0, 0, 0, 'Central Plaza 1', 4, 8, 20000, 600, 0, 0, 20, 0, 0),
(2215, 0, 0, 0, 0, 0, 'Park Lane 1a', 4, 21, 53000, 1220, 0, 4, 53, 0, 0),
(2216, 0, 0, 0, 0, 0, 'Park Lane 3a', 4, 21, 48000, 1220, 1, 4, 48, 0, 0),
(2217, 0, 0, 0, 0, 0, 'Park Lane 1b', 4, 27, 64000, 1380, 2, 4, 64, 0, 0),
(2218, 0, 0, 0, 0, 0, 'Park Lane 3b', 4, 20, 48000, 1100, 1, 4, 48, 0, 0),
(2219, 0, 0, 0, 0, 0, 'Park Lane 4', 4, 16, 42000, 980, 1, 4, 42, 0, 0),
(2220, 0, 0, 0, 0, 0, 'Park Lane 2', 4, 16, 42000, 980, 1, 4, 42, 0, 0),
(2221, 0, 0, 0, 0, 0, 'Magician''s Alley 8', 4, 21, 42000, 1400, 1, 4, 42, 0, 0),
(2222, 0, 0, 0, 0, 0, 'Moonkeep', 4, 240, 522000, 13020, 13, 32, 522, 0, 0),
(2225, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 01', 11, 10, 30000, 585, 1, 2, 30, 0, 0),
(2226, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 02', 11, 10, 20000, 585, 1, 2, 20, 0, 0),
(2227, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 03', 11, 10, 20000, 585, 1, 2, 20, 0, 0),
(2228, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 04', 11, 10, 20000, 585, 1, 2, 20, 0, 0),
(2229, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 07', 11, 10, 20000, 585, 1, 2, 20, 0, 0),
(2230, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 08', 11, 10, 20000, 585, 1, 2, 20, 0, 0),
(2231, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 09', 11, 10, 24000, 585, 1, 2, 24, 0, 0),
(2232, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 06', 11, 10, 24000, 585, 1, 2, 24, 0, 0),
(2233, 0, 0, 0, 0, 0, 'Castle, Basement, Flat 05', 11, 10, 24000, 585, 1, 2, 24, 0, 0),
(2234, 0, 0, 0, 0, 0, 'Castle Shop 1', 11, 31, 67000, 1890, 3, 2, 67, 0, 0),
(2235, 0, 0, 0, 0, 0, 'Castle Shop 2', 11, 31, 70000, 1890, 3, 2, 70, 0, 0),
(2236, 0, 0, 0, 0, 0, 'Castle Shop 3', 11, 31, 67000, 1890, 3, 2, 67, 0, 0),
(2237, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 09', 11, 13, 28000, 720, 1, 2, 28, 0, 0),
(2238, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 08', 11, 18, 42000, 945, 1, 2, 42, 0, 0),
(2239, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 06', 11, 18, 36000, 945, 1, 2, 36, 0, 0),
(2240, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 07', 11, 13, 30000, 720, 1, 2, 30, 0, 0),
(2241, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 05', 11, 14, 30000, 765, 1, 2, 30, 0, 0),
(2242, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 04', 11, 10, 25000, 585, 1, 2, 25, 0, 0),
(2243, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 03', 11, 10, 30000, 585, 1, 2, 30, 0, 0),
(2244, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 02', 11, 14, 30000, 765, 1, 2, 30, 0, 0),
(2245, 0, 0, 0, 0, 0, 'Castle, 4th Floor, Flat 01', 11, 10, 30000, 585, 1, 2, 30, 0, 0),
(2246, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 01', 11, 10, 30000, 585, 1, 2, 30, 0, 0),
(2247, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 02', 11, 14, 30000, 765, 1, 2, 30, 0, 0),
(2248, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 03', 11, 10, 25000, 585, 1, 2, 25, 0, 0),
(2249, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 05', 11, 14, 30000, 765, 1, 2, 30, 0, 0),
(2250, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 04', 11, 10, 25000, 585, 1, 2, 25, 0, 0),
(2251, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 06', 11, 16, 36000, 1045, 1, 4, 36, 0, 0),
(2252, 0, 0, 0, 0, 0, 'Castle, 3rd Floor, Flat 07', 11, 13, 30000, 720, 1, 2, 30, 0, 0),
(2253, 0, 0, 0, 0, 0, 'Castle Street 1', 11, 53, 112000, 2900, 1, 6, 112, 0, 0),
(2254, 0, 0, 0, 0, 0, 'Castle Street 2', 11, 26, 56000, 1495, 1, 4, 56, 0, 0),
(2255, 0, 0, 0, 0, 0, 'Castle Street 3', 11, 32, 56000, 1765, 1, 4, 56, 0, 0),
(2256, 0, 0, 0, 0, 0, 'Castle Street 4', 11, 32, 64000, 1765, 1, 4, 64, 0, 0),
(2257, 0, 0, 0, 0, 0, 'Castle Street 5', 11, 32, 61000, 1765, 1, 4, 61, 0, 0),
(2258, 0, 0, 0, 0, 0, 'Edron Flats, Basement Flat 2', 11, 31, 48000, 1540, 1, 4, 48, 0, 0),
(2259, 0, 0, 0, 0, 0, 'Edron Flats, Basement Flat 1', 11, 31, 48000, 1540, 1, 4, 48, 0, 0),
(2260, 0, 0, 0, 0, 0, 'Edron Flats, Flat 01', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2261, 0, 0, 0, 0, 0, 'Edron Flats, Flat 02', 11, 14, 28000, 860, 1, 4, 28, 0, 0),
(2262, 0, 0, 0, 0, 0, 'Edron Flats, Flat 03', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2263, 0, 0, 0, 0, 0, 'Edron Flats, Flat 04', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2264, 0, 0, 0, 0, 0, 'Edron Flats, Flat 06', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2265, 0, 0, 0, 0, 0, 'Edron Flats, Flat 05', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2266, 0, 0, 0, 0, 0, 'Edron Flats, Flat 07', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2267, 0, 0, 0, 0, 0, 'Edron Flats, Flat 08', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2268, 0, 0, 0, 0, 0, 'Edron Flats, Flat 11', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2269, 0, 0, 0, 0, 0, 'Edron Flats, Flat 12', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2270, 0, 0, 0, 0, 0, 'Edron Flats, Flat 14', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2271, 0, 0, 0, 0, 0, 'Edron Flats, Flat 13', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2272, 0, 0, 0, 0, 0, 'Edron Flats, Flat 16', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2273, 0, 0, 0, 0, 0, 'Edron Flats, Flat 15', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2274, 0, 0, 0, 0, 0, 'Edron Flats, Flat 18', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2275, 0, 0, 0, 0, 0, 'Edron Flats, Flat 17', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2276, 0, 0, 0, 0, 0, 'Edron Flats, Flat 22', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2277, 0, 0, 0, 0, 0, 'Edron Flats, Flat 21', 11, 14, 40000, 860, 1, 4, 40, 0, 0),
(2278, 0, 0, 0, 0, 0, 'Edron Flats, Flat 24', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2279, 0, 0, 0, 0, 0, 'Edron Flats, Flat 23', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2280, 0, 0, 0, 0, 0, 'Edron Flats, Flat 26', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2281, 0, 0, 0, 0, 0, 'Edron Flats, Flat 27', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2282, 0, 0, 0, 0, 0, 'Edron Flats, Flat 28', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2283, 0, 0, 0, 0, 0, 'Edron Flats, Flat 25', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2284, 0, 0, 0, 0, 0, 'Central Circle 1', 11, 66, 119000, 3020, 3, 4, 119, 0, 0),
(2285, 0, 0, 0, 0, 0, 'Central Circle 2', 11, 73, 108000, 3300, 3, 4, 108, 0, 0),
(2286, 0, 0, 0, 0, 0, 'Central Circle 3', 11, 79, 147000, 4160, 5, 10, 147, 0, 0),
(2287, 0, 0, 0, 0, 0, 'Central Circle 4', 11, 79, 147000, 4160, 5, 10, 147, 0, 0),
(2288, 0, 0, 0, 0, 0, 'Central Circle 5', 11, 79, 161000, 4160, 5, 10, 161, 0, 0),
(2289, 0, 0, 0, 0, 0, 'Central Circle 6 (Shop)', 11, 84, 182000, 3980, 6, 4, 182, 0, 0),
(2290, 0, 0, 0, 0, 0, 'Central Circle 7 (Shop)', 11, 84, 161000, 3980, 6, 4, 161, 0, 0),
(2291, 0, 0, 0, 0, 0, 'Central Circle 8 (Shop)', 11, 84, 166000, 3980, 6, 4, 166, 0, 0),
(2292, 0, 0, 0, 0, 0, 'Central Circle 9a', 11, 16, 42000, 940, 1, 4, 42, 0, 0),
(2293, 0, 0, 0, 0, 0, 'Central Circle 9b', 11, 18, 44000, 940, 1, 4, 44, 0, 0),
(2294, 0, 0, 0, 0, 0, 'Sky Lane, Guild 1', 11, 342, 666000, 21145, 11, 46, 666, 0, 0),
(2295, 0, 0, 0, 0, 0, 'Sky Lane, Guild 2', 11, 344, 650000, 19300, 12, 28, 650, 0, 0),
(2296, 0, 0, 0, 0, 0, 'Sky Lane, Guild 3', 11, 296, 564000, 17315, 10, 36, 564, 0, 0),
(2297, 0, 0, 0, 0, 0, 'Sky Lane, Sea Tower', 11, 80, 196000, 4775, 3, 12, 196, 0, 0),
(2298, 0, 0, 0, 0, 0, 'Wood Avenue 6a', 11, 23, 56000, 1450, 3, 4, 56, 0, 0),
(2299, 0, 0, 0, 0, 0, 'Wood Avenue 9a', 11, 26, 56000, 1540, 2, 4, 56, 0, 0),
(2300, 0, 0, 0, 0, 0, 'Wood Avenue 10a', 11, 26, 64000, 1540, 2, 4, 64, 0, 0),
(2301, 0, 0, 0, 0, 0, 'Wood Avenue 11', 11, 130, 253000, 7205, 7, 12, 253, 0, 0),
(2302, 0, 0, 0, 0, 0, 'Wood Avenue 8', 11, 117, 198000, 5960, 5, 6, 198, 0, 0),
(2303, 0, 0, 0, 0, 0, 'Wood Avenue 7', 11, 117, 191000, 5960, 5, 6, 191, 0, 0),
(2304, 0, 0, 0, 0, 0, 'Wood Avenue 6b', 11, 23, 56000, 1450, 3, 4, 56, 0, 0),
(2305, 0, 0, 0, 0, 0, 'Wood Avenue 9b', 11, 25, 56000, 1495, 2, 4, 56, 0, 0),
(2306, 0, 0, 0, 0, 0, 'Wood Avenue 10b', 11, 22, 64000, 1595, 3, 6, 64, 0, 0),
(2307, 0, 0, 0, 0, 0, 'Wood Avenue 5', 11, 32, 64000, 1765, 1, 4, 64, 0, 0),
(2308, 0, 0, 0, 0, 0, 'Wood Avenue 4a', 11, 26, 56000, 1495, 1, 4, 56, 0, 0),
(2309, 0, 0, 0, 0, 0, 'Wood Avenue 4b', 11, 26, 56000, 1495, 1, 4, 56, 0, 0),
(2310, 0, 0, 0, 0, 0, 'Wood Avenue 4c', 11, 32, 56000, 1765, 1, 4, 56, 0, 0),
(2311, 0, 0, 0, 0, 0, 'Wood Avenue 4', 11, 32, 64000, 1765, 1, 4, 64, 0, 0),
(2312, 0, 0, 0, 0, 0, 'Wood Avenue 3', 11, 32, 56000, 1765, 1, 4, 56, 0, 0),
(2313, 0, 0, 0, 0, 0, 'Wood Avenue 2', 11, 32, 49000, 1765, 1, 4, 49, 0, 0),
(2314, 0, 0, 0, 0, 0, 'Wood Avenue 1', 11, 32, 64000, 1765, 1, 4, 64, 0, 0),
(2315, 0, 0, 0, 0, 0, 'Magic Academy, Guild', 11, 155, 414000, 12025, 7, 28, 414, 0, 0),
(2316, 0, 0, 0, 0, 0, 'Magic Academy, Flat 1', 11, 16, 57000, 1465, 2, 6, 57, 0, 0),
(2317, 0, 0, 0, 0, 0, 'Magic Academy, Flat 2', 11, 21, 55000, 1530, 1, 4, 55, 0, 0),
(2318, 0, 0, 0, 0, 0, 'Magic Academy, Flat 3', 11, 24, 55000, 1430, 1, 2, 55, 0, 0),
(2319, 0, 0, 0, 0, 0, 'Magic Academy, Flat 4', 11, 21, 55000, 1530, 1, 4, 55, 0, 0),
(2320, 0, 0, 0, 0, 0, 'Magic Academy, Flat 5', 11, 23, 55000, 1430, 1, 2, 55, 0, 0),
(2321, 0, 0, 0, 0, 0, 'Magic Academy, Shop', 11, 18, 48000, 1595, 0, 2, 48, 0, 0),
(2322, 0, 0, 0, 0, 0, 'Stonehome Village 1', 11, 36, 74000, 1780, 2, 4, 74, 0, 0),
(2323, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 05', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2324, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 04', 11, 7, 25000, 400, 1, 2, 25, 0, 0),
(2325, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 06', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2326, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 03', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2327, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 01', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2328, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 02', 11, 11, 30000, 740, 1, 4, 30, 0, 0),
(2329, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 11', 11, 11, 35000, 740, 1, 4, 35, 0, 0),
(2330, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 12', 11, 11, 35000, 740, 1, 4, 35, 0, 0),
(2331, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 13', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2332, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 14', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2333, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 16', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2334, 0, 0, 0, 0, 0, 'Stonehome Flats, Flat 15', 11, 7, 20000, 400, 1, 2, 20, 0, 0),
(2335, 0, 0, 0, 0, 0, 'Stonehome Village 2', 11, 13, 35000, 640, 1, 2, 35, 0, 0),
(2336, 0, 0, 0, 0, 0, 'Stonehome Village 3', 11, 14, 36000, 680, 1, 2, 36, 0, 0),
(2337, 0, 0, 0, 0, 0, 'Stonehome Village 4', 11, 16, 42000, 940, 1, 4, 42, 0, 0),
(2338, 0, 0, 0, 0, 0, 'Stonehome Village 6', 11, 25, 55000, 1300, 1, 4, 55, 0, 0),
(2339, 0, 0, 0, 0, 0, 'Stonehome Village 5', 11, 28, 56000, 1140, 1, 4, 56, 0, 0),
(2340, 0, 0, 0, 0, 0, 'Stonehome Village 7', 11, 21, 49000, 1140, 1, 4, 49, 0, 0),
(2341, 0, 0, 0, 0, 0, 'Stonehome Village 8', 11, 14, 36000, 680, 1, 2, 36, 0, 0),
(2342, 0, 0, 0, 0, 0, 'Stonehome Village 9', 11, 14, 36000, 680, 1, 2, 36, 0, 0),
(2343, 0, 0, 0, 0, 0, 'Stonehome Clanhall', 11, 157, 345000, 8580, 15, 18, 345, 0, 0),
(2344, 0, 0, 0, 0, 0, 'Cormaya 1', 11, 21, 49000, 1270, 1, 4, 49, 0, 0),
(2345, 0, 0, 0, 0, 0, 'Cormaya 2', 11, 70, 145000, 3710, 3, 6, 145, 0, 0),
(2346, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 01', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2347, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 02', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2348, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 03', 11, 11, 30000, 820, 1, 4, 30, 0, 0),
(2349, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 06', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2350, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 05', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2351, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 04', 11, 11, 30000, 820, 1, 4, 30, 0, 0),
(2352, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 13', 11, 11, 30000, 820, 1, 4, 30, 0, 0),
(2353, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 14', 11, 11, 35000, 820, 1, 4, 35, 0, 0),
(2354, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 15', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2355, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 16', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2356, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 11', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2357, 0, 0, 0, 0, 0, 'Cormaya Flats, Flat 12', 11, 7, 20000, 450, 1, 2, 20, 0, 0),
(2358, 0, 0, 0, 0, 0, 'Cormaya 3', 11, 38, 72000, 2035, 1, 4, 72, 0, 0),
(2359, 0, 0, 0, 0, 0, 'Castle of the White Dragon', 11, 442, 882000, 25110, 16, 38, 882, 0, 0),
(2360, 0, 0, 0, 0, 0, 'Cormaya 4', 11, 31, 63000, 1720, 1, 4, 63, 0, 0),
(2361, 0, 0, 0, 0, 0, 'Cormaya 5', 11, 77, 167000, 4250, 2, 6, 167, 0, 0),
(2362, 0, 0, 0, 0, 0, 'Cormaya 6', 11, 46, 84000, 2395, 1, 4, 84, 0, 0),
(2363, 0, 0, 0, 0, 0, 'Cormaya 7', 11, 46, 84000, 2395, 1, 4, 84, 0, 0),
(2364, 0, 0, 0, 0, 0, 'Cormaya 8', 11, 53, 113000, 2710, 2, 4, 113, 0, 0),
(2365, 0, 0, 0, 0, 0, 'Cormaya 9b', 11, 50, 88000, 2620, 2, 4, 88, 0, 0),
(2366, 0, 0, 0, 0, 0, 'Cormaya 9a', 11, 20, 48000, 1225, 1, 4, 48, 0, 0),
(2367, 0, 0, 0, 0, 0, 'Cormaya 9c', 11, 20, 48000, 1225, 1, 4, 48, 0, 0),
(2368, 0, 0, 0, 0, 0, 'Cormaya 9d', 11, 50, 88000, 2620, 2, 4, 88, 0, 0),
(2369, 0, 0, 0, 0, 0, 'Cormaya 10', 11, 73, 140000, 3800, 2, 6, 140, 0, 0),
(2370, 0, 0, 0, 0, 0, 'Cormaya 11', 11, 38, 72000, 2035, 1, 4, 72, 0, 0),
(2371, 0, 0, 0, 0, 0, 'Demon Tower', 2, 50, 127000, 3340, 1, 4, 127, 0, 0),
(2372, 0, 0, 0, 0, 0, 'Nautic Observer', 4, 145, 300000, 6540, 4, 8, 300, 0, 0),
(2373, 0, 0, 0, 0, 0, 'Riverspring', 3, 284, 632000, 19450, 23, 36, 632, 0, 0),
(2374, 0, 0, 0, 0, 0, 'House of Recreation', 4, 337, 702000, 22540, 4, 32, 702, 0, 0),
(2375, 0, 0, 0, 0, 0, 'Valorous Venore', 1, 271, 507000, 14435, 15, 18, 507, 0, 0),
(2376, 0, 0, 0, 0, 0, 'Ab''Dendriel Clanhall', 5, 264, 498000, 14850, 11, 20, 498, 0, 0),
(2377, 0, 0, 0, 0, 0, 'Castle of the Winds', 5, 422, 842000, 23885, 21, 36, 842, 0, 0),
(2378, 0, 0, 0, 0, 0, 'The Hideout', 5, 321, 597000, 20800, 14, 40, 597, 0, 0),
(2379, 0, 0, 0, 0, 0, 'Shadow Towers', 5, 348, 750000, 21800, 16, 36, 750, 0, 0),
(2380, 0, 0, 0, 0, 0, 'Hill Hideout', 3, 193, 346000, 13950, 8, 30, 346, 0, 0),
(2381, 0, 0, 0, 0, 0, 'Meriana Beach', 7, 140, 184000, 8230, 1, 6, 184, 0, 0),
(2382, 0, 0, 0, 0, 0, 'Darashia 8, Flat 01', 10, 48, 80000, 2485, 1, 4, 80, 0, 0),
(2383, 0, 0, 0, 0, 0, 'Darashia 8, Flat 02', 10, 67, 114000, 3385, 2, 4, 114, 0, 0),
(2384, 0, 0, 0, 0, 0, 'Darashia 8, Flat 03', 10, 90, 171000, 4700, 5, 6, 171, 0, 0),
(2385, 0, 0, 0, 0, 0, 'Darashia 8, Flat 04', 10, 56, 90000, 2845, 1, 4, 90, 0, 0),
(2386, 0, 0, 0, 0, 0, 'Darashia 8, Flat 05', 10, 52, 85000, 2665, 1, 4, 85, 0, 0),
(2387, 0, 0, 0, 0, 0, 'Darashia, Eastern Guildhall', 10, 204, 444000, 12660, 15, 32, 444, 0, 0),
(2388, 0, 0, 0, 0, 0, 'Theater Avenue 5a', 4, 7, 20000, 450, 1, 2, 20, 0, 0),
(2389, 0, 0, 0, 0, 0, 'Theater Avenue 5b', 4, 7, 19000, 450, 1, 2, 19, 0, 0),
(2390, 0, 0, 0, 0, 0, 'Theater Avenue 5c', 4, 7, 16000, 450, 1, 2, 16, 0, 0),
(2391, 0, 0, 0, 0, 0, 'Theater Avenue 5d', 4, 7, 16000, 450, 1, 2, 16, 0, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `house_auctions`
--

CREATE TABLE IF NOT EXISTS `house_auctions` (
  `house_id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `player_id` int(11) NOT NULL,
  `bid` int(10) unsigned NOT NULL DEFAULT '0',
  `limit` int(10) unsigned NOT NULL DEFAULT '0',
  `endtime` bigint(20) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `house_id` (`house_id`,`world_id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `house_auctions`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `house_data`
--

CREATE TABLE IF NOT EXISTS `house_data` (
  `house_id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `data` longblob NOT NULL,
  UNIQUE KEY `house_id` (`house_id`,`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `house_data`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `house_lists`
--

CREATE TABLE IF NOT EXISTS `house_lists` (
  `house_id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `listid` int(11) NOT NULL,
  `list` text NOT NULL,
  UNIQUE KEY `house_id` (`house_id`,`world_id`,`listid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `house_lists`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `killers`
--

CREATE TABLE IF NOT EXISTS `killers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `death_id` int(11) NOT NULL,
  `final_hit` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `unjustified` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `war` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `death_id` (`death_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `killers`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `group_id` int(11) NOT NULL DEFAULT '1',
  `account_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '1',
  `vocation` int(11) NOT NULL DEFAULT '0',
  `health` int(11) NOT NULL DEFAULT '150',
  `healthmax` int(11) NOT NULL DEFAULT '150',
  `experience` bigint(20) NOT NULL DEFAULT '0',
  `lookbody` int(11) NOT NULL DEFAULT '0',
  `lookfeet` int(11) NOT NULL DEFAULT '0',
  `lookhead` int(11) NOT NULL DEFAULT '0',
  `looklegs` int(11) NOT NULL DEFAULT '0',
  `looktype` int(11) NOT NULL DEFAULT '136',
  `lookaddons` int(11) NOT NULL DEFAULT '0',
  `maglevel` int(11) NOT NULL DEFAULT '0',
  `mana` int(11) NOT NULL DEFAULT '0',
  `manamax` int(11) NOT NULL DEFAULT '0',
  `manaspent` int(11) NOT NULL DEFAULT '0',
  `soul` int(10) unsigned NOT NULL DEFAULT '0',
  `town_id` int(11) NOT NULL DEFAULT '0',
  `posx` int(11) NOT NULL DEFAULT '0',
  `posy` int(11) NOT NULL DEFAULT '0',
  `posz` int(11) NOT NULL DEFAULT '0',
  `conditions` blob NOT NULL,
  `cap` int(11) NOT NULL DEFAULT '0',
  `sex` int(11) NOT NULL DEFAULT '0',
  `lastlogin` bigint(20) unsigned NOT NULL DEFAULT '0',
  `lastip` int(10) unsigned NOT NULL DEFAULT '0',
  `save` tinyint(1) NOT NULL DEFAULT '1',
  `skull` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `skulltime` int(11) NOT NULL DEFAULT '0',
  `rank_id` int(11) NOT NULL DEFAULT '0',
  `guildnick` varchar(255) NOT NULL DEFAULT '',
  `lastlogout` bigint(20) unsigned NOT NULL DEFAULT '0',
  `blessings` tinyint(2) NOT NULL DEFAULT '0',
  `balance` bigint(20) NOT NULL DEFAULT '0',
  `stamina` bigint(20) NOT NULL DEFAULT '151200000' COMMENT 'stored in miliseconds',
  `direction` int(11) NOT NULL DEFAULT '2',
  `loss_experience` int(11) NOT NULL DEFAULT '100',
  `loss_mana` int(11) NOT NULL DEFAULT '100',
  `loss_skills` int(11) NOT NULL DEFAULT '100',
  `loss_containers` int(11) NOT NULL DEFAULT '100',
  `loss_items` int(11) NOT NULL DEFAULT '100',
  `premend` int(11) NOT NULL DEFAULT '0' COMMENT 'NOT IN USE BY THE SERVER',
  `online` tinyint(1) NOT NULL DEFAULT '0',
  `marriage` int(10) unsigned NOT NULL DEFAULT '0',
  `marrystatus` int(10) unsigned NOT NULL DEFAULT '0',
  `promotion` int(11) NOT NULL DEFAULT '0',
  `deleted` tinyint(1) NOT NULL DEFAULT '0',
  `description` varchar(255) NOT NULL DEFAULT '',
  `cast` tinyint(4) NOT NULL DEFAULT '0',
  `castViewers` int(11) NOT NULL DEFAULT '0',
  `castDescription` varchar(255) NOT NULL,
  `auction_balance` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`deleted`),
  KEY `account_id` (`account_id`),
  KEY `group_id` (`group_id`),
  KEY `online` (`online`),
  KEY `deleted` (`deleted`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Extraindo dados da tabela `players`
--

INSERT INTO `players` (`id`, `name`, `world_id`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `lookaddons`, `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `rank_id`, `guildnick`, `lastlogout`, `blessings`, `balance`, `stamina`, `direction`, `loss_experience`, `loss_mana`, `loss_skills`, `loss_containers`, `loss_items`, `premend`, `online`, `marriage`, `marrystatus`, `promotion`, `deleted`, `description`, `cast`, `castViewers`, `castDescription`, `auction_balance`) VALUES
(1, 'Account Manager', 0, 1, 1, 1, 0, 150, 150, 0, 0, 0, 0, 0, 110, 0, 0, 0, 0, 0, 0, 2, 32360, 31782, 7, '', 400, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 201660000, 0, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, '', 0, 0, '', 0),
(2, 'Rook Sample', 0, 1, 1, 1, 0, 150, 150, 0, 0, 0, 0, 0, 136, 0, 0, 150, 150, 0, 100, 6, 32097, 32219, 7, '', 400, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 201660000, 0, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, '', 0, 0, '', 0),
(3, 'Sorcerer Sample', 0, 1, 1, 8, 1, 150, 150, 4200, 0, 0, 0, 0, 138, 0, 4, 150, 150, 0, 100, 2, 32360, 31782, 7, '', 400, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 201660000, 0, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, '', 0, 0, '', 0),
(4, 'Druid Sample', 0, 1, 1, 8, 2, 150, 150, 4200, 0, 0, 0, 0, 138, 0, 4, 150, 150, 0, 100, 2, 32360, 31782, 7, '', 400, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 201660000, 0, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, '', 0, 0, '', 0),
(5, 'Paladin Sample', 0, 1, 1, 8, 3, 150, 150, 4200, 0, 0, 0, 0, 137, 0, 4, 150, 150, 0, 100, 2, 32360, 31782, 7, '', 400, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 201660000, 0, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, '', 0, 0, '', 0),
(6, 'Knight Sample', 0, 1, 1, 8, 4, 150, 150, 4200, 0, 0, 0, 0, 139, 0, 4, 150, 150, 0, 100, 2, 32360, 31782, 7, '', 400, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, 0, 201660000, 0, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, '', 0, 0, '', 0);

--
-- Gatilhos `players`
--
DROP TRIGGER IF EXISTS `oncreate_players`;
DELIMITER //
CREATE TRIGGER `oncreate_players` AFTER INSERT ON `players`
 FOR EACH ROW BEGIN
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 0, 10);
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 1, 10);
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 2, 10);
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 3, 10);
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 4, 10);
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 5, 10);
        INSERT INTO `player_skills` (`player_id`, `skillid`, `value`) VALUES (NEW.`id`, 6, 10);
END
//
DELIMITER ;
DROP TRIGGER IF EXISTS `ondelete_players`;
DELIMITER //
CREATE TRIGGER `ondelete_players` BEFORE DELETE ON `players`
 FOR EACH ROW BEGIN
        DELETE FROM `bans` WHERE `type` IN (2, 5) AND `value` = OLD.`id`;
        UPDATE `houses` SET `owner` = 0 WHERE `owner` = OLD.`id`;
END
//
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_deaths`
--

CREATE TABLE IF NOT EXISTS `player_deaths` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `date` bigint(20) unsigned NOT NULL,
  `level` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `player_deaths`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_depotitems`
--

CREATE TABLE IF NOT EXISTS `player_depotitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL COMMENT 'any given range, eg. 0-100 is reserved for depot lockers and all above 100 will be normal items inside depots',
  `pid` int(11) NOT NULL DEFAULT '0',
  `itemtype` int(11) NOT NULL,
  `count` int(11) NOT NULL DEFAULT '0',
  `attributes` blob NOT NULL,
  UNIQUE KEY `player_id_2` (`player_id`,`sid`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_depotitems`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_items`
--

CREATE TABLE IF NOT EXISTS `player_items` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `pid` int(11) NOT NULL DEFAULT '0',
  `sid` int(11) NOT NULL DEFAULT '0',
  `itemtype` int(11) NOT NULL DEFAULT '0',
  `count` int(11) NOT NULL DEFAULT '0',
  `attributes` blob NOT NULL,
  UNIQUE KEY `player_id_2` (`player_id`,`sid`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_items`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_killers`
--

CREATE TABLE IF NOT EXISTS `player_killers` (
  `kill_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  KEY `kill_id` (`kill_id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_killers`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_namelocks`
--

CREATE TABLE IF NOT EXISTS `player_namelocks` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `new_name` varchar(255) NOT NULL,
  `date` bigint(20) NOT NULL DEFAULT '0',
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_namelocks`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_skills`
--

CREATE TABLE IF NOT EXISTS `player_skills` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `skillid` tinyint(2) NOT NULL DEFAULT '0',
  `value` int(10) unsigned NOT NULL DEFAULT '0',
  `count` int(10) unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `player_id_2` (`player_id`,`skillid`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_skills`
--

INSERT INTO `player_skills` (`player_id`, `skillid`, `value`, `count`) VALUES
(2, 0, 10, 0),
(2, 1, 10, 0),
(2, 2, 10, 0),
(2, 3, 10, 0),
(2, 4, 10, 0),
(2, 5, 10, 0),
(2, 6, 10, 0),
(3, 0, 10, 0),
(3, 1, 10, 0),
(3, 2, 10, 0),
(3, 3, 10, 0),
(3, 4, 10, 0),
(3, 5, 10, 0),
(3, 6, 10, 0),
(4, 0, 10, 0),
(4, 1, 10, 0),
(4, 2, 10, 0),
(4, 3, 10, 0),
(4, 4, 10, 0),
(4, 5, 10, 0),
(4, 6, 10, 0),
(5, 0, 10, 0),
(5, 1, 10, 0),
(5, 2, 10, 0),
(5, 3, 10, 0),
(5, 4, 10, 0),
(5, 5, 10, 0),
(5, 6, 10, 0),
(6, 0, 10, 0),
(6, 1, 10, 0),
(6, 2, 10, 0),
(6, 3, 10, 0),
(6, 4, 10, 0),
(6, 5, 10, 0),
(6, 6, 10, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `player_spells`
--

CREATE TABLE IF NOT EXISTS `player_spells` (
  `player_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  UNIQUE KEY `player_id_2` (`player_id`,`name`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_spells`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_storage`
--

CREATE TABLE IF NOT EXISTS `player_storage` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `key` int(10) unsigned NOT NULL DEFAULT '0',
  `value` varchar(255) NOT NULL DEFAULT '0',
  UNIQUE KEY `player_id_2` (`player_id`,`key`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_storage`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `player_viplist`
--

CREATE TABLE IF NOT EXISTS `player_viplist` (
  `player_id` int(11) NOT NULL,
  `vip_id` int(11) NOT NULL,
  UNIQUE KEY `player_id_2` (`player_id`,`vip_id`),
  KEY `player_id` (`player_id`),
  KEY `vip_id` (`vip_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `player_viplist`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `polls`
--

CREATE TABLE IF NOT EXISTS `polls` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) NOT NULL,
  `poll` varchar(255) NOT NULL,
  `options` varchar(255) NOT NULL,
  `timestamp` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `polls`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `poll_votes`
--

CREATE TABLE IF NOT EXISTS `poll_votes` (
  `poll_id` int(11) NOT NULL,
  `votes` varchar(255) NOT NULL,
  `account_id` varchar(255) NOT NULL,
  KEY `poll_id` (`poll_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `poll_votes`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `server_config`
--

CREATE TABLE IF NOT EXISTS `server_config` (
  `config` varchar(35) NOT NULL DEFAULT '',
  `value` varchar(255) NOT NULL DEFAULT '',
  UNIQUE KEY `config` (`config`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_config`
--

INSERT INTO `server_config` (`config`, `value`) VALUES
('db_version', '25'),
('encryption', '2');

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_motd`
--

CREATE TABLE IF NOT EXISTS `server_motd` (
  `id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `text` text NOT NULL,
  UNIQUE KEY `id` (`id`,`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_motd`
--

INSERT INTO `server_motd` (`id`, `world_id`, `text`) VALUES
(1, 0, 'Welcome to The Forgotten Server!');

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_record`
--

CREATE TABLE IF NOT EXISTS `server_record` (
  `record` int(11) NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `timestamp` bigint(20) NOT NULL,
  UNIQUE KEY `record` (`record`,`world_id`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_record`
--

INSERT INTO `server_record` (`record`, `world_id`, `timestamp`) VALUES
(0, 0, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `server_reports`
--

CREATE TABLE IF NOT EXISTS `server_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `player_id` int(11) NOT NULL DEFAULT '1',
  `posx` int(11) NOT NULL DEFAULT '0',
  `posy` int(11) NOT NULL DEFAULT '0',
  `posz` int(11) NOT NULL DEFAULT '0',
  `timestamp` bigint(20) NOT NULL DEFAULT '0',
  `report` text NOT NULL,
  `reads` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `world_id` (`world_id`),
  KEY `reads` (`reads`),
  KEY `player_id` (`player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Extraindo dados da tabela `server_reports`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `tiles`
--

CREATE TABLE IF NOT EXISTS `tiles` (
  `id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `house_id` int(10) unsigned NOT NULL,
  `x` int(5) unsigned NOT NULL,
  `y` int(5) unsigned NOT NULL,
  `z` tinyint(2) unsigned NOT NULL,
  UNIQUE KEY `id` (`id`,`world_id`),
  KEY `x` (`x`,`y`,`z`),
  KEY `house_id` (`house_id`,`world_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `tiles`
--


-- --------------------------------------------------------

--
-- Estrutura da tabela `tile_items`
--

CREATE TABLE IF NOT EXISTS `tile_items` (
  `tile_id` int(10) unsigned NOT NULL,
  `world_id` tinyint(2) unsigned NOT NULL DEFAULT '0',
  `sid` int(11) NOT NULL,
  `pid` int(11) NOT NULL DEFAULT '0',
  `itemtype` int(11) NOT NULL,
  `count` int(11) NOT NULL DEFAULT '0',
  `attributes` blob NOT NULL,
  UNIQUE KEY `tile_id` (`tile_id`,`world_id`,`sid`),
  KEY `sid` (`sid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `tile_items`
--


--
-- Restrições para as tabelas dumpadas
--

--
-- Restrições para a tabela `account_viplist`
--
ALTER TABLE `account_viplist`
  ADD CONSTRAINT `account_viplist_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `account_viplist_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `environment_killers`
--
ALTER TABLE `environment_killers`
  ADD CONSTRAINT `environment_killers_ibfk_1` FOREIGN KEY (`kill_id`) REFERENCES `killers` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `guild_invites`
--
ALTER TABLE `guild_invites`
  ADD CONSTRAINT `guild_invites_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `guild_invites_ibfk_2` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `guild_kills`
--
ALTER TABLE `guild_kills`
  ADD CONSTRAINT `guild_kills_ibfk_1` FOREIGN KEY (`war_id`) REFERENCES `guild_wars` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `guild_kills_ibfk_2` FOREIGN KEY (`death_id`) REFERENCES `player_deaths` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `guild_kills_ibfk_3` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `guild_ranks`
--
ALTER TABLE `guild_ranks`
  ADD CONSTRAINT `guild_ranks_ibfk_1` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `guild_wars`
--
ALTER TABLE `guild_wars`
  ADD CONSTRAINT `guild_wars_ibfk_1` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `guild_wars_ibfk_2` FOREIGN KEY (`enemy_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `house_auctions`
--
ALTER TABLE `house_auctions`
  ADD CONSTRAINT `house_auctions_ibfk_1` FOREIGN KEY (`house_id`, `world_id`) REFERENCES `houses` (`id`, `world_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `house_auctions_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `house_data`
--
ALTER TABLE `house_data`
  ADD CONSTRAINT `house_data_ibfk_1` FOREIGN KEY (`house_id`, `world_id`) REFERENCES `houses` (`id`, `world_id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `house_lists`
--
ALTER TABLE `house_lists`
  ADD CONSTRAINT `house_lists_ibfk_1` FOREIGN KEY (`house_id`, `world_id`) REFERENCES `houses` (`id`, `world_id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `killers`
--
ALTER TABLE `killers`
  ADD CONSTRAINT `killers_ibfk_1` FOREIGN KEY (`death_id`) REFERENCES `player_deaths` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `players`
--
ALTER TABLE `players`
  ADD CONSTRAINT `players_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_deaths`
--
ALTER TABLE `player_deaths`
  ADD CONSTRAINT `player_deaths_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_depotitems`
--
ALTER TABLE `player_depotitems`
  ADD CONSTRAINT `player_depotitems_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_items`
--
ALTER TABLE `player_items`
  ADD CONSTRAINT `player_items_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_killers`
--
ALTER TABLE `player_killers`
  ADD CONSTRAINT `player_killers_ibfk_1` FOREIGN KEY (`kill_id`) REFERENCES `killers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `player_killers_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_namelocks`
--
ALTER TABLE `player_namelocks`
  ADD CONSTRAINT `player_namelocks_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_skills`
--
ALTER TABLE `player_skills`
  ADD CONSTRAINT `player_skills_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_spells`
--
ALTER TABLE `player_spells`
  ADD CONSTRAINT `player_spells_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_storage`
--
ALTER TABLE `player_storage`
  ADD CONSTRAINT `player_storage_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `player_viplist`
--
ALTER TABLE `player_viplist`
  ADD CONSTRAINT `player_viplist_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `player_viplist_ibfk_2` FOREIGN KEY (`vip_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `polls`
--
ALTER TABLE `polls`
  ADD CONSTRAINT `polls_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `poll_votes`
--
ALTER TABLE `poll_votes`
  ADD CONSTRAINT `poll_votes_ibfk_1` FOREIGN KEY (`poll_id`) REFERENCES `polls` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `server_reports`
--
ALTER TABLE `server_reports`
  ADD CONSTRAINT `server_reports_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `tiles`
--
ALTER TABLE `tiles`
  ADD CONSTRAINT `tiles_ibfk_1` FOREIGN KEY (`house_id`, `world_id`) REFERENCES `houses` (`id`, `world_id`) ON DELETE CASCADE;

--
-- Restrições para a tabela `tile_items`
--
ALTER TABLE `tile_items`
  ADD CONSTRAINT `tile_items_ibfk_1` FOREIGN KEY (`tile_id`) REFERENCES `tiles` (`id`) ON DELETE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
