package tests;

import haxe.ds.GenericStack;
import haxe.ds.Vector;
import benchmark.model.MethodTest;
import benchmark.model.TestSuite;

class CollectionTestSuite extends TestSuite {

    //------------------------------
    //  properties
    //------------------------------

    private var _array:Array<Int>;
    private var _vector:Vector<Int>;
    private var _list:List<Int>;
    private var _genericStack:GenericStack<Int>;
    private var _map:Map<Int, Int>;

    //------------------------------
    //  methods
    //------------------------------

    public function new() {
        super();

        name = "Collection";
        description = "Adding elements to end collections";
        initFunction = initialize;
        baselineTest = new MethodTest(baseline);
        loops = 10000;
        iterations = 4;
        tests = [
            new MethodTest(arrayPush, null, "Array push an item"),
            new MethodTest(vectorSet, null, "Vector set an item"),
            new MethodTest(listAdd, null, "List add an item"),
            new MethodTest(genericStackAdd, null, "Generic stack add an item"),
            new MethodTest(mapSet, null, "Map set an item")
        ];
    }


    //------------------------------
    //  initialization
    //------------------------------

    public function initialize():Void {
        _array = new Array<Int>();
        _genericStack = new GenericStack<Int>();
        _list = new List<Int>();
        _map = new Map<Int, Int>();
        _vector = new Vector<Int>(loops);
    }


    //------------------------------
    //  baseline
    //------------------------------

    public function baseline():Void {
        for (i in 0 ... loops) {
        }
    }


    //------------------------------
    //  tests
    //------------------------------


    public function arrayPush():Void {
        for (i in 0 ... loops) {
            _array.push(i);
        }
    }

    public function genericStackAdd():Void {
        for (i in 0 ... loops) {
            _genericStack.add(i);
        }
    }

    public function listAdd():Void {
        for (i in 0 ... loops) {
            _list.add(i);
        }
    }

    public function mapSet():Void {
        for (i in 0 ... loops) {
            _map.set(i, i);
        }
    }

    public function vectorSet():Void {
        for (i in 0 ... loops) {
            _vector.set(i, i);
        }
    }

}