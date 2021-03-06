import macros, tables, sets, strutils
import jnim/private/[jni_wrapper, jni_api, jni_generator]

type MethodDescr = object
  name: string
  retType: string
  argTypes: seq[string]
type
  GenericArgDef* = object
    name*: TypeName
  TypeName* = object
    name*: string
    genericArgs*: seq[GenericArgDef]

const
  JnimPackageName = "io.github.yglukhov.jnim"
  FinalizerName = "_0"
  PointerFieldName = "_1"
  JniExportedFunctionPrefix = "Java_" & JnimPackageName.replace('.', '_') & "_Jnim_00024"

proc initMethodDescr(name, retType: string, argTypes: seq[string]): MethodDescr =
  result.name = name
  result.retType = retType
  result.argTypes = argTypes

proc genGenericArgs(nI: NimNode, clsName: var TypeName) =
  #var clsName = TypeName()
  for i,a in nI:
    case a.kind
    of nnkIdent:
      if i == 0 and clsName.genericArgs.len == 0:
        clsName.name = $a
        echo "clsName: ", clsName
      #elif i == 0 and clsName.genericArgs.len != 0:
        #clsName.genericArgs.add GenericArgDef(name: TypeName(name: $a))
      else:
        clsName.genericArgs.add( GenericArgDef(name: TypeName(name: $a)) )
        echo "clsName add: ", clsName
    of nnkBracketExpr:
      var clsWithGens = TypeName()
      clsName.genericArgs.add( GenericArgDef(name: clsWithGens) )
      echo "clsWithGens: ", clsName
      genGenericArgs(a, clsName.genericArgs[^1].name)
    else:
      echo "Unexpected node: ", repr(a), "\n", treeRepr(a)
      doAssert(false)
        


proc toWords(a: NimNode, res: var seq[TypeName]) =
  echo "toWords: ", "\n", treeRepr(a)
  var strAddAfter: string
  case a.kind
  of nnkArgList:
    var i = 0
    while i < a.len and a[i].kind in {nnkCommand, nnkIdent, nnkInfix, nnkBracketExpr}:
      #if i == a.len-1:
        #res.add ">"
      toWords(a[i], res)
      inc i
      #if i < a.len and a[i].kind in {nnkCommand, nnkIdent, nnkBracketExpr}:
        #res.add ";"
  of nnkCommand:
    for n in a:        
      toWords(n, res)
  of nnkBracketExpr:
    var clsWithGens = TypeName()
    genGenericArgs(a, clsWithGens)
    res.add clsWithGens
    echo "genGenericArgs: ", clsWithGens
    #[
    for i,n in a:        
      #if i == a.len-1:
        #strAddAfter = ">"
      toWords(n, res)
      if i == 0:
        var clsNme = TypeName(name: $n)
        genGenericArgs(n, clsNme.genericArgs)
        res.add "<"
      if i == a.len-1:
        res.add ">"
      #if (a.len == 2 or (i >= 1 and i != a.len-1)) and n.kind == nnkIdent:
        #res.add ","
        #strAddAfter = ""]#
  of nnkIdent:
    res.add(TypeName(name: $a))
    #if addAfter != "":
      #res.add addAfter  
  of nnkInfix:
    a[0].expectKind(nnkIdent)
    a[1].expectKind(nnkIdent)
    assert($a[0] == "*")
    res.add(TypeName(name: $a[1] & "*"))
    toWords(a[2], res)
  else:
    echo "Unexpected node: ", repr(a), "\n", treeRepr(a)
    doAssert(false)

proc extractArguments(a: NimNode): tuple[className, parentClass: string, interfaces: seq[TypeName], body: NimNode, isPublic: bool] =
  var words: seq[TypeName]
  #var currGeneric: GenericArgDef
  a.toWords(words)
  echo "words: ", words
  var state: range[0 .. 4]
  for wT in words:
    var w = wT.name
    echo "w: ", w
    case state
    of 0: # Waiting class name
      result.className = w
      if w[^1] == '*':
        result.isPublic = true
        result.className = w[0 .. ^2]
      state = 1
    of 1: # Waiting extends keyword
      if w == "extends":
        state = 2
      elif w == "implements":
        state = 4
      else:
        assert(false)
    of 2: # Waiting superclass
      result.parentClass = w
      state = 3
    of 3: # Waiting implements keyword
      assert(w == "implements")
      state = 4
    of 4: # Waiting interface name
      result.interfaces.add(wT)
  if a[^1].kind != nnkIdent:
    result.body = a[^1]

const jnimGlue {.strdefine.} = "Jnim.java"

var
  javaGlue {.compileTime.} = newStringOfCap(1000000)
  imports {.compileTime.}: HashSet[string]
  classCursor {.compileTime.} = 0
  importCursor {.compileTime.} = 0

proc importNameFromFqcn(fq: string): string =
  if '.' in fq and not fq.startsWith("Jnim."):
    let dollarIdx = fq.find('$')
    if dollarIdx == -1:
      return fq
    else:
      return fq[0 .. dollarIdx - 1]

proc isConstr(m: MethodDescr): bool = m.name == "new"

proc genJavaGlue(className, parentClass: string, interfaces: seq[string], jinterfaces: string, isPublic: bool, methodDefs: seq[MethodDescr], staticSection, emitSection: string) =
  if classCursor == 0:
    javaGlue = "package " & JnimPackageName & ";\n"
    importCursor = javaGlue.len
    javaGlue &= """
public class Jnim {
public interface __NimObject {}
public static native void """ & FinalizerName & """(long p);
"""
    classCursor = javaGlue.len
    javaGlue &= "}\n"
    imports = initHashSet[string]()

  echo "className: ", className, " public: ", isPublic
  echo "super: ", parentClass
  echo "interfaces: ", interfaces
  echo "body: ", repr(body)
  # echo "cur javaglue.len: ", javaGlue.len

  var newImports = newStringOfCap(10000)

  proc noDollarFqcn(s: string): string = s.replace('$', '.')

  proc addImport(s: string) =
    if s.len != 0 and s notin imports:
      echo "addImport: ", s
      imports.incl(s)
      newImports &= "import "
      newImports &= s
      newImports &= ";\n"

  # addImport("ExportTestClass")
  # addImport(className)

  var classDef = newStringOfCap(100000)
  classDef &= "public static class "
  classDef &= className
  if parentClass.len != 0:
    classDef &= " extends "
    classDef &= parentClass.noDollarFqcn()
    addImport(importNameFromFqcn(parentClass))

  classDef &= " implements __NimObject, " & jinterfaces.noDollarFqcn()
  for f in interfaces:
    #classDef &= ", "
    #classDef &= f.noDollarFqcn()
    echo "f: ", f, " : ", importNameFromFqcn(f)
    addImport(importNameFromFqcn(f))
  echo "newImports: ", newImports
  classDef &= " {\n"
  if staticSection.len != 0:
    classDef &= "static { " & staticSection & "}\n"
  classDef &= emitSection
  classDef &= '\n'

  classDef &= """
protected void finalize() throws Throwable { super.finalize(); """ & FinalizerName & "(" & PointerFieldName & "); " & PointerFieldName & """ = 0; }
private long """ & PointerFieldName & """;
"""

  for m in methodDefs:
    if m.isConstr:
      classDef &= "public " & className
    else:
      classDef &= "public native "
      classDef &= m.retType
      classDef &= " "
      classDef &= m.name

    classDef &= "("
    for i, a in m.argTypes:
      if i != 0: classDef &= ", "
      classDef &= a.noDollarFqcn
      classDef &= " _" & $i
    classDef &= ")"

    if m.isConstr:
      classDef &= "{ super("
      for i, a in m.argTypes:
        if i != 0: classDef &= ", "
        classDef &= "_" & $i
      classDef &= "); }\n"
    else:
      classDef &= ";\n"

  classDef &= "}\n\n"

  if newImports.len != 0:
    javaGlue.insert(newImports, importCursor)
    importCursor += newImports.len
    classCursor += newImports.len

  javaGlue.insert(classDef, classCursor)
  classCursor += classDef.len
  # echo javaGlue
  # echo "new javaglue.len: ", javaGlue.len

  # echo classDef

  # var s {.global.}: string
  # s.insert($a & "\n")
  writeFile(jnimGlue, javaGlue)

proc genDexGlue(className, parentClass: string, interfaces: seq[string], jinterfaces: string, isPublic: bool, methodDefs: seq[MethodDescr], staticSection, emitSection: string): NimNode =
  doAssert(false, "Not implemented")

macro genJexportGlue(className, parentClass: static[string], interfaces: static[seq[string]], jinterfaces: static[string], isPublic: static[bool], methodDefs: static[seq[MethodDescr]], staticSection, emitSection: static[string]): untyped =
  # echo treeRepr(a)
  when defined(jnimGenDex):
    genDexGlue(className, parentClass, interfaces, jinterfaces, isPublic, methodDefs, staticSection, emitSection)
  else:
    genJavaGlue(className, parentClass, interfaces, jinterfaces, isPublic, methodDefs, staticSection, emitSection)

proc varargsToSeqStr(args: varargs[string]): seq[string] {.compileTime.} = @args
proc varargsToStr(args: varargs[string]): string {.compileTime.} = @args.join ""
proc varargsToSeqMethodDef(args: varargs[MethodDescr]): seq[MethodDescr] {.compileTime.} = @args

proc jniFqcn*(T: type[void]): string = "void"
proc jniFqcn*(T: type[jint]): string = "int"
proc jniFqcn*(T: type[jlong]): string = "long"
proc jniFqcn*(T: type[jfloat]): string = "float"
proc jniFqcn*(T: type[jdouble]): string = "double"
proc jniFqcn*(T: type[jboolean]): string = "boolean"
proc jniFqcn*(T: type[string]): string = "String"

template nimTypeToJNIType(T: type[int32]): type = jint
template nimTypeToJNIType(T: type[int64]): type = jlong
template nimTypeToJNIType(T: type[JVMObject]): type = jobject
template nimTypeToJNIType(T: type[string]): type = jstring


template jniValueToNim(e: JNIEnvPtr, v: jint, T: type[int32]): int32 = int32(v)
template jniValueToNim(e: JNIEnvPtr, v: jstring, T: type[string]): string = $v
template jniValueToNim(e: JNIEnvPtr, v: jobject, T: type[JVMObject]): auto =
  jniObjectToNimObj(e, v, T)


template nimValueToJni(e: JNIEnvPtr, v: int32, T: type[jint]): jint = jint(v)
template nimValueToJni(e: JNIEnvPtr, v: int64, T: type[jlong]): jlong = jlong(v)
template nimValueToJni(e: JNIEnvPtr, v: string, T: type[jstring]): jstring = e.NewStringUTF(e, v)
template nimValueToJni[T](e: JNIEnvPtr, v: T, V: type[void]) = v


template jniObjectToNimObj*(e: JNIEnvPtr, v: jobject, T: type[JVMObject]): auto =
  T.fromJObject(v)

template constSig(args: varargs[string]): cstring = static(cstring(args.join()))

proc raiseJVMException(e: JNIEnvPtr) {.noreturn.} =
  checkJVMException(e) # This should raise
  doAssert(false, "unreachable")

proc getNimObjectFromJObject(e: JNIEnvPtr, j: jobject): JVMObject =
  let clazz = e.GetObjectClass(e, j)
  if unlikely clazz.isNil: raiseJVMException(e)
  let fid = e.GetFieldID(e, clazz, PointerFieldName, "J")
  if unlikely fid.isNil: raiseJVMException(e)

  e.deleteLocalRef(clazz)
  result = cast[JVMObject](e.GetLongField(e, j, fid))

proc getNimDataFromJObject(e: JNIEnvPtr, j: jobject): RootRef =
  let clazz = e.GetObjectClass(e, j)
  if unlikely clazz.isNil: raiseJVMException(e)
  let fid = e.GetFieldID(e, clazz, PointerFieldName, "J")
  if unlikely fid.isNil: raiseJVMException(e)

  e.deleteLocalRef(clazz)
  result = cast[RootRef](e.GetLongField(e, j, fid))

proc setNimDataToJObject(e: JNIEnvPtr, j: jobject, clazz: JClass, o: RootRef) =
  let fid = e.GetFieldID(e, clazz, PointerFieldName, "J")
  if unlikely fid.isNil: raiseJVMException(e)
  GC_ref(o)
  e.SetLongField(e, j, fid, cast[jlong](o))

proc finalizeJobject(e: JNIEnvPtr, j: jobject, p: jlong) =
  let p = cast[RootRef](p)
  if not p.isNil:
    GC_unref(p)

proc implementConstructor(p: NimNode, className: string): NimNode =
  let iClazz = ident"clazz"
  let classIdent = ident(className)
  result = p
  p.params[0] = classIdent # Set result type to className
  p.params.insert(1, newIdentDefs(ident"this", newTree(nnkBracketExpr, ident"typedesc", classIdent))) # First arg needs to be typedesc[className]

  p.body = quote do:
    const fq = JnimPackageName.replace(".", "/") & "/Jnim$" & `className`
    var `iClazz` {.global.}: JVMClass
    if unlikely `iClazz`.isNil:
      `iClazz` = JVMClass.getByFqcn(fq)
      jniRegisterNativeMethods(`classIdent`, `iClazz`)

    let inst = `iClazz`.newObjectRaw("()V", [])
    when compiles(result.data):
      let data = new(type(result.data))
      setNimDataToJObject(theEnv, inst, `iClazz`.get, cast[RootRef](data))
    result = `classIdent`.fromJObjectConsumingLocalRef(inst)
    when compiles(result.data):
      result.data = data

macro jexport*(a: varargs[untyped]): untyped =
  var (className, parentClass, interfaces, body, isPublic) = extractArguments(a)
  echo "extractArguments: ", interfaces
  let classNameIdent = newIdentNode(className)

  let nonVirtualClassNameIdent = ident("JnimNonVirtual_" & className)

  let constructors = newNimNode(nnkStmtList)

  result = newNimNode(nnkStmtList)
  result.add quote do:

    proc jniFqcn*(t: type[`classNameIdent`]): string = "Jnim." & `className`

    proc jniObjectToNimObj*(e: JNIEnvPtr, v: jobject, T: typedesc[`classNameIdent`]): `classNameIdent` =
      result = T.fromJObject(v)
      when compiles(result.data):
        result.data = cast[type(result.data)](getNimDataFromJObject(e, v))

  var parentFq: NimNode
  if parentClass.len != 0:
    parentFq = newCall("jniFqcn", newIdentNode(parentClass))
    let nonVirtualParentClassNameIdent = ident("JnimNonVirtual_" & parentClass)
    result.add quote do:
      type `nonVirtualClassNameIdent` {.used.} = object of `nonVirtualParentClassNameIdent`
  else:
    parentFq = newLit("")
    result.add quote do:
      type `nonVirtualClassNameIdent` {.used.} = object of JnimNonVirtual_JVMObject

  result.add quote do:
    proc super*(v: `classNameIdent`): `nonVirtualClassNameIdent` =
      assert(not v.getNoCreate.isNil)
      `nonVirtualClassNameIdent`(obj: v.getNoCreate)

  proc toJInterfGens(genIinters: seq[GenericArgDef], inters: var NimNode, jinters: NimNode) =
    for i,genI in genIinters:
      inters.add newCall("jniFqcn", newIdentNode(genI.name.name))
      jinters.add(newCall("jniFqcn", newIdentNode(genI.name.name)))
      if genI.name.genericArgs.len != 0:
        jinters.add newLit("<")
      toJInterfGens genI.name.genericArgs, inters, jinters
      if i != genIinters.len-1:
        jinters.add newLit(", ")
    if genIinters.len != 0:
      jinters.add newLit(">")

  var inter = newCall(bindSym"varargsToSeqStr")
  var jinters = newCall(bindSym"varargsToStr")
  for i,interT in interfaces:
    inter.add(newCall("jniFqcn", newIdentNode(interT.name)))
    jinters.add(newCall("jniFqcn", newIdentNode(interT.name)))
    if interT.genericArgs.len != 0:
      jinters.add newLit("<")
    toJInterfGens interT.genericArgs, inter, jinters
    if i != interfaces.len-1:
      jinters.add newLit(", ")
  
  echo "jinters: ", jinters.repr
  var nativeMethodDefs = newNimNode(nnkBracket)

  var staticSection = newLit("")
  var emitSection = newLit("")

  var methodDefs = newCall(bindSym"varargsToSeqMethodDef")
  for m in body:
    case m.kind
    of nnkDiscardStmt: discard
    of nnkProcDef:
      let name = $m.name
      let isConstr = name == "new"

      let params = m.params

      var thunkParams = newSeq[NimNode]()
      let thunkName = genSym(nskProc, JniExportedFunctionPrefix & className & "_" & $m.name)
      var thunkCall = newCall(m.name)
      let envName = newIdentNode("jniEnv")

      # Prepare for jexportAux call
      var retType: NimNode
      if params[0].kind == nnkEmpty:
        retType = newLit("void")
        thunkParams.add(newIdentNode("void"))
      else:
        retType = newCall("jniFqcn", params[0])
        thunkParams.add(newCall(bindSym"nimTypeToJNIType", copyNimTree(params[0])))

      thunkParams.add(newIdentDefs(envName, newIdentNode("JNIEnvPtr")))
      thunkParams.add(newIdentDefs(ident"this", ident"jobject"))

      thunkCall.add(newCall(ident"jniObjectToNimObj", envName, ident"this", newCall("type", classNameIdent)))

      var sig = newCall(bindSym"constSig")
      sig.add(newLit("("))

      let argTypes = newCall(bindSym"varargsToSeqStr")
      for i in 1 ..< params.len:
        for j in 0 .. params[i].len - 3:
          let paramName = params[i][j]
          let pt = params[i][^2]
          let thunkParamType = newCall(bindSym"nimTypeToJniType", copyNimTree(pt))
          argTypes.add(newCall("jniFqcn", pt))
          sig.add(newCall("jniSig", copyNimTree(pt)))
          thunkParams.add(newIdentDefs(copyNimTree(paramName), thunkParamType))
          thunkCall.add(newCall(bindSym"jniValueToNim", envName, copyNimTree(paramName), copyNimTree(pt)))
      let md = newCall(bindSym"initMethodDescr", newLit($m.name), retType, argTypes)
      methodDefs.add(md)

      sig.add(newLit(")"))
      if params[0].kind == nnkEmpty:
        sig.add(newLit("V"))
      else:
        sig.add(newCall("jniSig", params[0]))

      if not isConstr:
        nativeMethodDefs.add(newTree(nnkObjConstr, newIdentNode("JNINativeMethod"),
          newTree(nnkExprColonExpr, newIdentNode("name"), newLit($m.name)),
          newTree(nnkExprColonExpr, newIdentNode("signature"), sig),
          newTree(nnkExprColonExpr, newIdentNode("fnPtr"), thunkName)))

        # Emit the definition as is
        m.params.insert(1, newIdentDefs(ident"this", classNameIdent))

        result.add(m)

        thunkCall = newCall(bindSym"nimValueToJni", envName, thunkCall, copyNimTree(thunkParams[0]))

        let thunk = newProc(thunkName, thunkParams)
        thunk.addPragma(newIdentNode("cdecl"))
        thunk.addPragma(newIdentNode("exportc")) # Allow jni runtime to discover the functions
        thunk.body = quote do:
          if theEnv.isNil: theEnv = `envName`
          `thunkCall`
        result.add(thunk)
  
      else:
        # implement constructor
        constructors.add(implementConstructor(m, className))


    of nnkCommand:
      case $m[0]
      of "staticSection":
        staticSection = m[1]
      of "emit":
        emitSection = m[1]
      else:
        echo "Unexpected AST: ", repr(m)
        assert(false)

    else:
      echo "Unexpected AST: ", repr(m)
      assert(false)

  block: # Finalizer thunk
    let thunkName = genSym(nskProc, JniExportedFunctionPrefix & className & "__0")
    result.add quote do:
      proc `thunkName`(jniEnv: JNIEnvPtr, this: jobject, p: jlong) {.exportc, cdecl.} =
        finalizeJobject(jniEnv, this, p)


  result.add newCall(bindSym"genJexportGlue", newLit(className), parentFq, inter, jinters, newLit(isPublic), methodDefs, staticSection, emitSection)

  # Add finalizer impl
  # nativeMethodDefs.add(newTree(nnkObjConstr, newIdentNode("JNINativeMethod"),
  #   newTree(nnkExprColonExpr, newIdentNode("name"), newLit(FinalizerName)),
  #   newTree(nnkExprColonExpr, newIdentNode("signature"), newLit("(J)V")),
  #   newTree(nnkExprColonExpr, newIdentNode("fnPtr"), bindSym"finalizeJobject")))

  let clazzIdent = ident"clazz"
  var nativeMethodsRegistration = newEmptyNode()
  if nativeMethodDefs.len != 0:
    nativeMethodsRegistration = quote do:
      var nativeMethods = `nativeMethodDefs`
      if nativeMethods.len != 0:
        let r = callVM theEnv.RegisterNatives(theEnv, `clazzIdent`.get(), addr nativeMethods[0], nativeMethods.len.jint)
        assert(r == 0)

  result.add quote do:
    proc jniRegisterNativeMethods(t: type[`classNameIdent`], `clazzIdent`: JVMClass) =
      `nativeMethodsRegistration`

  result.add(constructors)

  # Generate interface converters
  for interf in interfaces:
    let converterName = newIdentNode("to" & interf.name)
    let interfaceName = newIdentNode(interf.name)
    result.add quote do:
      converter `converterName`*(v: `classNameIdent`): `interfaceName` {.inline.} =
        cast[`interfaceName`](v)

  # echo repr result

macro debugPrintJavaGlue*(): untyped {.deprecated.} =
  echo javaGlue

