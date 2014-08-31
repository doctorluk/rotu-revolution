############################################################################################
#                                                                                          #
# title:         B3 plugin that saves statistics to a MySQL database for                   #
#                Reign of the Undead - Revolution, a Call of Duty 4: Modern Warfare mod    #
#                                                                                          #
# author:        FNRP-Sphere                                                               #
# website:       www.fnrp-servers.com                                                      #
# date:          31-08-2014                                                                #
#                                                                                          #
# installation:  1. create two new tables in the database using the rotustats.sql file     #
#                2. copy rotustats.py to b3/extplugins/ dir                                #
#                3. copy rotustats.xml to b3/extplugins/conf/ dir                          #
#                4. modify the rotustats.xml file, at least supply the                     #
#                   database information                                                   #
#                5. modify the B3 main config file,                                        #
#                   add the following line to the plugins section:                         #
#                                                                                          #
#                   <plugin name="rotustats" config="@b3/extplugins/conf/rotustats.xml"/>  #
#                                                                                          #
#                6. (re)start B3                                                           #
#                                                                                          #
# compatibility: - RotU-Revolution 0.6 Alpha or above                                      #
#                - only tested on python 2.6/2.7, may not work on python 3.x (use          #
#                  conversion script)                                                      #
#                - Not compatible with SQLite                                              #
#                                                                                          #
############################################################################################

__version__ = '1.0.0'
__author__  = 'FNRP-Sphere'

import re
import b3
import b3.storage
from b3.plugin import Plugin
from b3.events import eventManager, Event
from b3.parsers.cod4 import Cod4Parser
from datetime import datetime

# monkey patch the COD4 parser to generate the events we are interested in
def patchCod4Parser():
  lf = [
         re.compile(r"""^(?P<action>ROTU_STATS_GAME);
                         (?P<data>                             # data open parenthesis!
                           (?P<version>     [^;]     *      );   # server version
                           (?P<win>         [0-1]    {1}    );   # won game: 1, lose game: 0
                           (?P<killed>      [0-9]    {1,6}  );   # amount of zombies killed
                           (?P<duration>    [0-9]    {1,10} );   # played time in milliseconds
                           (?P<wave>        [0-9]    {1,3}  );   # waves played
                           (?P<map>         \w       {3,32} )    # map name
                         )$""", re.IGNORECASE|re.X),           # data closing parenthesis!

         re.compile(r"""^(?P<action>ROTU_STATS_PLAYER);
                         (?P<data>                             # data open parenthesis!
                           (?P<guid>        [0-9a-f] {32}   );   # guid
                           (?P<name>        [^;]     {1,32} );   # name
                           (?P<role>        [a-zA-Z] {3,16} );   # role
                           (?P<kills>       [0-9]    {1,6}  );   # zombies killed
                           (?P<assists>     [0-9]    {1,6}  );   # assists
                           (?P<deaths>      [0-9]    {1,3}  );   # deaths
                           (?P<downtime>    [0-9]    {1,10} );   # down time in milliseconds
                           (?P<revives>     [0-9]    {1,3}  );   # number of revived players
                           (?P<heals>       [0-9]    {1,6}  );   # health given in health points
                           (?P<ammo>        [0-9]    {1,6}  );   # ammo given
                           (?P<damage>      [0-9]    {1,10} );   # damage dealt
                           (?P<damageboss>  [0-9]    {1,10} );   # damage dealt to boss
                           (?P<turretkills> [0-9]    {1,6}  );   # turret kills
                           (?P<points>      [0-9]    {1,10} );   # current points
                           (?P<spent>       [0-9]    {1,10} );   # points spent
                           (?P<exkills>     [0-9]    {1,6}  );   # explosion kills
                           (?P<knifekills>  [0-9]    {1,6}  );   # knife kills
                           (?P<zombie>      [0-9]    {1,3}  );   # times turned into zombie
                           (?P<ignited>     [0-9]    {1,6}  );   # flamethrower damage
                           (?P<poisoned>    [0-9]    {1,6}  );   # times poisoned (metric?)
                           (?P<hskills>     [0-9]    {1,6}  );   # headshot kills
                           (?P<repairs>     [0-9]    {1,6}  )    # repaired barriers
                         )$""", re.IGNORECASE|re.X),           # data closing parenthesis!

         re.compile(r'^(?P<action>ROTU_STATS_DONE);(?P<data>.*)$', re.IGNORECASE)
       ]

  lf.extend(Cod4Parser._lineFormats)
  Cod4Parser._lineFormats = tuple(lf)

  global EVT_ROTU_STATS_GAME
  global EVT_ROTU_STATS_PLAYER
  global EVT_ROTU_STATS_DONE

  EVT_ROTU_STATS_GAME   = eventManager.createEvent('EVT_ROTU_STATS_GAME',   'rotu game stats')
  EVT_ROTU_STATS_PLAYER = eventManager.createEvent('EVT_ROTU_STATS_PLAYER', 'rotu player stats')
  EVT_ROTU_STATS_DONE   = eventManager.createEvent('EVT_ROTU_STATS_DONE',   'rotu stats done')

  def OnRotu_stats_game(self, action, data, match=None):
    return Event(EVT_ROTU_STATS_GAME, data=match)

  def OnRotu_stats_player(self, action, data, match=None):
    return Event(EVT_ROTU_STATS_PLAYER, data=match)

  def OnRotu_stats_done(self, action, data, match=None):
    return Event(EVT_ROTU_STATS_DONE, data=None)

  Cod4Parser.OnRotu_stats_game   = OnRotu_stats_game
  Cod4Parser.OnRotu_stats_player = OnRotu_stats_player
  Cod4Parser.OnRotu_stats_done   = OnRotu_stats_done

class RotustatsPlugin(Plugin):
  requiresConfigFile = True
  _statsGameTable    = 'rotustats_game'
  _statsPlayerTable  = 'rotustats_player'
  _storage = None
  _dsn     = ''
  _logToDB = True
  _validID = False
  _ID      = None
  _IP      = '127.0.0.1'
  _port    = 1337

  def startup(self):
    patchCod4Parser()
    self.readConfig()

    if self._logToDB:
      self._storage = b3.storage.getStorage('database', self._dsn, self.console)
      self.debug('succesfully connected to database: %s' % self._storage.status())
      self.checkTablesExist()

    self.registerEvent(EVT_ROTU_STATS_GAME)
    self.registerEvent(EVT_ROTU_STATS_PLAYER)
    self.registerEvent(EVT_ROTU_STATS_DONE)

    self.debug('Started')

  def onEvent(self, event):
    if event.type == EVT_ROTU_STATS_GAME:
      self.debug('event EVT_ROTU_STATS_GAME:   %s' % (event.data.group('map')))
      self.onStatsGame(event.data)
    if event.type == EVT_ROTU_STATS_PLAYER:
      self.debug('event EVT_ROTU_STATS_PLAYER: %s' % (event.data.group('name')))
      self.onStatsPlayer(event.data)
    if event.type == EVT_ROTU_STATS_DONE:
      self.debug('event EVT_ROTU_STATS_DONE')
      self.onStatsDone()

  def onStatsGame(self, m):
    if self._logToDB:
      self.logStatsGameDB(m)

  def onStatsPlayer(self, m):
    if self._logToDB:
      self.logStatsGamePlayer(m)

  def onStatsDone(self):
    self._validID = False
    self._storage.closeConnection()

  def logStatsGameDB(self, m):
    q = """INSERT INTO `%s`
           (`version`, `win`, `zombiesKilled`, `gameDuration`,
            `waveNumber`, `mapname`, `ip`, `port`, `date`) VALUES(
            '%s', %d, %d, %d,
            %d, '%s', '%s', %d, '%s');""" % (self._statsGameTable,
                                             m.group('version'),
                                             int(m.group('win')),
                                             int(m.group('killed')),
                                             int(m.group('duration')),
                                             int(m.group('wave')),
                                             m.group('map'),
                                             self._IP,
                                             self._port,
                                             datetime.today().strftime('%Y-%m-%d %H:%M:%S'))

    if not self._storage.status():
      self._storage.connect()

    try:
      self._storage.query(q)
      self._storage.db.commit()
    except Exception as e:
      self.debug('LogStatsGameDB() insert exception: %s' % str(e))
      self.debug('LogStatsGameDB() query: %s' % q)
      self._validID = False
      return

    try:
      cursor = self._storage.query('SELECT MAX(`id`) AS maxid FROM `%s`' % self._statsGameTable)
      self._ID = int(cursor.getValue('maxid'))
    except Exception as e:
      self.debug('LogStatsGameDB() maxid exception: %s' % str(e))
      self.debug('LogStatsGameDB() query: %s' % q)
      self._validID = False
    else:
      self._validID = True

  def logStatsGamePlayer(self, m):
    if not self._validID:
      self.debug('logStatsGamePlayer(): _validID == False')
      return

    q = """INSERT INTO `%s`
           (`id`, `guid`, `name`, `role`,
            `kills`, `assists`, `deaths`, `downtime`,
            `revives`, `healsGiven`, `ammoGiven`, `damageDealt`,
            `damageDealtToBoss`, `turretKills`, `upgradepoints`, `upgradepointsspent`,
            `explosiveKills`, `knifeKills`, `timesZombie`, `ignitions`,
            `poisons`, `headshotKills`, `barriersRestored`) VALUES(
            %d, '%s', '%s', '%s',
            %d, %d, %d, %d,
            %d, %d, %d, %d,
            %d, %d, %d, %d,
            %d, %d, %d, %d,
            %d, %d, %d);""" % (self._statsPlayerTable,
                               self._ID,                   m.group('guid'),
                               m.group('name'),            m.group('role'),
                               int(m.group('kills')),      int(m.group('assists')),
                               int(m.group('deaths')),     int(m.group('downtime')),
                               int(m.group('revives')),    int(m.group('heals')),
                               int(m.group('ammo')),       int(m.group('damage')),
                               int(m.group('damageboss')), int(m.group('turretkills')),
                               int(m.group('points')),     int(m.group('spent')),
                               int(m.group('exkills')),    int(m.group('knifekills')),
                               int(m.group('zombie')),     int(m.group('ignited')),
                               int(m.group('poisoned')),   int(m.group('hskills')),
                               int(m.group('repairs')))
    try:
      self._storage.query(q)
      self._storage.db.commit()
    except Exception as e:
      self.debug('LogStatsPlayerDB() insert exception: %s' % str(e))
      self.debug('LogStatsPlayerDB() query: %s' % q)

  def checkTablesExist(self):
    try:
      cursor = self._storage.query("SHOW TABLES LIKE '%s'" % self._statsGameTable)

      if cursor.rowcount == 1:
        self.debug('table %s exists' % self._statsGameTable)
      else:
        self.critical('table %s does not exist!' % self._statsGameTable)
        self.critical('critical error, cannot continue, disabling plugin')
        self.disable()

      cursor = self._storage.query("SHOW TABLES LIKE '%s'" % self._statsPlayerTable)

      if cursor.rowcount == 1:
        self.debug('table %s exists' % self._statsPlayerTable)
      else:
        self.critical('table %s does not exist!' % self._statsPlayerTable)
        self.critical('critical error, cannot continue, disabling plugin')
        self.disable()

    except Exception as e:
      self.debug('checkTablesExist() show tables exception: %s' % str(e))

  def readConfig(self):
    if self.config.has_option('database', 'enabled'):
      self._logToDB = self.config.getboolean('database', 'enabled')
      self.debug('config: database/enabled set: %s' % self._logToDB)
    else:
      self.debug('config: database/enabled not set, using default: %s' % self._logToDB)

    if self.config.has_option('database', 'dsn'):
      self._dsn = self.config.get('database', 'dsn')
      self.debug('config: database/dsn set')
    else:
      self.critical('config: database/dsn not set')
      self.critical('critical error, cannot continue, disabling plugin')
      self.disable()

    if self.config.has_option('database', 'stats_player_table'):
      self._statsPlayerTable = self.config.get('database', 'stats_player_table')
      self.debug('config: database/stats_player_table set: %s' % self._statsPlayerTable)
    else:
      self.debug('config: database/stats_player_table not set, using default: %s' % self._statsPlayerTable)

    if self.config.has_option('database', 'stats_game_table'):
      self._statsGameTable = self.config.get('database', 'stats_game_table')
      self.debug('config: database/stats_game_table set: %s' % self._statsGameTable)
    else:
      self.debug('config: database/stats_game_table not set, using default: %s' % self._statsGameTable)

    if self.console.config.has_option('server', 'public_ip'):
      self._IP = self.console.config.get('server', 'public_ip')
      self.debug('config: b3/public_ip set: %s' % self._IP)
    else:
      self.debug('config: b3/public_ip not set in B3 config, using default: %s' % self._IP)

    if self.console.config.has_option('server', 'port'):
      self._port = self.console.config.getint('server', 'port')
      self.debug('config: b3/port set: %d' % self._port)
    else:
      self.debug('config: b3/port not set in B3 config, using default: %d' % self._port)
