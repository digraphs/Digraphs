InstallGlobalFunction(DIGRAPHS_DeclareObsoleteSynonym,
function(oldname, func)
  if not IsString(oldname) then
    ErrorNoReturn("the 1st argument <oldname> must be a string,");
  fi;
  if not IsFunction(func) then
    ErrorNoReturn("the 2nd argument <func> must be a function,");
  fi;

  BindGlobal(oldname, function(arg...)
    Info(InfoWarning, 1, "\"", oldname, "\" is obsolete and will be removed ",
         "in a future version;");
    Info(InfoWarning, 1, "use \"", NameFunction(func), "\" instead");
    return CallFuncList(func, arg);
  end);
end);