package benchmark.core;

import openfl.events.EventDispatcher;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import benchmark.constant.TestState;
import benchmark.event.TestEvent;
import benchmark.model.AbstractTest;
import benchmark.model.TestSuite;

class Benchmark extends EventDispatcher {

#if cpp
    @:native("__hxcpp_set_float_format") @:extern
    static function setFloatFormat(format:String):Void { }
#end


    //------------------------------
    //  model
    //------------------------------

    private var queue:Array<TestSuite>;
    private var index:Int;
    private var iteration:UInt;
    private var synchronous:Bool;
    private var currentTest:AbstractTest;
    private var currentTestSuite:TestSuite;
    private var timer:Timer;
    private var state:String;


    //------------------------------
    //  lifecycle
    //------------------------------

    public function new() {
        super();

        queue = [];
        synchronous = false;
        index = iteration = 0;
        state = TestState.IDLE;
    }

    public function enqueueTestSuite(testSuite:TestSuite):Void {
        queue.push(testSuite);
    }

    public function enqueueTestSuites(testSuites:Array<TestSuite>) {
        for (t in testSuites) {
            enqueueTestSuite(t);
        }
    }

    public function runSynchronous():Void {
        synchronous = true;
        next();
    }

    public function runAsynchronous():Void {
        synchronous = false;

        timer = new Timer(50, 1);
        timer.addEventListener(TimerEvent.TIMER, timerHandler);

        next();
    }

    private function timerHandler(event:TimerEvent):Void {
        next();
    }

    private function next():Void {
        switch (state) {
            case TestState.IDLE:
                // If there are more tests to run, load next test suite
                if (queue.length > 0) {
                    currentTestSuite = queue.shift();
                    state = TestState.PENDING;
                }
            case TestState.PENDING:
                // There is a test suite to run
                traceTestSuite(currentTestSuite);
                state = TestState.INITIALIZE;
            case TestState.INITIALIZE:
                // Initialize the test suite
                index = iteration = 0;
                if (currentTestSuite.initFunction != null)
                    Reflect.callMethod(currentTestSuite, currentTestSuite.initFunction, []);
                state = TestState.BENCHMARK;
            case TestState.BENCHMARK:
                // Benchmark the test suite
                if (currentTestSuite.baselineTest != null) {
                    runBaselineTest();
                    traceBaseline(currentTestSuite);
                }
                state = TestState.RUNNING;
            case TestState.RUNNING:
                // Run each iteration of the test suite
                if (index < currentTestSuite.tests.length) {
                    if (runTest(currentTestSuite.tests[index])) {
                        index++;
                    }
                }

                if (index >= currentTestSuite.tests.length) {
                    currentTestSuite.complete();
                    state = TestState.DISPOSE;
                }
            case TestState.DISPOSE:
                // Cleanup and dispose test suite
                currentTestSuite.dispose();
                currentTestSuite = null;
                state = TestState.IDLE;
        }

        if (synchronous) {
            next();
        } else if (queue.length > 0 || currentTestSuite != null) {
            timer.reset();
            timer.start();
        }
    }

    private function runBaselineTest():Void {
        var baselineTest:AbstractTest = currentTestSuite.baselineTest;
        var i:Int = baselineTest.iterations == 0 ? 10 : baselineTest.iterations;
        var count:UInt = 0;
        var good:Bool = false;
        var t:Float = -1;
        var oldTime:Float = -1;

        while (!good && i-- > 0) {
            count++;
            t = baselineTest.run();
            if (t < 0)
                continue;
            var d:Float = Math.abs(t - oldTime);
            good = (oldTime >= 0) && (d / (oldTime + t) * 2 < 0.1 || d < 2);
            oldTime = t;
        }
        baselineTest.iterations = count;
        currentTestSuite.baselineTime = (t < 0 || oldTime < 0) ? -1 : (t + oldTime) / 2;
    }

    private function runTest(test:AbstractTest):Bool {
        if (currentTest != test) {
            iteration = 0;
            currentTest = test;

            traceTest(currentTest);

            if (test.iterations == 0 && currentTestSuite != null)
                test.iterations = currentTestSuite.iterations;
            if (test.iterations == 0)
                test.iterations = 1;
        }
        iteration++;

        var t:Int = test.run();
        traceTestIteration(t, test);

        var completed:Bool = (t < 0 || iteration >= currentTest.iterations);
        if (completed) {
            traceTestResult(currentTest, currentTestSuite);
            dispatchEvent(new TestEvent(TestEvent.COMPLETE));

            currentTest.complete();
            currentTest = null;
        }

        return completed;
    }

    public function traceTestSuite(testSuite:TestSuite):Void {
        trace("TestSuite: " + testSuite.name + " (" + testSuite.description + ")");
    }

    public function traceBaseline(testSuite:TestSuite):Void {
        trace("   Baseline time: " + testSuite.baselineTime);
    }

    public function traceTest(test:AbstractTest) {
        trace("   Test: " + currentTest.name);
    }

    public function traceTestIteration(time:Int, test:AbstractTest):Void {
        #if cpp setFloatFormat("%.3f"); #end

        trace("      time: " + time +
        ", min: " + test.min +
        ", max: " + test.max +
        ", average: " + toFixed(test.average, 3) +
        ", deviation: " + toFixed(test.deviation, 3));
    }

    public function traceTestResult(test:AbstractTest, testSuite:TestSuite):Void {
        #if cpp setFloatFormat("%.8f"); #end

        var t:Float = ((test.average - testSuite.baselineTime) / testSuite.loops);
        trace("      Result: " + toFixed(t, 6) + " ms per operation / " + (1.0 / t) + " operations per ms");

        if (t < 0) {
            trace("      ERROR: Test faster than baseline");
        }
    }

    public static function toFixed(value:Float, precision:UInt):Float {
        return Std.int(value * (Math.pow(10, precision))) / Math.pow(10, precision);
    }

}
