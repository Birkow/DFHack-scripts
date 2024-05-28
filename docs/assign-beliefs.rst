assign-beliefs
==============

.. dfhack-tool::
    :summary: Adjust a unit's beliefs and values.
    :tags: fort armok units

Beliefs are defined with the belief token and a number from -3 to 3,
which describes the different levels of belief strength, as explained on the
:wiki:`wiki <Personality_trait>`.

Usage
-----

::

    assign-beliefs [--unit <id>] <options>

Please run ``devel/query --table df.value_type`` to see the list of valid belief
tokens.

Example
-------

::

    assign-beliefs --reset --beliefs [ TRADITION 2 CRAFTSMANSHIP 3 POWER 0 CUNNING -1 ]

Resets all the unit beliefs, then sets the listed beliefs to the following
values:

* Tradition: a random value between 26 and 40 (level 2);
* Craftsmanship: a random value between 41 and 50 (level 3);
* Power: a random value between -10 and 10 (level 0);
* Cunning: a random value between -25 and -11 (level -1).

The final result (for a dwarf) will be: "She personally is a firm believer in
the value of tradition and sees guile and cunning as indirect and somewhat
worthless."

Note that the beliefs aligned with the cultural values of the unit have not
triggered a report.

Options
-------

``--unit <id>``
    The target unit ID. If not present, the currently selected unit will be the
    target.
``--beliefs [ <belief> <level> [<belief> <level> ...] ]``
    The list of the beliefs to modify and their levels. The valid belief tokens
    can be found in the :wiki:`Personality_trait` (substitute any space with
    underscores). Levels range from -3 to 3. There must be a space before and
    after each square bracket.
``--reset``
    Reset all beliefs to a neutral level, aligned with the unit's race's
    cultural values. If both this option and ``--beliefs`` are specified, the
    unit's beliefs will be reset and then the listed beliefs will be modified.

Belief strengths
----------------

The belief strength corresponds to the text that DF will use to describe a
unit's beliefs:

========  =========
Strength  Effect
========  =========
3         Highest
2         Very High
1         High
0         Neutral
-1        Low
-2        Very Low
-3        Lowest
========  =========

Resetting a belief means setting it to a level that does not trigger a report in
the "Thoughts and preferences" screen, which is dependent on the race of the
unit.
