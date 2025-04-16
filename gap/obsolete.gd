InstallDeprecatedMethod := function(oldName, newName, info, filters, func)
  local warningMsg, newMethod, args;
  warningMsg := Concatenation(oldName, " is deprecated. Instead use ", newName, ".");

  args := Length(filters);
  if args = 0 then
    newMethod := function()
      Warning(warningMsg);
      return func();
    end;
  elif args = 1 then
    newMethod := function(a)
      Warning(warningMsg);
      return func(a);
    end;
  elif args = 2 then
    newMethod := function(a, b)
      Warning(warningMsg);
      return func(a, b);
    end;
  elif args = 3 then
    newMethod := function(a, b, c)
      Warning(warningMsg);
      return func(a, b, c);
    end;
  elif args = 4 then
    newMethod := function(a, b, c, d)
      Warning(warningMsg);
      return func(a, b, c, d);
    end;
  elif args = 5 then
    newMethod := function(a, b, c, d, e)
      Warning(warningMsg);
      return func(a, b, c, d, e);
    end;
  elif args = 6 then
    newMethod := function(a, b, c, d, e, f)
      Warning(warningMsg);
      return func(a, b, c, d, e, f);
    end;
  else
    Error("Unsupported args: ", args);
  fi;

  InstallMethod(oldName, info, filters, newMethod);
end;

DeclareDeprecatedSynonym := function(oldName, newName)
  local i, method;
  for i in [0 .. 6] do
    for method in MethodsOperation(newName, i) do
      InstallDeprecatedMethod(oldName, NameFunction(newName), method.info, method.argFilt, method.func);
    od;
  od;
end;
