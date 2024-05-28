devel/eventful-client
=====================

.. dfhack-tool::
    :summary: Simple client for testing event callbacks.
    :tags: dev

You can use this tool to discover when specific events fire and to test when
callbacks are called for different callback frequency settings.

Note this script does not handle the eventful reaction or workshop events.

Usage
-----

::

    devel/eventful-client help
    devel/eventful-client add <event type> <frequency>
    devel/eventful-client add all <frequency>
    devel/eventful-client list
    devel/eventful-client clear

:help:  shows this help text and a list of valid event types
:add:   add a handler for the named event type at the requested tick frequency
:list:  lists active handlers and their metadata
:clear: unregisters all handlers
