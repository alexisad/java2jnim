# To run these tests, simply execute `nimble test`.
GC_disable()

import jnim
#import jnim/private/jni_export
import java2jnim
import unittest
import strutils
import sequtils except toSeq

    
when false:
    jnimport_all:
        java.lang.Object
        java.lang.Comparable
        java.lang.Number
        java.lang.Boolean
        java.lang.Integer
        java.lang.Long
        java.lang.Double
        java.lang.String
        java.util.stream.Stream
        java.util.stream.Stream$Builder as StreamBuilder
        java.util.Collection
        java.util.Collections
        java.util.Set
        java.util.ArrayList
        java.util.Iterator
        java.util.HashMap
        java.util.Map
        java.util.Map$Entry as MapEntry
        
        java.util.function.BiFunction
        #java.util.Map$Entry as MapEntry

when true:
    jclassDef java.lang.Object * of JVMObject
    proc `$`*(o: Object): string =
        o.toStringRaw

    jclassDef java.lang.Comparable * [T] of Object
    jclassDef java.lang.Number * of Object
    jclassDef java.lang.Boolean * of Object
    jclassDef java.lang.Integer * of Number
    jclassDef java.lang.Long * of Number
    jclassDef java.lang.Double * of Number
    jclassDef java.lang.String * of Object
    jclassDef java.lang.AutoCloseable * of Object
    jclassDef java.util.stream.BaseStream * [T, S] of AutoCloseable
    jclassDef java.util.stream.Stream * [T] of BaseStream[T, Object]
    jclassDef java.util.function.Consumer * [T] of Object
    jclassDef java.util.stream.Stream $ Builder * [T] as StreamBuilder of Consumer[T]
    jclassDef java.lang.Iterable * [T] of Object
    jclassDef java.util.Collection * [E] of Iterable[E]
    jclassDef java.util.Collections * of Object
    jclassDef java.util.Set * [E] of Collection[E]
    jclassDef java.util.AbstractCollection * [E] of Object
    jclassDef java.util.AbstractList * [E] of AbstractCollection[E]
    jclassDef java.util.ArrayList * [E] of AbstractList[E]
    jclassDef java.util.Iterator * [E] of Object
    jclassDef java.util.AbstractMap * [K, V] of Object
    jclassDef java.util.HashMap * [K, V] of AbstractMap[K, V]
    jclassDef java.util.Map * [K, V] of Object
    jclassDef java.util.Map $ Entry * [K, V] as MapEntry of Object
    jclassDef java.util.function.BiFunction * [T, U, R] of Object
    jclassDef java.lang.Class * [T] of Object
    jclassDef java.util.Comparator * [T] of Object
    jclassDef java.nio.charset.Charset * of Object
    jclassDef java.lang.AbstractStringBuilder * of Object
    jclassDef java.lang.StringBuffer * of AbstractStringBuilder
    jclassDef java.lang.StringBuilder * of AbstractStringBuilder
    jclassDef java.lang.CharSequence * of Object
    jclassDef java.util.Locale * of Object
    jclassDef java.util.function.Predicate * [T] of Object
    jclassDef java.util.function.Function * [T, R] of Object
    jclassDef java.util.stream.IntStream * of BaseStream[Integer, IntStream]
    jclassDef java.util.function.ToIntFunction * [T] of Object
    jclassDef java.util.stream.LongStream * of BaseStream[Long, LongStream]
    jclassDef java.util.function.ToLongFunction * [T] of Object
    jclassDef java.util.stream.DoubleStream * of BaseStream[Double, DoubleStream]
    jclassDef java.util.function.ToDoubleFunction * [T] of Object
    jclassDef java.util.function.IntFunction * [R] of Object
    jclassDef java.util.function.BinaryOperator * [T] of BiFunction[T, T, T]
    jclassDef java.util.Optional * [T] of Object
    jclassDef java.util.function.Supplier * [T] of Object
    jclassDef java.util.function.BiConsumer * [T, U] of Object
    jclassDef java.util.stream.Collector * [T, A, R] of Object
    jclassDef java.util.function.UnaryOperator * [T] of Function[T, T]
    jclassDef java.util.Spliterator * [T] of Object
    jclassDef java.util.List * [E] of Collection[E]
    jclassDef java.util.Random * of Object
    jclassDef java.util.SortedSet * [E] of Set[E]
    jclassDef java.util.NavigableSet * [E] of SortedSet[E]
    jclassDef java.util.SortedMap * [K, V] of Map[K, V]
    jclassDef java.util.NavigableMap * [K, V] of SortedMap[K, V]
    jclassDef java.util.Queue * [E] of Collection[E]
    jclassDef java.util.ListIterator * [E] of Iterator[E]
    jclassDef java.util.Enumeration * [E] of Object
    jclassDef java.util.Deque * [E] of Queue[E]
    jclassImpl java.lang.Object * of JVMObject:
        proc new*()
        proc getClass*(): Class[Object] {.final.}
        proc hashCode*(): jint
        proc equals*(a03: Object): bool
        proc toString*(): String
        proc notify*() {.final.}
        proc notifyAll*() {.final.}
        proc wait*(a07: jlong) {.final.}
        proc wait*(a08: jlong; a18: jint) {.final.}
        proc wait*() {.final.}
    jclassImpl java.lang.Comparable * [T] of Object:
        proc compareTo*(a00: T): jint
    jclassImpl java.lang.Number * of Object:
        proc new*()
        proc intValue*(): jint
        proc longValue*(): jlong
        proc floatValue*(): jfloat
        proc doubleValue*(): jdouble
        proc byteValue*(): jbyte
        proc shortValue*(): jshort
    jclassImpl java.lang.Boolean * of Object:
        proc TRUE*(): Boolean {.prop, final, `static`.}
        proc FALSE*(): Boolean {.prop, final, `static`.}
        proc TYPE*(): Class[Boolean] {.prop, final, `static`.}
        proc new*(a03: jboolean)
        proc new*(a04: string)
        proc parseBoolean*(a05: string): bool {.`static`.}
        proc booleanValue*(): bool
        proc valueOf*(a07: jboolean): Boolean {.`static`.}
        proc valueOf*(a08: string): Boolean {.`static`.}
        proc toString*(a09: jboolean): String {.`static`.}
        proc toString*(): String
        proc hashCode*(): jint
        proc hashCode*(a012: jboolean): jint {.`static`.}
        proc equals*(a013: Object): bool
        proc getBoolean*(a014: string): bool {.`static`.}
        proc compareTo*(a015: Boolean): jint
        proc compare*(a016: jboolean; a116: jboolean): jint {.`static`.}
        proc logicalAnd*(a017: jboolean; a117: jboolean): bool {.`static`.}
        proc logicalOr*(a018: jboolean; a118: jboolean): bool {.`static`.}
        proc logicalXor*(a019: jboolean; a119: jboolean): bool {.`static`.}
        proc compareTo*(a020: Object): jint
    jclassImpl java.lang.Integer * of Number:
        proc MIN_VALUE*(): jint {.prop, final, `static`.}
        proc MAX_VALUE*(): jint {.prop, final, `static`.}
        proc TYPE*(): Class[Integer] {.prop, final, `static`.}
        proc SIZE*(): jint {.prop, final, `static`.}
        proc BYTES*(): jint {.prop, final, `static`.}
        proc toString*(a05: jint; a15: jint): String {.`static`.}
        proc toUnsignedString*(a06: jint; a16: jint): String {.`static`.}
        proc toHexString*(a07: jint): String {.`static`.}
        proc toOctalString*(a08: jint): String {.`static`.}
        proc toBinaryString*(a09: jint): String {.`static`.}
        proc toString*(a010: jint): String {.`static`.}
        proc toUnsignedString*(a011: jint): String {.`static`.}
        proc parseInt*(a012: string; a112: jint): jint {.`static`.}
        proc parseInt*(a013: string): jint {.`static`.}
        proc parseUnsignedInt*(a014: string; a114: jint): jint {.`static`.}
        proc parseUnsignedInt*(a015: string): jint {.`static`.}
        proc valueOf*(a016: string; a116: jint): Integer {.`static`.}
        proc valueOf*(a017: string): Integer {.`static`.}
        proc valueOf*(a018: jint): Integer {.`static`.}
        proc new*(a019: jint)
        proc new*(a020: string)
        proc byteValue*(): jbyte
        proc shortValue*(): jshort
        proc intValue*(): jint
        proc longValue*(): jlong
        proc floatValue*(): jfloat
        proc doubleValue*(): jdouble
        proc toString*(): String
        proc hashCode*(): jint
        proc hashCode*(a029: jint): jint {.`static`.}
        proc equals*(a030: Object): bool
        proc getInteger*(a031: string): Integer {.`static`.}
        proc getInteger*(a032: string; a132: jint): Integer {.`static`.}
        proc getInteger*(a033: string; a133: Integer): Integer {.`static`.}
        proc decode*(a034: string): Integer {.`static`.}
        proc compareTo*(a035: Integer): jint
        proc compare*(a036: jint; a136: jint): jint {.`static`.}
        proc compareUnsigned*(a037: jint; a137: jint): jint {.`static`.}
        proc toUnsignedLong*(a038: jint): jlong {.`static`.}
        proc divideUnsigned*(a039: jint; a139: jint): jint {.`static`.}
        proc remainderUnsigned*(a040: jint; a140: jint): jint {.`static`.}
        proc highestOneBit*(a041: jint): jint {.`static`.}
        proc lowestOneBit*(a042: jint): jint {.`static`.}
        proc numberOfLeadingZeros*(a043: jint): jint {.`static`.}
        proc numberOfTrailingZeros*(a044: jint): jint {.`static`.}
        proc bitCount*(a045: jint): jint {.`static`.}
        proc rotateLeft*(a046: jint; a146: jint): jint {.`static`.}
        proc rotateRight*(a047: jint; a147: jint): jint {.`static`.}
        proc reverse*(a048: jint): jint {.`static`.}
        proc signum*(a049: jint): jint {.`static`.}
        proc reverseBytes*(a050: jint): jint {.`static`.}
        proc sum*(a051: jint; a151: jint): jint {.`static`.}
        proc max*(a052: jint; a152: jint): jint {.`static`.}
        proc min*(a053: jint; a153: jint): jint {.`static`.}
        proc compareTo*(a054: Object): jint
    jclassImpl java.lang.Long * of Number:
        proc MIN_VALUE*(): jlong {.prop, final, `static`.}
        proc MAX_VALUE*(): jlong {.prop, final, `static`.}
        proc TYPE*(): Class[Long] {.prop, final, `static`.}
        proc SIZE*(): jint {.prop, final, `static`.}
        proc BYTES*(): jint {.prop, final, `static`.}
        proc toString*(a05: jlong; a15: jint): String {.`static`.}
        proc toUnsignedString*(a06: jlong; a16: jint): String {.`static`.}
        proc toHexString*(a07: jlong): String {.`static`.}
        proc toOctalString*(a08: jlong): String {.`static`.}
        proc toBinaryString*(a09: jlong): String {.`static`.}
        proc toString*(a010: jlong): String {.`static`.}
        proc toUnsignedString*(a011: jlong): String {.`static`.}
        proc parseLong*(a012: string; a112: jint): jlong {.`static`.}
        proc parseLong*(a013: string): jlong {.`static`.}
        proc parseUnsignedLong*(a014: string; a114: jint): jlong {.`static`.}
        proc parseUnsignedLong*(a015: string): jlong {.`static`.}
        proc valueOf*(a016: string; a116: jint): Long {.`static`.}
        proc valueOf*(a017: string): Long {.`static`.}
        proc valueOf*(a018: jlong): Long {.`static`.}
        proc decode*(a019: string): Long {.`static`.}
        proc new*(a020: jlong)
        proc new*(a021: string)
        proc byteValue*(): jbyte
        proc shortValue*(): jshort
        proc intValue*(): jint
        proc longValue*(): jlong
        proc floatValue*(): jfloat
        proc doubleValue*(): jdouble
        proc toString*(): String
        proc hashCode*(): jint
        proc hashCode*(a030: jlong): jint {.`static`.}
        proc equals*(a031: Object): bool
        proc getLong*(a032: string): Long {.`static`.}
        proc getLong*(a033: string; a133: jlong): Long {.`static`.}
        proc getLong*(a034: string; a134: Long): Long {.`static`.}
        proc compareTo*(a035: Long): jint
        proc compare*(a036: jlong; a136: jlong): jint {.`static`.}
        proc compareUnsigned*(a037: jlong; a137: jlong): jint {.`static`.}
        proc divideUnsigned*(a038: jlong; a138: jlong): jlong {.`static`.}
        proc remainderUnsigned*(a039: jlong; a139: jlong): jlong {.`static`.}
        proc highestOneBit*(a040: jlong): jlong {.`static`.}
        proc lowestOneBit*(a041: jlong): jlong {.`static`.}
        proc numberOfLeadingZeros*(a042: jlong): jint {.`static`.}
        proc numberOfTrailingZeros*(a043: jlong): jint {.`static`.}
        proc bitCount*(a044: jlong): jint {.`static`.}
        proc rotateLeft*(a045: jlong; a145: jint): jlong {.`static`.}
        proc rotateRight*(a046: jlong; a146: jint): jlong {.`static`.}
        proc reverse*(a047: jlong): jlong {.`static`.}
        proc signum*(a048: jlong): jint {.`static`.}
        proc reverseBytes*(a049: jlong): jlong {.`static`.}
        proc sum*(a050: jlong; a150: jlong): jlong {.`static`.}
        proc max*(a051: jlong; a151: jlong): jlong {.`static`.}
        proc min*(a052: jlong; a152: jlong): jlong {.`static`.}
        proc compareTo*(a053: Object): jint
    jclassImpl java.lang.Double * of Number:
        proc POSITIVE_INFINITY*(): jdouble {.prop, final, `static`.}
        proc NEGATIVE_INFINITY*(): jdouble {.prop, final, `static`.}
        proc NaN*(): jdouble {.prop, final, `static`.}
        proc MAX_VALUE*(): jdouble {.prop, final, `static`.}
        proc MIN_NORMAL*(): jdouble {.prop, final, `static`.}
        proc MIN_VALUE*(): jdouble {.prop, final, `static`.}
        proc MAX_EXPONENT*(): jint {.prop, final, `static`.}
        proc MIN_EXPONENT*(): jint {.prop, final, `static`.}
        proc SIZE*(): jint {.prop, final, `static`.}
        proc BYTES*(): jint {.prop, final, `static`.}
        proc TYPE*(): Class[Double] {.prop, final, `static`.}
        proc toString*(a011: jdouble): String {.`static`.}
        proc toHexString*(a012: jdouble): String {.`static`.}
        proc valueOf*(a013: string): Double {.`static`.}
        proc valueOf*(a014: jdouble): Double {.`static`.}
        proc parseDouble*(a015: string): jdouble {.`static`.}
        proc isNaN*(a016: jdouble): bool {.`static`.}
        proc isInfinite*(a017: jdouble): bool {.`static`.}
        proc isFinite*(a018: jdouble): bool {.`static`.}
        proc new*(a019: jdouble)
        proc new*(a020: string)
        proc isNaN*(): bool
        proc isInfinite*(): bool
        proc toString*(): String
        proc byteValue*(): jbyte
        proc shortValue*(): jshort
        proc intValue*(): jint
        proc longValue*(): jlong
        proc floatValue*(): jfloat
        proc doubleValue*(): jdouble
        proc hashCode*(): jint
        proc hashCode*(a031: jdouble): jint {.`static`.}
        proc equals*(a032: Object): bool
        proc doubleToLongBits*(a033: jdouble): jlong {.`static`.}
        proc doubleToRawLongBits*(a034: jdouble): jlong {.`static`.}
        proc longBitsToDouble*(a035: jlong): jdouble {.`static`.}
        proc compareTo*(a036: Double): jint
        proc compare*(a037: jdouble; a137: jdouble): jint {.`static`.}
        proc sum*(a038: jdouble; a138: jdouble): jdouble {.`static`.}
        proc max*(a039: jdouble; a139: jdouble): jdouble {.`static`.}
        proc min*(a040: jdouble; a140: jdouble): jdouble {.`static`.}
        proc compareTo*(a041: Object): jint
    jclassImpl java.lang.String * of Object:
        proc CASE_INSENSITIVE_ORDER*(): Comparator[String] {.prop, final, `static`.}
        proc new*()
        proc new*(a02: string)
        proc new*(a03: seq[jchar])
        proc new*(a04: seq[jchar]; a14: jint; a24: jint)
        proc new*(a05: seq[jint]; a15: jint; a25: jint)
        proc new*(a06: seq[jbyte]; a16: jint; a26: jint; a36: jint)
        proc new*(a07: seq[jbyte]; a17: jint)
        proc new*(a08: seq[jbyte]; a18: jint; a28: jint; a38: string)
        proc new*(a09: seq[jbyte]; a19: jint; a29: jint; a39: Charset)
        proc new*(a010: seq[jbyte]; a110: string)
        proc new*(a011: seq[jbyte]; a111: Charset)
        proc new*(a012: seq[jbyte]; a112: jint; a212: jint)
        proc new*(a013: seq[jbyte])
        proc new*(a014: StringBuffer)
        proc new*(a015: StringBuilder)
        proc length*(): jint
        proc isEmpty*(): bool
        proc charAt*(a018: jint): jchar
        proc codePointAt*(a019: jint): jint
        proc codePointBefore*(a020: jint): jint
        proc codePointCount*(a021: jint; a121: jint): jint
        proc offsetByCodePoints*(a022: jint; a122: jint): jint
        proc getChars*(a023: jint; a123: jint; a223: seq[jchar]; a323: jint)
        proc getBytes*(a024: jint; a124: jint; a224: seq[jbyte]; a324: jint)
        proc getBytes*(a025: string): seq[jbyte]
        proc getBytes*(a026: Charset): seq[jbyte]
        proc getBytes*(): seq[jbyte]
        proc equals*(a028: Object): bool
        proc contentEquals*(a029: StringBuffer): bool
        proc contentEquals*(a030: CharSequence): bool
        proc equalsIgnoreCase*(a031: string): bool
        proc compareTo*(a032: string): jint
        proc compareToIgnoreCase*(a033: string): jint
        proc regionMatches*(a034: jint; a134: string; a234: jint; a334: jint): bool
        proc regionMatches*(a035: jboolean; a135: jint; a235: string; a335: jint; a435: jint): bool
        proc startsWith*(a036: string; a136: jint): bool
        proc startsWith*(a037: string): bool
        proc endsWith*(a038: string): bool
        proc hashCode*(): jint
        proc indexOf*(a040: jint): jint
        proc indexOf*(a041: jint; a141: jint): jint
        proc lastIndexOf*(a042: jint): jint
        proc lastIndexOf*(a043: jint; a143: jint): jint
        proc indexOf*(a044: string): jint
        proc indexOf*(a045: string; a145: jint): jint
        proc lastIndexOf*(a046: string): jint
        proc lastIndexOf*(a047: string; a147: jint): jint
        proc substring*(a048: jint): String
        proc substring*(a049: jint; a149: jint): String
        proc subSequence*(a050: jint; a150: jint): CharSequence
        proc concat*(a051: string): String
        proc replace*(a052: jchar; a152: jchar): String
        proc matches*(a053: string): bool
        proc contains*(a054: CharSequence): bool
        proc replaceFirst*(a055: string; a155: string): String
        proc replaceAll*(a056: string; a156: string): String
        proc replace*(a057: CharSequence; a157: CharSequence): String
        proc split*(a058: string; a158: jint): seq[String]
        proc split*(a059: string): seq[String]
        proc join*(a060: CharSequence; a160: varargs[CharSequence]): String {.`static`.}
        proc join*(a061: CharSequence; a161: Iterable[CharSequence]): String {.`static`.}
        proc toLowerCase*(a062: Locale): String
        proc toLowerCase*(): String
        proc toUpperCase*(a064: Locale): String
        proc toUpperCase*(): String
        proc trim*(): String
        proc toString*(): String
        proc toCharArray*(): seq[jchar]
        proc format*(a069: string; a169: varargs[Object]): String {.`static`.}
        proc format*(a070: Locale; a170: string; a270: varargs[Object]): String {.`static`.}
        proc valueOf*(a071: Object): String {.`static`.}
        proc valueOf*(a072: seq[jchar]): String {.`static`.}
        proc valueOf*(a073: seq[jchar]; a173: jint; a273: jint): String {.`static`.}
        proc copyValueOf*(a074: seq[jchar]; a174: jint; a274: jint): String {.`static`.}
        proc copyValueOf*(a075: seq[jchar]): String {.`static`.}
        proc valueOf*(a076: jboolean): String {.`static`.}
        proc valueOf*(a077: jchar): String {.`static`.}
        proc valueOf*(a078: jint): String {.`static`.}
        proc valueOf*(a079: jlong): String {.`static`.}
        proc valueOf*(a080: jfloat): String {.`static`.}
        proc valueOf*(a081: jdouble): String {.`static`.}
        proc intern*(): String
        proc compareTo*(a083: Object): jint
    jclassImpl java.util.stream.Stream * [T] of BaseStream[T, Object]:
        proc filter*(a00: Predicate[T]): Stream[T]
        proc map*[R](a01: Function[T, R]): Stream[R]
        proc mapToInt*(a02: ToIntFunction[T]): IntStream
        proc mapToLong*(a03: ToLongFunction[T]): LongStream
        proc mapToDouble*(a04: ToDoubleFunction[T]): DoubleStream
        proc flatMap*[R](a05: Function[T, Stream]): Stream[R]
        proc flatMapToInt*(a06: Function[T, IntStream]): IntStream
        proc flatMapToLong*(a07: Function[T, LongStream]): LongStream
        proc flatMapToDouble*(a08: Function[T, DoubleStream]): DoubleStream
        proc `distinct`*(): Stream[T]
        proc sorted*(): Stream[T]
        proc sorted*(a011: Comparator[T]): Stream[T]
        proc peek*(a012: Consumer[T]): Stream[T]
        proc limit*(a013: jlong): Stream[T]
        proc skip*(a014: jlong): Stream[T]
        proc forEach*(a015: Consumer[T])
        proc forEachOrdered*(a016: Consumer[T])
        proc toArray*(): seq[Object]
        proc toArray*[A](a018: IntFunction[seq[A]]): seq[A]
        proc reduce*(a019: T; a119: BinaryOperator[T]): T
        proc reduce*(a020: BinaryOperator[T]): Optional[T]
        proc reduce*[U](a021: U; a121: BiFunction[U, T, U]; a221: BinaryOperator[U]): U
        proc collect*[R](a022: Supplier[R]; a122: BiConsumer[R, T]; a222: BiConsumer[R, R]): R
        proc collect*[R, A](a023: Collector[T, A, R]): R
        proc min*(a024: Comparator[T]): Optional[T]
        proc max*(a025: Comparator[T]): Optional[T]
        proc count*(): jlong
        proc anyMatch*(a027: Predicate[T]): bool
        proc allMatch*(a028: Predicate[T]): bool
        proc noneMatch*(a029: Predicate[T]): bool
        proc findFirst*(): Optional[T]
        proc findAny*(): Optional[T]
        proc builder*[T](): StreamBuilder[T] {.`static`.}
        proc empty*[T](): Stream[T] {.`static`.}
        proc `of`*[T](a034: T): Stream[T] {.`static`.}
        proc `of`*[T](a035: varargs[T]): Stream[T] {.`static`.}
        proc iterate*[T](a036: T; a136: UnaryOperator[T]): Stream[T] {.`static`.}
        proc generate*[T](a037: Supplier[T]): Stream[T] {.`static`.}
        proc concat*[T](a038: Stream[T]; a138: Stream[T]): Stream[T] {.`static`.}
    jclassImpl java.util.stream.Stream $ Builder * [T] as StreamBuilder of Consumer[T]:
        proc accept*(a00: T)
        proc add*(a01: T): StreamBuilder[T]
        proc build*(): Stream[T]
    jclassImpl java.util.Collection * [E] of Iterable[E]:
        proc size*(): jint
        proc isEmpty*(): bool
        proc contains*(a02: Object): bool
        proc `iterator`*(): Iterator[E]
        proc toArray*(): seq[Object]
        proc add*(a05: E): bool
        proc remove*(a06: Object): bool
        proc containsAll*(a07: Collection[Object]): bool
        proc addAll*(a08: Collection[E]): bool
        proc removeAll*(a09: Collection[Object]): bool
        proc removeIf*(a010: Predicate[E]): bool
        proc retainAll*(a011: Collection[Object]): bool
        proc clear*()
        proc equals*(a013: Object): bool
        proc hashCode*(): jint
        proc spliterator*(): Spliterator[E]
        proc stream*(): Stream[E]
        proc parallelStream*(): Stream[E]
    jclassImpl java.util.Collections * of Object:
        proc EMPTY_SET*(): Set {.prop, final, `static`.}
        proc EMPTY_LIST*(): List {.prop, final, `static`.}
        proc EMPTY_MAP*(): Map {.prop, final, `static`.}
        proc sort*[T](a03: List[T]) {.`static`.}
        proc sort*[T](a04: List[T]; a14: Comparator[T]) {.`static`.}
        proc binarySearch*[T](a05: List[Comparable]; a15: T): jint {.`static`.}
        proc binarySearch*[T](a06: List[T]; a16: T; a26: Comparator[T]): jint {.`static`.}
        proc reverse*(a07: List[Object]) {.`static`.}
        proc shuffle*(a08: List[Object]) {.`static`.}
        proc shuffle*(a09: List[Object]; a19: Random) {.`static`.}
        proc swap*(a010: List[Object]; a110: jint; a210: jint) {.`static`.}
        proc fill*[T](a011: List[T]; a111: T) {.`static`.}
        proc copy*[T](a012: List[T]; a112: List[T]) {.`static`.}
        proc min*[T](a013: Collection[T]): T {.`static`.}
        proc min*[T](a014: Collection[T]; a114: Comparator[T]): T {.`static`.}
        proc max*[T](a015: Collection[T]): T {.`static`.}
        proc max*[T](a016: Collection[T]; a116: Comparator[T]): T {.`static`.}
        proc rotate*(a017: List[Object]; a117: jint) {.`static`.}
        proc replaceAll*[T](a018: List[T]; a118: T; a218: T): bool {.`static`.}
        proc indexOfSubList*(a019: List[Object]; a119: List[Object]): jint {.`static`.}
        proc lastIndexOfSubList*(a020: List[Object]; a120: List[Object]): jint {.`static`.}
        proc unmodifiableCollection*[T](a021: Collection[T]): Collection[T] {.`static`.}
        proc unmodifiableSet*[T](a022: Set[T]): Set[T] {.`static`.}
        proc unmodifiableSortedSet*[T](a023: SortedSet[T]): SortedSet[T] {.`static`.}
        proc unmodifiableNavigableSet*[T](a024: NavigableSet[T]): NavigableSet[T] {.
            `static`.}
        proc unmodifiableList*[T](a025: List[T]): List[T] {.`static`.}
        proc unmodifiableMap*[K, V](a026: Map[K, V]): Map[K, V] {.`static`.}
        proc unmodifiableSortedMap*[K, V](a027: SortedMap[K, V]): SortedMap[K, V] {.`static`.}
        proc unmodifiableNavigableMap*[K, V](a028: NavigableMap[K, V]): NavigableMap[K, V] {.
            `static`.}
        proc synchronizedCollection*[T](a029: Collection[T]): Collection[T] {.`static`.}
        proc synchronizedSet*[T](a030: Set[T]): Set[T] {.`static`.}
        proc synchronizedSortedSet*[T](a031: SortedSet[T]): SortedSet[T] {.`static`.}
        proc synchronizedNavigableSet*[T](a032: NavigableSet[T]): NavigableSet[T] {.
            `static`.}
        proc synchronizedList*[T](a033: List[T]): List[T] {.`static`.}
        proc synchronizedMap*[K, V](a034: Map[K, V]): Map[K, V] {.`static`.}
        proc synchronizedSortedMap*[K, V](a035: SortedMap[K, V]): SortedMap[K, V] {.`static`.}
        proc synchronizedNavigableMap*[K, V](a036: NavigableMap[K, V]): NavigableMap[K, V] {.
            `static`.}
        proc checkedCollection*[E](a037: Collection[E]; a137: Class[E]): Collection[E] {.
            `static`.}
        proc checkedQueue*[E](a038: Queue[E]; a138: Class[E]): Queue[E] {.`static`.}
        proc checkedSet*[E](a039: Set[E]; a139: Class[E]): Set[E] {.`static`.}
        proc checkedSortedSet*[E](a040: SortedSet[E]; a140: Class[E]): SortedSet[E] {.
            `static`.}
        proc checkedNavigableSet*[E](a041: NavigableSet[E]; a141: Class[E]): NavigableSet[E] {.
            `static`.}
        proc checkedList*[E](a042: List[E]; a142: Class[E]): List[E] {.`static`.}
        proc checkedMap*[K, V](a043: Map[K, V]; a143: Class[K]; a243: Class[V]): Map[K, V] {.
            `static`.}
        proc checkedSortedMap*[K, V](a044: SortedMap[K, V]; a144: Class[K]; a244: Class[V]): SortedMap[
            K, V] {.`static`.}
        proc checkedNavigableMap*[K, V](a045: NavigableMap[K, V]; a145: Class[K];
                                    a245: Class[V]): NavigableMap[K, V] {.`static`.}
        proc emptyIterator*[T](): Iterator[T] {.`static`.}
        proc emptyListIterator*[T](): ListIterator[T] {.`static`.}
        proc emptyEnumeration*[T](): Enumeration[T] {.`static`.}
        proc emptySet*[T](): Set[T] {.final, `static`.}
        proc emptySortedSet*[E](): SortedSet[E] {.`static`.}
        proc emptyNavigableSet*[E](): NavigableSet[E] {.`static`.}
        proc emptyList*[T](): List[T] {.final, `static`.}
        proc emptyMap*[K, V](): Map[K, V] {.final, `static`.}
        proc emptySortedMap*[K, V](): SortedMap[K, V] {.final, `static`.}
        proc emptyNavigableMap*[K, V](): NavigableMap[K, V] {.final, `static`.}
        proc singleton*[T](a056: T): Set[T] {.`static`.}
        proc singletonList*[T](a057: T): List[T] {.`static`.}
        proc singletonMap*[K, V](a058: K; a158: V): Map[K, V] {.`static`.}
        proc nCopies*[T](a059: jint; a159: T): List[T] {.`static`.}
        proc reverseOrder*[T](): Comparator[T] {.`static`.}
        proc reverseOrder*[T](a061: Comparator[T]): Comparator[T] {.`static`.}
        proc enumeration*[T](a062: Collection[T]): Enumeration[T] {.`static`.}
        proc list*[T](a063: Enumeration[T]): ArrayList[T] {.`static`.}
        proc frequency*(a064: Collection[Object]; a164: Object): jint {.`static`.}
        proc disjoint*(a065: Collection[Object]; a165: Collection[Object]): bool {.`static`.}
        proc addAll*[T](a066: Collection[T]; a166: varargs[T]): bool {.`static`.}
        proc newSetFromMap*[E](a067: Map[E, Boolean]): Set[E] {.`static`.}
        proc asLifoQueue*[T](a068: Deque[T]): Queue[T] {.`static`.}
    jclassImpl java.util.Set * [E] of Collection[E]:
        proc size*(): jint
        proc isEmpty*(): bool
        proc contains*(a02: Object): bool
        proc `iterator`*(): Iterator[E]
        proc toArray*(): seq[Object]
        proc add*(a05: E): bool
        proc remove*(a06: Object): bool
        proc containsAll*(a07: Collection[Object]): bool
        proc addAll*(a08: Collection[E]): bool
        proc retainAll*(a09: Collection[Object]): bool
        proc removeAll*(a010: Collection[Object]): bool
        proc clear*()
        proc equals*(a012: Object): bool
        proc hashCode*(): jint
        proc spliterator*(): Spliterator[E]
    jclassImpl java.util.ArrayList * [E] of AbstractList[E]:
        proc new*(a00: jint)
        proc new*()
        proc new*(a02: Collection[E])
        proc trimToSize*()
        proc ensureCapacity*(a04: jint)
        proc size*(): jint
        proc isEmpty*(): bool
        proc contains*(a07: Object): bool
        proc indexOf*(a08: Object): jint
        proc lastIndexOf*(a09: Object): jint
        proc clone*(): Object
        proc toArray*(): seq[Object]
        proc get*(a012: jint): E
        proc set*(a013: jint; a113: E): E
        proc add*(a014: E): bool
        proc add*(a015: jint; a115: E)
        proc remove*(a016: jint): E
        proc remove*(a017: Object): bool
        proc clear*()
        proc addAll*(a019: Collection[E]): bool
        proc addAll*(a020: jint; a120: Collection[E]): bool
        proc removeAll*(a021: Collection[Object]): bool
        proc retainAll*(a022: Collection[Object]): bool
        proc listIterator*(a023: jint): ListIterator[E]
        proc listIterator*(): ListIterator[E]
        proc `iterator`*(): Iterator[E]
        proc subList*(a026: jint; a126: jint): List[E]
        proc forEach*(a027: Consumer[E])
        proc spliterator*(): Spliterator[E]
        proc removeIf*(a029: Predicate[E]): bool
        proc replaceAll*(a030: UnaryOperator[E])
        proc sort*(a031: Comparator[E])
    jclassImpl java.util.Iterator * [E] of Object:
        proc hasNext*(): bool
        proc next*(): E
        proc remove*()
        proc forEachRemaining*(a03: Consumer[E])
    jclassImpl java.util.HashMap * [K, V] of AbstractMap[K, V]:
        proc new*(a00: jint; a10: jfloat)
        proc new*(a01: jint)
        proc new*()
        proc new*(a03: Map[K, V])
        proc size*(): jint
        proc isEmpty*(): bool
        proc get*(a06: Object): V
        proc containsKey*(a07: Object): bool
        proc put*(a08: K; a18: V): V
        proc putAll*(a09: Map[K, V])
        proc remove*(a010: Object): V
        proc clear*()
        proc containsValue*(a012: Object): bool
        proc keySet*(): Set[K]
        proc values*(): Collection[V]
        proc entrySet*(): Set[MapEntry[K, V]]
        proc getOrDefault*(a016: Object; a116: V): V
        proc putIfAbsent*(a017: K; a117: V): V
        proc remove*(a018: Object; a118: Object): bool
        proc replace*(a019: K; a119: V; a219: V): bool
        proc replace*(a020: K; a120: V): V
        proc computeIfAbsent*(a021: K; a121: Function[K, V]): V
        proc computeIfPresent*(a022: K; a122: BiFunction[K, V, V]): V
        proc compute*(a023: K; a123: BiFunction[K, V, V]): V
        proc merge*(a024: K; a124: V; a224: BiFunction[V, V, V]): V
        proc forEach*(a025: BiConsumer[K, V])
        proc replaceAll*(a026: BiFunction[K, V, V])
        proc clone*(): Object
    jclassImpl java.util.Map * [K, V] of Object:
        proc size*(): jint
        proc isEmpty*(): bool
        proc containsKey*(a02: Object): bool
        proc containsValue*(a03: Object): bool
        proc get*(a04: Object): V
        proc put*(a05: K; a15: V): V
        proc remove*(a06: Object): V
        proc putAll*(a07: Map[K, V])
        proc clear*()
        proc keySet*(): Set[K]
        proc values*(): Collection[V]
        proc entrySet*(): Set[MapEntry[K, V]]
        proc equals*(a012: Object): bool
        proc hashCode*(): jint
        proc getOrDefault*(a014: Object; a114: V): V
        proc forEach*(a015: BiConsumer[K, V])
        proc replaceAll*(a016: BiFunction[K, V, V])
        proc putIfAbsent*(a017: K; a117: V): V
        proc remove*(a018: Object; a118: Object): bool
        proc replace*(a019: K; a119: V; a219: V): bool
        proc replace*(a020: K; a120: V): V
        proc computeIfAbsent*(a021: K; a121: Function[K, V]): V
        proc computeIfPresent*(a022: K; a122: BiFunction[K, V, V]): V
        proc compute*(a023: K; a123: BiFunction[K, V, V]): V
        proc merge*(a024: K; a124: V; a224: BiFunction[V, V, V]): V
    jclassImpl java.util.Map $ Entry * [K, V] as MapEntry of Object:
        proc getKey*(): K
        proc getValue*(): V
        proc setValue*(a02: V): V
        proc equals*(a03: Object): bool
        proc hashCode*(): jint
        proc comparingByKey*[K, V](): Comparator[MapEntry[K, V]] {.`static`.}
        proc comparingByValue*[K, V](): Comparator[MapEntry[K, V]] {.`static`.}
        proc comparingByKey*[K, V](a07: Comparator[K]): Comparator[MapEntry[K, V]] {.
            `static`.}
        proc comparingByValue*[K, V](a08: Comparator[V]): Comparator[MapEntry[K, V]] {.
            `static`.}
    jclassImpl java.util.function.BiFunction * [T, U, R] of Object:
        proc apply*(a00: T; a10: U): R
        proc andThen*[V](a01: Function[R, V]): BiFunction[T, U, V]


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
        #var map = jcast[ Map[Integer, string] ](m)
        let mSet = m.entrySet()
        let cbV = MapEntry[Integer, string].comparingByValue()
        let stm = mSet
                .stream()
                .sorted(Collections.reverseOrder(MapEntry[Integer, string].comparingByValue()))
        let it = mSet.`iterator`
        while it.hasNext:
            let me = jcast[ MapEntry[Integer, string] ](it.next)
            echo me.getKey
        var mapFrSet = jcast[ Map[Integer, string] ](HashMap[Integer, string].new())

        #let cmpV = m.comparingByValue()