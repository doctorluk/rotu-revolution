SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
--
-- Table structure for table `rotustats_game`
--

DROP TABLE IF EXISTS `rotustats_game`;
CREATE TABLE IF NOT EXISTS `rotustats_game` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` text NOT NULL,
  `win` tinyint(3) unsigned NOT NULL,
  `zombiesKilled` int(10) unsigned NOT NULL,
  `gameDuration` bigint(20) unsigned NOT NULL,
  `waveNumber` int(11) NOT NULL,
  `mapname` text NOT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

-- --------------------------------------------------------

--
-- Table structure for table `rotustats_player`
--

DROP TABLE IF EXISTS `rotustats_player`;
CREATE TABLE IF NOT EXISTS `rotustats_player` (
  `id` int(10) unsigned NOT NULL,
  `guid` text NOT NULL,
  `name` text NOT NULL,
  `role` text NOT NULL,
  `kills` int(10) unsigned NOT NULL,
  `assists` int(10) unsigned NOT NULL,
  `deaths` int(10) unsigned NOT NULL,
  `downtime` bigint(20) unsigned NOT NULL,
  `healsGiven` int(10) unsigned NOT NULL,
  `ammoGiven` int(10) unsigned NOT NULL,
  `damageDealt` int(10) unsigned NOT NULL,
  `damageDealtToBoss` int(10) unsigned NOT NULL,
  `turretKills` int(10) unsigned NOT NULL,
  `upgradepoints` int(10) unsigned NOT NULL,
  `upgradepointsSpent` int(10) unsigned NOT NULL,
  `explosiveKills` int(10) unsigned NOT NULL,
  `knifeKills` int(10) unsigned NOT NULL,
  `timesZombie` smallint(5) unsigned NOT NULL,
  `ignitions` int(10) unsigned NOT NULL,
  `poisons` int(10) unsigned NOT NULL,
  `headshotKills` int(10) unsigned NOT NULL,
  `barriersRestored` int(10) unsigned NOT NULL,
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
