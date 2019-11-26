# To run these tests, simply execute `nimble test`.

import jnim
import java2jnim
import unittest
import sequtils except toSeq

jnimport_all:
    java.lang.Object
    java.lang.Iterable
    java.util.AbstractCollection
    java.util.AbstractList
    java.util.ArrayList
    java.util.Iterator
    java.util.AbstractMap
    java.util.HashMap
    #java.util.Collection
    #java.util.List

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