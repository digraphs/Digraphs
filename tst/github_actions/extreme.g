LoadPackage("digraphs", false);;
if DigraphsTestExtreme(rec(earlyStop := false)) then
  QUIT_GAP(0);
else
  QUIT_GAP(1);
fi;
FORCE_QUIT_GAP(1);
