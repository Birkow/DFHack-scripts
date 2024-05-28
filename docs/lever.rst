lever
=====

.. dfhack-tool::
    :summary: Inspect and pull levers.
    :tags: fort armok inspection productivity buildings

Usage
-----

``lever list``
    Print out a list of your fort's levers, including their ID, name, activation
    state, and what they are linked to (if anything).
``lever pull [<options>]``
    Queue a job so a dwarf will pull the lever. This is the same as selecting
    the lever and triggering a pull job in the UI.
``lever show``
    If a lever is selected, print information about it.
``lever show --id <id>``
    Center the display on the specified lever and print information about it.

Examples
--------

``lever pull --id 42 --priority``
    Queue a job to pull lever 42 at high priority.
``lever pull --id 42 --instant``
    Skip the job and pull the lever with the hand of Armok!

Options
-------

``--id``
    Select the lever by ID to show/pull. Uses the currently selected lever if
    not specified.
``--priority``
    Queue a job at high priority.
``--instant``
    Instantly toggle the lever without a job.
