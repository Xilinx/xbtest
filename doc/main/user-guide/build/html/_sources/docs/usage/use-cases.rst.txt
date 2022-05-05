
.. include:: ../../../../shared/links.rst
.. include:: ../shared/include.rst

##########################################################################
Use cases
##########################################################################

xbtest supports the following different uses cases described in next sections:

.. contents::
    :depth: 1
    :local:

********************************************************
Multiple tests / cards
********************************************************

xbtest can dispatch tests targeting multiple cards (possibly set with different deployment platforms) simultaneously. Different series of tests can also be dispatched on one or more cards.

In this case, only the card and test status are reported in the console and stored for all targeted cards.

.. note::
    In case of reset on one card, the tests running on other cards are not interrupted.

      * But all or some tests following reset may fail for this specific card before the reset has completed.

********************************************************
Single test
********************************************************

When running a single test on a single card, xbtest also reports the |test cases| status for the targeted card and the result directory structure is simplified.