LoadPackage("digraphs");
if DigraphsTestInstall() and DigraphsTestAll() and DigraphsTestExtreme() then
  FORCE_QUIT_GAP(0);
fi;

FORCE_QUIT_GAP(1);
