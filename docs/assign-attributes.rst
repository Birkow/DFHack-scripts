assign-attributes
=================

.. dfhack-tool::
    :summary: Adjust physical and mental attributes.
    :tags: fort armok units

Attributes are divided into tiers from -4 to 4. Tier 0 is the standard level and
represents the average values for that attribute, tier 4 is the maximum level,
and tier -4 is the minimum level.

For more information on attributes, please see the :wiki:`wiki <Attribute>`.

Usage
-----

::

    assign-attributes [--unit <id>] <options>

Please run::

    devel/query --table df --maxdepth 1 --search [ physical_attribute_type mental_attribute_type ]

to see the list of valid attribute tokens.

Example
-------

::

    assign-attributes --reset --attributes [ STRENGTH 2 AGILITY -1 SPATIAL_SENSE -1 ]

This will reset all attributes to a neutral value and will then set the
following values (the ranges will differ based on race; this example assumes
a dwarf is selected in the UI):

 * Strength: a random value between 1750 and 1999 (tier 2);
 * Agility: a random value between 401 and 650 (tier -1);
 * Spatial sense: a random value between 1043 and 1292 (tier -1).

The final result will be: "She is very strong, but she is clumsy. She has a
questionable spatial sense."

Options
-------


``--unit <id>``
    The target unit ID. If not present, the currently selected unit will be the
    target.
``--attributes [ <attribute> <tier> [<attribute> <tier> ...] ]``
    The list of the attributes to modify and their tiers. The valid attribute
    names can be found in the :wiki:`Attribute` (substitute any space with
    underscores). Tiers range from -4 to 4. There must be a space before and
    after each square bracket.
``--reset``
    Reset all attributes to the average level (tier 0). If both this option and
    ``attributes`` are specified, the unit attributes will be reset and then the
    listed attributes will be modified.

Tiers
-----

The tier corresponds to the text that DF will use to describe a unit with
attributes in that tier's range. For example, here is the mapping for the
"Strength" attribute:

====  ===================
Tier  Description
====  ===================
4     unbelievably strong
3     mighty
2     very strong
1     strong
0     (no description)
-1    weak
-2    very weak
-3    unquestionably weak
-4    unfathomably weak
====  ===================
