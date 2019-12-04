import parseutils, strutils, macros

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
                pos = s.skip(">", result)
                assert(pos == 1)
                result += pos
                break

proc parseTypeName_old(s: string, tn: var TypeName, start: int): int =
    ##echo "-tn.name"
    ##echo tn.name, s
    result = s.parseWhile(tn.name, IdentChars + {'.', '$'}, start)
    #echo "tn.name: ", tn.name
    if result != 0:
        result += s.parseGenericArgs(tn.genericArgs, start + result)
        ##echo "tn.genericArgs: ", tn.genericArgs
    var pos = s.skip("[][]", start + result)
    result += pos
    if pos != 0:
        tn.isArray = true
        tn.countArrayDeep = 2
    pos = s.skip("[]", start + result)
    result += pos
    if pos != 0:
        tn.isArray = true
        tn.countArrayDeep = 1


proc parseTypeName(s: string, tn: var TypeName, start: int): int =
    #var dummStr: string
    #echo "-tn.name: ", tn.name, " s: ", s, " start: ", start, " skip <: ", s.parseUntil(dummStr, {'<'}, start)
    #echo "dummStr: ", dummStr
    var pos: int
    #result = s.parseGenericArgs(tn.genericArgs, start)
    when false:
        var genType: string
        var pos = s.skipWhile({'<'}, start)
        if pos != 0:
            discard s.parseWhile(genType, IdentChars, pos + start)
            genType = "[" & genType & "]"
            echo "genType: ", genType
            inc pos
            while true:
                var pos2 = s.skipWhile(IdentChars + {' ', '<', '.', '$', '?', ','}, pos + start)
                if pos2 != 0:
                    pos2 += s.skipWhile({'>'}, pos2 + pos + start)
                    #echo "pos parseGener: ", pos, " ", pos2
                    pos += pos2
                    if s.skipWhile({' '}, pos + start) != 0:
                        inc pos
                        #echo "break"
                        break
            #echo "pos parseGenerX: ", pos
        result += pos
    result += s.parseWhile(tn.name, IdentChars + {'.', '$'}, start + result)
    #tn.name = genType & tn.name
    #echo "tn.name: ", tn.name
    if result != 0:
        result += s.parseGenericArgs(tn.genericArgs, start + result)
        ##echo "tn.genericArgs: ", tn.genericArgs
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
    if meth.genericArgs.len != 0:
        echo "genType: ", meth.genericArgs
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
    ##echo "parseMethods s: ", s.substr(start)
    result += start
    defer: result -= start
    while true:
        methods.add(MethodDef())
        #echo "methods: ", methods
        if methods.len >= 2:
            echo "methods[^2]: ", methods[^2]
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
    ##echo "pos0: ", pos, " "
    ##echo "parseJavap s: ", s
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
    ##echo "pos: ", pos


proc nodeToAsName(e: NimNode): string {.compileTime.} =
    if e.kind == nnkInfix and $e[0] == "as":
        result = $e[2]

proc nodeToString(e: NimNode): string {.compileTime.} =
    if e.kind == nnkIdent:
        result = $e
    elif e.kind == nnkAccQuoted:
        result = ""
        for s in e.children:
            result &= nodeToString(s)
    elif e.kind == nnkDotExpr:
        result = nodeToString(e[0]) & "." & nodeToString(e[1])
    elif e.kind == nnkInfix and $e[0] == "$":
        result = nodeToString(e[1]) & "$" & nodeToString(e[2])
    elif e.kind == nnkInfix and $e[0] == "as":
        result = nodeToString(e[1])
    else:
        ##echo treeRepr(e)
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


proc argDescr(arg: TypeName, inp = true, chckGeneric = true, argG: GenericArgDef = GenericArgDef()): string

proc genericArg2Nim(gArgs: seq[GenericArgDef], isClassName = false): string =
    if gArgs.len == 0:
        return ""
    var args: seq[string]
    for a in gArgs:
        let gAstr = genericArg2Nim(a.name.genericArgs)
        let aName =
            if isClassName:
                a.name.name
            else:
                argDescr a.name, false, false, argG=a
        args.add aName.split(".")[^1] & gAstr
    result = "[" & args.join(",") & "]"



proc argDescr(arg: TypeName, inp = true, chckGeneric = true, argG: GenericArgDef = GenericArgDef()): string =
    let isVarArg =
        if arg.name.contains("..."): true
        else: false
    result =
        if arg.name.contains("."):
            if isVarArg:
                arg.name.split(".")[^4]
            else:
                arg.name.split(".")[^1]
        else:
            if arg.name.len < 3: #some T, K, N
                if arg.name == "?" and argG.to.name != "":
                    if argG.relation == "extends": argG.to.name else: argG.to.name
                else:
                    arg.name 
            else:
                "j" & arg.name
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
        result &=  genericArg2Nim(arg.genericArgs)
    if arg.isArray:
        if arg.countArrayDeep == 1:
            result = "seq[" & result & "]"
        else:
            result = "seq[seq[" & result & "]]"
    if isVarArg:
        result = "varargs[" & result & "]"
    result = result.replace("[?]", "[Object]")
    result = result.replace("[?,?]", "[Object,Object]")
    result = result.replace("[?,?,?]", "[Object,Object,Object]")


proc classExists(jClsDefs: seq[string], name: string): bool =
    result = false
    for def in jClsDefs:
        if def.contains("jclassDef " & name):
            return true


proc makejclassDef(cd: ClassDef, withAsCls = true): tuple[className, clNameOf: string] =
    let genericArg = genericArg2Nim(cd.name.genericArgs, true)
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
        clNameOf &= cd.extends.name.split(".")[^1] & genericArg2Nim cd.extends.genericArgs
    #echo "set jclassDef: ", cd.name.genericArgs
    #echo "jclassDef " & clNameOf
    result.className = className
    result.clNameOf = clNameOf
    #result.add parseStmt("jclassDef " & clNameOf)


proc jclassDefFromArg(jclsDefs: seq[string], typeName: TypeName): seq[string] =
    let tNameAndGen = typeName.name & "*" &
            (genericArg2Nim typeName.genericArgs)
                .replace("[?]", "[T]")
    let tN = typeName.name.replace("...", "")
    if not classExists(jclsDefs, tN & "*") and
                not classExists(jclsDefs, tN & " as") and
                tNameAndGen.contains ".":
        let javapOutput = staticExec("javap -public -s " & typeName.name.replace("...", ""))
        echo javapOutput
        var cdT: ClassDef
        discard parseJavap(javapOutput, cdT, false)
        let clDef = jclassDefFromArg(jclsDefs, cdT.extends)
        if clDef.len != 0:
            result.add clDef
        let (className, clNameOf) = makejclassDef(cdT)
        result.add "jclassDef " & clNameOf
    



proc collectSetAliases(cd: ClassDef, clsAliases: var seq[ClsAliasPair]) =
    let shortName = cd.name.name.split(".")[^1]
    var prfx = " of "
    clsAliases.add (shortName: prfx & shortName, alias: prfx & cd.asName)
    #prfx = " : "
    #clsAliases.add (shortName: prfx & shortName, alias: prfx & cd.asName)
    prfx = "["
    clsAliases.add (shortName: prfx & shortName & prfx, alias: prfx & cd.asName & prfx)
    prfx = "["
    clsAliases.add (shortName: prfx & shortName & "]", alias: prfx & cd.asName & "]")
    prfx = ": "
    clsAliases.add (shortName: prfx & shortName, alias: prfx & cd.asName)


macro jnimport_all*(e: untyped): untyped =
    #echo "e:"
    #echo e.treeRepr
    #echo e.kind
    var cds = newSeq[ClassDef]()
    var clsAliases = newSeq[ClsAliasPair]()
    var eList = newStmtList()  
    if e.kind != nnkStmtList:
        eList.add e
    else:
        eList = e
    for eN in eList:
        let className = nodeToString(eN)
        let javapOutput = staticExec("javap -public -s " & className)
        echo javapOutput
        #var cJavapOutput = javapOutput.replace("...", "")
        var cJavapOutput = javapOutput
                        #.replace("...", "")
                        .replace("  public <U> java.lang.Class<? extends U> asSubclass(java.lang.Class<U>);\l    descriptor: (Ljava/lang/Class;)Ljava/lang/Class;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <A extends java.lang.annotation.Annotation> A getAnnotation(java.lang.Class<A>);\l    descriptor: (Ljava/lang/Class;)Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <A extends java.lang.annotation.Annotation> A[] getAnnotationsByType(java.lang.Class<A>);\l    descriptor: (Ljava/lang/Class;)[Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <A extends java.lang.annotation.Annotation> A getDeclaredAnnotation(java.lang.Class<A>);\l    descriptor: (Ljava/lang/Class;)Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <A extends java.lang.annotation.Annotation> A[] getDeclaredAnnotationsByType(java.lang.Class<A>);\l    descriptor: (Ljava/lang/Class;)[Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <T extends java.lang.annotation.Annotation> T getAnnotation(java.lang.Class<T>);\l    descriptor: (Ljava/lang/Class;)Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <T extends java.lang.annotation.Annotation> T[] getAnnotationsByType(java.lang.Class<T>);\l    descriptor: (Ljava/lang/Class;)[Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <T extends java.lang.annotation.Annotation> T getDeclaredAnnotation(java.lang.Class<T>);\l    descriptor: (Ljava/lang/Class;)Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <T extends java.lang.annotation.Annotation> T[] getDeclaredAnnotationsByType(java.lang.Class<T>);\l    descriptor: (Ljava/lang/Class;)[Ljava/lang/annotation/Annotation;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public abstract <T> T[] toArray(T[]);\l    descriptor: ([Ljava/lang/Object;)[Ljava/lang/Object;\l\l", "")
        cJavapOutput = cJavapOutput.replace("  public <T> T[] toArray(T[]);\l    descriptor: ([Ljava/lang/Object;)[Ljava/lang/Object;\l\l", "")
        #echo cJavapOutput
        var cdT: ClassDef
        cdT.asName = nodeToAsName(eN)
        discard parseJavap(cJavapOutput, cdT)
        if cdT.asName != "":
            collectSetAliases(cdT, clsAliases)
        #echo "cdT: ", cdT
        cds.add cdT

    ##echo "All Classes: ", cds
    ##echo "Class name: ", cd.name.name
    ##echo "Class Extends: ", cd.extends.name
    #dumpAstGen:
        #jclassDef java.lang.Object of JVMObject
    var clNameOfs = newSeq[string]()
    var jclsDefs = newSeq[string]()
    result = newStmtList()
    for cd in cds:
        let clDef = jclassDefFromArg(jclsDefs, cd.extends)
        if clDef.len != 0:
            jclsDefs.add clDef
        var (className, clNameOf) = makejclassDef(cd)
        jclsDefs.add "jclassDef " & clNameOf
        clNameOfs.add clNameOf
        if cd.name.name == "java.lang.Object":
            jclsDefs.add "proc `$`*(o: Object): string ="
            jclsDefs.add "  o.toStringRaw"

    #result.add quote do:
        ##echo "boooooooooooooooooooo"
        #jclassDef java.lang.Object of JVMObject
        #`clName`
    #echo "!!!!!!!!!!!!!!!!"
    #echo "xxx:"
    #echo xxx.repr
    var impls = newSeq[string]()
    for i,cd in cds:
        if cd.methods.len == 0: #maybe interface without methods
            continue
        impls.add "jclassImpl " & clNameOfs[i] & ":"
        let className = cd.name.name
        #var implMeths = newTree(nnkStmtList)
        for i,m in cd.methods:
            #echo m.name, " --------------------", m.descriptor
            #echo m.retType.name & " genArgs: " & "->>" & genericArg2Nim m.retType.genericArgs
            let methGenType = genericArg2Nim m.genericArgs
            let clDef = jclassDefFromArg(jclsDefs, m.retType)
            if clDef.len != 0:
                jclsDefs.add clDef
            var prcN = 
                if m.name == className: "new"
                else: m.name
            case m.name
            of "cast":
                prcN = "`cast`"
            of "iterator":
                prcN = "`iterator`"
            of "distinct":
                prcN = "`distinct`"
            of "of":
                prcN = "`off`"
            var args = newSeq[string]()
            for j,arg in m.argTypes:
                let tArg = argDescr(arg)
                args.add "a" & $j & $i & ": " & tArg
                let clDef = jclassDefFromArg(jclsDefs, arg)
                if clDef.len != 0:
                    #echo "arg= ", arg
                    jclsDefs.add clDef    
            let retArg = argDescr(m.retType, false)
            var propPragms = newSeq[string]()
            if m.prop:
                propPragms.add "prop"
            if m.final:
                propPragms.add "final"
            if m.`static`:
                propPragms.add "`static`"
            let argsStr =
                if args.len != 0:
                    "(" & args.join(", ") & ")"
                else:
                    ""
            impls.add "  proc " & prcN & "*" & methGenType & argsStr &
                    (if retArg != "jvoid": ": " & retArg else: "") &
                    (if propPragms.len != 0: " {." & propPragms.join(", ") & ".}" else: "")
            let mN = createMethod(m)
            #implMeths.add mN
            ##echo m
    #echo "jclsDefs Expr:"
    #echo jclsDefs.join("\n")
    var clsDefs = jclsDefs.join("\n")
            #.replace("K,V,V", "K,V,V1")
    var clsImpls = impls.join("\n")
            #.replace("K,V,V", "K,V,V1")
    for als in clsAliases:
        clsDefs = clsDefs.replace(als.shortName, als.alias)
        clsImpls = clsImpls.replace(als.shortName, als.alias)
    result.add parseStmt(clsDefs)
    result.add parseStmt(clsImpls)
    #echo "REPR:"
    echo result.repr