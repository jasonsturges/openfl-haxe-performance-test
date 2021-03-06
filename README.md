OpenFL Haxe Benchmark
=====================

Modeled after [Grant Skinner's](http://gskinner.com/blog) ActionScript project [PerformanceTest](http://gskinner.com/blog/archives/2010/02/performancetest.html), this variation is designed for [OpenFL](http://www.openfl.org/) to benchmark segments of [Haxe](https://haxe.org/) code.

![object-instantiation](https://user-images.githubusercontent.com/1213591/106400141-5d0fb000-63e2-11eb-9410-7605f9ff43b4.png)

Executing a batch of tests every 50-milliseconds on a Timer, each iteration runs a defined number of loops for multiple samples.  Overhead baseline is removed from the result, and deviation of each iteration is denoted.

### Example: Event Dispatch Test

In the test suite below, one test has been executed over 4-iterations.

    TestSuite: Event Test (Event dispatching operations.)
       Baseline time: 0
       Test: dispatchHandled (Dispatch and handle an event.)
          time: 127, min: 127, max: 127, average: 127, deviation: 0
          time: 125, min: 125, max: 127, average: 126, deviation: 0.01587301587
          time: 124, min: 124, max: 127, average: 125.3333333, deviation: 0.02393617021
          time: 125, min: 124, max: 127, average: 125.25, deviation: 0.02395209581
          Result: 0.00012525 ms per operation, 7984 operations per ms

Each iteration executes the function 10,000,000 for a cumulative total of 40,000,000 calls to the function.  This is configurable per test suite.

Each sample of the four iterations are measured - below we see:

- 1<sup>st</sup> sample made 10,000,000 function calls in 127ms
- 2<sup>nd</sup> sample made 10,000,000 function calls in 125ms
- 3<sup>rd</sup> sample made 10,000,000 function calls in 124ms
- 4<sup>th</sup> sample made 10,000,000 function calls in 125ms

Each iteration displays a running average of total time to execute test, also expressing consistency by calculating deviation.

Finally, after all samples of this test have been run, the result of the function call is calculated to take `0.00012525` milliseconds.

In this example, looping the test function incurred immeasurable overhead.  Baseline is calculated and removed from total results to compensate computation time of executing the test loop.


### Creating Test Suites

Test suites are a collection of multiple tests.  To create a Test Suite, extend `TestSuite`:

    class ExampleTestSuite extends TestSuite {
    }

In your constructor, define properties of the test suite, such as:

- *name* &mdash; Name of this test suite
- *description* &mdash; Description of the this test suite
- *initFunction* &mdash; Function to call before tests of this test suite are executed, to initialize any properties of this class
- *baselineTest* &mdash; Function to measure overhead of looping, or other metrics to remove from total time calculations
- *loops* &mdash; Number of times each test function should loop when be executed.  In this example, each test will execute 10,000,000 times
- *iterations* &mdash; Number of times the test should be run.  In this example, each test will be run 4-times, each time looping 10,000,000 times for a total of 40,000,000 function calls

Example constructor:

        public function new() {
            super();

            name = "Example Test Suite";
            description = "This is an example test suite for multiple tests";
            initFunction = initialize;
            baselineTest = new MethodTest(baseline);
            loops = 10000000;
            iterations = 4;
            tests = [
            ];
        }

If your test suite has local properties, or other initialization that must be performed before running the test suite, place code inside the initialize function:

        public function initialize():Void {
            // Any initialization of the test suite here
        }

Each time the test is run, there may be computational overhead of looping or other tasks which take time.  By executing this code without the test operation, a baseline may be calculated.  That baseline will be removed from final test results.

For example, calculate how much overhead it takes to execute a `for` loop:

        public function baseline():Void {
            for (i in 0 ... loops) {
            }
        }

#### Add Tests to Test Suites

To add tests to your test suite, add a subclass of `AbstractTest` to your `tests` array of your test suite.  For example, to call a method on your test suite, use `MethodTest`:

        tests = [
            new MethodTest(test1, null, "Execute function `test1()` from this class"),
            new MethodTest(test2, null, "Execute function `test2()` from this class")
        ];

Above, two tests are defined that will call `test1()` and `test2()` functions on the test suite.

        public function test1():Void {
            for (i in 0 ... loops) {
                // test operation here
            }
        }

        public function test2():Void {
            for (i in 0 ... loops) {
                // test operation here
            }
        }

This means your "Test Function 1" test will be tested 4-iterations, and each iteration will loop inside the function 10,000,000 times.

Likewise, exactly the same thing will happen for the second test defined: "Test Function 2".

### Example Test Suite

    package tests;

    import benchmark.model.MethodTest;
    import benchmark.model.TestSuite;

    class ExampleTestSuite extends TestSuite {

        //------------------------------
        //  properties
        //------------------------------

        // define any fields you need here


        //------------------------------
        //  methods
        //------------------------------

        public function new() {
            super();

            name = "Example Test Suite";
            description = "This is an example test suite for multiple tests";
            initFunction = initialize;
            baselineTest = new MethodTest(baseline);
            loops = 10000000;
            iterations = 4;
            tests = [
                new MethodTest(test1, null, "Execute function `test1()` from this class"),
                new MethodTest(test2, null, "Execute function `test2()` from this class")
            ];
        }

        // add additional utility methods if needed


        //------------------------------
        //  initialization
        //------------------------------

        public function initialize():Void {
            // Any initialization of the test suite here
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

        public function test1():Void {
            for (i in 0 ... loops) {
                // test operation here
            }
        }

        public function test2():Void {
            for (i in 0 ... loops) {
                // test operation here
            }
        }

    }


### Executing Tests

Currently tests results are traced; therefore, some targets will output results in a terminal whereas targets such as html5 will need to inspect the console.

To execute all tests, call `openfl test` by target, such as:

    $ openfl test mac
    $ openfl test flash
    $ openfl test neko
    $ openfl test html5

Executing one of the examples under the `tests` package, here are the results of the instantiation test suite:


## License

This project is free, open-source software under the [MIT license](LICENSE.md).

Copyright 2015-2017 [Jason Sturges](http://jasonsturges.com)
