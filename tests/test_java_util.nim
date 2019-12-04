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
        java.lang.Long
        java.lang.String
        java.util.stream.Stream
        java.util.stream.Stream$Builder as StreamBuilder
        java.util.Collection
        java.util.ArrayList
        java.util.Iterator
        java.util.HashMap
        java.util.Map$Entry as MapEntry
        java.lang.Number
        java.lang.Integer
        java.util.function.BiFunction
        #java.util.Map$Entry as MapEntry



#################################################################################################### 
# Helpers

proc toSeq*[V](c: Collection[V]): seq[V] =
    result = newSeq[V]()
    let it = c.`iterator`
    while it.hasNext:
        result.add it.next

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
        var x = HashMap[Integer, string].new()
        discard x.put(Integer.new 1, "A")
        var m = HashMap[Integer, string].new()
        discard m.put(Integer.new 1, "A")
        discard m.put(Integer.new 3, "C")
        discard m.put(Integer.new 2, "B")
        check: m.get(Integer.new 1) == "A"
        check: m.get(Integer.new 2) == "B"
        check: m.get(Integer.new 3) == "C"
        check: m.keySet.toSeq.mapIt(it.intValue) == @[1.jint, 2, 3]
        check: m.keySet.toSeq == @[1.jint, 2, 3].mapIt(Integer.new(it))
        check: m.values.toSeq == @[ "A",  "B",  "C"]