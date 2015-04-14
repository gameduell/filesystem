import unittest.implementations.TestHTTPLogger;
import unittest.implementations.TestJUnitLogger;
import unittest.implementations.TestSimpleLogger;

import unittest.TestRunner;

import FilesystemTest;

import duell.DuellKit;

class MainTester
{
    private static var r : TestRunner;
    static function main()
    {
        DuellKit.initialize(start);
    }

    static function start() : Void
    {
        r = new TestRunner(testComplete, DuellKit.instance().onError);
		r.add(new FileSystemTest());

        #if test

        #if jenkins
        r.addLogger(new TestHTTPLogger(new TestJUnitLogger()));
        #else
        r.addLogger(new TestHTTPLogger(new TestSimpleLogger()));
        #end

        #else
        r.addLogger(new TestSimpleLogger());
        #end

        r.run();
    }

    static function testComplete()
    {
        trace(r.result);
    }

}
