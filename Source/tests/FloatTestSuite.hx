package tests;

import benchmark.model.MethodTest;
import benchmark.model.TestSuite;

class FloatTestSuite extends TestSuite {

    //------------------------------
    //  properties
    //------------------------------


    //------------------------------
    //  methods
    //------------------------------

    public function new() {
        super();

        name = "Float Test";
        description = "Mathematical operations on `Float` data type.";
        initFunction = initialize;
        baselineTest = new MethodTest(baseline);
        loops = 10000000;
        iterations = 4;
        tests = [
            new MethodTest(addition, null, "Addition `+` operator"),
            new MethodTest(subtraction, null, "Subtraction `-` operator"),
            new MethodTest(division, null, "Division `/` operator"),
            new MethodTest(multiplication, null, "Multiplication `*` operator"),
            new MethodTest(modulo, null, "Modulo, `%` operator")
        ];
    }


    //------------------------------
    //  initialization
    //------------------------------

    public function initialize():Void {
    }


    //------------------------------
    //  baseline
    //------------------------------

    public function baseline():Void {
        var n = 0.0;
        for (i in 0 ... loops) {
            n = i;
        }
    }


    //------------------------------
    //  tests
    //------------------------------

    public function addition():Void {
        var n = 0.0;
        for (i in 0 ... loops) {
            n = i + 0.1;
        }
    }

    public function subtraction():Void {
        var n = 0.0;
        for (i in 0 ... loops) {
            n = i - 0.1;
        }
    }

    public function division():Void {
        var n = 0.0;
        for (i in 0 ... loops) {
            n = i / 1000.0;
        }
    }

    public function multiplication():Void {
        var n = 0.0;
        for (i in 0 ... loops) {
            n = i * 0.001;
        }
    }

    public function modulo():Void {
        var n = 0.0;
        for (i in 0 ... loops) {
            n = i % 2.0;
        }
    }
}
