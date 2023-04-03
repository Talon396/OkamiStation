-- Sign of an expression is determined using the first value

return function(tree,savedCount)
    local ircode = {{},{},{}}

    local function text(...)
        table.insert(ircode[1],table.pack(...))
    end

    local function rodata(name,typ,dat)
        table.insert(ircode[2],{name,typ,dat})
    end

    local function bss(name,size)
        table.insert(ircode[3],{name,size})
    end

    local function irgenErr(modname,err)
        io.stderr:write("\x1b[1;31mModule("..modname..") - "..err.."\x1b[0m\n")
        os.exit(4)
    end

    local function findModule(name)
        for _,i in ipairs(tree) do
            if i[1] == "module" and i[2] == name then
                return i
            end
        end
        irgenErr(name,"<-- Attempted to find this nonexistant module")
    end
    local function findProcedure(mod,name)
        for _,i in ipairs(mod[6]) do
            if i[1] == "procedure" and i[2] == name then
                return i
            end
        end
        for _,i in ipairs(mod[5]) do
            if i[1] == "extern" and i[2] then
                for j=3,#i do
                    if i[j][1] == name then
                        return {"extern",table.unpack(i[j])}
                    end
                end
            end
        end
        return nil
    end
    local function getProcedure(mod,imports,name)
        for _,i in ipairs(imports) do
            local val = findProcedure(findModule(i),name)
            if val ~= nil then
                return 
            end
        end
        irgenErr(mod,"Undefined Procedure \""..name.."\" (hint: use IMPORT to use procedures from other modules)")
    end
    local function getType(mod,imports,typ)
        for _,i in ipairs(imports) do
            local mod = findModule(i)
            for _,j in ipairs(mod[4]) do
                if j[1] == typ[2] then
                    return j[2]
                end
            end
        end
        irgenErr(mod,"Undefined Type \""..typ[2].."\" (hint: use IMPORT to use types from other modules)")
    end
    local function getSize(mod,imports,typ)
        if typ[1] == "numType" then
            return typ[2]
        elseif typ[1] == "ptrOf" then
            return 4
        elseif typ[1] == "array" then
            return typ[2]*getSize(typ[3])
        elseif typ[1] == "record" then

        else
            return getSize(mod,imports,getType(mod,imports,typ[2]))
        end
    end

    for _,mod in ipairs(tree) do
        for _,proc in ipairs(mod[6]) do
            text("DefSymbol",proc[2])
            text("PushRet")
            local varSpace = {}
            local stackUsage = 4
            for _,a in ipairs(proc[3]) do
                varSpace[a[1]] = stackUsage
                stackUsage = stackUsage + getSize(mod[2],mod[3],a[2])
            end
            for _,a in ipairs(proc[5]) do
                varSpace[a[1]] = stackUsage
                stackUsage = stackUsage + getSize(mod[2],mod[3],a[2])
            end
            text("PopRet")
            text("Return")
        end
    end
    return ircode
end