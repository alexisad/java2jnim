# To run these tests, simply execute `nimble test`.

import jnim
import jnim/private/jni_export
import java2jnim
import unittest
import strutils
import sequtils except toSeq

when true:
    jnimport_all:
        java.lang.Object
        java.util.ArrayList
        java.util.Iterator
        java.util.HashMap
        java.util.Map$Entry as MapEntry
        java.lang.Integer
        #java.util.function.BiFunction
        #java.util.Map$Entry as MapEntry


when false:
    jclassDef java.lang.Object * of JVMObject
    proc `$`*(o: Object): string =
        o.toStringRaw

    jclassDef java.util.function.BiFunction * [T, U, R] of Object
    jclassDef java.lang.Class * [T] of Object
    jclassDef java.lang.String * of Object
    jclassDef java.util.function.Function * [R, V] of Object
    jclassImpl java.lang.Object * of JVMObject:
        proc new*()
        proc getClass*(): Class[Object]
        proc hashCode*(): jint
        proc equals*(a0: Object): bool
        proc toString*(): String
        proc notify*()
        proc notifyAll*()
        proc wait*(a0: jlong)
        proc wait*(a0: jlong; a1: jint)
        proc wait*()
    jclassImpl java.lang.String * of Object:
        proc new*
        proc new*(s: string)
        proc new*(chars: seq[jbyte])
        proc new*(chars: seq[jbyte], charsetName: string)
        proc length*: jint
        proc getBytes*: seq[jbyte]
        proc getBytes*(charsetName: string): seq[jbyte]
    jclassImpl java.util.function.BiFunction * [T, U, R] of Object:
        proc apply*(a0: T; a1: U): R
        proc andThen*[V](a0: Function[R, V]): BiFunction[T, U, V]



when false:
    jnimport_all:
        java.lang.Object
        java.lang.Iterable
        java.util.AbstractCollection
        java.util.AbstractList
        java.util.ArrayList
        java.util.function.BiFunction
        java.util.Iterator
        java.util.AbstractMap
        #java.util.Comparator
        java.util.Map
        java.util.Map$Entry as MapEntry
        java.util.HashMap
        #java.util.Collection
        #java.util.List

when false:
    jclassDef java.util.Map$Entry*[K,V] as MapEntry of Object
    jclassDef java.util.Comparator[T] * of Object
    jclassImpl java.util.Map$Entry*[K,V] as MapEntry of Object:
        proc getKey*: K
        proc getValue*: V
        proc setValue*(v: V): V
        proc comparingByKey*(): Comparator[MapEntry[K,V]]


# Initialize JVM
initJNI(JNIVersion.v1_8)

suite "java.util":
    setup:
        if not isJNIThreadInitialized():
            initJNI(JNIVersion.v1_8)
    test "java.util.List":
        let xs = ArrayList[string].new()
        discard xs.add("Hello")
        xs.add(1, "world")
        check: xs.get(0) == "Hello"
        check: xs.get(1) == "world"
        expect JavaException:
            discard xs.get(3)
        var s = newSeq[string]()
        let it = xs.`iterator`
        while it.hasNext:
            s.add it.next
        check: s == @["Hello", "world"]
        #discard xs.removeAll(ArrayList[string].new(["world", "!"]))
        #check: xs.toSeq == @["Hello"]
    test "java.util.Map":
        let m = HashMap[Integer, string].new()
        discard m.put(1.jint, "A")
        discard m.put(2.jint, "B")
        discard m.put(3.jint, "C")
        check: m.get(1.jint) == "A"
        check: m.get(2.jint) == "B"
        check: m.get(3.jint) == "C"
        check: m.keySet.toSeq.mapIt(it.intValue) == @[1.jint, 2, 3]
        check: m.keySet.toSeq == @[1.jint, 2, 3].mapIt(Integer.new(it))
        check: m.values.toSeq == @["A", "B", "C"]