#############################################################################
##
##  digraphs.g
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DeclareAttributeReturnsDigraph", [IsString, IsOperation]);

InstallMethod(DeclareAttributeReturnsDigraph, "for a string",
[IsString, IsOperation],
function(oper_name, filt)
  local attr_name, has_attr_name, oper, attr, has_attr;

  attr_name := Concatenation(oper_name, "Attr");
  has_attr_name := Concatenation("Has", attr_name);

  DeclareOperation(oper_name, [filt]);
  DeclareAttribute(attr_name, filt);

  oper     := ValueGlobal(oper_name);
  attr     := ValueGlobal(attr_name);
  has_attr := ValueGlobal(has_attr_name);

  InstallMethod(oper, Concatenation("for a digraph with ", has_attr_name),
  [IsDigraph and has_attr], SUM_FLAGS, attr);
  InstallMethod(attr, "for an immutable digraph", [IsImmutableDigraph], oper);
  # Now it suffices to install a method for the oper and a subcategory of
  # filt and this ought to just work.
end);
