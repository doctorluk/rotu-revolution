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
