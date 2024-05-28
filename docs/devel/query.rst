devel/query
===========

.. dfhack-tool::
    :summary: Search/print data algorithmically.
    :tags: dev inspection

Query is a useful script for finding and reading values of data structure
fields. Players can use it to explore data structures or list elements of enums
that they might need for another command. Developers can even integrate this
script into another script to print data out for a player.

This script takes your data selection (e.g. a data table, unit, item, tile,
etc.) and recursively iterates through it, outputting names and values of what
it finds.

As it iterates, you can have it do other things, like search for fields that
match a `Lua pattern <https://www.lua.org/manual/5.3/manual.html#6.4.1>`__ or
set the value of specific fields.

.. Warning::

    This script searches recursive data structures. You can, fairly easily,
    cause an infinite loop. You can even more easily run a query that simply
    requires an inordinate amount of time to complete. Set your limits wisely!

.. Tip::

    Should the need arise, you can stop ``devel/query`` from another shell with
    `kill-lua`, e.g. by running ``dfhack-run kill-lua`` from another terminal.

Usage
-----

::

    devel/query <source option> <query options> [<additional options>]

Examples
--------

``devel/query --unit --getfield id``
    Prints the id of the selected unit.
``devel/query --unit --search STRENGTH --maxdepth 3``
    Prints out information about the selected unit's ``STRENGTH`` attribute.
``devel/query --unit --search physical_attrs --maxdepth 3``
    Prints out information about all of the selected unit's physical attributes.
``devel/query --tile --search designation``
    Prints out information about the selected tile's designation structure.
``devel/query --tile --search "occup.*carv"``
    Prints out information about the carving configuration for the selected
    tile.
``devel/query --table df --maxdepth 0``
    List the top-level fields in the ``df`` data structure.
``devel/query --table df.profession --findvalue FISH``
    Lists the enum values in the ``df.profession`` table that contain the
    substring ``FISH``.

Source options
--------------

``--table <identifier>``
    Selects the specified table. You must use dot notation to denote sub-tables,
    e.g. ``df.global.world``.
``--block``
    Selects the highlighted tile's block.
``--building``
    Selects the highlighted building.
``--item``
    Selects the highlighted item.
``--job``
    Selects the highlighted job.
``--plant``
    Selects the highlighted plant.
``--tile``
    Selects the highlighted tile's block, and then uses the tile's local
    position to index the 2D data.
``--unit``
    Selects the highlighted unit.
``--script <script>``
    Selects the specified script (which must support being included with
    `reqscript() <reqscript>`).
``--json <file>``
    Loads the specified json file as a table to query. The path starts at the DF
    root directory, e.g. :file:`hack/scripts/dwarf_profiles.json`.

Query options
-------------

``--getfield <field>``
    Gets the specified field from the source.
``--search <pattern> [<pattern>]``
    Searches the source for field names with substrings matching any of the
    specified patterns.
``--findvalue <value>``
    Searches the source for field values matching the specified value.
``--maxdepth <value>``
    Limits the field recursion depth (default: 7).
``--maxlength <value>``
    Limits the number of items that the script will iterate through in a list
    (default: 2048).
``--excludetypes [a|bfnstu0]``
    Excludes native Lua data types. Single letters correspond to (in order):
    (a)ll types listed here, (b)oolean, (f)unction, (n)umber, (s)tring, (t)able,
    (u)serdata, nil values.
``--excludekinds [a|bces]``
    Excludes DF data types. Single letters correspond to (in order): (a)ll types
    listed here, (b)itfields, (c)lasses, (e)nums, (s)tructs.
``--dumb``
    Disables intelligent checking for recursive data structures (loops) and
    increases the ``--maxdepth`` to 25 if a value is not already present.

General options
---------------

``--showpaths``
    Displays the full path of a field instead of indenting.
``--setvalue <value>``
    Attempts to set the values of any printed fields. Supported types: boolean,
    string, integer.
``--oneline``
    Reduces output to one line (except with ``--debugdata``) in cases where
    multiple lines of information is displayed for a field.
``--alignto <value>``
    Specifies the alignment column.
``--nopointers``
    Disables printing values which contain memory addresses.
``--debug <value>``
    Enables debug log verbosity for entries equal to or less than the value
    provided (valid values: 0-3).
``--debugdata``
    Prints type information under each field.
