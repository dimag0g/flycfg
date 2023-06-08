# FlyCfg
Simple flight controller configurator

FlyCfg allows you to read/write/analyze your Flight Controller configuration using its command line interface. It uses colors and tabs to draw attention to information you'll be most likely interested in.

FlyCfg primarily supports Betaflight, but can be used with similar FC software (e.g. iNav) to some extent.

Color code
---

Throughout FlyCfg, colors are used on config lines. These colors correspond to different properties and are described below in descending order of priorities. For instance, a resource assignment which is "conflicting" and "unsaved" will be displayed as "conflicting".

🔴Invalid: a setting which is out of range, doesn't exist or is incompatible with another setting in the configuration. You'll likely need to fix that if you need the corresponding function to work.

🔵Unsaved: a setting which was modified since you last uploaded the configuration in the FC. Don't forget to save it (either in the FC or in a file) before you quit.

🟢Custom: a setting which was modified w.r.t to the default FC configuration. If there's a problem after a config change, these are the lines you'll likely want to review.

⚪Inactive: a setting which results in a function being deactivated.

⚫Default: a setting which doesn't belong to any of the above, that is a default value which is non-conflicting and active.


Build instructions
---

FlyCfg is developed using Lazarus IDE.

On Windows, download the Lazarus IDE from https://www.lazarus-ide.org/index.php?page=downloads
On Linux (including Raspberry Pi), run `sudo apt install lazarus`

To build FlyCfg, you'll need to clone the repo (including the submodules), and then run the following command:

    git clone --recurse-submodules https://github.com/dimag0g/flycfg && cd flycfg
    lazbuild --build-mode="Release" TLazSerial/LazSerialPort.lpk flycfg.lpi

Before a release or a pull request, it's advised to run tests:

    lazbuild fpcunittest.lpi && fpcunittest

If you have an FC board, having it connected during a test run allow to test reading (but not writing!) the FC config. The rest of the tests use a dummy config file, `test.cfg`.

Licenses
---

The software itself is licensed under GPL v.3, see LICENSE. The source code is available at https://github.com/dimag0g/flycfg

The bee icon is free for non-commerical use with attribution, see: https://www.vecteezy.com/vector-art/596994-bee-logo-and-symbol-vector-templates
