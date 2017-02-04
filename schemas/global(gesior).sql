-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Servidor: localhost
-- Tempo de Geração: Fev 04, 2017 as 03:53 
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
  `vip_time` int(11) NOT NULL DEFAULT '0',
  `loot_time` int(15) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=2 ;

--
-- Extraindo dados da tabela `accounts`
--

INSERT INTO `accounts` (`id`, `name`, `password`, `salt`, `premdays`, `lastday`, `email`, `key`, `blocked`, `warnings`, `group_id`, `vip_time`, `loot_time`) VALUES
(1, '1', '1', '', 65535, 0, '', '0', 0, 0, 1, 0, 0);

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
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=9 ;

--
-- Extraindo dados da tabela `players`
--


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
  `value` int(11) NOT NULL,
  UNIQUE KEY `config` (`config`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Extraindo dados da tabela `server_config`
--

INSERT INTO `server_config` (`config`, `value`) VALUES
('db_version', 23);

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
