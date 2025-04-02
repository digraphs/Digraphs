GetFunctionName := function(func)
  local names, name;
  names := Names(GLOBAL);
  for name in names do
    if IsBound(name) and Eval(name) = func then
      return name;
    fi;
  od;
  return func+ "cannot be found";
end;

DeclareDeprecatedSynonym := function(oldName, newFunc)
  local newName, warningMsg;
  
  newName := GetFunctionName(newFunc);
  warningMsg := Concatenation(oldName, " is deprecated. Instead use ", newName, ".");
  
  DeclareOperation(oldName, [ ]);
  InstallMethod(oldName, [ ], function() 
  Warning(warningMsg);
    return newFunc();
  end);
  
  DeclareOperation(oldName, [ IsObject ]);
  InstallMethod(oldName, [ IsObject ], function(a)
    Warning(warningMsg);
    return newFunc(a);
  end);

  DeclareOperation(oldName, [ IsObject, IsObject ]);
  InstallMethod(oldName, [ IsObject, IsObject ], function(a, b)
    Warning(warningMsg);
    return newFunc(a, b);
  end);
  
  DeclareOperation(oldName, [ IsObject, IsObject, IsObject ]);
  InstallMethod(oldName, [ IsObject, IsObject, IsObject ], function(a, b, c)
    Warning(warningMsg);
    return newFunc(a, b, c);
  end);
  
  DeclareOperation(oldName, [ IsObject, IsObject, IsObject, IsObject ]);
  InstallMethod(oldName, [ IsObject, IsObject, IsObject, IsObject ], function(a, b, c, d)
    Warning(warningMsg);
    return newFunc(a, b, c, d);
  end);
end;




InstallDeprecatedMethod := function(oldName, newName, info, filters, func)
  local warningMsg, newMethod, args;
  warningMsg := Concatenation(oldName, " is deprecated. Instead use ", newName, ".");

  args := Length(filters);
  if args = 0 then
    newMethod := function(args...)
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
