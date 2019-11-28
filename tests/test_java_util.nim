# To run these tests, simply execute `nimble test`.
GC_disable()

import jnim
#import jnim/private/jni_export
import java2jnim
import unittest
import strutils
import sequtils except toSeq

when true:
    jnimport_all:
        java.lang.Object
        java.lang.String
        java.util.ArrayList
        java.util.Iterator
        java.util.HashMap
        java.util.Map$Entry as MapEntry
        java.lang.Integer
        #java.util.function.BiFunction
        #java.util.Map$Entry as MapEntry





# Initialize JVM
initJNI()
#initJNI(JNIVersion.v1_6)

suite "java.util":
    setup:
        echo "setup test..."
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
        var m2 = HashMap[string, string].new()
        let x3 = m2.put("111.00", "Hi Alex")
        var m = HashMap[Integer, String].new()
        let x = m.put(Integer.new(1), String.new("Hi"))
        let x2 = m.put(Integer.new(1), String.new "B")
        echo "m: ", m, m2
        echo "x2: ", x2
        when false:
            discard m.put(3.jint, "C")
            check: m.get(1.jint) == "A"
            check: m.get(2.jint) == "B"
            check: m.get(3.jint) == "C"
            check: m.keySet.toSeq.mapIt(it.intValue) == @[1.jint, 2, 3]
            check: m.keySet.toSeq == @[1.jint, 2, 3].mapIt(Integer.new(it))
            check: m.values.toSeq == @["A", "B", "C"]