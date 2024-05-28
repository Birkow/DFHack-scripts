autonick
========

.. dfhack-tool::
    :summary: Give dwarves random unique nicknames.
    :tags: fort productivity units

Names are chosen randomly from the ``dfhack-config/autonick.txt`` config file,
which you can edit with your own preferred names, if you like.

Dwarves who already have nicknames will keep the nicknames they have, and no
other dwarf will be assigned that nickname.

If there are fewer available nicknames than dwarves, the remaining
dwarves will go un-nicknamed.

Usage
-----

::

    autonick all [<options>]

You may wish to use this script with the "repeat" command so that new migrants
automatically get nicknamed::

    repeat -name autonick -time 3 -timeUnits months -command [ autonick all ]

Options
-------

``-q``, ``--quiet``
    Do not report how many dwarves were given nicknames.

Config file format
------------------

The ``dfhack-config/autonick.txt`` config file has a simple format:

- One nickname per line
- Empty lines, lines beginning with ``#``, and repeat entries are discarded

You can add any nicknames you like!
