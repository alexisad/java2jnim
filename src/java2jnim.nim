import parseutils, strutils, macros, strformat, tables, sequtils

const jcp {.strdefine.}: string = ""
template dbg(x: untyped): untyped =
    when defined(jdbgen):
        x
template jgen(x: untyped): untyped =
    when defined(jgen):
        x
        

type
    AccessType* = enum
        atPublic
        atPrivate
        atProtected

    GenericArgDef* = object
        name*: TypeName
        relation*: string
        to*: TypeName

    TypeName* = object
        name*: string
        genericArgs*: seq[GenericArgDef]
        isArray*: bool
        countArrayDeep*: int

    MethodDef* = object
        retType*: TypeName
        argTypes*: seq[TypeName]
        genericArgs*: seq[GenericArgDef]
        name*: string
        access*: AccessType
        synchronized*: bool
        prop*: bool
        throws*: seq[TypeName]
        descriptor*: string
        `static`*: bool
        final*: bool

    ClassDef* = object
        methods*: seq[MethodDef]
        name*: TypeName
        asName*: string
        extends*: TypeName
        implements*: seq[TypeName]
        access*: AccessType
        final*: bool
        postReplaces: seq[tuple[fromStr, toStr: string]] #sometimes fails in java class description needed to replace
    JClassDescr* = object
        className: string
        postReplaces: seq[tuple[fromStr, toStr: string]]

type
    ClsAliasPair = tuple[shortName, alias: string]


proc parseAccessor(s: string, at: var AccessType, start: int): int =
    at = atPublic
    result = s.skip("public", start)
    if result == 0:
        at = atPrivate
        result = s.skip("private", start)
        if result == 0:
            at = atProtected
            result = s.skip("protected", start)

    
proc parseFinalFlag(s: string, final: var bool, start: int): int =
    result = s.skip("final ", start)
    final = result != 0

proc parseTypeName(s: string, tn: var TypeName, start: int): int

proc parseExtendsSection(s: string, extends: var TypeName, start: int): int =
    result = s.skip("extends ", start)
    if result != 0:
        result += s.parseTypeName(extends, result + start)

proc parseCommaSeparatedTypeList(s: string, types: var seq[TypeName], start: int): int =
    result += start
    defer: result -= start
    while true:
        types.add(TypeName())
        result += s.skipWhitespace(result)
        var pos = s.parseTypeName(types[^1], result)
        result += pos
        if pos == 0:
            types.setLen(types.len - 1)
            break
        result += s.skipWhitespace(result)
        pos = s.skip(",", result)
        result += pos
        if pos == 0:
            break

proc parseImplementsSection(s: string, implements: var seq[TypeName], start: int): int =
    result = s.skip("implements ", start)
    if result != 0:
        result += start
        defer: result -= start
        implements = newSeq[TypeName]()
        result += s.parseCommaSeparatedTypeList(implements, result)

proc parseGenericArgName(s: string, name: var TypeName, start: int): int =
    result = s.skip("?", start)
    if result != 0:
        name.name = "?"
    else:
        result = s.parseTypeName(name, start)

proc parseGenericRelation(s: string, relation: var string, start: int): int =
    for r in ["super", "extends"]:
        result = s.skip(r, start)
        if result != 0:
            relation = r
            break

proc parseGenericArgDef(s: string, def: var GenericArgDef, start: int): int =
    result = s.parseGenericArgName(def.name, start)
    result += start
    defer: result -= start
    result += s.skipWhitespace(result)
    var pos = s.parseGenericRelation(def.relation, result)
    result += pos
    if pos != 0:
        result += s.skipWhitespace(result)
        result += s.parseTypeName(def.to, result)

proc parseGenericArgs(s: string, args: var seq[GenericArgDef], start: int): int =
    result = s.skip("<", start)
    if result != 0:
        result += start
        defer: result -= start
        args = newSeq[GenericArgDef]()
        while true:
            args.add(GenericArgDef())
            result += s.skipWhitespace(result)
            var pos = s.parseGenericArgDef(args[^1], result)
            result += pos
            if pos == 0:
                pos = s.skip(">", result)
                assert(pos == 1)
                result += pos
                args.setLen(args.len - 1)
                break
            result += s.skipWhitespace(result)
            pos = s.skip(",", result)
            result += pos
            if pos == 0:
                #dbg: echo "sss:", s[result..^1]
                pos = s.skip(">", result)
                if pos == 0:
                    pos = s.skipUntil({'>'}, result)
                    result += pos
                    pos = s.skip(">", result)
                assert(pos == 1)
                result += pos
                break


proc parseTypeName(s: string, tn: var TypeName, start: int): int =
    #var dummStr: string
    #dbg: echo "-tn.name: ", tn.name, " s: ", s, " start: ", start, " skip <: ", s.parseUntil(dummStr, {'<'}, start)
    #dbg: echo "dummStr: ", dummStr
    var pos: int
    #result = s.parseGenericArgs(tn.genericArgs, start)
    when false:
        var genType: string
        var pos = s.skipWhile({'<'}, start)
        if pos != 0:
            discard s.parseWhile(genType, IdentChars, pos + start)
            genType = "[" & genType & "]"
            #dbg: echo "genType: ", genType
            inc pos
            while true:
                var pos2 = s.skipWhile(IdentChars + {' ', '<', '.', '$', '?', ','}, pos + start)
                if pos2 != 0:
                    pos2 += s.skipWhile({'>'}, pos2 + pos + start)
                    #dbg: echo "pos parseGener: ", pos, " ", pos2
                    pos += pos2
                    if s.skipWhile({' '}, pos + start) != 0:
                        inc pos
                        #dbg: echo "break"
                        break
            #dbg: echo "pos parseGenerX: ", pos
        result += pos
    result += s.parseWhile(tn.name, IdentChars + {'.', '$'}, start + result)
    #tn.name = genType & tn.name
    #dbg: echo "tn.name: ", tn.name
    if result != 0:
        result += s.parseGenericArgs(tn.genericArgs, start + result)
        #dbg: echo "tn.genericArgs: ", tn.genericArgs
    var dotsname: string
    result += s.parseWhile(dotsname, {'.'}, start + result)
    tn.name &= dotsname
    pos = 0
    pos = s.skip("[][]", start + result)
    result += pos
    if pos != 0:
        tn.isArray = true
        tn.countArrayDeep = 2
    pos = s.skip("[]", start + result)
    result += pos
    if pos != 0:
        tn.isArray = true
        tn.countArrayDeep = 1


proc parseMethodModifiers(s: string, meth: var MethodDef, start: int): int =
    var pos = s.skip("final synchronized", start)
    if pos == 0:
        pos = s.skip("static synchronized", start)
    result += pos
    pos = s.skip("synchronized", start)
    result += pos
    result += start
    defer: result -= start
    if pos != 0:
        meth.synchronized = true
        result += s.skipWhitespace(result)
    pos = s.skip("static", result)
    if pos != 0:
        meth.`static` = true
    result += pos
    result += s.skipWhitespace(result)
    pos = s.skip("final", result)
    if pos != 0:
        meth.final = true
    result += pos
    result += s.skipWhitespace(result)
    pos = s.skip("native", result)
    result += pos
    result += s.skipWhitespace(result)

proc parseMethodThrows(s: string, throws: var seq[TypeName], start: int): int =
    result += start
    defer: result -= start
    result += s.skipWhitespace(result)
    var pos = s.skip("throws", result)
    result += pos
    if pos != 0:
        throws = newSeq[TypeName]()
        result += s.parseCommaSeparatedTypeList(throws, result)

proc parseFieldDescriptor(s: string, meth: var MethodDef, start: int): int =
    var pos = s.skip("descriptor: ", start)
    if pos != 0:
        result = start + pos
        defer: result -= start
        result += s.parseUntil(meth.descriptor, '\l', result)

proc parseMethod(s: string, meth: var MethodDef, start: int): int =
    result += start
    defer: result -= start
    result += s.skipWhitespace(result)
    var pos = s.parseAccessor(meth.access, result)
    result += pos
    if pos == 0:
        return 0
    result += s.skipWhitespace(result)
    result += s.skip("abstract", result)
    result += s.skipWhitespace(result)
    result += s.parseMethodModifiers(meth, result)
    result += s.parseGenericArgs(meth.genericArgs, result)
    result += s.skipWhitespace(result)
    #if meth.genericArgs.len != 0:
        #dbg: echo "genType: ", meth.genericArgs
    result += s.parseTypeName(meth.retType, result)
    pos = s.skip("(", result)
    result += pos
    if pos != 0:
        # This is constructor
        meth.name = meth.retType.name
        meth.genericArgs = meth.retType.genericArgs
        meth.retType.name = "void"
        #meth.retType.genericArgs = nil
    else:
        var dummyTypeName : TypeName
        result += s.skipWhitespace(result)
        result += s.parseTypeName(dummyTypeName, result)
        meth.name = dummyTypeName.name
        #meth.genericArgs = dummyTypeName.genericArgs
        result += s.skipWhitespace(result)
        pos = s.skip("(", result)
        result += pos
        if pos == 0:
            if s.skip(";", result) == 1:
                meth.prop = true
    if not meth.prop:
        meth.argTypes = newSeq[TypeName]()
        result += s.parseCommaSeparatedTypeList(meth.argTypes, result)
        result += s.skipWhitespace(result)
        #dbg: echo "mmm:", s[result..^1]
        #dbg: echo "meth:", meth
        pos = s.skip(")", result)
        result += pos
        assert(pos != 0)
        result += s.parseMethodThrows(meth.throws, result)
    pos = s.skip(";", result)
    result += pos
    assert(pos != 0)
    result += s.skipWhitespace(result)
    result += s.parseFieldDescriptor(meth, result)

proc parseMethods(s: string, methods: var seq[MethodDef], start: int): int =
    ##dbg: echo "parseMethods s: ", s.substr(start)
    result += start
    defer: result -= start
    while true:
        methods.add(MethodDef())
        #dbg: echo "methods: ", methods
        #if methods.len >= 2:
            #dbg: echo "methods[^2]: ", methods[^2]
        var pos = s.parseMethod(methods[^1], result)
        result += pos
        if pos == 0:
            methods.setLen(methods.len - 1)
            break
    if methods[^1].name == "":
        methods.setLen(methods.len - 1)


proc parseJavap*(s: string, def: var ClassDef, isParseMeths = true): int =
    def.implements = newSeq[TypeName]()
    def.methods = newSeq[MethodDef]()

    var pos = s.skipUntil('\l') + 1
    ##dbg: echo "pos0: ", pos, " "
    ##dbg: echo "parseJavap s: ", s
    pos += s.parseAccessor(def.access, pos)
    pos += s.skipWhitespace(pos)
    pos += s.parseFinalFlag(def.final, pos)
    pos += s.skip("abstract", pos)
    pos += s.skipWhitespace(pos)
    pos += s.skip("class", pos)
    pos += s.skipWhitespace(pos)
    pos += s.skip("interface", pos)
    pos += s.skipWhitespace(pos)
    pos += s.parseTypeName(def.name, pos)
    pos += s.skipWhitespace(pos)
    pos += s.parseExtendsSection(def.extends, pos)
    pos += s.skipWhitespace(pos)
    pos += s.parseImplementsSection(def.implements, pos)
    pos += s.skipWhitespace(pos)
    pos += s.skip("{", pos)
    #pos += s.skipUntil('\l', pos) + 1
    if isParseMeths:
        pos += s.parseMethods(def.methods, pos)
    ##dbg: echo "pos: ", pos


proc nodeToAsName(e: NimNode): string {.compileTime.} =
    if e.kind == nnkInfix and $e[0] == "as":
        result = $e[2]

proc nodeToJClassDescr(e: NimNode): JClassDescr {.compileTime.} =
    if e.kind == nnkIdent:
        result.className = $e
    elif e.kind == nnkAccQuoted:
        result.className = ""
        for s in e.children:
            result.className &= nodeToJClassDescr(s).className
    elif e.kind == nnkDotExpr:
        result.className = nodeToJClassDescr(e[0]).className & "." & nodeToJClassDescr(e[1]).className
    elif e.kind == nnkInfix and $e[0] == "$":
        result.className = nodeToJClassDescr(e[1]).className & "$" & nodeToJClassDescr(e[2]).className
    elif e.kind == nnkInfix and $e[0] == "as":
        result.className = nodeToJClassDescr(e[1]).className
        if e.len > 3:
            let jclsDesc = nodeToJClassDescr(e[3])
            result.postReplaces.add jclsDesc.postReplaces
            dbg: echo "asas:", nodeToJClassDescr(e[3]), "<-"
    elif e.kind == nnkCall and e[0].kind == nnkDotExpr:
        result.className &= nodeToJClassDescr(e[0]).className
        if e.len > 1:
            let jclsDesc = nodeToJClassDescr(e[1])
            result.className &= jclsDesc.className
            result.postReplaces.add jclsDesc.postReplaces
    elif e.kind == nnkStmtList and e[0].kind == nnkCall and
            $e[0][0] == "postReplaces":
        for pRepls in e[0][1]:
            dbg: echo $pRepls[0]
            dbg: echo $pRepls[1]
            result.postReplaces.add (fromStr: $pRepls[0], toStr: $pRepls[1])
        dbg: echo "postProcess:", result.postReplaces
        dbg: echo treeRepr(e)
        #discard
    else:
        ##dbg: echo treeRepr(e)
        assert(false, "Cannot stringize node")


proc createMethod(m: MethodDef): NimNode =
    nnkProcDef.newTree(
        nnkPostfix.newTree(
            newIdentNode("*"),
            newIdentNode(m.name)
        ),
        newEmptyNode(),
        newEmptyNode(),
        nnkFormalParams.newTree(
            nnkBracketExpr.newTree(
                newIdentNode("seq"),
                newIdentNode("jbyte")
            ),
            nnkIdentDefs.newTree(
                newIdentNode("charsetName"),
                newIdentNode("string"),
                newEmptyNode()
            )
        ),
        newEmptyNode(),
        newEmptyNode(),
        newEmptyNode()
    )

proc hasIgnoredClasses(m: MethodDef, clss: seq[string]): bool =
    result = false
    for arg in m.argTypes:
        for cN in clss:
            if arg.name.contains(cN):
                return true;
    for cN in clss:
        if m.retType.name.contains(cN):
            return true;


proc argDescr(arg: TypeName, inp = true, chckGeneric = true,
                argG: GenericArgDef = GenericArgDef(),
                aliases: Table[string, string]): string

proc genericArg2Java(gArgs: seq[GenericArgDef], jArgs: var seq[string]) =
    for a in gArgs:
        if a.name.genericArgs.len > 0:
            genericArg2Java(a.name.genericArgs, jArgs)
        if a.name.name.contains("."):
            jArgs.add(a.name.name.replace("...", ""))

proc genericArg2Nim(gArgs: seq[GenericArgDef], isClassName = false,
                    isExtends = false,
                    aliases: Table[string, string]): string =
    if gArgs.len == 0:
        return ""
    var args: seq[string]
    for a in gArgs:
        let gAstr =
            if isExtends and a.name.genericArgs.len > 0:
                "Object" # avoid ]] at the end of generic extends
            else:
                genericArg2Nim(a.name.genericArgs, aliases = aliases)
        let aName =
            if isClassName:
                a.name.name
            else:
                argDescr a.name, false, false, argG=a, aliases = aliases
        if isExtends and gAstr == "Object":
            args.add gAstr
        else:
            let aN =
                if aliases.hasKey(aName):
                    aliases[aName]
                else:
                    aName.split(".")[^1]
            args.add aN & gAstr
    result = "[" & args.join(",") & "]"



proc argDescr(arg: TypeName, inp = true, chckGeneric = true,
                argG: GenericArgDef = GenericArgDef(),
                aliases: Table[string, string]): string =
    let isVarArg =
        if arg.name.contains("..."): true
        else: false
    let aName = arg.name.replace("...", "")
    let aN =
        if aliases.hasKey(aName):
            aliases[aName]
        else:
            aName.split(".")[^1]
    result =
        if arg.name.contains("."):
            aN
        else:
            if arg.name in ["boolean",
                            "int",
                            "byte",
                            "short",
                            "long",
                            "float",
                            "double",
                            "char",
                            "void"
                                ]:
                "j" & arg.name
            else:
                if arg.name.len < 3: #some T, K, N
                    if arg.name == "?" and argG.to.name != "":
                        argG.to.name
                    else:
                        arg.name
                else:
                    arg.name 
    if inp:
        case result
        of "String":
            result = "string"
    else:
        case result
        of "jboolean":
            result = "bool"
        #result &=  (if result == "TypeVariable": genericArg2Nim(arg.genericArgs) else: "")
    if chckGeneric:
        result &=  genericArg2Nim(arg.genericArgs, aliases = aliases)
    if arg.isArray:
        if arg.countArrayDeep == 1:
            result = "seq[" & result & "]"
        else:
            result = "seq[seq[" & result & "]]"
    if isVarArg:
        result = "varargs[" & result & "]"
    result = result.replace("?]", "Object]")
    result = result.replace("?,?]", "Object,Object]")
    result = result.replace("?,?,?]", "Object,Object,Object]")


proc classExists(jClsDefs: seq[string], name: string): bool =
    result = false
    if name.contains("GroupedIterator"):
        dbg: echo "GroupedIterator:", name, "->", jClsDefs
    for def in jClsDefs:
        if def.contains("jclassDef " & name):
            return true

proc jclassDefFromArg(jclsDefs: seq[string], typeName: TypeName,
        aliases: var Table[string, string]): seq[string]


proc makejclassDef(cd: ClassDef, withAsCls = true,
                    aliases: Table[string, string]): tuple[className, clNameOf: string] =
    let genericArg = genericArg2Nim(cd.name.genericArgs, isClassName=true, aliases=aliases)
    let asClsName =
        if cd.asName != "" and withAsCls:
            " as " & cd.asName & (if genericArg == "": "*" else: "")
        else: ""
    let className = cd.name.name &
            (if asClsName == "": "*" else: (if genericArg == "": "" else: "*")) & genericArg
    var clNameOf = className & asClsName & " of "
    if cd.extends.name == "":
        if cd.name.name == "java.lang.Object":
            clNameOf &= "JVMObject"
        else:
            clNameOf &= "Object"
    else:
        var genericExt = genericArg2Nim(cd.extends.genericArgs, isExtends = true, aliases = aliases)
        dbg: echo "cd.name.name:", cd.name.name, " cd.extends:", cd.extends
        dbg: echo "cd.extends.genericArgs:", cd.extends.genericArgs, "<-", genericExt
        #[for genArg in cd.extends.genericArgs:
            dbg: echo "genArg.name:", genArg.name
            let clDef = jclassDefFromArg(jclsDefs, genArg.name, aliases = aliases)
            if clDef.len != 0:
                jclsDefs.add clDef]#
        #if genericExt.len > 1 and genericExt[^2..^1] == "]]":
            #dbg: echo "cd.extends.name: ", cd.extends.name, " :: ", genericExt
        let aN =
            if aliases.hasKey(cd.extends.name):
                aliases[cd.extends.name]
            else:
                cd.extends.name.split(".")[^1]
        clNameOf &= aN & genericExt
    #dbg: echo "set jclassDef: ", cd.name.genericArgs
    #dbg: echo "jclassDef " & clNameOf
    result.className = className
    result.clNameOf = clNameOf
    #if className.strip() == "*":
        #dbg: echo "className: ", cd
    #result.add parseStmt("jclassDef " & clNameOf)

proc replaceInnGener(s: string): string =
    var sr: string
    var num = s.parseUntil(result, ">.")
    if num == s.len:
        return s
    while true:
        dec(num)
        var t: string
        let pos = result.parseUntil(t, "<", num)
        if pos == 0:
            break
        else:
            sr = result.substr(num)
    result = s.replace("<" & sr & ">.", ".")


proc jclassDefFromArg(jclsDefs: seq[string], typeName: TypeName,
                        aliases: var Table[string, string]): seq[string] =
    #[
    let tNameAndGen = typeName.name & "*" &
            (genericArg2Nim typeName.genericArgs)
                .replace("[?]", "[T]")]#
    let tN = typeName.name.replace("...", "")
    if not tN.contains("."):
        return result
    var tNs = newSeq[string]()
    tNs.add tN
    if not tN.contains("$"):
        var tNsps = tN.split(".")
        let tNInn = tNsps[^1]
        tNsps.delete(tNsps.high, tNsps.high)
        tNs.add(tNsps.join(".") & "$" & tNInn)
    for cN in tNs:
        if classExists(jclsDefs, cN & "*") or
                classExists(jclsDefs, cN & " as"):
            return result
    let cp = 
        when defined(jcp):
            "-cp " & jcp
        else:
            ""
    let asName =
        if tN.contains("$"):
            tN.replace( "$", "").split(".")
                    .map(proc(x: string): string = x.capitalizeAscii)
                    .join
        else:
            ""
    let javapCmd = &"javap -public -s {cp} " & tN.multiReplace( ("...", ""), ("$", ".") )
    dbg: echo "2. javapCmd: ", javapCmd 
    let javapOutputTmp = staticExec( javapCmd )
    if javapOutputTmp.find("class not found") != -1:
        quit(javapOutputTmp, 1)
    let javapOutput = javapOutputTmp.replaceInnGener.replace("BuilderType", "T")
    dbg: echo javapOutput
    var cdT: ClassDef
    discard parseJavap(javapOutput, cdT, false)
    if asName != "":
        cdT.asName = asName
        aliases[cdT.name.name] = cdT.asName
    let clDef = jclassDefFromArg(jclsDefs, cdT.extends, aliases = aliases)
    if clDef.len != 0:
        result.add clDef
    let (className, clNameOf) = makejclassDef(cdT, aliases = aliases)
    result.add "jclassDef " & clNameOf
    



proc collectSetAliases(cd: ClassDef, clsAliases: var seq[ClsAliasPair]) =
    template toAlias(prfx, shName, psfx: string): untyped =
        clsAliases.add (shortName: prfx & shortName & psfx, alias: prfx & cd.asName & psfx)
    let shortName = cd.name.name.split(".")[^1]
    toAlias(" of ", shortName, "")
    toAlias(",", shortName, "]")
    toAlias(",", shortName, ",")
    toAlias("[", shortName, ",")
    toAlias("[", shortName, "]")
    toAlias("", shortName, "[")
    toAlias(": ", shortName, " ")
    toAlias(": ", shortName, ")")
    toAlias(": ", shortName, ";")
    toAlias(": ", shortName, "\l")

proc addJclsDefs(jclsDefs: var seq[string], jClsses: seq[string], aliases: var Table[string, string]) =
    for jCls in jClsses:
        let clDef = jclassDefFromArg(jclsDefs, TypeName(name: jCls), aliases = aliases)
        if clDef.len != 0:
            jclsDefs.add clDef


proc saveJGen(genCode: string): string {.compileTime.} =
    dbg: echo "genCode:", genCode
    let prjPath = getProjectPath()
    #discard staticExec("dbg: echo " & "genCode" & " > " & prjPath & """\bebe.nim""")
    #result = staticExec("dir " & prjPath)
    result = staticExec("dir")
    #result = getProjectPath() & "<->" & currentSourcePath()# & staticExec("dir")
    #result = "dbg: echo " & "genCode" & " > " & prjPath & """\bebe.nim"""
              
#const prjPath = getProjectPath()

macro jnimport_all*(e: untyped): untyped =
    dbg: echo "e:"
    dbg: echo e.treeRepr
    #dbg: echo e.kind
    var cds = newSeq[ClassDef]()
    var clsAliases = newSeq[ClsAliasPair]()
    var clsAliasTbl = initTable[string, string]()
    var eList = newStmtList()  
    if e.kind != nnkStmtList:
        eList.add e
    else:
        eList = e
    let cp = 
        when defined(jcp):
            "-cp " & jcp
        else:
            ""
    for eN in eList:
        let jclassDescr = nodeToJClassDescr(eN)
        let className = jclassDescr.className
        let javapCmd = &"javap -public -s {cp} " & className.multiReplace( ("...", ""), ("$", ".") )
        dbg: echo "javapCmd: ", javapCmd
        let javapOutputTmp = staticExec(javapCmd)
        if javapOutputTmp.find("class not found") != -1:
            quit(javapOutputTmp, 1)
        let javapOutput = javapOutputTmp.replaceInnGener.replace("BuilderType", "T")
        dbg: echo "javapOutput: ", javapOutput
        #dbg: echo cJavapOutput
        var cdT: ClassDef
        cdT.asName = nodeToAsName(eN)
        discard parseJavap(javapOutput, cdT)
        if jclassDescr.postReplaces.len != 0:
            dbg: echo "jclassDescr.postReplaces:", jclassDescr.postReplaces
            cdT.postReplaces = jclassDescr.postReplaces
        if cdT.asName != "":
            #collectSetAliases(cdT, clsAliases)
            discard clsAliasTbl.hasKeyOrPut(className, cdT.asName)
        #dbg: echo "cdT: ", cdT
        cds.add cdT

    #dbg: echo "All AlliasesClasses: ", clsAliasTbl
    ##dbg: echo "Class name: ", cd.name.name
    ##dbg: echo "Class Extends: ", cd.extends.name
    #dumpAstGen:
        #jclassDef java.lang.Object of JVMObject
    var clNameOfs = newSeq[string]()
    var jclsDefs = newSeq[string]()
    result = newStmtList()
    for cd in cds:
        let clDef = jclassDefFromArg(jclsDefs, cd.extends, aliases = clsAliasTbl)
        if clDef.len != 0:
            jclsDefs.add clDef
        var (className, clNameOf) = makejclassDef(cd, aliases = clsAliasTbl)
        #[for genArg in cd.extends.genericArgs:
            dbg: echo "genArg.name:", genArg.name
            let clDef = jclassDefFromArg(jclsDefs, genArg.name, aliases = clsAliasTbl)
            if clDef.len != 0:
                jclsDefs.add clDef]#
        jclsDefs.add "jclassDef " & clNameOf
        clNameOfs.add clNameOf
        if cd.name.name == "java.lang.Object":
            jclsDefs.add "proc `$`*(o: Object): string ="
            jclsDefs.add "  o.toStringRaw"

    #result.add quote do:
        ##dbg: echo "boooooooooooooooooooo"
        #jclassDef java.lang.Object of JVMObject
        #`clName`
    #dbg: echo "!!!!!!!!!!!!!!!!"
    #dbg: echo "xxx:"
    #dbg: echo xxx.repr
    var impls = newSeq[string]()
    for i,cd in cds:
        if cd.methods.len == 0: #maybe interface without methods
            continue
        impls.add "jclassImpl " & clNameOfs[i] & ":"
        let className = cd.name.name
        #var implMeths = newTree(nnkStmtList)
        for i,m in cd.methods:
            #dbg: echo "GenArgs:", m.genericArgs
            #dbg: echo "GenArgs RetType:", m.retType.genericArgs
            var jClsFromGeneric: seq[string]
            genericArg2Java(m.genericArgs, jClsFromGeneric)
            genericArg2Java(m.retType.genericArgs, jClsFromGeneric)
            addJclsDefs(jclsDefs, jClsFromGeneric, aliases = clsAliasTbl)
            #if jClsFromGeneric.len > 0:
                #dbg: echo "jClsFromGeneric:", jClsFromGeneric
            #dbg: echo m.name, " --------------------", m.descriptor
            #dbg: echo m.retType.name & " genArgs: " & "->>" & genericArg2Nim m.retType.genericArgs
            let methGenType = genericArg2Nim(m.genericArgs, aliases = clsAliasTbl)
            let clDef = jclassDefFromArg(jclsDefs, m.retType, aliases = clsAliasTbl)
            if clDef.len != 0:
                jclsDefs.add clDef
            var prcN = 
                if m.name == className: "new"
                else: m.name
            prcN = prcN.multireplace(("_$", "_§"), ("$_", "§_"))
            let isUndescr = (prcN[0] == '_' or prcN[^1] == '_')
            if prcN.contains '$':
                prcN = "`" & prcN & "`"
            case m.name
            of "cast":
                prcN = "`cast`"
            of "iterator":
                prcN = "`iterator`"
            of "distinct":
                prcN = "`distinct`"
            of "of":
                prcN = "`of`"
            of "in":
                prcN = "`in`"
            of "out":
                prcN = "`out`"
            var args = newSeq[string]()
            for j,arg in m.argTypes:
                let tArg = argDescr(arg, aliases = clsAliasTbl)
                args.add "a" & $j & $i & ": " & tArg
                let clDef = jclassDefFromArg(jclsDefs, arg, aliases = clsAliasTbl)
                if clDef.len != 0:
                    #dbg: echo "arg= ", arg
                    jclsDefs.add clDef
                for genArgType in arg.genericArgs:
                    let clDefGen = jclassDefFromArg(jclsDefs, genArgType.name, aliases = clsAliasTbl)
                    if clDefGen.len != 0:
                        #dbg: echo "arg= ", arg
                        jclsDefs.add clDefGen
            let retArg = argDescr(m.retType, false, aliases = clsAliasTbl)
            var propPragms = newSeq[string]()
            if m.prop:
                propPragms.add "prop"
            if m.final:
                propPragms.add "final"
            if m.`static`:
                propPragms.add "`static`"
            let argsStr = "(" & args.join(", ") & ")"
            var procDef = "  proc " & prcN & "*" & methGenType & argsStr &
                (if retArg != "jvoid": ": " & retArg else: "") &
                (if propPragms.len != 0: " {." & propPragms.join(", ") & ".}" else: "")
            if isUndescr:
                procDef = procDef.replace(" proc ", " #proc ")
            for r in cd.postReplaces:
                #dbg: echo "r.fromStr, r.toStr:", r.fromStr, "<->", r.toStr
                #dbg: echo procDef
                procDef = procDef.replaceWord(r.fromStr, r.toStr)
            impls.add procDef
    dbg: echo "jclsDefs Expr:"
    dbg: echo jclsDefs.join("\n")
    var clsDefs = jclsDefs.join("\n")
            #.replace("K,V,V", "K,V,V1")
    var clsImpls = impls.join("\n")
    #[var jclsResult: string
    jclsResult = clsDefs & "\n" & clsImpls
    result.add(
        quote do:
            dbg: echo `jclsResult`
    )]#
    #[for als in clsAliases:
        clsDefs = clsDefs.replace(als.shortName, als.alias)
        dbg: echo "multiReplace0:", als.shortName, "->", als.alias
        clsImpls = clsImpls.replace(als.shortName, als.alias)]#
    result.add parseStmt(clsDefs)
    dbg: echo "clsImpls:"
    dbg: echo clsImpls
    result.add parseStmt(clsImpls)
    dbg: echo "REPR:"
    dbg: echo result.repr
    jgen:
        echo ">>>begin jgen for jnim"
        echo result.repr
        echo ">>>end jgen for jnim"
    #var genCode: string
    #genCode = result.repr
    #dbg: echo genCode
    #dbg: echo staticExec("dbg: echo " & genCode & " > xexp.nim")
    #dbg: echo staticExec("dir")
    #dbg: echo "bebe:", saveJGen(genCode)
