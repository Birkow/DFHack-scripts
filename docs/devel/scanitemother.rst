devel/scanitemother
===================

.. dfhack-tool::
    :summary: Display the item lists that the selected item is part of.
    :tags: dev

When an item is selected in the UI, this tool will list the indices in
``world.item.other[]`` where the item appears. For example, if a piece of good
meat is selected in the UI, this tool might output::

    IN_PLAY
    ANY_GOOD_FOOD
    ANY_EDIBLE_RAW
    ANY_EDIBLE_CARNIVORE
    ANY_EDIBLE_BONECARN
    ANY_EDIBLE_VERMIN
    ANY_EDIBLE_VERMIN_BOX
    ANY_CAN_ROT
    ANY_COOKABLE
    MEAT

Usage
-----

::

    devel/scanitemother
