use inc::Module::Install;
name 'ShipIt-Step-UploadGitHub';
all_from 'lib/ShipIt/Step/UploadGitHub.pm';

test_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
