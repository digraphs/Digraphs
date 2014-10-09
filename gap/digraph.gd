#############################################################################
##
#W  digraph.gd
#Y  Copyright (C) 2014                                   James D. Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# category, family, type, representations . . .

DeclareCategory("IsMultiDigraph", IsObject);
DeclareCategory("IsDigraph", IsMultiDigraph);

BindGlobal("MultiDigraphFamily", NewFamily("MultiDigraphFamily",
 IsMultiDigraph));

BindGlobal("DigraphType", NewType(MultiDigraphFamily,
 IsDigraph and IsComponentObjectRep and IsAttributeStoringRep));

BindGlobal("MultiDigraphType", NewType(MultiDigraphFamily,
 IsMultiDigraph and IsComponentObjectRep and IsAttributeStoringRep));

# constructors . . . 

opers := [ ["Digraph", [IsRecord]],   ["Digraph", [IsList]], 
           ["DigraphNC", [IsRecord]], ["DigraphNC", [IsList]] ];

for arg in opers do 
  CallFuncList(DeclareOperation, arg);
  arg[1]:=Concatenation("Multi", arg[1]);
  CallFuncList(DeclareOperation, arg);
od;

DeclareOperation("MultiDigraphByAdjacencyMatrix", [IsRectangularTable]);
DeclareOperation("MultiDigraphByAdjacencyMatrixNC", [IsRectangularTable]);
DeclareOperation("MultiDigraphByEdges", [IsRectangularTable]);
DeclareOperation("MultiDigraphByEdges", [IsRectangularTable, IsPosInt]);

DeclareOperation("Graph", [IsMultiDigraph]);
DeclareOperation("RandomDigraph", [IsPosInt]);

DeclareOperation("AsDigraph", [IsMultiDigraph]);
DeclareOperation("AsMultiDigraph", [IsDigraph]);

DeclareOperation("AsDigraph", [IsTransformation]);
DeclareOperation("AsDigraph", [IsTransformation, IsInt]);

if not IsBound(IS_DIGRAPH) then 
  DeclareGlobalFunction("IS_DIGRAPH");
fi;

BindGlobal("InstallDigraphMethod",
  function(name, str, filts, method)
    InstallMethod(name, str, filts, 
    function(graph)
      local out;
      out:=method(graph);
      SetFilterObj(out, IsDigraph);
      return out;
    end);
  end
);

