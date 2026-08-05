BEGIN;
SELECT plan(1);

SELECT pass('Local pgTAP test runner is available.');

SELECT * FROM finish();
ROLLBACK;
