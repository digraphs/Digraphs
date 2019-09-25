#############################################################################
##
##  digraphs.g
##  Copyright (C) 2014-19                                James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

DeclareOperation("DeclareAttributeThatReturnsDigraph", [IsString, IsOperation]);
DeclareOperation("InstallMethodThatReturnsDigraph",
                 [IsOperation, IsString, IsList, IsFunction]);

InstallMethod(DeclareAttributeThatReturnsDigraph, "for a string",
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

InstallMethod(InstallMethodThatReturnsDigraph,
"for an operation, info string, list of argument filters, and function",
[IsOperation, IsString, IsList, IsFunction],
function(oper, info, filt, func)
  InstallMethod(oper, info, filt,
  function(D)
    local C, attr_name, set_attr;
    C := func(D);
    if IsImmutableDigraph(D) then
      if not IsImmutableDigraph(C) then
        MakeImmutable(C);
      fi;
      attr_name := Concatenation(NameFunction(oper), "Attr");
      set_attr  := ValueGlobal(Concatenation("Set", attr_name));
      set_attr(D, C);
    fi;
    return C;
  end);
end);
