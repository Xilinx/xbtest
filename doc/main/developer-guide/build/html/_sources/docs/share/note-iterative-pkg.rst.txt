
.. important::
    The steps :ref:`fill-platform-definition-json`, :ref:`build-rpm-and-deb-packages` and :ref:`complete-checklist` are part of an iterative process and are inter-linked.

      1. You need first to create an initial valid package by using the default pre-canned tests templates and :ref:`platform-definition-JSON-file-template` (along with the xclbin).
      2. You'll use this initial package to fill the checklist.
         The checklist will guide you:

           * To update the :ref:`platform-definition-JSON-file` according to your platform.
           * To update (or not) default pre-canned test JSON files.

      3. Re-package your xclbin, :ref:`platform-definition-JSON-file` (and potentially pre-canned test JSON files).

           * Finalize the last step of the checklist (actual results of the pre-canned tests).